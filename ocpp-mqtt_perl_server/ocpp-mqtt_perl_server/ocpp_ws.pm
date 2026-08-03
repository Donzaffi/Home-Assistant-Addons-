#
# SPDX-FileCopyrightText: 2025-2026 Luca Bonissi <wallbox@bonissi.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Interface to handle websocket and OCPP protocol
#

$VERSION{WS}="1.9915";

sub SOL_TCP { return 6; }
sub TCP_NODELAY { return 1; }

#################################
#### General Socket routines ####
#################################

sub fhbits {
  my(@fhlist) = @_;
  my($bits);
  for (@fhlist) {
     vec($bits,fileno($_),1) = 1;
  }
  $bits;
}

sub cflush {
  my $sock=shift;
  my $buffer=shift;
  my $b1;
  return;
  while(Wait($sock,0)) {
     if(Recv($sock,$b1,1)<=0) { verbose(1,"Error reading: $!\n"); last; }
     $buffer.=$b1;
  }
  verbose(1,"Error receiving: ",join(' ',unpack("H*",$buffer)),"\n");
}

$Wtimeout=60;
$timeout=60;
$queue_timeout=1;
$select_timeout=5;

sub Wait {
  my $sock=shift;
  my $local_timeout=shift;
  my $rin = $win = $ein = '';
  vec($rin,fileno($sock),1) = 1;
  #$win=$rin;
  $ein = $rin | $win;
  $!=0;
  $nfound=select($rout=$rin,$wout=$win,$eout=$ein,$local_timeout);
}

sub WWait {
  my $sock=shift;
  my $local_timeout=shift;
  my $rin = $win = $ein = '';
  vec($win,fileno($sock),1) = 1;
  #$win=$rin;
  $ein = $rin | $win;
  $!=0;
  $nfound=select($rout=$rin,$wout=$win,$eout=$ein,$local_timeout);
}

sub SendNB {
  send($_[0],$_[1],0);
}

sub SendNB2 {
  my($sock,$msg,$flags);
  my($wt,$len,$i);
  $len=length($msg);
  $wt=1;
  while($wt>0 && $i<$len) {
    $wt=send($sock,$msg,$flags);
    $i+=$wt;
    if($wt>0 && $i<$len) {
      $msg=substr($msg,$wt);
      WWait($sock,$Wtimeout);
    }
  }
  return($i);
}

sub Recv {
  local $sock=$_[0];
  local $size=$_[2];
  local $bb="";
  local $nread=0;
  eval {
    local $SIG{ALRM} = sub { die "alarm\n" };
    alarm $timeout;
    $nread = sysread($sock, $_[1], $size);
    alarm 0;
  };
  return $nread;
}

$sysread=0;

sub SysRead {
  my($sock,undef,$size)=@_;
  my($tread,$nread,$buffer,$b1);
  $nread=1;
  $sysread++;
  while($nread>0 && $tread<$size) {
    $nread=Recv($sock,$b1,$size-$tread);
    $errno=$!+0;
    $errstr="".$!;
    verbose(22,"NREAD($sysread - $errno)=$nread\n");
    if($nread==0) {
      if($errno==EAGAIN) {
        $nread=1;
        Wait($sock,$select_timeout);
      }
      else {
	# Error reading from socket
	verbose(4,"Error reading from socket: $errstr [$errno]\n");
        $nread=-1;
      }
    }
    else {
      $tread+=$nread;
      $buffer.=$b1;
    }
  }
  if($nread<=0) {
    verbose(8,"Error reading $errstr [$errno]\n");
  }
  $_[1]=$buffer;
  return($tread);
}

###########################
### Websocket specific  ###
###########################

sub SendWS
{
  my($i,$opcode,$buffer,$ver)=@_;
  my $sock=$client[$i];
  verbose($ver,"[TX$i] => $buffer\n");
  my($framehead,$blen);
  $framehead=pack("C",$opcode);
  $blen=length($buffer);
  if($blen>65535) {
    $framehead.=pack("C",127).pack("N",$blen>>32).pack("N",$blen & 0xFFFFFFFF);
  }
  elsif($blen>=126) {
    $framehead.=pack("C",126).pack("n",$blen);
  }
  else {
    $framehead.=pack("C",$blen);
  }
  send($sock,$framehead.$buffer,0);
}

sub ReadWebSocket
{
  my $i=shift;
  $buffer="";
  if($connected[$i]==1) {
    $rd=Recv($client[$i],$buffer,65535);
    if($rd<=0) {
      verbose(4,"Error reading $i (1), closing connection ($i)\n");
      sleep(1);
      close($client[$i]);
      $connected[$i]=0;
    }
    else 
    {
      if($buffer=~m/^GET/)
      {
	# Handle WebSocket Headers:
	verbose(3,"Headers:\n$buffer\n");
	@headers=split("\n",$buffer);
	$key="";
	foreach(@headers) {
	  if(m/Sec-WebSocket-Key/) {
	    s/.*?: //;
	    s/[\s\r\n]//gs;
	    $key=$_;
	    verbose(20,"KEY=$key\n");
	    $key=encode_base64(sha1($key.$GUID));
	    verbose(20,"RKEY=$key\n");
	    $key=~s/[\s\r\n]//gs;
	    verbose(20,"RKEY2=$key\n");
	    last;
	  }
	}
	$buffer="HTTP/1.1 101 Switching Protocols\r\n".
		"Upgrade: websocket\r\n".
		"Connection: Upgrade\r\n".
		"Sec-WebSocket-Accept: $key\r\n".
		"Sec-WebSocket-Protocol: ocpp1.6\r\n".
		"\r\n";
	verbose(3,"Sending: $buffer");
	send($client[$i],$buffer,0);
	$connected[$i]=2;
      }
      else {
	# Already in WebSocket
	$connected[$i]=3;
      }
    }
  }
  if($connected[$i]>0) {
    if($connected[$i]<3) {
      $connected[$i]++;
    }
    else {
      if(length($buffer)==0) {
	# Read Web socket frame header;
	$rd=SysRead($client[$i],$buffer,2);
	if(length($buffer)==0) {
	  # Error reading, closing connection
	  verbose(4,"Error reading $i, closing connection ($i)\n");
	  sleep(1);
	  close($client[$i]);
	  $connected[$i]=0;
	}
      }
      if($connected[$i]>0) {
	if(length($buffer)>=2) {
	  ($opcode,$mask)=unpack("C*",substr($buffer,0,2));
	  if($websock{$opcode}) {
	    $buffer=substr($buffer,2);
	    $len=$mask & 0x7F;
	    if($mask & 0x80) { $mask=1; }
	    else { $mask=0; }
	    if($len==126) {
	      if(length($buffer)<2) {
		SysRead($client[$i],$data,2-length($buffer));
		$buffer.=$data;
	      }
	      $len=unpack("n",substr($buffer,0,2));
	      $buffer=substr($buffer,2);
	    }
	    elsif($len==127) {
	      if(length($buffer)<8) {
		SysRead($client[$i],$data,8-length($buffer));
		$buffer.=$data;
	      }
	      $len=unpack("N",substr($buffer,0,4))*65536*65536+unpack("N",substr($buffer,4,4));
	      $buffer=substr($buffer,8);
	    }
	    if($mask) {
	      if(length($buffer)<4) {
		SysRead($client[$i],$data,4-length($buffer));
		$buffer.=$data;
	      }
	      $maskbit=substr($buffer,0,4);
	      $buffer=substr($buffer,4);
	    }
	    verbose(20,"LEN=$len, MASK($mask)=".unpack("H*",$maskbit)."\n");
	    if(length($buffer)<$len) {
	      SysRead($client[$i],$data,$len-length($buffer));
	      $buffer.=$data;
	    }
	    $blen=length($buffer);
	    if($blen<$len) {
	      verbose(3,"Warning, could not get enoght data (expected $len, retrieved $blen)\n");
	    }
	    if($mask) {
	      # Unmask buffer
	      $maskbit = $maskbit x (int($blen/4)+1);
	      $buffer = $buffer ^ $maskbit;
	      substr($buffer,$blen)=""; # Truncate
	    }
	    $json=undef;
	    $action=undef;
	    # JSON Message
	    if($opcode == 0x81) { # JSON text
	      $nowverb=$now=$lastmsg[$i]=time();
	      $ver=9;
	      eval {
		$json = decode_json($buffer);
	      };
	      if(!defined($json)) {
		verbose($ver,"[RX$i] <= $buffer\n");
		verbose(1,"ERROR decoding JSON: $@\n");
		$buffer="[4, \"0\", {\"status\": \"Error decoding JSON\"";
		$buffer.="} ]\r\n";
	      }
	      else {
		($msgtype,$id,$action,$payload)=@{$json};
		if(ref($action) ne "") { 
		  $payload=$action;
		  $action="Reply";
		}
		if(defined($ver{$action})) { $ver=$ver{$action}; }
		if(ref($payload) eq "HASH") {
		  $payload->{now}=$now;
		}
		verbose($ver,"[RX$i] <= $buffer\n");
		$buffer="[3, \"$id\", {";
		if(defined(&$action)) {
		  eval {
		    $buffer.=&$action($payload,$client[$i],$i);
		  };
		}
		else {
		  $buffer.="\"warning\": \"Unknown Action\"";
		}
		$buffer.="}]";
		if(($now-$wallbox{$wallbox}{heartbeat})>$MQTT_HEARTBEAT_INTERVAL) {
  		  MQTT_PublishHeartbeat($wallbox,{now=>$now});
	        }
	      }
	    }
	    elsif($opcode == 0x89) {
	      $nowverb=$now=$lastmsg[$i]=time();
	      $ver=15;
	      verbose($ver,"[RX$i] <= $buffer\n");
	      # Ping
	      $buffer="ping";
	      $opcode=0x8A;
	    }
	    elsif($opcode == 0x8A) {
	      $nowverb=$now=$lastmsg[$i]=time();
	      $ver=9;
	      verbose($ver,"[RX$i] <= $buffer\n");
	      $action="Reply";
	    }
	    if($action ne "Reply") {
	      SendWS($i,$opcode,$buffer,$ver);
	    }
	  }
	  else {
	    # Not valid websocket, discard frame
	    Recv($client[$i],$buffer2,65535);
	    $buffer.=$buffer2;
	    verbose(3,"Invalid websocket frame ($opcode): ".unpack("H*",$buffer)."\n");
	  }
	}
	else {
	  verbose(3,"Invalid buffer len: ".length($buffer)."\n");
	}
      }
    } #web socket
  }
}

#############################
### OCPP socket functions ###
#############################

sub OCPP_OpenSocket
{
  my ($i,$laddr);
  verbose(3,"Opening socket...\n");
  # Opening HSMS TCP listen port
  my $proto = getprotobyname('tcp');

  for($i=0;$i<$numsock;$i++)
  {
    if($sock_opened[$i]<=0) {
      $sock[$i]=gensym();
      $iaddr=inet_aton($listen_addr);
      socket($sock[$i], PF_INET, SOCK_STREAM, $proto)        || die "socket: $!";
      setsockopt($sock[$i], SOL_SOCKET, SO_REUSEADDR,pack("l", 1))   || die "setsockopt: $!";
      bind($sock[$i], sockaddr_in($listen_port[$i], $iaddr))        || die "bind: $!";
      listen($sock[$i],1)                            || die "listen: $!";
      ($listen_port,$listen_host) = sockaddr_in(getsockname($sock[$i]));
      $listen_hostname = gethostbyaddr($listen_host,AF_INET);
      $listen_hostaddr=inet_ntoa($listen_host);
      verbose(3,"LISTENING ON $listen_hostname [$listen_hostaddr], $listen_port\n");
      $sock_opened[$i]=1;
    }
  }

  @websock=(0x81,0x89,0x8a);
  foreach(@websock) { $websock{$_}=1; }

  $boottime=time()-100;

}

sub OCPP_GetMsg
{
  my $rin = $win = $ein = '';
  my ($i,$j);
  @fd=();
  $conn="";
  for($i=0;$i<$numsock;$i++)
  {
    push(@fd,$sock[$i]);
    $conn.="S$i ";
    $sock_opened[$i]=2;
  }
  for($i=0;$i<$numclient;$i++)
  {
    if($connected[$i]) {
      push(@fd,$client[$i]);
      $conn.="C$i ";
    }
  }
  $ein = $rin = fhbits(@fd);  
  $queue_len=$#queue+1;
  verbose(18,"Waiting($conn)...\n");
  $!=0; # Reset error
  $nfound=select($rout=$rin,$wout=$win,$eout=$ein,$MAX_OCPP_MQTT_WAIT); 
  verbose(17,"IO ".unpack("H*",$rout)." E=".unpack("H*",$eout)."\n");
  $errno=$!+0;
  $buffer="";


  for($i=0;$i<$numsock;$i++) {
    if(vec($rout,fileno($sock[$i]),1)) {
      # Accepting nullmodem connection
      # Find a free client:
      for($j=0;$j<$numclient;$j++) {
	if(!$connected[$j]) { last; }
      }
      if($j>=$numclient) {
	verbose(8,"Creating new client ($j)\n");
	# Create a new client
	$client[$numclient]=gensym();
	$numclient++;
      }
      if(($paddr = accept($client[$j],$sock[$i])))
      {
	verbose(7,"CONNECTED ($listen_port[$i]), sock $i, client $j ($numclient).\n");
	my($port,$iaddr) = sockaddr_in($paddr);
	#my $name = gethostbyaddr($iaddr,AF_INET);
	#verbose(7,"NAME.\n");
	my $name="";
	$asc_addr=inet_ntoa($iaddr);

	setsockopt($client[$j], SOL_TCP, TCP_NODELAY,pack("l", 1))   || die "setsockopt: $!";
	if($OS ne "Win") {
	  $oldflag=fcntl($client[$j],F_GETFL,$packed);
	  fcntl($client[$j],F_SETFL,$oldflag+O_NONBLOCK) || print STDERR "fcntl: $!";
	}
	verbose(4,"($j) Connection from $name [ $asc_addr ]. Flag: $oldflag. Remote port: $port\n");
	$connected[$j]=1;
	$buffer="[2,\"".time()."\",\"GetConfiguration\",{}]\r\n";
	$buffer="";
	$lastmsg[$j]=time();
	$lastping[$j]=0;
	$lastclient=$j;
	#send($client[$j],"HTTP/1.1 100 Connected\r\n\r\n".$buffer,0);
      }
    }
  }
  $sockred=0;
  $connected=0;
  for($i=0;$i<$numclient;$i++) {
    my $localsockred=0;
    if(($now-$lastcmd)>$WAITDATA_TIMEOUT) {
      $localsockred++;
    }
    verbose(20,"Checking client $i ($numclient)...\n");
    if($connected[$i] && vec($eout,fileno($client[$i]),1)) {
      # Error on connecting, closing
      verbose(4,"Connection closed for $i\n");
      close($client[$i]);
      $connected[$i]=0;
    }
    elsif($connected[$i] && vec($rout,fileno($client[$i]),1)) {
      # Received nullmodem data and handle them
      ReadWebSocket($i);
      $localsockred=1;
      if($connected[$i] && !$nolastclient{$action}) { $lastclient=$i; }
    } # connected

    if($connected[$i]>0) {
      $connected++;
      if($localsockred) {
	eval {
	  Cmd($client[$i],$i);
	};
      }
      if((time()-$lastmsg[$i])>600) {
	$lastping[$i]++;
	if($lastping[$i]>3) {
	  verbose(5,"Ping not responding for $i, closing connection (".fileno($client[$i]).")\n");
	  close($client[$i]);
	  $connected[$i]=0;
	}
	else {
	  SendWS($i,0x89,"ping",9);
	}
      }
    }
    $sockred+=$localsockred;
  } # for client

  if($sockred || ($now-$lastcmd)>$WAITDATA_TIMEOUT) {
    if(!$sockred) {
      # To handle reconf and MQTT-only wallboxes
      eval {
	Cmd($client[$i],$i);
      };
    }
    eval {
      HandleQueue($lastclient);
    };
  }

  if(($now-$lastcmd)>$WAITDATA_TIMEOUT) {
    $lastcmd=$now;
  }
}

sub OCPP_Exit {
  verbose(1,"Error $errstr [$errno/$err], closing client[s].\n");
  for($i=0;$i<$numsock;$i++)
  {
    if($connected[$i]) {
      close($client[$i]);
    }
    $connected[$i]=0;
  }

  if($err>2 && 0) 
  {
    # Disabled...
    if(length($lastbuffer)>0) {
      verbose(5,"S$lastrec $lastbuffer\n");
    }
    verbose(3,"Closing log and sockets...\n");
    close(PLOG);
    $log_opened=0;
    for($i=0;$i<$numsock;$i++)
    {
      close($sock[$i]);
      $sock_opened[$i]=-1;
    }
    exit;
  }
}

sub CleanShutdown {
  my($i);
  verbose(3,"Closing sockets...\n");
  for($i=0;$i<$numsock;$i++) { 
    close($sock[$i]);
    $sock_opened[$i]=-1;
    if($connected[$i]) {
      close($client[$i]);
    }
    $connected[$i]=0;
  }
  MQTT_Shutdown();
}

1;
