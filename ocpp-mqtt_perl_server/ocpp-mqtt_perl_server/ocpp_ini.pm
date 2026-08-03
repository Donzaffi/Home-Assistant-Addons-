#
# SPDX-FileCopyrightText: 2023-2026 Luca Bonissi <wallbox@bonissi.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

$VERSION{INI}="1.9923";
$VERSION{MINMAIN}="1.9919";

use Time::Local;

sub SendMail {
  my($subject,$from,$addrs,$message,@attach)=@_;
  my($boundary,$i);
  my(@addrs)=split(' ',$addrs);
  if($#addrs<0) {
    print STDERR "No address specified.\n";
    return(0);
  }
  srand();
  $boundary="myProgramBoundary_" . int(rand(2000000000));
  if(!open(MAIL,"|/usr/sbin/sendmail $addrs"))
  {
    print STDERR "Could not start mail: $!\n";
    return(0);
  }
  print MAIL "MIME-Version: 1.0\n";
  print MAIL "From: $from\n";
  print MAIL "Subject: $subject\n";
  print MAIL "Sender: $from\n";
  print MAIL "To: $addrs[0]";
  for($i=1;$i<=$#addrs;$i++) { print MAIL ",\n $addrs[$i]"; }
  print MAIL "\n";
  print MAIL "Content-Type: multipart/mixed;\n";
  print MAIL " boundary=\"$boundary\"\n\n";
  print MAIL "\n--$boundary\n";
  print MAIL "Content-Type: text/plain; charset=us-ascii\n";
  print MAIL "Content-Transfer-Encoding: 7bit\n";
  print MAIL "\n";
  print MAIL "$message\n";
  print MAIL "\n";
  for($i=0;$i<=$#attach;$i++)
  {
    print MAIL "\n--$boundary\n";
    print MAIL "Content-Type: $attach[$i]{type};\n";
    print MAIL " name=\"$attach[$i]{filename}\"\n";
    print MAIL "Content-Transfer-Encoding: $attach[$i]{encoding}\n";
    print MAIL "Content-Disposition: $attach[$i]{disposition};\n";
    print MAIL " filename=\"$attach[$i]{filename}\"\n";
    print MAIL "\n";
    print MAIL "$attach[$i]{body}";
  }
  print MAIL "--${boundary}--\n\n";
  close(MAIL);
  return 1;
}


sub TimeSec {
  my $ms=shift;
  my ($hr,$min,$sec)=split(":",$ms);
  if(!defined($min)) {
    # Check if it is a plausible hours
    if($hr>=60) {
      # Probably already converted in seconds, return the number as is
      return($hr);
    }
  }
  return($hr*3600+$min*60+$sec);
}

sub TimeSecPerc {
  my $ms=shift;
  if($ms=~m/%/) { return($ms); }
  return(TimeSec($ms));
}

# Do not round sec:
sub Zulu {
  my($time)=@_;
  my($msec);
  if(!defined($time)) {
    $time=time();
  }
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($time);
  $year+=1900;
  $mon++;
  $msec=int(($time-POSIX::floor($time))*1000);
  return(sprintf("%04d-%02d-%02dT%02d:%02d:%02d.%03dZ",$year,$mon,$mday,$hour,$min,$sec,$msec));
  #2013-02-01T20:53:32.486Z
}

# Just an alias of Zulu:
sub ZuluNR {
  return(Zulu(@_));
}

sub ZuluR {
  my($time)=@_;
  if(!defined($time)) {
    $time=time();
  }
  # Round up the time, since ABB seems not handling millisec
  if($ROUND_ZULU) { $time=POSIX::round($time); }
  return(Zulu($time));
}

sub LTime
{
    my $now=shift;
    if(length($now)==0) { $now=time(); }
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(POSIX::floor($now));
    return(sprintf("%04d-%02d-%02d %02d:%02d:%02d.%06d",$year+1900,$mon+1,$mday,$hour,$min,$sec,int(($now-POSIX::floor($now))*1000000)));
}

sub DayS
{
    my $now=shift;
    if($now) { $now=time(); }
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(POSIX::floor($now));
    return(sprintf("%04d%02d%02d",$year+1900,$mon+1,$mday));
}

sub WaitTime {
  # Fix the wait time if it was expressed as "ticks" instead of seconds
  my $wtime=shift;
  if($wtime<=20 && !($wtime=~m/s/i)) {
    $wtime=$wtime*36;
  }
  return($wtime+0);
}

# Append to LOG file
sub PrintLog {
  if(!$log_opened) {
    # Open the log file for append
    return unless open(PLOG,">>$log_filename");
    $old_file=select(PLOG);
    # Disable buffering (show the log immediateli with "tail")
    $|=1;
    select($old_file);
    $log_opened=1;
  }
  my $fsize=tell(PLOG);
  if($fsize>$log_size)
  {
    # Rotate the log in case it reach the maximum size
    close(PLOG);
    my ($old_file,$new_file,$i);
    for($i=$log_versions;$i>0;$i--)
    {
      $new_file=$log_filename . "." . sprintf("%02d",$i);
      $old_file=$log_filename . "." . sprintf("%02d",$i-1);
      if($i==1) { $old_file=$log_filename; }
      rename($old_file,$new_file);
    }
    return unless open(PLOG,">$log_filename");
    $old_file=select(PLOG);
    $|=1;
    select($old_file);
    $log_opened=1;
  }
  $!=0;
  print PLOG @_;
  if($!) {
    print STDERR "Error writing log: $!\n";
    # Something wrong, close log and retry
    close(PLOG);
    $log_opened=0;
  }
}

# Conditional log based on global verbosity level.
# Parameters: $verbose=LEVEL of verbosity
sub verbose {
  my $verbose=shift;
  if($VERBOSE>=$verbose) {
    my $msg=LTime($nowverb)." - ".join("",@_);
    print $msg;
    PrintLog $msg;
  }
  undef($nowverb);
}

sub DataLog {
  if(length($datadir)==0) { return; }
  my $suffix=shift;
  my $now=shift;
  if($now==0) { $now=time(); }
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(POSIX::floor($now));
  $year+=1900;
  $mon++;
  if(!-d $datadir) {
    mkdir($datadir);
  }
  if(!-d "$datadir/$year") {
    mkdir("$datadir/$year");
  }
  my $filename=sprintf("%s/%s/%04d%02d%02d_%s.dat",$datadir,$year,$year,$mon,$mday,$suffix);
  if(open(DT,">>$filename")) {
    print DT join("\t",	POSIX::floor($now),
			sprintf("%02d%02d%02d",$hour,$min,$sec),
			sprintf(".%06d",int(($now-POSIX::floor($now))*1000000)),
			@_)."\n";
    close(DT);
  }
}

sub CalcEaster {
  my $year=shift;
  my $a=$year % 19;
  my $b=int($year/100);
  my $c=$year % 100;
  my $d=int($b/4);
  my $e=$b % 4;
  my $f=int(($b+8)/25);
  my $g=int(($b-$f+1)/3);
  my $h=($a*19+$b-$d-$g+15)%30;
  my $i=int($c/4);
  my $k=$c % 4;
  my $L=(32+$e*2+$i*2-$h-$k) % 7;
  my $m=int(($a+$h*11+$L*22)/451);
  my $A=$h+$L-$m*7+114;
  my $AM=int($A/31);
  my $AD=($A%31)+1;
  return ("$AM/$AD");
}

sub Version {
  my $ver="0";
  my ($i);
  foreach $i (qw(MAIN INI FUNC MQTT WS)) {
    if($ver lt $VERSION{$i}) {
      $ver=$VERSION{$i};
    }
  }
  if($ver ne $VERSION) {
    $VERSION=$ver;
    verbose(1,"Perl OCPP/MQTT server VERSION: $VERSION\n");
    if($VERSION{MAIN} lt $VERSION{MINMAIN}) {
      verbose(1,"WARNING: server should be restarted because MAIN minimum version required is $VERSION{MINMAIN} (actual running: $VERSION{MAIN})\n");
    }
  }
}

@trans_params=qw(STATUS SUBSTATUS CONNSTATUS TRANSACTION TAG STARTTAG
	         START_TIME START_SESSION LAST_WH LAST_SPAN LAST_AVGASUM LAST_AVGACOUNT LAST_AVGCURSUM LAST_PV LAST_TSWH[] LAST_PVWH[]
		 GRID_OVER_START GRID_OVER_PAUSE
	         currTransaction currSub backup_currSub currTransactionFull currSet currLSet currLActive lastSet powerSet
		 laststop stopremote meterStart
		 lastenergyT 
                 avgAsum avgAcount avgA avgAsum avgCUR avgCURsum avgAlasttime avgW
	         pvwh lastgridtime lastgrid lastPowertime lastPower
	         tswh[] pvwh[] hpvwh hfetchwh htotwh lastchgwh lasthour
	         connectorId GLOBAL_WH absolute_wh globalwh
		 MQTT_FIXED MQTT_STARTED MQTT_TAG MQTT_started_published
                 WALLBOX_VENDOR WALLBOX_MODEL WALLBOX_METERTYPE WALLBOX_SERIAL WALLBOX_FIRMWARE
		 WALLBOX_VAR[]
		 EV_VAR[]
		);

@profile_params=qw(WAIT_CHANGE WAIT_ON_START AVG AVG_DEV AVG_HISTORIC_SEC AVG_CHANGING_SEC
                   MAXPOWER_SUSPEND MAXPOWER_REDUCE MINPOWER_START MINPOWER_INCREASE FIXED CHARGING_MINPOWER
		   NO_AVERAGE STOP_ON_SUSPENDEV
		  );

@grid_params=qw(GRID_LIMIT GRID_LIMIT_SAFE GRID_LIMIT_SAFE_REDUCE GRID_LIMIT_MAXTIME GRID_LIMIT_REDUCETIME
                GRID_LIMIT_PAUSE GRID_LIMIT_RESTART_PAUSE
               );

@time_params=qw(ENABLE TIME WEEKDAY YEARDAY
               );

# MINVOLTAGE and MAXVOLTAGE to be moved to the planned meter params
@general_params=qw(LOG_VERSIONS LOG_FILENAME LOG_SIZE VERBOSE DATADIR CHARGE_LOG HOUR_LOG
		   MINPOWER MAXPOWER 
		   MINVOLTAGE MAXVOLTAGE
		   WARNMAIL USE_STOP_AS_SUSPEND ADD_WALLBOX_POWER_TO_METER VOLT_AVG 
		   AUTOSTART CS_PROFILE_ID CS_STACK_LEVEL GETCONF GLOBAL_ENERGY
		   ROUND_ZULU MAX_ENERGY_SESSION 
		   WAITDATA_TIMEOUT QUEUE_DELAY_TIME QUEUE_WAIT QUEUE_WAIT_BOOT MAX_QUEUE
		   ALLOW_ONLY_DEFINED_CARDS

		   MQTT_ENABLED MQTT_BROKER MQTT_USERNAME MQTT_PASSWORD MQTT_TOPIC_PREFIX
		   MQTT_CONFIG_GENERAL_BASE MQTT_CONFIG_PROFILE_BASE MQTT_CONFIG_GRID_BASE MQTT_CONFIG_BASELOAD_BASE MQTT_CONFIG_WALLBOX_BASE MQTT_CONFIG_EV_BASE
		   MQTT_SESSIONS_BASE MQTT_METER_NAME MQTT_METER_BASE MQTT_WALLBOX_BASE MQTT_EV_BASE
		   MQTT_SINGLE_VALUES
		   MQTT_STATUS_INTERVAL MQTT_METER_INTERVAL MQTT_HEARTBEAT_INTERVAL
		   MQTT_POWER_UNIT MQTT_ENERGY_UNIT

		   HA_DISCOVERY_ENABLED HA_DISCOVERY_PREFIX

		   METER_MQTT_PREFIX
		   METER_MQTT_POWER METER_MQTT_L1_POWER METER_MQTT_L2_POWER METER_MQTT_L3_POWER METER_MQTT_POWER_MULTIPLIER
		   METER_MQTT_L1_VOLTAGE METER_MQTT_L2_VOLTAGE METER_MQTT_L3_VOLTAGE METER_MQTT_VOLTAGE_MULTIPLIER
		   METER_MQTT_L1_CURRENT METER_MQTT_L2_CURRENT METER_MQTT_L3_CURRENT METER_MQTT_CURRENT_MULTIPLIER

		   PV_MQTT_PREFIX PV_MQTT_TIMEOUT
		   PV_MQTT_POWER PV_MQTT_POWER_MULTIPLIER 
		   PV_MQTT_VOLTAGE PV_MQTT_VOLTAGE_MULTIPLIER
		   PV_MQTT_CURRENT PV_MQTT_CURRENT_MULTIPLIER
		   PV_MQTT_FREQUENCY PV_MQTT_FREQUENCY_MULTIPLIER
		   PV_MQTT_ENERGY PV_MQTT_ENERGY_MULTIPLIER
		   PV_MQTT_EFFICIENCY PV_MQTT_EFFICIENCY_MULTIPLIER
		   PV_MQTT_TEMPERATURE PV_MQTT_TEMPERATURE_MULTIPLIER
		   PV_MQTT_HUMIDITY PV_MQTT_HUMIDITY_MULTIPLIER

		   GRID_MQTT_IMPORT GRID_MQTT_EXPORT
		   HOME_MQTT_ENERGY HOME_INCLUDE_WALLBOX
		  );

@baseload_params=qw(BASELOAD FALLBACK_BASELOAD);

@wallbox_params=qw(WALLBOX_SN WALLBOX_SET_LIMIT_FINESTEP WALLBOX_SET_LIMIT_UNIT WALLBOX_SET_LIMIT_MAINSTEP WALLBOX_SET_LIMIT_MINADD WALLBOX_SET_LIMIT_ZERO_ON_STOP
		   WALLBOX_CONNECTORS WALLBOX_USE_METER_VOLTAGE
		   WALLBOX_NPHASES WALLBOX_CURRENT_SWITCH_PHASE_UP WALLBOX_CURRENT_SWITCH_PHASE_DOWN 
		   WALLBOX_MQTT_BASE WALLBOX_MQTT_CMD_BASE 
		   WALLBOX_MQTT_NAME
		   WALLBOX_MQTT_CONNECTOR1_BASE WALLBOX_MQTT_CONNECTOR2_BASE WALLBOX_MQTT_CONNECTOR3_BASE WALLBOX_MQTT_CONNECTOR4_BASE

		   WALLBOX_MQTT_GET_BASE 
		   WALLBOX_MQTT_GET_CONNECTOR1_BASE WALLBOX_MQTT_GET_CONNECTOR2_BASE WALLBOX_MQTT_GET_CONNECTOR3_BASE WALLBOX_MQTT_GET_CONNECTOR4_BASE
		   WALLBOX_MQTT_GET_STATUS 
		   WALLBOX_MQTT_GET_POWER WALLBOX_MQTT_GET_POWER_MULTIPLIER
		   WALLBOX_MQTT_GET_VOLTAGE WALLBOX_MQTT_GET_VOLTAGE_MULTIPLIER
		   WALLBOX_MQTT_GET_CURRENT WALLBOX_MQTT_GET_CURRENT_MULTIPLIER 
		   WALLBOX_MQTT_GET_TIME WALLBOX_MQTT_GET_TIME_MULTIPLIER
		   WALLBOX_MQTT_GET_ENERGY WALLBOX_MQTT_GET_ENERGY_MULTIPLIER WALLBOX_MQTT_GET_GLOBAL_ENERGY WALLBOX_MQTT_GET_ENERGY_MULTIPLIER
		   WALLBOX_MQTT_GET_ERROR WALLBOX_MQTT_GET_MODE 

		   WALLBOX_MQTT_RESULT_BASE 
		   WALLBOX_MQTT_SET_LIMIT WALLBOX_MQTT_SET_LIMIT_RESULT_SUCCESS WALLBOX_MQTT_SET_LIMIT_RESULT_ERROR
		   WALLBOX_MQTT_SET_MODE WALLBOX_MQTT_SET_MODE_RESULT_SUCCESS WALLBOX_MQTT_SET_MODE_RESULT_ERROR
		  );

@ev_params=qw(EV_MQTT_BASE EV_MQTT_NAME
	      EV_MQTT_PREFIX EV_MQTT_TIMEOUT EV_MQTT_SOC 
	      EV_MQTT_REMAIN EV_MQTT_REMAIN_MULTIPLIER EV_MQTT_ENERGY EV_MQTT_ENERGY_MULTIPLIER EV_MQTT_CHARGE EV_MQTT_CHARGE_MULTIPLIER
	      EV_MQTT_VOLTAGE EV_MQTT_VOLTAGE_MULTIPLIER EV_MQTT_CURRENT EV_MQTT_CURRENT_MULTIPLIER EV_MQTT_POWER EV_MQTT_POWER_MULTIPLIER
	      EV_MQTT_AC_VOLTAGE EV_MQTT_AC_VOLTAGE_MULTIPLIER EV_MQTT_AC_CURRENT EV_MQTT_AC_CURRENT_MULTIPLIER
	      EV_MQTT_CELLVMIN EV_MQTT_CELLVMIN_MULTIPLIER
	      EV_MQTT_CELLVMAX EV_MQTT_CELLVMAX_MULTIPLIER
	      EV_MQTT_CELLVAVG EV_MQTT_CELLVAVG_MULTIPLIER
	      EV_MQTT_CELLVDIFF EV_MQTT_CELLVDIFF_MULTIPLIER
	      EV_MQTT_BATTEMP EV_MQTT_BATTMIN EV_MQTT_BATTMAX EV_MQTT_OUTDOOR EV_MQTT_INDOOR
	      EV_MQTT_CHARGING

	      EV_SOC_LIMIT
             );

$read_trans=1;

sub ExpandParams {
  my $p=shift;
  my (@a,@b);
  if($p=~m/\[\]/) {
    # Array, expand
    $p=~s/\[\]//;
    @a=eval("\@$p");
    for($a=0;$a<=$#a;$a++) {
      push(@b,"$p"."[$a]");
    }
  }
  else {
    @b=($p);
  }
  return(@b);
}

sub GetCRLF {
  my($s)=@_;
  ($s)=($s=~m/([\n\r]+)$/s);
  return($s);
}

sub RemoveReturn {
  my($ch);
  $_[0]=~s/[\n\r]+$//gs;
  return($_[0]);
}

sub FindParam {
  my($lines,$param)=@_;
  my($i,@ret,$p,$value);
  for($i=0;$i<=$#{$lines};$i++) {
    ($p,$value)=($lines->[$i]=~m/^(\S+?)\s*=\s*(.*)/);
    if($param eq $p) {
      push(@ret,$i);
    }
  }
  return(@ret);
}

sub UpdateValue
{
  my($line,$newval)=@_;
  my ($pre,$val,$comment,$crlf);
  ($pre,$val)=($line=~m/^(\S+?\s*=\s*)(.*)/s);
  # Get out CRLF:
  ($val,$crlf)=($val=~m/(.*?)([\r\n]+)/s);
  # Split the comment, if present
  if($val=~m/#/) {
    ($val,$comment)=($val=~m/(.*?)(\s*#.*)/);
  }
  if($val ne $newval) {
    $iniupdated++;
  }
  $val="$pre$newval$comment";
  RemoveReturn($line);
  verbose(19,"OLD=$line => NEW=$val\n");
  return("$val$crlf");
}

sub AddEmptyLine
{
  my ($sdata,$l,$sname)=@_;
  my ($val);
  $val=$#{$sdata->[$l]};
  $val=$sdata->[$l][$val];
  RemoveReturn($val);
  if(length($val)>0) {
    push(@{$sdata->[$l]},$crlf);
    verbose(11,"Adding an empty line at section $l [$sname->[$l]]\n");
  }
}

sub FindPriority {
  my $section=shift;
  my($j,$i);
  for($j=0;$j<=$#smart;$j++)
  {
    if($smart[$j] eq $section) {
      $i=$j;
    }
  }
  return($i);
}

sub SetDefaultParams
{
  $WBMINPOWER=WallboxMinPower();
  if(length($MQTT_WALLBOX_BASE)==0) {
    $MQTT_WALLBOX_BASE="wallbox";
  }
  if(length($MQTT_METER_BASE)==0) {
    $MQTT_METER_BASE="meter";
  }
  if(length($MQTT_EV_BASE)==0) {
    $MQTT_EV_BASE="ev";
  }
}

sub UpdateIni {
  my ($section,$param)=@_;
  my (%section,@sdata,$sc,@sname,$sname,$val,$i,$k,$j,@line,$l,$last,$pre,$newprio);
  $iniupdated=0;
  $sname="";
  $sc=0;
  $sname[$sc]=$sname;
  $section{$sname}=$sc;
  # First of all, load the file
  if(open(F,$cfg_file)) {
    while(<F>) {
      if(m/^\[.*\]/) {
        ($sname)=m/\[(.*?)\]/;
	$sc++;
        $sname[$sc]=$sname;
        $section{$sname}=$sc;
      }
      push(@{$sdata[$sc]},$_);
    }
    close(F);

    if($#sdata>=0) {
      $crlf=GetCRLF($sdata[0][0]);
    }
    elsif($OS eq "Win") {
      $crlf="\r\n";
    }
    else {
      $crlf="\n";
    }

    # Always add an empty line at the end, if not yet done:
    if($#sdata>=0) {
      AddEmptyLine(\@sdata,$#sdata,\@sname);
    }
    if(!defined($i=$section{$section})) {
      $sc++;
      $i=$sc;
      $sname[$i]=$section;
      $section{$section}=$i;
      push(@{$sdata[$i]},"[$section]$crlf");
    }
    $last=$#{$sdata[$i]};
    $val=$sdata[$i][$last];
    RemoveReturn($val);
    if(length($val)>0) {
      $last++;
    }
    $newprio=undef;
    foreach $k (sort keys %{$param}) {
      if($k eq "priority" || $k eq "name") {
        # Discard added fields
	next;
      }
      if($k eq "new_priority") {
        # Set the priority/position
	$newprio=$param->{$k};
	if($newprio<1) { $newprio=1; }
	elsif($newprio>$#sdata) {
	  $newprio=$#sdata+1;
	}
	next;
      }
      @line=FindParam($sdata[$i],$k);
      if(ref($param->{$k}) eq "ARRAY") {
        if($k=~m/^HOLIDAY|^TIMESLOT|^CARD|^CONFKEY/ ) {
	  # Special handling, not yet done
	}
	else {
	  # Set newvalues in RAM
	  if($section eq "") {
	    # General:
	    eval("\@$k=\@{\$param->{$k}}");
	  }
	  else {
	    @{$smart{$section}{$k}}=@{$param->{$k}};
	  }
	  if($#line>0) {
	    # More lines, put each array element in one line
	    $l=$last;
	    for($j=0;$j<=$#{$param->{$k}};$j++) {
	      if($j<=$#line) {
	        $l=$line[$j];
	        $sdata[$i][$l]=UpdateValue($sdata[$i][$l],$param->{$k}[$j]);
		$l++;
	      }
	      else {
	        # Add new entry after the last one
		verbose(19,"Adding at section line $l $k=$param->{$k}[$j]");
		splice(@{$sdata[$i]},$l,0,"$k=$param->{$k}[$j]$crlf");
	        $iniupdated++;
		$l++;
		$last++;
	      }
	    }
	    # Delete no more necessary lines
	    $l=0;
	    while($j<=$#line) {
	      splice(@{$sdata[$i]},$line[$j]-$l,1);
	      $l++;
	      $iniupdated++;
	      $j++;
	      $last--;
	    }
	  }
	  else {
	    if($#{$param->{$k}}<0) {
	      if($#line==0) {
	        # Delete param if present
	        splice(@{$sdata[$i]},$line[0],1);
	        $iniupdated++;
		$last--;
	      }
	    }
	    elsif($#line==0) {
	      # Only 1 line, put element comma separated
	      $l=$line[0];
	      $sdata[$i][$l]=UpdateValue($sdata[$i][$l],join(",",@{$param->{$k}}));
	    }
	    else {
	      # Add new array element
	      verbose(19,"Adding at section line $last $k=".join(",",@{$param->{$k}})."\n");
	      splice(@{$sdata[$i]},$last,0,"$k=".join(",",@{$param->{$k}})."$crlf");
	      $iniupdated++;
	      $last++;
	    }
	  }
	}
      }
      else {
        # Update value in memory
	if($section eq "") {
	  # General:
	  ${$k}=FixValue($k,$param->{$k});
	}
	else {
	  $smart{$section}{$k}=$param->{$k};
	  verbose(13,"Updating [$section], param $k => $param->{$k}\n");
	}
        if($#line>=0) {
	  if(defined($param->{$k})) {
	    # Update only the last line:
	    $l=$line[$#line];
	    if($k=~m/WAIT_CHANGE|WAIT_ON_START/) {
	      # Added "s" to be sure the value will be interpreted as seconds
	      if(!($param->{$k}=~m/s/i)) {
	        $param->{$k}.="s";
	      }
	    }
	    $sdata[$i][$l]=UpdateValue($sdata[$i][$l],$param->{$k});
	  }
	  else {
	    # Delete param[s]
	    $l=0;
	    for($l=0;$l<=$#line;$l++) {
	      verbose(19,"Deleting at section line $line[$l] $k");
	      splice(@{$sdata[$i]},$line[$l]-$l,1);
	      $iniupdated++;
	      $last--;
	    }
	  }
	}
	elsif(defined($param->{$k})) {
	  #Add in the last position
	  verbose(19,"Adding at section line $ast $k=$param->{$k}");
	  splice(@{$sdata[$i]},$last,0,"$k=$param->{$k}$crlf");
	  $iniupdated++;
	  $last++;
	}
      }
    }
    # Add an empty line, in case of new section
    AddEmptyLine(\@sdata,$i,\@sname);
    if($newprio>0 && $newprio!=$i) {
      # First of all, insert the section at the new position/priority:
      splice(@sdata,$newprio,0,$sdata[$i]);
      # Then delete the old one:
      if($newprio<=$i) {
        $i++;
      }
      splice(@sdata,$i,1);
      $iniupdated++;
    }

    # Write the file
    if($iniupdated) {
      MQTT_SectionRetainUpdate($section,FindPriority($section));
      # Check last backup time
      my @s=stat("$cfg_file.bak");
      if((time()-$s[9])>3600) {
        # Make backup only after 1 hour from the last update
	unlink("$cfg_file.bk2");
	rename("$cfg_file.bak","$cfg_file.bk2");
	rename("$cfg_file","$cfg_file.bak");
	@s=stat("$cfg_file.bak");
	# Create the file and change mode:
	if(open(C,">$cfg_file")) {
	  chmod(($s[2] & 07777)|0600,C);
	  close(C);
	}
      }
      if(open(C,">$cfg_file")) {
	for($i=0;$i<=$#sdata;$i++) {
	  print C @{$sdata[$i]};
	}
	close(C);
      }
      my @s=stat($cfg_file);
      $last_cfg_file=$s[9];
      SetDefaultParams();
    }
  }
  else {
    verbose(3,"Could not open config file '$cfg_file': $!\n");
  }
}

sub ReadConf {
  my ($now)=@_;
  if(length($now)==0) { $now=time(); }
  my($section,%params,%profile_params,%grid_params,%general_params,%baseload_params);
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($now);
  $mon++;
  $year+=1900;
  $last_year=$year;
  @smart=();
  @timeslot=();
  @confkey=();
  %smart=();
  %holiday=();
  @holiday=();
  %default=();
  %card=();
  @card=();
  @wallbox=();
  @ev=();
  $nsmart=0;
  $wallbox="";
  $ev="";

  foreach(@profile_params) { $profile_params{$_}=1; }
  foreach(@grid_params) { $grid_params{$_}=1; }
  foreach(@general_params) { $general_params{$_}=1; }
  foreach(@baseload_params) { $baseload_params{$_}=1; }

  if(open(S,$cfg_file))
  {
    while(<S>) {
      RemoveReturn($_);
      if(m/^#/) { next; } # Skip comments
      if(m/^\[/) {
        ($section)=m/\[(.*?)\]/;
	if(length($section)>0) {
	  $smart[$nsmart]=$section;
	  $smart{$section}{name}=$section;
	  ##$smart{$section}{TIME}="0-86400";
	  #$smart{$section}{TIME}=[];
	  #$smart{$section}{WEEKDAY}="0-7";
	  #$smart{$section}{YEARDAY}="0-367";
	  $smart{$section}{ENABLE}=1;
	  #$smart{$section}{WAIT_CHANGE}=$default{WAIT_CHANGE};
	  #$smart{$section}{WAIT_ON_START}=$default{WAIT_ON_START};
	  #$smart{$section}{STOP_ON_SUSPENDEV}=$default{STOP_ON_SUSPENDEV};
	  #$smart{$section}{NO_AVERAGE}=$default{NO_AVERAGE};
	  $nsmart++;
        }
      }
      else {
	($param,$value)=m/^(\S+?)\s*=\s*(.*)/;
	$value=~s/#.*//;
	$value=~s/\s+$//;
	if($param eq "LOG_FILENAME") {
	  $log_filename=$value;
	}
	elsif($param eq "LOG_SIZE") {
	  $value=~s/_//g;
	  if($value>=10000) {
	    $log_size=$value+0;
	  }
	}
	elsif($param eq "LOG_VERSIONS") {
	  $log_versions=$value+0;
	}
	elsif($param eq "CHARGE_LOG") {
	  $charge_log=$value;
	}
	elsif($param eq "HOUR_LOG") {
	  $hour_log=$value;
	}
	elsif($param eq "DATADIR") {
	  $datadir=$value;
	}
	elsif($param eq "BASEDIR_CMD") {
	  $basedir=$value;
	}
	elsif($param=~m/^LISTEN/) {
	  $nport=substr($param,6)+0;
	  if(($nport+1)>$numsock) {
	    $numsock=$nport+1;
	  }
	  if(($value+0)>1024) {
	    $listen_port[$nport]=$value+0;
	  }
	}
	elsif($param eq "WAITDATA_TIMEOUT") {
	  if($value>0) {
	    $WAITDATA_TIMEOUT=$value+0;
	  }
	}
	elsif($param eq "ROUND_ZULU") {
	  $ROUND_ZULU=$value+0;
	}
	elsif($param =~m/^ADD_WALLBOX_POWER/) {
	  $ADD_WALLBOX_POWER_TO_METER=$value+0;
	}
	elsif($param eq "SAMPLED_DATA") {
	  push(@confkey,"MeterValuesSampledData:$value");
	}
	elsif($param eq "CONFKEY") {
	  push(@confkey,"$value");
	}
	elsif($param eq "MAX_ENERGY_SESSION") { # To be moved on MQTT
	  $MAX_ENERGY_SESSION=$value;
	  SetMaxEnergy();
	}
	elsif($param eq "HOLIDAY") {
	  push(@holiday,$value);
	  my($mm,$dd);
	  if($value=~m/EASTER/) {
	    ($mm,$dd)=split('/',CalcEaster($year));
	    my($t)=timelocal(0,0,12,$dd,$mm-1,$year);
	    $t=int($t/86400);
	    $value=~s/EASTER/$t/;
	    $t=eval($value)*86400+43200;
            (undef,undef,undef,$dd,$mm) = localtime($t);
	    $mm++;
	  }
	  else {
	    ($mm,$dd)=split('/',$value);
	  }
	  $value=sprintf("%02d/%02d",$mm,$dd);
	  verbose(20,"HOLIDAY=$value\n");
	  $holiday{$value}=1;
	}
	elsif($param eq "TIMESLOT") {
	  my($name,$range)=($value=~m/(\S+)\s*=>\s*(\S+)/);
	  my $ti=$#timeslot+1;
	  $timeslot[$ti]{name}=$name;
	  $timeslot[$ti]{raw}=$range;
	  my $ri=0;
	  foreach(split(",",$range)) {
	    my ($tspec,$wrange)=split('@',$_);
	    my ($start,$end)=split("-",$tspec);
	    my ($wstart,$wend)=split("-",$wrange);
	    if(length($wstart)==0) { $wstart=0; $wend=6; }
	    if(length($wend)==0) { $wend=$wstart; }
	    $timeslot[$ti]{range}[$ri]{start}=TimeSec($start);
	    $timeslot[$ti]{range}[$ri]{end}=TimeSec($end);
	    $timeslot[$ti]{range}[$ri]{wstart}=$wstart+0;
	    $timeslot[$ti]{range}[$ri]{wend}=$wend+1;
	    $ri++;
	  }
	}
	elsif($param eq "CARD") {
	  my($sub,$card)=($value=~m/(\S+)\s*=>\s*(\S+)/);
	  $card{$sub}=$card;
	  $card{$card}=$sub;
	  push(@card,{name=>$sub,id=>$card});
	}
	elsif($param eq "STARTCMD") {
	  $start_command=$value;
	}
	elsif($general_params{$param}) {
	  eval("\$$param=\$value");
	  if($param eq "MAXPOWER") {
	    foreach(qw(MAXPOWER_SUSPEND MAXPOWER_REDUCE MINPOWER_START MINPOWER_INCREASE FIXED)) {
	      if(!defined($default{$_}) || length($default{$_})==0) {
	        $default{$_}=$MAXPOWER;
	      }
	    }
	  }
	}

	if($param =~ m/GRID_LIMIT_.*TIME|GRID_LIMIT.*PAUSE|STOP_ON_SUSPENDEV/) {
	    # Convert HH:MM:SS later to keep original formatting for MQTT
	    #$value=TimeSecPerc($value);
	}
	if($param =~ m/WAIT_CHANGE|WAIT_ON_START/) {
	    $value=WaitTime($value);
	}
	if(length($section)>0)
	{
	  if($param=~m/^ENABLED?$/) { # Accept both ENABLE and ENABLE
	    $smart{$section}{ENABLE}=$value;
	  }
	  elsif($param eq "TIME") {
	    #my $trange="";
	    #my ($tspec,$wrange)=split('@',$value);
	    #foreach(split(",",$tspec)) {
	    #  my ($start,$end)=split("-",$_);
	    #  $trange.=TimeSec($start)."-".TimeSec($end).",";
	    #}
	    #chop($trange);
	    #if(length($wrange)>0) {
	    #  $trange.='@'.$wrange;
	    #}
	    #push(@{$smart{$section}{TIME}},$trange);
	    # Convert HH:MM:SS later to keep original formatting for MQTT
	    push(@{$smart{$section}{TIME}},$value);
	  }
	  #elsif($param=~m/FIXED|AVG|MAXPOWER_|MINPOWER_|WEEKDAY|YEARDAY|GRID_LIMIT/)
	  elsif(length($param)>0) # Keep all values
	  {
	    $smart{$section}{$param}=$value;
	  }
	  
	  # Set the default wallbox section:
	  if($param=~m/^WALLBOX/) {
	    $wallbox=$section;
	    if($#wallbox<0 || $wallbox[$#wallbox] ne $section) {
	      push(@wallbox,$section);
	    }
	  }
	  if($param=~m/^EV/) {
	    $ev=$section;
	    if($#ev<0 || $ev[$#ev] ne $section) {
	      push(@ev,$section);
	    }
	  }
	}
	elsif($param eq "GRID_LIMIT_MAXTIME") {
	  $default{GRID_LIMIT_MAXTIME}=$value;
	  if($default{GRID_LIMIT_REDUCETIME} eq "") {
	    $default{GRID_LIMIT_REDUCETIME}=$default{GRID_LIMIT_MAXTIME};
	  }
	}
	elsif(length($param)>0) {
	  $default{$param}=$value;
	}
      }
    }
    close(S);
    SetDefaultParams();
  }
  if(length($MQTT_POWER_UNIT)==0) { $MQTT_POWER_UNIT="W"; }
  if(length($MQTT_ENERGY_UNIT)==0) { $MQTT_ENERGY_UNIT="kWh"; }

  my($a);
  foreach $a(@trans_params) {
    foreach (ExpandParams($a)) {
      $params{$_}=1;
    }
  }
  if($read_trans && open(S,$trans_file))
  {
    while(<S>) {
      chomp;
      if(m/^\[/) {
        ($section)=m/\[(.*?)\]/;
	if(length($section)>0) {
	  # Do nothing
        }
      }
      else {
	($param,$value)=m/^(\S+)\s*=\s*(.*)/;
	$value=~s/#.*//;
	$value=~s/\s+$//;
	if(defined($params{$param}) || $param=~m/\[/) {
	  verbose(13,"TRANS PARAM=$param, VALUE=$value\n");
	  eval("\$$param=\$value");
	  if($param=~m/GRID_OVER|TIME/) {
	    eval("\$$param+=0");
	  }
	}
      }
    }
    close(S);
  }
}

sub SaveConf
{
  my ($buffer,%tset,%params,$a);
  # FIX: non salvare charging=1 se non siamo in CHARGE.
  # Solo valori positivi: i valori negativi rappresentano stato 'precharging'
  # che e' valido in stati non-CHARGE; resettarli desincronizzerebbe il topic MQTT.
  if($STATUS ne "CHARGE" && $MQTT_started_published>0) {
    $MQTT_started_published=0;
  }
  foreach $a (@trans_params) {
    foreach (ExpandParams($a)) {
      $params{$_}=eval("\$$_");
      if($params{$_}!=0 && m/GRID_OVER|TIME/) {
	eval("\$$_+=0");
	$params{$_}+=0;
	$params{$_}.=" ".scalar(localtime(abs($params{$_})));
      }
    }
  }
  if(open(S,$trans_file))
  {
    while(<S>) {
      ($param,$value)=m/^(\S+)\s*=\s*(.*)/;
      if(!$tset{$param}) {
	if(exists($params{$param})) {
	  $_="$param=$params{$param}\n";
	}
	$tset{$param}=1;
	$buffer.=$_;
      }
    }
    close(S);
    foreach $a (@trans_params)
    {
      foreach (ExpandParams($a)) {
	if(!$tset{$_}) {
	  $buffer.="$_=$params{$_}\n";
	}
      }
    }
  }
  if(open(S,">$trans_file"))
  {
    print S $buffer;
    close(S);
  }
}

1;
