#
# SPDX-FileCopyrightText: 2023-2026 Luca Bonissi <wallbox@bonissi.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# Function definitions: could be changed runtime
#

$VERSION{FUNC}="1.9923";

%ver=(
"DataTransfer"=>14,
"MeterValues"=>14,
"Authorize"=>5,
"BootNotification"=>3,
"StartTransaction"=>5,
"StopTransaction"=>5,
"StatusNotification"=>6,

"Reply"=>9,
);

%nolastclient=("DataTransfer"=>1);

$inv_3600=1.0/3600.0;

sub LsTime
{
    my $now=shift;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(POSIX::floor($now));
    if($sec>=30) { $now+=61-$sec; }
    my $s=substr(LTime($now),2,14);
    $s=~s/-//g;
    $s=~s/ /-/g;
    return($s);
}

sub Now {
    my $now=shift;
    if(length($now)==0) {
      $now=time();
    }
    return($now);
}

sub TimeToHM
{
  my $min=shift;
  $min=int(($min)/60.0+0.5);
  my $hour=int($min/60);
  $min-=$hour*60;
  return(sprintf("%d:%02d",$hour,$min));
}

sub TimeToHMS
{
  my $sec=shift;
  $sec=int($sec+0.5);
  my $hour=int($sec/3600);
  $sec-=$hour*3600;
  my $min=int($sec/60);
  $sec-=$min*60;
  return(sprintf("%d:%02d:%02d",$hour,$min,$sec));
}


sub TimePerc
{
  my ($check,$time)=@_;
  my $checkt=$check;
  if($check=~m/%/) {
    $checkt=$time*$check*0.01;
    #verbose(11,"Time check: $checkt ($check) $time\n");
  }
  return($checkt);
}

sub Float0 {
  my $val=shift;
  if($val==0) { return("0"); }
  return(sprintf("%.3f",$val));
}

sub ActVolt
{
  my $line=shift;
  my $volt;
  if(length($line)>0) {
    $volt=$lastmeter{"L$line"}{voltage};
  }
  if($volt==0) { $volt=$currVolt; }
  if($volt==0) { $volt=$VOLT_AVG; }
  if($volt==0) { $volt=230; }
  return($volt);
}

sub ActVoltWallbox
{
  my $volt=$wallbox_currVolt;
  if($volt==0) { $volt=ActVolt(); }
  return($volt);
}

sub MinActVolt
{
  my $volt=$currVolt;
  if($volt==0) { $volt=$VOLT_AVG; }
  if($volt==0) { $volt=230; }
  if($wallbox_currVolt>0 && $wallbox_currVolt<$volt) { $volt=$wallbox_currVolt; }
  return($volt);
}

sub MaxActVolt
{
  my $volt=$meter_currVolt;
  if($wallbox_currVolt>0 && $wallbox_currVolt>$volt) { $volt=$wallbox_currVolt; }
  if($volt==0) { $volt=$VOLT_AVG; }
  if($volt==0) { $volt=230; }
  return($volt);
}

sub ActVoltFormatted
{
  return(sprintf("%.1f",ActVolt()));
}

sub PowerAmpere
{
  my $power=shift;
  if($currLActive<=1) {
    $currLActive=1;
  }
  if($power=~m/W/i) {
    if($currLActive<=1) {
      $power=$power/(ActVolt()-10)+0.8;
    }
    else {
      $power=$power/(ActVolt()*$currLActive);
    }
  }
  else {
    $power+=0;
  }
  return($power);
}

sub intPower 
{
  return(int($_[0]));
}

sub Power
{
  my ($power,$volt)=@_;
  if($power=~m/W/i) {
    $power+=0;
  }
  else {
    $power=$power*$volt;
  }
  return(intPower($power));
}

sub Ampere
{
  my ($ampere)=@_;
  $ampere=RoundFineStep(PowerAmpere($ampere));
  return($ampere);
}

sub CurrOffered
{
  my($co);
  $co=$currOffered;
  if($currLActive<1) { $currLActive=1; }
  if($currLActive>1) { $co=$co*$currLActive; }
  return($co);
}

sub PowerOffered
{
  my $po=$lastPowerOffered;
  if(length($po)==0) { $po=CurrOffered()*ActVoltWallbox(); }
  return(intPower($po));
}

sub EvParam
{
  my($param,$e)=@_;
  my($val);
  if($e eq "") { $e=$ev; }
  $val=$smart{$e}{$param};
  if(!defined($val)) {
    # Check for global param:
    $val=$default{$param};
  }
  return($val);
}


sub WallboxParam
{
  my($param,$wb)=@_;
  my($val);
  if($wb eq "") { $wb=$wallbox; }
  $val=$smart{$wb}{$param};
  if(!defined($val)) {
    # Check for global param:
    $val=$default{$param};
    if(!defined($val)) {
      # Maybe the general param was without WALLBOX_ prefix, remove it
      $param=~s/^WALLBOX_//;
      $val=$default{$param};
    }
  }
  return($val);
}

sub WallboxFineStep
{
  my($fs);
  $fs=WallboxParam("WALLBOX_SET_LIMIT_FINESTEP");
  if($fs==0) { return(1); }
  return($fs);
}

sub WallboxCurrAdd
{
  my $curr=shift;
  if($curr==0) { return($curr); }
  return(($curr+WallboxFineStep()/3));
}

sub PowerWallbox
{
  my ($power,$volt)=@_;
  if($power=~m/W/i) {
    $power+=0;
  }
  else {
    if(length($volt)==0) {
      $volt=ActVoltWallbox();
    }
    $power=intPower(WallboxCurrAdd($power)*$volt);
  }
  return(intPower($power));
}

sub PowerWallboxMax
{
  my $power=shift;
  return(PowerWallbox($power,MaxActVolt()));
}

sub WallboxMainStep
{
  my($fs,$incdec);
  $fs=WallboxFineStep();
  $incdec=WallboxParam("WALLBOX_SET_LIMIT_MAINSTEP");
  if($incdec<=0) { $incdec=1; }
  if($currLActive<1) { $currLActive=1; }
  if($incdec<($fs*$currLActive)) {
    $incdec=$fs*$currLActive;
  }
  return($incdec);
}

sub TruncFineStep {
  my $value=shift;
  # Use the lowest energy
  my $fs=WallboxFineStep();
  if($fs==1) {
    return(int($value));
  }
  return(int($value/$fs)*$fs);
}

sub RoundFineStep {
  my $value=shift;
  # Use the lowest energy
  my $fs=WallboxFineStep();
  if($fs==1) {
    return(int($value+0.5));
  }
  return(int($value/$fs+0.5)*$fs);
}

sub CurrOfferedFull
{
  my($co);
  $co=CurrOffered();
  if($co ne $currOffered) {
    $co.="/$currOffered";
  }
  return($co);
}

sub CheckAvg
{
  my($great)=@_;
  my($val,$amp,$factor);
  if($canincrease>0 && $AVG && ($avgAlasttime-$START_TIME)>100 && $AVG_DEV>0) {
    # Wait at least 3 sampling before doing any action
    if($FIXED=~m/W/i) {
      # Consider effective power
      $val=($FIXED-$avgW)/ActVoltWallbox()*$great;
      $amp=$FIXED*$avgA/$avgW;
    }
    else {
      # Consider Amperes offered
      $val=($FIXED-$avgA)*$great;
      $amp=$FIXED+0;
    }
    $factor=abs($amp-$currOffered);
    if($factor<1) { $factor=1; }
    $factor*=$AVG_DEV;
    #verbose(11,"CheckAmpere: $FIXED ($amp), AvgA=$avgA, AvgW=$avgW, V=$val, G=$great [$factor]\n");
    if($great>0) {
      # Do not keep decrease if value near FIXED
      if($currOffered<=($amp-1) && $val>0 && $val<$factor) { return(10); }
      # Do not increase more if value near FIXED
      if($currOffered>=($amp+1) && $val<($factor*2)) { return(0); }
    }
    else {
      # Do not keep increase if value near FIXED
      if($currOffered>=($amp+1) && $val>0 && $val<$factor) { return(10); }
      # Do not decrease more if value near FIXED
      if($currOffered<=($amp-1) && $val<($factor*2)) { return(0); }
    }
    #verbose(11,"HERE: $val > $AVG_DEV ?\n");
    if($val>$AVG_DEV) { return(1); }
  }
  return(0);
}

sub ConnectorId
{
  if($connectorId==0) { 
    # Fix bug on ABB Terra AC where the reported connectorId is 0 at start
    if(length($connectorId)==0 || $started_from_boot<=0) {
      $connectorId=1;
    }
  }
  else {
    $started_from_boot=-1;
  }
}

sub SetTransactionFull
{
  $currTransactionFull=$currTransaction;
  if($currSub>0) {
    $currTransactionFull.="-$currSub";
  }
}

sub SubStatus 
{
  my $newOffered=shift;
  if($newOffered<$WBMINPOWER) {
    $SUBSTATUS="SUSPEND";
  }
  else {
    $SUBSTATUS="SUSPENDSTART";
  }
}

sub ShowStatus
{
  my $showstatus=$STATUS;
  if($SUBSTATUS eq "SUSPEND" || ($STATUS eq "STOP" && $SUBSTATUS=~m/SUSPEND/)) {
    $showstatus.="/$SUBSTATUS";
  }
  return($showstatus);
}

sub LogTrans
{
  my ($trans,$st,$et,$totalspan,$prevwh,$wh,$avgA,$pvwh,$avgCUR)=@_;
  my ($sts,$ets,$spans,$totalspans,$kwh,$tkwh,$span,$avgtkw,$avgkw,$pvkwh,$pvp,$cwh,@tskwh,$fetchwh,$gridwh,$factor,$i,$s,$fetchcount,$pvcount,$fetchfirst,$pvfirst,$fetchmap,$pvmap,$tslot);
  my (@ftot,$tpvkwh,$tpvp);

  $st=POSIX::floor($st);
  $et=POSIX::floor($et);
  $sts=LsTime($st);
  $ets=LsTime($et);
  $span=$et-$st;
  $spans=TimeToHM($span);
  $totalspans=TimeToHM($totalspan);

  $cwh=$wh-$prevwh;
  $kwh=sprintf("%.3f",$cwh*0.001);
  $tkwh=sprintf("%.3f",($wh)*0.001);

  $pvcount=0;
  $pvfirst=-1;
  $pvmap=0;
  #if($pvwh>$cwh) { # Could not more bigger than cwh // Fixed direclty during pseudo-realtime
  #  $factor=$cwh/$pvwh;
  #  for($i=0;$i<=$#timeslot;$i++) {
  #    if($pvwh[$i]>0) {
  #      $pvmap|=(1<<$i);
  #      $pvwh[$i]=$pvwh[$i]*$factor;
  #      $pvcount++;
  #      if($pvfirst<0) { $pvfirst=$i; }
  #    }
  #  }
  #  $pvwh=$cwh;
  #}
  $pvkwh=Float0($pvwh*0.001);
  if($cwh>0) {
    $pvp=sprintf(" %.0f%%",$pvwh/($cwh)*100);
  }
  $tpvkwh=Float0($LAST_PV*0.001);
  if($wh>0) {
    $tpvp=sprintf(" %.0f%%",$LAST_PV/$wh*100);
  }

  $fetchwh=0;
  $fetchcount=0;
  for($i=0;$i<=$#timeslot;$i++) {
    $fetchwh+=$tswh[$i];
    $ftot[$i]=sprintf("%.3f",$LAST_TSWH[$i]*0.001);
  }

  $gridwh=$cwh-$pvwh;
  if($gridwh>0 && $fetchwh==0) {
    $fetchwh=$gridwh;
    $tslot=TimeSlot(SecWDayHour($et));
    $tswh[$tslot]=$gridwh;
  }
  elsif($gridwh==0 && $fetchwh>0) {
    for($i=0;$i<=$#timeslot;$i++) {
      $tswh[$i]=0;
    }
  }
  #elsif($gridwh>0 && int($gridwh+0.5)!=int($fetchwh+0.5)) {
  #  $factor=$gridwh/$fetchwh;
  #  for($i=0;$i<=$#timeslot;$i++) {
  #    $tswh[$i]=$tswh[$i]*$factor;
  #  }
  #}
  for($i=0;$i<=$#timeslot;$i++) {
    if($tswh[$i]>=0.5) {
      $tskwh[$i]=sprintf("%.3f",$tswh[$i]*0.001);
    }
    elsif($pvwh[$i]>0) {
      $tskwh[$i]="0";
    }
    else {
      $tskwh[$i]="-";
    }
    if($tskwh[$i] ne "-") {
      $fetchcount++;
      if($fetchfirst<0) { 
        $fetchfirst=$i;
	if($pvfirst>$i) {
          # Usually you have only a single time slot for PV generation,
	  # and it is usually the same as first one of grid fetch.
	  # If we reach this branch, it means that the time slot is
	  # not the first. Increase (virtually) the number of PV
	  # time slots, so an empty will be create in the report.
	  $pvcount++;
	}
      }
    }
  }

  # If $pvcount is > 1, means we have to put more than one number.
  # Fill only the slot where some grid energy is fetched (or marked
  # as "0" for PV slot)
  if($pvcount>1) {
    # Recompose PV number[s]
    $pvkwh="";
    for($i=0;$i<=$#timeslot;$i++) {
      if($tskwh[$i] ne "-") {
        if(length($pvkwh)>0) { $pvkwh.="/"; }
	if($pvwh[$i]>0) {
          $pvkwh.=Float0($pvwh[$i]*0.001);
	}
      }
    }
  }


  if($span<=0) { $span=1; }
  if($totalspan<=0) { $totalspan=1; }
  $avgtkw=sprintf("%.2fkW",$wh*3.6/$totalspan);
  $avgkw=sprintf("%.2fkW",($wh-$prevwh)*3.6/$span);
  $avgA=sprintf("%.2fA/%.2fA",$avgA,$avgCUR);
  if($kwh>0) {
    if(length($charge_log)>0) {
      $s="";
      if(! -f "$charge_log") {
	# Write header:
	$s.="TransID	StartTime  StartTimeTxt	EndTime    EndTimeTxt	TkWh	Ttime	TavgkW	kWh	time	avgkW	avgO/avgA	PV";
	for($i=0;$i<=$#timeslot;$i++) {
	  $s.="\t$timeslot[$i]{name}";
	}
	$s.="\n";
      }
      if(open(C,">>$charge_log"))
      {
	$s.="$trans\t$st $sts\t$et $ets\t$tkwh\t$totalspans\t$avgtkw\t$kwh\t$spans\t$avgkw\t$avgA\t$pvkwh";
	for($i=0;$i<=$#timeslot;$i++) {
	  $s.="\t$tskwh[$i]";
	}
	print C "$s\n";
	close(C);
      }
    }
    # Publish MQTT, split session and sub session
    my($session,$subsession)=split("-",$trans);
    $subsession=sprintf("%03d",$subsession);
    MQTT_PublishLog($START_SESSION,$session,$subsession,$st,$et,$kwh,$span,$avgAsum,$avgCURsum,$avgAcount,$pvkwh,@tskwh);
    MQTT_PublishLog($START_SESSION,$session,"",$START_SESSION,$et,$tkwh,$LAST_SPAN,$LAST_AVGASUM,$LAST_AVGCURSUM,$LAST_AVGACOUNT,$tpvkwh,@ftot);
  }
  $s="T=$trans, ST=$sts, ET=$ets, TIME=$spans, kWh=$kwh\@$avgkw ($tkwh\@$avgtkw) $avgA Pv=$pvkwh$pvp";
  for($i=0;$i<=$#timeslot;$i++) {
    if($tskwh[$i] ne "-") {
      $s.=" ".$timeslot[$i]{name}."=".$tskwh[$i];
    }
  }
  verbose(5,"$s\n");
}

sub GenUUID
{
  #my $uuid=`uuidgen`; chomp($uuid);
  #my $uuid=int(rand(2147483647));
  #Avoid truly random number. Generate seed only every 24 hours
  if((time()-$lastuuid)>=86400) {
    $uuidseed=int(rand(2000000000));
  }
  $uuidseed+=int(rand(100))+1;
  return($uuidseed);
}

sub InRange
{
  my($range,$num,$conv)=@_;
  my($start,$end);
  if(length($range)==0) { return(1); }
  foreach(split(",",$range)) {
    ($start,$end)=split("-");
    if($conv) {
      $start=TimeSec($start);
      $end=TimeSec($end);
    }
    if(length($end)==0) { $end=$start+1; }
    elsif($end<7) { $end++; } # Week number
    if($start>$end) {
      # Rolling hours
      if($num>=$start || $num<$end) {
	return(1);
      }
    }
    elsif($num>=$start && $num<$end) {
      return(1);
    }
  }
  return(0);
}

sub Holiday {
  my($mon,$mday)=@_;
  return($holiday{sprintf("%02d/%02d",$mon,$mday)});
}

sub SecWDayHour
{
  my($now)=@_;
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($now);
  $sec=$sec+$min*60+$hour*3600;
  if(Holiday($mon+1,$mday)) { $wday=0; }
  return(($sec,$wday,$hour));
}

sub TimeSlot
{
  my ($time,$wday)=@_;
  my ($timeslot,$i,$ri);
  for($i=0;$i<=$#timeslot;$i++) {
    for($ri=0;$ri<=$#{$timeslot[$i]{range}};$ri++) {
      if($time>=$timeslot[$i]{range}[$ri]{start} &&
         $time< $timeslot[$i]{range}[$ri]{end} &&
         $wday>=$timeslot[$i]{range}[$ri]{wstart} &&
         $wday< $timeslot[$i]{range}[$ri]{wend})
      {
	$timeslot=$i;
        last;
      }
    }
    if(defined($timeslot)) {
      last;
    }
  }
  if(!defined($timeslot)) { $timeslot=$i; }
  return($timeslot);
}

sub PushQueue
{
  my($buffer,$remove,$immediate)=@_;

  if(length($remove)>0) {
    # Check and remove any similar message[s]:
    my($i);
    $i=0;
    while($i<=$#queue) {
      if($queue[$i]=~m/$remove/) {
        splice(@queue,$i,1);
      }
      else {
        $i++;
      }
    }
    $queue_len=$#queue+1;
  }

  if($MAX_QUEUE==0) { $MAX_QUEUE=30; }
  if($MAX_QUEUE>0 && $queue_len>$MAX_QUEUE) {
    splice(@queue,0,$queue_len-$MAX_QUEUE);
    $queue_len=$MAX_QUEUE;
  }

  if($immediate) {
    unshift(@queue,$buffer);
    $queue_wait=0;
    undef($lastsend);
  }
  else {
    push(@queue,$buffer);
  }
  $queue_len=$#queue+1;
}

sub Reply
{
  my ($payload,$sock,$socki)=@_;
  my ($keys,$now,$i,$uuid,$action,$message);
  $now=Now($payload->{now});
  for($i=0;$i<=$#queue_uuid;$i++) {
    if($id eq $queue_uuid[$i][0]) {
      $action=$queue_uuid[$i][1];
      #$message=$queue_uuid[$i][3];
      verbose(19,"Handling reply $action $id...\n");
      splice(@queue_uuid,$i,1);
      $i--;
      # Handle the reply
      if($action eq "SetChargingProfile") {
	if($smartcharging<=0) {
	  if($payload->{status}=~m/Accepted/i) {
	    # OK, SmartCharging supported
	    $smartcharging=2;
	    verbose(7,"SmartCharging supported even if not present in FeatureProfiles\n");
	  }
	  elsif(length(WallboxParam("WALLBOX_MQTT_SET_LIMIT"))) {
	    verbose(7,"SmartCharging supported by MQTT\n");
	    $smartcharging=100;
	  }
	  else {
	    verbose(7,"SmartCharging NOT supported, use Remote Start/Stop to resume/suspend charging\n");
	  }
	}
	if($smartcharging>0) {
	  $canincrease=-1;
	}
      }
      elsif($action eq "GetConfiguration") {
	if(!defined($smartcharging)) { $smartcharging=0; }
	if(defined($keys=$payload->{configurationKey}))
	{
	  my %conf=();
	  foreach (@{$keys})
	  {
	    $conf{$_->{key}}=$_->{value};
	    if($_->{readonly}) { $conf{$_->{key}}.="(RO)"; }

	    if($_->{key} eq "SupportedFeatureProfiles") {
	      $supportedfeatureprofiles=$_->{value};
	      $smartcharging=0;
	      if($supportedfeatureprofiles=~m/Smart\s*Charg/i) {
		$smartcharging=1;
	      }
	      if($smartcharging>0) {
		# When connector is plugged in, we don't want that charging starts
		# immediately: by default limit current to 0 (charging suspended)
		verbose(7,"SmartCharging supported, set default limit to ".($FIXED>0?$FIXED:0)."\n");
	      }
	      else {
		verbose(7,"SmartCharging seems unsupported, try anyway to set default limit\n");
		#verbose(7,"SmartCharging NOT supported, use Remote Start/Stop to resume/suspend charging\n");
	      }
	      DataLog("trans",$now,"SupProf",$smartcharging,$supportedfeatureprofiles);
	      # Try anyway to set default limit
	      if($FIXED>0) {
		DefaultLimit($FIXED,PowerWallboxMax($FIXED));
	      }
	      else {
		DefaultLimit(0,0,CheckStop()?1000:0);
	      }
	    } # SupportedFeatureProfiles
	  }
	  MQTT_PublishConfiguration($wallbox,\%conf);
	}
      }
      elsif($action=~m/Remote.*Transaction|Unlock|Reset|TriggerMessage/) {
	# If RemoteStopTransaction is Rejected by wallbox force StopCharging on MQTT side to keep HA sensor in sync
	if($action eq "RemoteStopTransaction" && $payload->{status}=~m/Rejected/i) {
	  verbose(5,"RemoteStopTransaction Rejected by wallbox (STATUS=$STATUS/$SUBSTATUS), forcing MQTT StopCharging\n");
	  StopCharging();
	}
	CheckTriggerMQTT($payload);
      }
      $lastsend=undef;
    }
    else {
      verbose(19,"Reply $queue_uuid[$i][0] ($queue_uuid[$i][1]) still in the queue...\n");
    }
  }
}

sub HandleQueue
{
  my($i)=@_;
  my($now,$k);
  if($QUEUE_DELAY_TIME==0) { $QUEUE_DELAY_TIME=30; }
  if($QUEUE_WAIT==0) { $QUEUE_WAIT=3; }
  if($lastsend>0 && (time()-$lastsend)>$QUEUE_DELAY_TIME) {
    # Missing reply from last command, possibly unsupported
    undef($lastsend);
    if($lastaction eq "SetChargingProfile" && $smartcharging<=0) {
      verbose(3,"SmartCharging seems unsupported, please check!\n");
    }
    else {
      verbose(3,"Wallbox not responding to $lastaction, please check!\n");
    }
  }
  if($queue_len>0 && $queue_wait<=0 && (time()-$lastsend)>$QUEUE_DELAY_TIME) {
    $nowverb=$now=time();
    SendWS($i,0x81,$queue[0],6);
    ($lastuuid,$lastaction)=($queue[0]=~m/\[\s*\d+\s*,\s*"(\S+?)"\s*,\s*"(\S+?)"/);
    if($lastaction eq "SetChargingProfile") {
      my ($limit)=($queue[0]=~m/"limit":\s*([\d\.]+)/);
      if($queue[0]=~m/TxDefaultProfile/) {
        DataLog("trans",$now,"DefLim",$limit);
      }
      else {
        my ($tid)=($queue[0]=~m/"transactionId":\s*([\d]+)/);
        DataLog("trans",$now,"Limit",$limit,$tid);
      }
    }
    elsif($lastaction eq "RemoteStartTransaction") {
      my ($tag)=($queue[0]=~m/"idTag":\s*([\d]+)/);
      DataLog("trans",$now,"RStart",$tag);
    }
    elsif($lastaction eq "RemoteStopTransaction") {
      my ($tid)=($queue[0]=~m/"transactionId":\s*([\d]+)/);
      DataLog("trans",$now,"RStop",$tid);
    }
    undef($nowverb);
    $lastsend=time();
    $queue_wait=$QUEUE_WAIT;

    # Queue UUID historic: 0=uuid, 1=Action, 2=time, 3=Message
    # Scan for too old UUID:
    for($k=0;$k<=$#queue_uuid;$k++) {
      if(($now-$queue_uuid[$k][2])>300) {
        shift(@queue_uuid);
	$k--;
      }
      else {
        # uuid are in order of time, do not scan the next
        last;
      }
    }
    push(@queue_uuid,[$lastuuid,$lastaction,$now,$queue[0]]);

    shift(@queue);
    $queue_len=$#queue+1;
  }
  elsif($queue_wait>0) { $queue_wait--; }
}

sub GetCharging {
  return($MQTT_started_published);
}

sub PreCharging {
  if($MQTT_started_published>=0) {
    verbose(11,"Publish precharging => (actual=$MQTT_started_published)\n");
    $MQTT_started_published=0-Now();
    if(length($start_command)>0) {
      system("$start_command -1 \&");
    }
    MQTT_PublishCharging($wallbox,-1);
  }
}

sub StartCharging {
  my $ampere=shift;
  if($STATUS eq "STOPEV") {
    StopCharging();
  }
  elsif($USE_STOP_AS_SUSPEND && $STATUS eq "STOP" && $SUBSTATUS eq "SUSPENDSTART") {
    # RemoteStart queued but wallbox not yet in CHARGE (e.g. EV battery full):
    # publish 'precharging' instead of claiming we're charging.
    PreCharging();
  }
  else {
    if($MQTT_started_published<=0) {
      verbose(11,"Publish charging => (actual=$MQTT_started_published)\n");
      $MQTT_started_published=1;
      if(length($start_command)>0) {
	system("$start_command $ampere \&");
      }
      MQTT_PublishCharging($wallbox,1);
    }
  }
}

sub StopCharging {
  if($MQTT_started_published ne "0")
  {
    verbose(11,"Publish stop => (actual=$MQTT_started_published)\n");
    $MQTT_started_published=0;
    MQTT_PublishCharging($wallbox,0);
    $lastmeasure{power}=0;
    $lastmeasure{current}=0;
    $lastmeasure{charging}=0;
    $lastmeasure{now}=Now();
    MQTT_PublishSession($wallbox,\%lastmeasure);
  }
}

sub StartStop
{
  my ($newOffered,$newPower,$currTransaction,$immediate)=@_;
  my ($err);
  my $uuid=GenUUID();
  my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthas)=caller(1);
  verbose(15,"STARTSTOP [caller=$subroutine] [prof=$currProfile] (newO=$newOffered [$newPower] $TRANSACTION ($currSub // $currTransaction // $currTransactionFull) $LAST_WH ($prevLAST_WH) $LAST_SPAN\n");
  if($newOffered>0) {
    if(GetCharging()==0) {
      # Delay a little bit to allow OBD data collection setup
      $queue_wait+=3;
    }
    if(length($TAG)==0) { $TAG="REMOTE"; }
    ConnectorId();
    if(!$immediate && $USE_STOP_AS_SUSPEND) {
      if((IsUnitWatt())||($deflimit!=$newOffered)) {
        # Set the default limit if unit is Watt
        DefaultLimit($newOffered,$newPower);
      }
    }
    PushQueue("[2,\"$uuid\",\"RemoteStartTransaction\", { \"connectorId\": $connectorId, \"idTag\": \"$TAG\" } ]","Remote.*Transaction",$immediate);
    if($immediate && $USE_STOP_AS_SUSPEND) {
      if((IsUnitWatt())||($deflimit!=$newOffered)) {
        # Immediate push the default limit before RemoteStart
        DefaultLimit($newOffered,$newPower,undef,$immediate);
      }
    }
    if($smartcharging<=0) {
      $powerSet=$lastSet=$currSet=$newOffered+0;
    }
    #StartCharging($currSet);
  }
  elsif(length($currTransaction)>0 || $newOffered=~m/force/) {
    if(length($currTransaction)==0) {
      ConnectorId();
      $err=Unlock($connectorId,1,$immediate);
    }
    else {
      PushQueue("[2,\"$uuid\",\"RemoteStopTransaction\", { \"transactionId\": $currTransaction } ]","Remote.*Transaction",$immediate);
    }
    $stopremote=1;
    if($smartcharging<=0) { 
      $powerSet=$lastSet=$currSet=$newOffered+0;
      $smartcharging=-1;
    }
  }
  else {
    $err="Rejected|No active transaction";
  }
  if($smartcharging<=0) { 
    $canincrease=-2;
  }
  return($err);
}

sub Unlock {
  my ($connector,$force,$immediate)=@_;
  my ($err);
  my $uuid=GenUUID();
  verbose(10,"UNLOCK $STATUS / $SUBSTATUS ($force)\n");
  if($STATUS ne "CHARGE" || $force) {
    $connectorId=$connector;
    ConnectorId();
    verbose(15,"Pushing UnlockConnector\n");
    PushQueue("[2,\"$uuid\",\"UnlockConnector\", { \"connectorId\": $connectorId } ]","UnlockConnector",$immediate);
  }
  else {
    $err="Rejected|Charging in progress";
  }
  return($err);
}

sub Reset {
  my ($type,$force,$immediate)=@_;
  my ($err);
  my $uuid=GenUUID();
  verbose(15,"RESET $STATUS / $SUBSTATUS\n");
  if($STATUS ne "CHARGE" || $force) {
    ConnectorId();
    PushQueue("[2,\"$uuid\",\"Reset\", { \"type\": \"$type\" } ]","Reset",$immediate);
  }
  else {
    $err="Rejected|Charging in progress";
  }
  return($err);
}

sub WallboxMinPower
{
  if(WallboxUnit()=~m/W/i) {
    my $add=WallboxParam("WALLBOX_SET_LIMIT_MINADD");
    if(length($add)==0) { $add=1; }
    return($MINPOWER+$add)
  }
  return($MINPOWER);
}

sub MinPowerCharging {
  my $minpower=$CHARGING_MINPOWER;
  if(length($minpower)==0) { $minpower=$WBMINPOWER; }
  else {
    $minpower=Ampere($minpower);
    if($minpower<$WBMINPOWER) { $minpower=$WBMINPOWER; }
  }
  return($minpower);
}

sub WallboxUnit
{
  my $unit=WallboxParam("WALLBOX_SET_LIMIT_UNIT");
  if(length($unit)==0) { $unit="A"; }
  return($unit);
}

sub IsUnitWatt
{
  if(WallboxUnit()=~m/W/i) {
    return(1);
  }
  return(0);
}

sub GetPhasesValue
{
  my ($newOffered,$newPower)=@_;
  my ($curph,$unit,$phases,$value,$i);
  if(length($newPower)==0) {
    if(CurrOffered()>0) {
      $newPower=(WallboxCurrAdd($newOffered))*MinActVolt();
    }
    else {
      $newPower=(WallboxCurrAdd($newOffered))*MaxActVolt();
    }
  }
  $newPower=intPower($newPower);

  $unit=WallboxUnit();

  $curph=$currLSet;
  if($curph<1) { $curph=$currLActive; }
  if($curph<1) { $curph=1; }
  if($allowed_phases[0]>0) {
    for($i=0;$i<=$#allowed_phases;$i++) {
      if($allowed_phases[$i]==$currLActive) {
        if($i<$#allowed_phases && $switch_phase_up[$i]>0 && $newOffered>$switch_phase_up[$i]) {
	  $curph=$allowed_phases[$i+1];
	  last;
	}
        elsif($i>0 && $switch_phase_down[$i]>0 && $newOffered<$switch_phase_down[$i]) {
	  $curph=$allowed_phases[$i-1];
	  last;
	}
      }
    }
    $phases=", \"numberPhases\": $curph";
  }
  if($unit=~m/W/i) {
    $value=$newPower;
    if($unit=~m/kW/i) {
      $value=sprintf("%.3f",$value*0.001);
    }
  }
  else {
    if($curph>1) {
      $value=sprintf("%.2f",$newOffered/$curph)+0.0;
    }
    else {
      $value=$newOffered;
    }
  }
  verbose(12,"Value=$value, unit=$unit, phases=$phases, curphases=$curph, newCurr=$newOffered, newPow=$newPower\n");
  return(($phases,$value,$unit,$curph,$newPower));
}

sub NewOffered
{
  my ($newOffered,$newPower,$currTransaction,$immediate)=@_;
  #my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthas)=caller(1);
  #verbose(3,"NEWOFFERED, caller=$subroutine\n");
  my $uuid=GenUUID();
  if(length($currTransaction)==0) { 
    DefaultLimit($newOffered,$newPower,1001);
    return;
  }
  $newOffered=Ampere($newOffered);
  my $pid=$CS_PROFILE_ID;
  my $stack=$CS_STACK_LEVEL;
  if(length($pid)==0) { $pid=2; }
  if(length($stack)==0) { $stack=1; }
  ConnectorId();
  if($USE_STOP_AS_SUSPEND && $newOffered<$WBMINPOWER) {
    SubStatus($newOffered);
    # Stop transaction
    StartStop($newOffered,$newPower,$currTransaction,$immediate);
  }
  elsif($USE_STOP_AS_SUSPEND && $STATUS eq "STOP" && $SUBSTATUS ne "SUSPENDSTART") {
    SetTransactionFull();
    SubStatus($newOffered);
    # Start transaction, always set default limit
    StartStop($newOffered,$newPower,$currTransaction,$immediate);
  }
  else {
    if($USE_STOP_AS_SUSPEND && $STATUS eq "STOP")
    {
      SetTransactionFull();
      # Use DefaultLimit only and skip TxProfile to avoid Rejected responses.
      if($SUBSTATUS eq "SUSPENDSTART") {
        verbose(7,"NewOffered: STOP/SUSPENDSTART, skip TxProfile, use DefaultLimit only\n");
        DefaultLimit($newOffered,PowerWallboxMax($newOffered));
        $lastSet=$currSet=$newOffered;
        $powerSet=$newPower;
        $canincrease=-2;
        MQTT_PublishLimit($wallbox,{});
        return;
      }
    }
    if(GetCharging()==0 && $newOffered>=$WBMINPOWER) {
      # Delay a little bit to allow OBD data collection setup
      $queue_wait+=3;
    }
    if(!$USE_STOP_AS_SUSPEND) { $SUBSTATUS=""; }
    if($smartcharging>=100) {
      DataLog("trans",time(),"Limit",$newOffered,$currTransaction);
      MQTT_SetLimit($wallbox,$connectorId,$newOffered);
    }
    else {
      #PushQueue("[2,\"$uuid\",\"SetChargingProfile\", { \"connectorId\": $connectorId, \"csChargingProfiles\": { \"chargingProfileId\": $pid, \"chargingProfileKind\": \"Recurring\", \"chargingProfilePurpose\": \"TxProfile\", \"chargingSchedule\": { \"chargingRateUnit\": \"A\", \"chargingSchedulePeriod\": [ { \"limit\": $newOffered, \"startPeriod\": 0 } ], \"duration\": 86400 }, \"stackLevel\": $stack, \"transactionId\": $currTransaction } } ]","SetChargingProfile.*TxProfile",$immediate);
      my ($phstring,$value,$unit,$curph)=GetPhasesValue($newOffered,$newPower);
      PushQueue("[2,\"$uuid\",\"SetChargingProfile\", { \"connectorId\": $connectorId, \"csChargingProfiles\": { \"chargingProfileId\": $pid, \"chargingProfileKind\": \"Absolute\", \"chargingProfilePurpose\": \"TxProfile\", \"chargingSchedule\": { \"chargingRateUnit\": \"$unit\", \"chargingSchedulePeriod\": [ { \"limit\": $value, \"startPeriod\": 0 $phstring } ] }, \"stackLevel\": $stack, \"transactionId\": $currTransaction } } ]","SetChargingProfile.*TxProfile",$immediate);
      $currLSet=$curph;
    }
    if($newOffered<$WBMINPOWER) {
      $laststop="";
    }
  }
  if($currSet<$WBMINPOWER && $newOffered>=$WBMINPOWER) {
    StartCharging($newOffered);
  }
  $lastSet=$currSet=$newOffered;
  $powerSet=$newPower;
  $canincrease=-2;
  MQTT_PublishLimit($wallbox,{});
}

sub MinDefLimit {
  if($USE_STOP_AS_SUSPEND) {
    return(MinPowerCharging());
  }
  return(0);
}

sub DefaultLimit
{
  my ($limit,$power,$force,$immediate)=@_;
  my $uuid=GenUUID();
  if($force>=1000) {
    # Check if it should be applied
    if(!WallboxParam("WALLBOX_SET_LIMIT_ZERO_ON_STOP")) {
      $force-=1000;
    }
  }
  if($limit>=0) {
    $deflimit=$limit;
  }
  $defpower=$power;
  $limit=Ampere($limit);
  my $pid=$CS_PROFILE_ID;
  my $stack=$CS_STACK_LEVEL;
  if(length($pid)==0) { $pid=2; }
  if(length($stack)==0) { $stack=1; }
  ConnectorId();
  #PushQueue("[2,\"$uuid\",\"SetChargingProfile\", { \"connectorId\": $connectorId, \"csChargingProfiles\": { \"chargingProfileId\": 1, \"chargingProfileKind\": \"Recurring\", \"chargingProfilePurpose\": \"TxDefaultProfile\", \"chargingSchedule\": { \"chargingRateUnit\": \"A\", \"chargingSchedulePeriod\": [ { \"limit\": $limit, \"startPeriod\": 0 } ], \"duration\": 86400 }, \"stackLevel\": 1 } } ]");
  if($USE_STOP_AS_SUSPEND && $limit<$WBMINPOWER && $force<1000) {
    $limit=MinPowerCharging();
    $deflimit=$limit;
    $power=PowerWallboxMax($limit);
  }
  verbose(15,"USE STOP AS SUSPEND=$USE_STOP_AS_SUSPEND, power charging=$limit [$power] -- (WBMIN=$WBMINPOWER)\n");
  if($smartcharging<100) {
    my ($phstring,$value,$unit,$curph)=GetPhasesValue($limit,$power);
    PushQueue("[2,\"$uuid\",\"SetChargingProfile\", { \"connectorId\": $connectorId, \"csChargingProfiles\": { \"chargingProfileId\": 1, \"chargingProfileKind\": \"Absolute\", \"chargingProfilePurpose\": \"TxDefaultProfile\", \"chargingSchedule\": { \"chargingRateUnit\": \"$unit\", \"chargingSchedulePeriod\": [ { \"limit\": $value, \"startPeriod\": 0 $phstring } ] }, \"stackLevel\": 1 } } ]","TxDefaultProfile",$immediate);
  }
  elsif($smartcharging>=100) {
    if($limit>0 && $force) {
      DataLog("trans",time(),"DefLim",$limit);
      MQTT_SetLimit($wallbox,$connectorId,$limit);
    }
  }
  if(length($currSet)==0 || $currSet<0) { $currSet=$limit; }
}

sub SmartStart
{
  my($newOffered,$ct)=@_;

  if(length($newOffered)==0) { $newOffered=$WBMINPOWER; }

  if($deflimit>0 || !$USE_STOP_AS_SUSPEND) {
    my $power=PowerWallboxMax($newOffered);
    verbose(11,"SmartStart: curr=$newOffered, power=$power, trans=$ct\n");
    return(StartStop($newOffered,$power,$ct,1));
  }
  else {
    # Set only the status/substatus
    if(length($currTransaction)==0 || !($SUBSTATUS=~m/SUSPEND/)) {
      # Just in case StartTransaction was not yet arrived
      $TRANSACTION++;
      $currTransaction=$TRANSACTION;
      if(length($currSub)>0) {
        $backup_currSub=$currSub;
      }
      undef($currSub);
      ResetSession();
      SetTransactionFull();
    }
    $SUBSTATUS="SUSPEND";
    verbose(11,"SmartStart: set SUSPEND status for transaction $currTransaction\n");
    return("Suspended|Transaction will be started when condition will met");
  }
}

sub BootNotification
{
  my ($payload,$sock)=@_;
  #[2, "7053156", "BootNotification", {"chargePointModel": "CDT_TACW7::NET_WIFI", "chargePointVendor": "ABB", "chargeBoxSerialNumber": "TACW70000000000", "firmwareVersion": "TAC1Z9118606710273::V1.6.9", "meterType": "V1"}]
  #[2, "4920116", "BootNotification", {"chargePointModel": "CDT_TACW7::NET_WIFI", "chargePointVendor": "ABB", "chargeBoxSerialNumber": "TACW70000000000", "chargePointSerialNumber": "TACW70000000000", "firmwareVersion": "TAC1Z9118606710273::V1.8.32", "meterType": "V1"}]
  $started_from_boot=0;
  %WALLBOX=%{$payload};
  $WALLBOX_VENDOR=$payload->{chargePointVendor};
  $WALLBOX_MODEL=$payload->{chargePointModel};
  $WALLBOX_METERTYPE=$payload->{meterType};
  $WALLBOX_SERIAL=$payload->{chargePointSerialNumber};
  if(length($WALLBOX_SERIAL)==0) { $WALLBOX_SERIAL=$payload->{chargeBoxSerialNumber}; }
  $WALLBOX_FIRMWARE=$payload->{firmwareVersion};
  $bootok=1;
  my $uuid=GenUUID();
  PushQueue("[2,\"$uuid\", \"TriggerMessage\", {\"requestedMessage\": \"StatusNotification\"}]","StatusNotification");
  $uuid=GenUUID();
  PushQueue("[2,\"$uuid\", \"GetConfiguration\", {\"key\": [\"SupportedFeatureProfiles\"]}]","GetConfiguration|ChangeConfiguration");
  if($GETCONF) {
    # All configuration keys requested, put in the queue
    $uuid=GenUUID();
    PushQueue("[2,\"$uuid\", \"GetConfiguration\", {}]");
  }
  foreach(@confkey) {
    # Set custom keys
    $uuid=GenUUID();
    my ($key,$data)=m/(\S+?):(.*)/;
    PushQueue("[2,\"$uuid\", \"ChangeConfiguration\", {\"key\": \"$key\", \"value\": \"$data\"}]");
  }
  DataLog("trans",Now($payload->{now}),"Boot",$payload->{chargePointModel},$payload->{chargePointVendor},$payload->{meterType},$payload->{chargeBoxSerialNumber},$payload->{firmwareVersion});
  MQTT_PublishBoot($wallbox,$payload);
  return("\"status\": \"Accepted\", ".
         "\"currentTime\": \"".ZuluR()."\", ".
         "\"interval\": 3600");
}

sub Heartbeat
{
  my ($payload,$sock)=@_;
  MQTT_PublishHeartbeat($wallbox,$payload);
  return("\"currentTime\": \"".ZuluR()."\"");
}

sub StatusNotification
{
  my ($payload,$sock)=@_;
  my ($status,$buffer,$now);
  $now=Now($payload->{now});
  $status=$payload->{status};

  if(length($payload->{connectorId})>0) { $connectorId=$payload->{connectorId}; }

  if($status=~m/SuspendedEV|Finishing|Stop/) {
    my $uuid=GenUUID();
    $buffer="[2,\"$uuid\", \"TriggerMessage\", {\"requestedMessage\": \"MeterValues\"}]";
    if($status eq "SuspendedEV") {
      $trigger_context="Transaction.Begin";
    }
    else {
      $trigger_context="Transaction.End";
    }
    PushQueue($buffer,"TriggerMessage.*MeterValues");
    $lastover=undef;
    $stopChargeTime=time();
  }

  if($status=~m/SuspendedEVSE/) {
    if($STATUS=~m/STOP|AVAIL/) { $canincrease=1; }
    $STATUS="SUSPEND";
    StopCharging();
  }
  elsif($status=~m/SuspendedEV/) {
    if($STATUS=~m/STOP|AVAIL/) { $canincrease=1; }
    $STATUS="STOPEV";
    StopCharging();
  }
  elsif($status=~m/Avail/) {
    # Avaiable status only valid when connectorId>=1, but ignore it since
    # there is "Finishing" status that is always present when connectorId=1
    if($connectorId>0) {
      $STATUS="AVAIL";
      $FORCE_STOP=0;
      if($SUBSTATUS=~m/SUSPEND/) {
	$SUBSTATUS=$laststop="";
	$START_SESSION=0;
	verbose(15,"AVAILABLE, resetting START_SESSION\n");
	if($MQTT_RESET_MAX_ENERGY) {
	  $MQTT_MAX_ENERGY_SESSION=undef;
	}
	$just_authorize=undef;
	undef($currTransaction);
	undef($currTransactionFull);
	if(length($currSub)>0) {
	  $backup_currSub=$currSub;
	}
	undef($currSub);
      }
      StopCharging();
    }
  }
  elsif($status=~m/Finish|Stop|Prepar/) {
    if($smartcharging==0) {
      # Charging stopped by RFID card or completed by EV: do not allow restart
      $smartcharging=-99;
    }
    if($status=~m/Prepar/) {
      # Set Charging to -1, to allow a prompt OBD data collection
      PreCharging();
    }
    else {
      StopCharging();
    }
    if($status=~m/Prepar/ && ($now-$just_authorize)<120) {
      # Only authorization, car not yet connected, do not change status
    }
    else {
      $STATUS="STOP";
    }
    if(!($status=~m/Finish/) && !($SUBSTATUS=~m/SUSPEND/)) {
      $START_SESSION=0;
      if($MQTT_RESET_MAX_ENERGY) {
	$MQTT_MAX_ENERGY_SESSION=undef;
      }
      undef($currTransaction);
      undef($currTransactionFull);
      if(length($currSub)>0) {
        $backup_currSub=$currSub;
      }
      undef($currSub);
    }
    undef($currSet);
    if($status=~m/Prepar/ && $AUTOSTART && !$FORCE_STOP) {
      # Wallbox does not support RFID, start automatically when plugged
      SmartStart();
    }
  }
  elsif($status=~m/Charg/) {
    $startChargeTime=time();
    $stopChargeTime=undef;
    if(length($trigger_context)==0) {
      my $uuid=GenUUID();
      $buffer="[2,\"$uuid\", \"TriggerMessage\", {\"requestedMessage\": \"MeterValues\"}]";
      $trigger_context="Transaction.Begin";
      PushQueue($buffer,"TriggerMessage.*MeterValues");
    }
    $STATUS="CHARGE";
    StartCharging($currSet);
  }
  else {
    $STATUS=$status;
  }
  if($STATUS eq "AVAIL") {
    $CONNSTATUS=0;
  }
  else {
    $CONNSTATUS=1;
  }
  MQTT_PublishStatus($wallbox,$payload);
  DataLog("trans",Now($payload->{now}),"Status",$status,$STATUS,$currTransactionFull);
  SaveConf();
  return("");
}

sub SecurityEventNotification
{
  my ($payload,$sock)=@_;
  MQTT_PublishSecurity($wallbox,$payload);
  return("");
}

sub ResetCounters
{
  my($i);
  $pvwh=0;
  $avgAsum=0;
  $avgAcount=0;
  $avgA=0;
  $avgCURsum=0;
  $avgCUR=0;
  @tswh=();
  @pvwh=();
  $hpvwh=$hfetchwh=$htotwh=0;
  $lasthour=-1;
  for($i=0;$i<=$#timeslot;$i++) { 
    $tswh[$i]=0;
    $pvwh[$i]=0;
  }
}

sub ResetSession
{
  my($i);
  $LAST_WH=$lastchgwh=$prevLAST_WH=0;
  $LAST_PV=0;
  $LAST_AVGACOUNT=$LAST_AVGASUM=0;
  $LAST_AVGCURCOUNT=$LAST_AVGCURSUM=0;
  $LAST_SPAN=0;
  @LAST_TSWH=();
  @LAST_PVWH=();
  for($i=0;$i<=$#timeslot;$i++) { 
    $LAST_TSWH[$i]=0;
    $LAST_PVWH[$i]=0;
  }
}

sub StartTransaction
{
  my ($payload,$sock)=@_;
  my ($newset,$localstart);
  verbose(15,"STARTTRANSACTION: $TRANSACTION ($currSub // $currTransaction // $currTransactionFull) $LAST_WH ($prevLAST_WH) $LAST_SPAN\n");
  $started_from_boot++ if($started_from_boot>=0);
  $START_TIME=Now($payload->{now});
  if($USE_STOP_AS_SUSPEND || $STATUS ne "SUSPEND") {
    StartCharging($currSet);
  }
  else {
    PreCharging();
  }
  if(length($currTransaction)==0 || !($SUBSTATUS=~m/SUSPEND/)) {
    $TRANSACTION++;
    $START_SESSION=$START_TIME;
    $currTransaction=$TRANSACTION;
    $backup_currSub=$currSub;
    $currSub=undef;
    SetTransactionFull();
  }
  $localstart=0;
  if(defined($payload->{meterStart})) {
    $localstart=$meterStart=$GLOBAL_WH=$payload->{meterStart};
  }
  elsif($GLOBAL_ENERGY && $LAST_WH>0 && !($SUBSTATUS=~m/SUSPEND/)) {
    # Missing TransactionEnd, set now GLOBAL_WH
    if($absolute_wh>$GLOBAL_WH) {
      $GLOBAL_WH=$absolute_wh;
    }
    else {
      $GLOBAL_WH+=$LAST_WH;
    }
    $localstart=$GLOBAL_WH;
  }

  MQTT_PublishStart($wallbox,$payload);

  my (@sample,$i,$la,$context,$localstart);
  $context="Transaction.Begin-StartTransaction";
  $la=$currLActive;
  if($la<1) { $la=1; }
  for($i=1;$i<=$la;$i++) {
    push(@sample,{measurand=>"Voltage", value=>ActVolt($i), phase=>"L${i}-N", unit=>"V", context=>"$context", format=>"Raw"});
    push(@sample,{measurand=>"Current.Import", value=>0, phase=>"L$i", unit=>"A", context=>"$context", format=>"Raw"});
    if($la>1) {
      push(@sample,{measurand=>"Current.Offered", value=>$currOffered, phase=>"L$i", unit=>"A", context=>"$context", format=>"Raw"});
    }
  }
  if($la<=1) {
    push(@sample,{measurand=>"Current.Offered", value=>$currOffered, unit=>"A", context=>"$context", format=>"Raw"});
  }
  push(@sample,{measurand=>"Energy.Active.Import.Register", value=>$localstart, unit=>"Wh", context=>"$context", format=>"Raw"});
  push(@sample,{measurand=>"Power.Active.Import", value=>0, unit=>"W", context=>"$context", format=>"Raw"});
  # Some wallboxes does not send MeterValues on Trigger, simulate here:
  MeterValues({connectorId=>$connectorId, transactionId=>$payload->{transactionId},
    meterValue => [{timestamp=>$payload->{timestamp}, sampledValue => \@sample
    }]},$sock);

  if($SUBSTATUS=~m/SUSPEND/) {
    $prevLAST_WH=$LAST_WH;
    $SUBSTATUS="SUSPENDSTART";
  }
  else {
    ResetSession();
  }
  if($USE_STOP_AS_SUSPEND) {
    # Set anyway the substatus as suspend for wallboxes that stop
    # the transaction if too few power was set (e.g. Huawei)
    $SUBSTATUS="SUSPENDSTART";
    #if($STATUS eq "STOP") { # No more needed, use to avoi showing SUSPENDSTART in log
    #  $SUBSTATUS="SUSPEND";
    #}
  }
  $lastSet=$currSet=-1;
  $avgAlasttime=0;
  $avgW=0;
  ResetCounters();
  $lastover=undef;
  if($smartcharging<0) { $smartcharging=0; }

  $STARTTAG="";
  if(length($payload->{idTag})>0)
  {
    if(length($TAG)==0) { $TAG=$payload->{idTag}; }
    $STARTTAG=$payload->{idTag};
  }
  SaveConf();

  $transaction_started=$MAXPOWER;
  DataLog("trans",Now($payload->{now}),"Start",$payload->{idTag},$TRANSACTION,$meterStart);
  if($FIXED!=0 && $GRID_LIMIT>0) {
    # Limit the maximum current to the actual grid limit
    my $newOffered=Ampere($FIXED);
    my $power=Power($FIXED,ActVoltWallbox())-PowerOffered();
    if(($currPower+$power)>($GRID_LIMIT-$GRID_LIMIT_TOLERANCE)) {
      my $co=CurrOfferedFull();
      verbose(17,"START -- GL=$GRID_LIMIT, CP=$currPower, CO=$co, V=".MaxActVolt().", AddP=$power\n");
      my $newPower=intPower($GRID_LIMIT-$currPower+PowerOffered()-$GRID_LIMIT_TOLERANCE);
      if($newPower<($WBMINPOWER*ActVoltWallbox())) {
        $newPower=intPower(WallboxCurrAdd($WBMINPOWER)*ActVoltWallbox());
      }
      $newOffered=TruncFineStep(($GRID_LIMIT-$currPower)/MaxActVolt()+1+CurrOffered());
      if($newOffered<$WBMINPOWER) {
	$newOffered=$WBMINPOWER;
      }
      NewOffered($newOffered,$newPower,$TRANSACTION,1);
      $newset=1;
    }
  }
  if(!$newset) {
    # Set anyway the limit on current transaction, because some wallboxes (Huawei) will
    # use default limit
    if($FIXED>0) {
      NewOffered($FIXED,PowerWallbox($FIXED),$TRANSACTION,1);
    }
    else {
      if($lastSet<=0) {
	$lastSet=$deflimit;
      }
      if($powerSet<=0) {
        $powerSet=$defpower;
	if($powerSet<=0) {
	  $powerSet=PowerWallbox($lastSet);
	}
      }
      if($lastSet>=$WBMINPOWER) {
        NewOffered($lastSet,$powerSet,$TRANSACTION,1);
      }
    }
  }
  return("\"transactionId\": $TRANSACTION, ".
         "\"idTagInfo\": {".
           "\"status\": \"Accepted\", ".
	   "\"expiryDate\": \"".ZuluR(time()+24*60*60*30)."\"".
	 "}");
}

sub CheckStop
{
  if($STATUS eq "STOP" || $STATUS eq "AVAIL") {
    return(1);
  }
  return(0);
}

sub CheckTag
{
  my $enable=shift;
  #verbose(5,"ENABLE=$enable, TAG=$TAG ($card{$TAG})\n");
  if(length($MQTT_TAG)>0) {
    $TAGPROFILE=$MQTT_TAG;
  }
  else {
    $TAGPROFILE=$TAG;
  }
  if($enable eq "1" || $enable eq "ALL") { return(1); }
  if(index(",$enable,",",$TAGPROFILE,")>=0) { return(1); }
  if(index(",$enable,",",$card{$TAGPROFILE},")>=0) { return(1); }
  return(0);
}

sub CheckPresence
{
  my $smart=shift;
  my (@params)=@_;
  my ($i);
  #verbose(3,"K=".join(" # ",keys(%{$smart}))."\n");
  for($i=0;$i<=$#params;$i++) {
    #verbose(4,"PAR=$params[$i] VAL=$smart->{$params[$i]}\n");
    if(defined($smart->{$params[$i]}) && length($smart->{$params[$i]})>0) {
      return(1);
    }
  }
  return(0);
}

sub Authorize
{
  my ($payload,$sock)=@_;
  my $lasttag="$TAG";
  my $status="Accepted";
  my $allow=1;
  if($ALLOW_ONLY_DEFINED_CARDS) {
    # Check if the card is allowed:
    if(!defined($card{$payload->{idTag}})) {
      $allow=0;
    }
  }
  if($allow) {
    $TAG=$payload->{idTag};
    $just_auhtorize=Now($payload->{now});
    if(length($lasttag)>0 && $TAG ne $lasttag && !CheckStop()) {
      # Since RFID cards are only used to change the charge profile,
      # refuse the autorization if the tag is different from the
      # previous and the charging status is not stopped (EV disconnected
      # or charging stopped by EVSE)
      $status="Blocked";
    }
    if($smartcharging<=0) {
      if(CheckStop()) {
	if($FIXED==0 || $USE_STOP_AS_SUSPEND) {
	  # Do not allow start charging when smartcharging not supported and
	  # charging disabled (otherwise it will start for few seconds and then
	  # you should stop)
	  $status="Blocked";
	}
	$smartcharging=0;
      }
      elsif($STATUS eq "CHARGE") {
	if($TAG eq $lasttag) {
	  # If charging is stopped by RFID card, do not restart it.
	  # Usually WallBox does not requires "Authorize" if the tag
	  # is the same of the StartTransaction one, but just in case
	  # place the code here.
	  $smartcharging=-98;
	}
      }
    }
  }
  else {
    $status="Blocked";
    verbose(5,"RFID $payload->{idTag} not authorized\n");
  }
  DataLog("trans",Now($payload->{now}),"Auth",$payload->{idTag},$STATUS,$status,$smartcharging);
  return("\"idTagInfo\": {".
           "\"status\": \"$status\", ".
	   "\"expiryDate\": \"".ZuluR(time()+24*60*60*30)."\"".
	 "}");
}

sub WallboxLimitZero
{
  my ($curr,$power,$wzero);
  $curr=$power=0;
  $wzero=WallboxParam("WALLBOX_SET_LIMIT_ZERO_ON_STOP");
  if($wzero ne "1") {
    $curr=$wzero;
    $power=Power($wzero,MinActVolt());
  }
  return(($curr,$power));
}

sub StopTransaction
{
  #2025-12-20 08:09:31.195936 - [RX0] <= [2, "6724646", "StopTransaction", {"meterStop": 25299, "idTag": "878E33E4", "timestamp": "2025-12-20T07:09:27.000Z", "transactionId": 213, "reason": "EVDisconnected"}]
  my ($payload,$sock)=@_;
  if(length($payload->{idTag})>0 && length($TAG)==0) { $TAG=$payload->{idTag}; }
  DataLog("trans",Now($payload->{now}),"Stop",$payload->{idTag},$payload->{reason},$payload->{meterStop},$payload->{transactionId},$currTransactionFull);

  if(WallboxParam("WALLBOX_SET_LIMIT_ZERO_ON_STOP")) { DefaultLimit(WallboxLimitZero(),1000); }
  elsif($FIXED==0 && $deflimit!=MinDefLimit()) { DefaultLimit(0,0); }

  $laststop=$payload->{reason};
  if(($laststop=~m/Local/i) && !$stopremote) {
    # ABB Terra AC sometimes sends reason "EVDisconnected" instead of "Remote".
    # Test only "Local" (RFID card passed for stop) reason as valid to reset
    # SUBSTATUS (old reasons $laststop=~m/Remote|Other/)
    #
    # Check if the transaction was stopped by RFID card:
    if(length($payload->{idTag})>0 && $payload->{idTag} eq $STARTTAG && defined($card{$STARTTAG})) {
      verbose(10,"Resetting START_SESSION ($laststop // $stopremote)\n");
      $SUBSTATUS="";
    }
  }
  $stopremote=0;
  MQTT_PublishStop($wallbox,$payload);
  StopCharging();

  my (@sample,$i,$la,$context);
  $context="Transaction.End-StopTransaction";
  $la=$currLActive;
  if($la<1) { $la=1; }
  for($i=1;$i<=$la;$i++) {
    push(@sample,{measurand=>"Voltage", value=>ActVolt($i), phase=>"L${i}-N", unit=>"V", context=>"$context", format=>"Raw"});
    push(@sample,{measurand=>"Current.Import", value=>0, phase=>"L$i", unit=>"A", context=>"$context", format=>"Raw"});
    if($la>1) {
      push(@sample,{measurand=>"Current.Offered", value=>$currOffered, phase=>"L$i", unit=>"A", context=>"$context", format=>"Raw"});
    }
  }
  if($la<=1) {
    push(@sample,{measurand=>"Current.Offered", value=>$currOffered, unit=>"A", context=>"$context", format=>"Raw"});
  }
  push(@sample,{measurand=>"Energy.Active.Import.Register", value=>$payload->{meterStop}, unit=>"Wh", context=>"$context", format=>"Raw"});
  push(@sample,{measurand=>"Power.Active.Import", value=>0, unit=>"W", context=>"$context", format=>"Raw"});
  # Some wallboxes does not send MeterValues on Trigger, simulate here:
  MeterValues({connectorId=>$connectorId, transactionId=>$payload->{transactionId},
    meterValue => [{timestamp=>$payload->{timestamp}, sampledValue => \@sample
    }]},$sock);

  if(!($SUBSTATUS=~m/SUSPEND/)) {
    $MQTT_STARTED=0;
    $START_SESSION=0;
    if($MQTT_RESET_MAX_ENERGY) {
      $MQTT_MAX_ENERGY_SESSION=undef;
    }
    undef($currTransaction);
    undef($currTransactionFull);
    undef($currSet);
    undef($currSub);
    undef($backup_currSub);
  }
  else {
    $SUBSTATUS="SUSPEND";
  }
  SaveConf();
  return(
         "\"idTagInfo\": {".
           "\"status\": \"Accepted\", ".
	   "\"expiryDate\": \"".ZuluR(time()+24*60*60*1)."\"".
	 "}");
}

sub SaveHour {
  my($time)=@_;
  if($htotwh!=0) {
    if(length($hour_log)>0) {
      if(open(PV,">>$hour_log"))
      {
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(int($time));
	$year+=1900;
	$mon++;
	if(length($lastenergyT)==0) { $lastenergyT=$TRANSACTION; }
	print PV sprintf("%04d%02d%02d-%02d\t%s\t%s\t%s\t%s\n",$year,$mon,$mday,$hour,$lastenergyT,Float0($htotwh*0.001),Float0($hpvwh*0.001),Float0($hfetchwh*0.001));
	close(PV);
      }
    }
  }
  $hpvwh=$htotwh=$hfetchwh=0;
}

sub UpdatePVEnergy
{
  my($now,$power,$end)=@_;
  my($avgpower,$t1,$t2,$spanwh,$sec,$wday,$hour,$pvenergy,$fetchenergy);
  ($sec,$wday,$hour)=SecWDayHour($now);
  $timeslot=TimeSlot($sec,$wday);

  if($lasthour>=0 && $lasthour!=$hour) {
    SaveHour($lastpvtime);
  }
  $lasthour=$hour;
  $lastpvtime=$now;

  # Try to interpolate Photovoltaic energy used by EVSE :
  # current power used for charging - current power fetch from grid (if positive)
  #if($lastgridtime<$START_TIME) { $lastgridtime=$START_TIME; }
  #if($lastPowertime<$lastgridtime) { $lastPowertime=$lastgridtime; }
  #if($pvwh>0 && $now>$lastgridtime) {
  #  my $t1=abs($now-$lastPowertime);
  #  my $t2=abs($lastPowertime-$lastgridtime);
  #  $avgpower=($power*$t2+$lastgrid*$t1)/($t1+$t2);
  #  if($t1<=$t2)
  #  {
  #    if($power>=$lastgrid) {
  #	$avgpower=$power;
  #    }
  #  }
  #  else
  #  {
  #    if($lastgrid>=$power) {
  #	$avgpower=$lastgrid;
  #    }
  #  }
  #}
  #else 
  #{
  #  if($power>$lastgrid) { $avgpower=$power; }
  #  else { $avgpower=$lastgrid; }
  #}

  # Simplify the power calculation, since it is usually only
  # few Wh difference:

  if($power>$lastgrid || $hpvwh>0) {
    $avgpower=$power;
  }
  else {
    $avgpower=$lastgrid;
  }

  if($lastPower>0 && $avgpower<$lastPower) {
    if($avgpower>0) {
      $fetchpower=$avgpower;
      $avgpower=$lastPower-$avgpower;
    }
    else {
      $fetchpower=0;
      $avgpower=$lastPower;
    }
  }
  else {
    if($lastPower>0) { $avgpower=0; }
    $fetchpower=$lastPower;
  }

  my $currwh=$lastWh-$lastchgwh;
  $lastchgwh=$lastWh;
  if($lastPower>0) {
    $pvenergy=$currwh*$avgpower/$lastPower;
    $fetchenergy=$currwh*$fetchpower/$lastPower;
  }
  else {
    if($avgpower>0 || $hfetchwh>=$hpvwh) {
      $fetchenergy=$currwh;
      $pvenergy=0;
    }
    else {
      $fetchenergy=0;
      $pvenergy=$currwh;
    }
  }

  $hpvwh+=$pvenergy;
  $hfetchwh+=$fetchenergy;
  $htotwh+=$currwh;

  #my $pvlast=$avgpower*($now-$lastgridtime)/3600;
  $pvwh+=$pvenergy;
  $pvwh[$timeslot]+=$pvenergy;
  $tswh[$timeslot]+=$fetchenergy;

  $lastenergyT=$currTransactionFull;
  if($end || $end eq "END") { SaveHour($lastpvtime); }

}

#3-phases (https://github.com/lbbrhzn/ocpp/issues/19):
# Log Home Assistant..
#2021-06-21 18:14:32 INFO (MainThread) [ocpp] CH1Beheer: send [3,"220",{}]
#2021-06-21 18:15:02 INFO (MainThread) [ocpp] CH1Beheer: receive message [2,"221","Heartbeat",{}]
#2021-06-21 18:15:02 INFO (MainThread) [ocpp] CH1Beheer: send [3,"221",{"currentTime":"2021-06-21T16:15:02.648607"}]
#2021-06-21 18:15:28 INFO (MainThread) [ocpp] CH1Beheer: receive message [2,"222","MeterValues",{"connectorId":1,"transactionId":9223372036854766666,
# "meterValue":[{"timestamp":"2021-06-21T16:15:09Z","sampledValue":[
#   {"value":"1305570.000","context":"Sample.Periodic","measurand":"Energy.Active.Import.Register","location":"Outlet","unit":"Wh"},
#   {"value":"0.000","context":"Sample.Periodic","measurand":"Current.Import","location":"Outlet","unit":"A","phase":"L1"},
#   {"value":"0.000","context":"Sample.Periodic","measurand":"Current.Import","location":"Outlet","unit":"A","phase":"L2"},
#   {"value":"0.000","context":"Sample.Periodic","measurand":"Current.Import","location":"Outlet","unit":"A","phase":"L3"},
#   {"value":"16.000","context":"Sample.Periodic","measurand":"Current.Offered","location":"Outlet","unit":"A"},
#   {"value":"50.010","context":"Sample.Periodic","measurand":"Frequency","location":"Outlet"},
#   {"value":"0.000","context":"Sample.Periodic","measurand":"Power.Active.Import","location":"Outlet","unit":"W"},
#   {"value":"0.000","context":"Sample.Periodic","measurand":"Power.Active.Import","location":"Outlet","unit":"W","phase":"L1"},
#   {"value":"0.000","context":"Sample.Periodic","measurand":"Power.Active.Import","location":"Outlet","unit":"W","phase":"L2"},
#   {"value":"0.000","context":"Sample.Periodic","measurand":"Power.Active.Import","location":"Outlet","unit":"W","phase":"L3"},
#   {"value":"0.000","context":"Sample.Periodic","measurand":"Power.Factor","location":"Outlet"},
#   {"value":"38.500","context":"Sample.Periodic","measurand":"Temperature","location":"Body","unit":"Celsius"},
#   {"value":"228.000","context":"Sample.Periodic","measurand":"Voltage","location":"Outlet","unit":"V","phase":"L1-N"},
#   {"value":"227.000","context":"Sample.Periodic","measurand":"Voltage","location":"Outlet","unit":"V","phase":"L2-N"},
#   {"value":"229.300","context":"Sample.Periodic","measurand":"Voltage","location":"Outlet","unit":"V","phase":"L3-N"},
#   {"value":"395.900","context":"Sample.Periodic","measurand":"Voltage","location":"Outlet","unit":"V","phase":"L1-L2"},
#   {"value":"396.300","context":"Sample.Periodic","measurand":"Voltage","location":"Outlet","unit":"V","phase":"L2-L3"},
#   {"value":"398.900","context":"Sample.Periodic","measurand":"Voltage","location":"Outlet","unit":"V","phase":"L3-L1"}
# ]}]}]

#3-phases Huawei, connected to single phase:
#[2,"697374760000025d0255","MeterValues",{"connectorId":1,"transactionId":23,"meterValue":
#[{"timestamp":"2026-01-23T13:15:34.000Z","sampledValue":
#[
#{"value":"0.00","context":"Transaction.Begin","measurand":"Current.Import","phase":"L1","unit":"A"},
#{"value":"0.00","context":"Transaction.Begin","measurand":"Current.Import","phase":"L2","unit":"A"},
#{"value":"0.00","context":"Transaction.Begin","measurand":"Current.Import","phase":"L3","unit":"A"},
#{"value":"6.00","context":"Transaction.Begin","measurand":"Current.Offered","phase":"L1","unit":"A"},
#{"value":"0.00","context":"Transaction.Begin","measurand":"Current.Offered","phase":"L2","unit":"A"},
#{"value":"0.00","context":"Transaction.Begin","measurand":"Current.Offered","phase":"L3","unit":"A"},
#{"value":"108.09","context":"Transaction.Begin","measurand":"Energy.Active.Import.Register","unit":"kWh"},
#{"value":"0.00","context":"Transaction.Begin","measurand":"Power.Active.Import","unit":"kW"},
#{"value":"1.36","context":"Transaction.Begin","measurand":"Power.Offered","unit":"kW"},
#{"value":"28.04","context":"Transaction.Begin","measurand":"Temperature","location":"Body","unit":"Celsius"},
#{"value":"125.41","context":"Transaction.Begin","measurand":"Voltage","phase":"L1-N","unit":"V"},
#{"value":"0.00","context":"Transaction.Begin","measurand":"Voltage","phase":"L2-N","unit":"V"},
#{"value":"0.00","context":"Transaction.Begin","measurand":"Voltage","phase":"L3-N","unit":"V"}]}]}]

#Single phase (ABB Terra AC):
#2023-11-27 23:46:57.155358 - [RX] <= [2, "5124128", "MeterValues", {"connectorId": 1, "transactionId": 39, 
# "meterValue": [{"timestamp": "2023-11-27T22:46:56.000Z", "sampledValue": [
#   {"value": "225.60", "context": "Sample.Periodic", "format": "Raw", "measurand": "Voltage", "phase": "L1-N", "unit": "V"},
#   {"value": "12.31", "context": "Sample.Periodic", "format": "Raw", "measurand": "Current.Import", "phase": "L1", "unit": "A"},
#   {"value": "2692", "context": "Sample.Periodic", "format": "Raw", "measurand": "Power.Active.Import", "phase": "L1", "unit": "W"}, 
#   {"value": "264", "context": "Sample.Periodic", "format": "Raw", "measurand": "Energy.Active.Import.Register", "unit": "Wh"}, 
#   {"value": "13", "context": "Sample.Periodic", "format": "Raw", "measurand": "Current.Offered", "unit": "A"}
# ]}]}]

#Clock Aligned Meter Data (global energy):
#[2, "9052506", "MeterValues", {"connectorId": 1, 
# "meterValue": [{"timestamp": "2025-12-26T23:54:00.000Z", "sampledValue": [
#   {"value": "2939167", "context": "Sample.Clock", "format": "Raw", "measurand": "Energy.Active.Import.Register", "location": "Inlet"}
# ]}]
#}]

sub MeterValues
{
  my ($payload,$sock)=@_;
  my $sample=$payload->{meterValue}[0]{sampledValue};
  my (@volt,@phase,@vref,$voltc,@current,@cref,$currentc,$currentact,$now,$volt,$volt3,$volt1c,$volt3c,$current,@power,$power,$powerall,$powerc,$kwh,$currkwh,$wh,$offered,$meas,$value,$phase,$context,$onlycontext,$cavg,%measure,$line,$frequency,$temperature,$power_factor,$unit,$offeredc,@offered,$offeredact,$powerOffered);
  my (@currentdis,@powerdis,$addcontext);

  my $timestamp=$payload->{meterValue}[0]{timestamp};
  my ($y3,$m3,$d3,$hh,$mm,$ss)=($timestamp=~m/(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)/);
  my $metertime=timegm($ss,$mm,$hh,$d3,$m3-1,$y3);

  $now=Now($payload->{now});

  if(abs($metertime-$now)<60) { $metertime=$now; }


  foreach(@{$sample})
  {
    if(length($_->{context})) { $context=$_->{context}; }
    $meas=$_->{measurand};
    $value=$_->{value};
    $phase=$_->{phase};
    $unit=$_->{unit};
    if($unit=~/mA/i) { $value*=0.001; }
    elsif($unit=~/mV/i) { $value*=0.001; }
    elsif($unit=~/kW/i) { $value*=1000; }

    $line=substr($phase,0,2);
    if($meas eq "Voltage") {
      if($value>10) {
        # Take only used phases
	$volt[$voltc]=$value; 
	if($phase=~m/L.*L/) {
	  $measure{$line}{voltage3phase}=$value+0.0;
	  $volt3+=$value;
	  $volt3c++;
	}
	else {
	  $measure{$line}{voltage}=$value+0.0;
	  $volt+=$value;
	  $volt1c++;
	}
	$voltc++;
      }
    }
    elsif($meas eq "Current.Import") { 
      $measure{$line}{current}=$value+0.0;
      $current[$currentc]=$value;
      if($value>0) { 
        $currentact++;
	push(@currentdis,$value);
      }
      $current+=$value;
      $currentc++;
    }
    elsif($meas eq "Power.Active.Import") { 
      if($phase eq "") {
        $powerall=$value;
      }
      else {
        $measure{$line}{power}=MQTT_Power($value+0.0);
	$power[$powerc]=$value;
	if($phase=~m/L/) {
	  $power+=$value;
	  if($value>0) {
	    push(@powerdis,$value);
	  }
	}
	$powerc++;
      }
    }
    elsif($meas eq "Energy.Active.Import.Register") { 
      $absolute_wh=$value;
      if($GLOBAL_ENERGY || $meterStart>0) {
        if($GLOBAL_WH==0) {
	  # Not yet initialized, do it now
	  if($value>10) {
	    $GLOBAL_WH=$value-10;
	  }
	  else {
	    $GLOBAL_WH=0.01;
	  }
	  SaveConf();
	}
        if($value>=$GLOBAL_WH) {
          $value-=$GLOBAL_WH;
        }
	else {
	  # Some wallboxes could return meterStop less than meterStart
	  $value=0;
	}
      }
      elsif($USE_STOP_AS_SUSPEND || $smartcharging<=0) {
        if($START_TIME>0) {
          $value+=$LAST_WH;
	}
	else {
          $value+=$prevLAST_WH;
	}
      }
      $wh=$value;
      $measure{energy_session}=MQTT_Energy($value+0.0);
      if($wh!=$absolute_wh) {
        $measure{energy_global}=MQTT_Energy($absolute_wh+0.0);
	$globalwh=$absolute_wh;
        MQTT_PublishLimit($wallbox,{});
      }
      $kwh=sprintf("%0.3f",$wh*0.001);
    }
    elsif($meas eq "Power.Offered") {
      $powerOffered=$value+0.0;
      $measure{power_offered}=MQTT_Power($value);
    }
    elsif($meas eq "Current.Offered") {
      if(length($line)>0) {
        $measure{$line}{offered}=$value+0.0;
      }
      $offered[$offeredc]=$value;
      if($value>0) { $offeredact++; }
      $offered+=$value;
      $offeredc++;
    }
    elsif($meas eq "Frequency") { 
      $frequency=$value;
      $measure{frequency}=$value+0.0;
    }
    elsif($meas eq "Power.Factor") { 
      $power_factor=$value;
      $measure{power_factor}=$value+0.0;
    }
    elsif($meas eq "Temperature") { 
      $temperature=$value;
      $measure{temperature}=$value+0.0;
    }
  }
  if($currentact==0) { 
    if($offeredact>0) { $currentact=$offeredact; }
    elsif($currLActive>0) { $currentact=$currLActive; }
    else { $currentact=1; }
  }
  if($voltc>1) {
    if($volt1c>1) { $volt=$volt/$volt1c; }
    if($volt3c>1) { $volt3=$volt3/$volt3c; }
  }
  if($currentact>1) { $current=$current/$currentact; }
  if($powerall>$power) {
    $power=$powerall;
  }
  if($#powerdis<=0) {
    $powerdis[0]=$power;
  }
  if($#currentdis<=0) {
    $currentdis[0]=$current;
  }
  if($offeredact==0) { $offeredact=1; }
  if($offeredact>1) { $offered=$offered/$offeredact; }
  $measure{offered}=$offered+0.0;
  #if($currOffered>$currSet) { $currSet=$currOffered; } # Could collide when decreasing, disabling
  my $ver=20;
  if(abs($metertime-$now)>120) { $timestamp=" $timestamp"; }
  else { $timestamp=""; }
  $onlycontext=$context;
  if($onlycontext eq "Trigger" && length($trigger_context)>0) {
    $onlycontext=$trigger_context."-".$onlycontext;
    $addcontext="-$trigger_context";
    $trigger_context="";
  }
  if($context=~m/Sample.Clock/i) {
    # Global kWh, special handling/log
    if($absolute_wh!=$globalwh) {
      $kwh=sprintf("%.3f",$absolute_wh*0.001);
      $globalwh=$absolute_wh;
      if($STATUS ne "CHARGE") { $ver=6; }
      verbose($ver,"LIFETIME kWh=$kwh\n");
      MQTT_PublishLimit($wallbox,{});
      if(!($STATUS=~m/CHARGE|SUSPEND/)) {
        # Update fields, if present
	if(length($volt)>0) {
          $lastmeasure{voltage}=sprintf("%.1f",$volt)+0;
	}
	if(length($temperature)>0) {
          $lastmeasure{temperature}=$temperature+0;
	}
        MQTT_PublishSession($wallbox,\%lastmeasure);
      }
    }
  }
  else {
    $currOffered=$offered;
    if($context=~m/Sample\.Periodic/i) { $onlycontext=$context=undef; }
    elsif(length($context)>0) { $context=" -- $context"; }
    if($lastOffered!=$offered || $lastPower!=$power || $lastWh!=$wh)
    {
      $ver=7;
    }
    elsif(length($timestamp)>0 || length($context)>0) {
      $ver=6;
    }
    #verbose(13,"lastWh=$lastWh, wh=$wh, ver=$ver, pn=$payload->{now}, now=$now, meter=$metertime, ".scalar(localtime($now))."\n");
    if(WallboxParam("WALLBOX_USE_METER_VOLTAGE")>0 && 
       abs(ActVolt()-$volt) > (ActVolt()*WallboxParam("WALLBOX_USE_METER_VOLTAGE")*0.01)) {
      $wallbox_currVolt=ActVolt();
    }
    else {
      $wallbox_currVolt=$currVolt=$volt;
    }
    $currLActive=$currentact;
    $volt=sprintf("%.1f",$volt);
    $lastPower=$power; 
    $lastCurrent=$current; 
    $lastPowertime=$metertime; 
    $lastWh=$wh; 
    if($power>0 && $offered>0 && $STATUS ne "CHARGE" && ($context=~m/Sample/)) {
      $checkcoherent++;
      if($checkcoherent>3) {
	# To recover from restart ocpp.pl or broken connection
	verbose(3,"WARNING: status ($STATUS) not coherent with power ($power) and offered ($offered), change to CHARGE\n");
	$STATUS="CHARGE";
	StartCharging($offered);
	$currSub=$backup_currSub;
      }
    }
    # Some wallboxes (e.g. Huawei) do not send SuspendedEV when battery is full.
    # Detect this case: power=0 with currSet>0 while STATUS=CHARGE for more than 2 minutes.
    elsif($power==0 && ($offered>0 || $currSet>0) && $STATUS eq "CHARGE" && $START_TIME>0 && ($now-$START_TIME)>120) {
      $checkcoherent++;
      if($checkcoherent>3) {
	# In case we miss SuspendedEV event or bug in handling Trigger message
	verbose(3,"WARNING: charging with 0 power, switching to STOPEV\n");
	$STATUS="STOPEV";
	StopCharging();
      }
    }
    else {
      $checkcoherent=0;
    }
    if($START_TIME>0 && $STATUS ne "CHARGE" && $STATUS ne "Updating")
    {
      if(length($currTransaction)==0) {
	$currTransaction=$currTransactionFull=$TRANSACTION;
	$backup_currSub=$currSub;
	$currSub=undef;
      }

      UpdatePVEnergy($now,$lastgrid,"END");

      my $timelimit=120;
      if($context=~m/Transaction.End/) {
	$timelimit=12;
      }
      if(($metertime-$stopChargeTime)<$timelimit) { $metertime=$stopChargeTime; }

      $LAST_SPAN+=$metertime-$START_TIME;
      $LAST_AVGASUM+=$avgAsum;
      $LAST_AVGACOUNT+=$avgAcount;
      $LAST_AVGCURSUM+=$avgCURsum;
      $LAST_PV+=$pvwh;
      for(my $i=0;$i<=$#timeslot;$i++) { 
	$LAST_TSWH[$i]+=$tswh[$i];
	$LAST_PVWH[$i]+=$pvwh[$i];
      }
      LogTrans($currTransactionFull,$START_TIME,$metertime,$LAST_SPAN,$LAST_WH,$wh,$avgA,$pvwh,$avgCUR);
      # $wh-$LAST_WH/$pvwh
      if(($wh-$LAST_WH)>0) {
	$currSub++;
      }
      $START_TIME=0;
      $prevLAST_WH=$LAST_WH;
      $lastchgwh=$LAST_WH=$wh;
      if($LAST_WH==0) {
	# StartTransaction could arrive when current limit is set to 0.
	# Check if we have some Wh, otherwise reset $START_SESSION:
	verbose(11,"LAST_WH==0, resetting START_SESSION\n");
	$START_SESSION=0;
      }
      if(($GLOBAL_ENERGY || $meterStart>0)&& !($SUBSTATUS=~m/SUSPEND/)) {
	if(CheckStop() || $context=~m/Transaction.End/) {
	  $GLOBAL_WH=$absolute_wh;
	  $lastchgwh=$LAST_WH=$prevLAST_WH=0;
	}
      }
      ResetCounters();
      SaveConf();
    }
    if($payload->{transactionId}>0) { 
      if($currTransaction ne $payload->{transactionId}) {
	$currTransaction=$payload->{transactionId}; 
	SetTransactionFull();
      }
    }
    if($currTransaction>0) {
      if($START_TIME==0 && $STATUS eq "CHARGE" && ($wh!=$LAST_WH || $context=~m/Transaction.Begin/i)) {
	# Set new transaction
	$START_TIME=$metertime;
	if(($START_TIME-$startChargeTime)<120) { $START_TIME=$startChargeTime; }
	if($START_SESSION==0) {
	  verbose(15,"START_SESSION==0, setting as START_TIME ($START_TIME)\n");
	  $START_SESSION=$START_TIME;
	}
	ResetCounters();
	SetTransactionFull();
	$avgAlasttime=$START_TIME;
	$avgA=$offered;
	$avgCUR=$current;
	$avgW=$current*ActVoltWallbox();
	if($currTransaction>$TRANSACTION) {
	  verbose(3,"WARNING: Transaction counter ($TRANSACTION) lower than current transaction ($currTransaction), fixing\n");
	  $TRANSACTION=$currTransaction;
	  # Reset WH counter, missing start transaction
	  ResetSession();
	}
	elsif($LAST_WH==0) {
	  ResetSession();
	}
	$lastchgwh=$LAST_WH;
	verbose(5,"Starting new charging ($LAST_WH, $LAST_SPAN -- $START_SESSION)\n");
	SaveConf();
      }
      if($metertime>$START_TIME) {
	# Update ampere AVG
	if($avgAlasttime>0 && $avgAcount>0) {
	  $avgAsum+=($metertime-$avgAlasttime)*$offered;
	  $avgAcount+=($metertime-$avgAlasttime);
	  $avgA=$avgAsum/$avgAcount;
	  $avgCURsum+=($metertime-$avgAlasttime)*$current;
	  $avgCUR=$avgCURsum/$avgAcount;
	}
	else {
	  $avgAcount=1;
	  $avgA=$avgAsum=$offered;
	  $avgCUR=$avgCURsum=$current;
	}
	$avgAlasttime=$metertime;
	$avgW=($wh-$LAST_WH)*3600/($metertime-$START_TIME);
      }
    }
    if($lastOffered!=$offered || $lastlastOffered==$lastOffered)
    {
      if($canincrease<-1) { $canincrease++; }
      else { $canincrease=1; }
    }
    verbose(13,"o=$offered lo=$lastOffered llo=$lastlastOffered => $canincrease (WBMINPOWER=$WBMINPOWER)\n");
    $lastlastOffered=$lastOffered;
    $lastOffered=$offered;

    if($avgA>0) {
      $cavg=sprintf(" Avg=%.2fA/%.2fkW",$avgA,$avgW*0.001);
      if($cavg ne $lastavgcontext) {
	$context="$cavg$context";
	$lastavgcontext=$cavg;
      }
    }
    $measure{energy}=MQTT_Energy($wh-$LAST_WH);
    $measure{energy_pv}=MQTT_Energy(POSIX::round($pvwh));
    $measure{energy_grid}=$measure{energy}-$measure{energy_pv};
    $measure{energy_session_pv}=MQTT_Energy(POSIX::round($pvwh+$LAST_PV));
    $measure{energy_session_grid}=$measure{energy_session}-$measure{energy_session_pv};
    if($measure{energy}>0) {
      $measure{energy_pvperc}=sprintf("%.1f",$measure{energy_pv}*100.0/$measure{energy})+0.0;
    }
    if($measure{energy_session}>0) {
      $measure{energy_session_pvperc}=sprintf("%.1f",$measure{energy_session_pv}*100.0/$measure{energy_session})+0.0;
    }
    if($avgA>0) {
      $measure{current_average}=sprintf("%.2f",$avgCUR)+0.0;
      $measure{offered_average}=sprintf("%.2f",$avgA)+0.0;
      $measure{power_average}=MQTT_Power(sprintf("%.0f",$avgW)+0);
      if($avgAcount>0) {
	$measure{current_session_average}=sprintf("%.2f",($LAST_AVGCURSUM+$avgCURsum)/($avgAcount+$LAST_AVGACOUNT))+0.0;
	$measure{offered_session_average}=sprintf("%.2f",($LAST_AVGASUM+$avgAsum)/($avgAcount+$LAST_AVGACOUNT))+0.0;
	#$avgW=($wh-$LAST_WH)*3600/($metertime-$START_TIME);
      }
      my $tottime=$LAST_SPAN+$now-$START_TIME;
      if($tottime>0) {
	$measure{power_session_average}=MQTT_Power(sprintf("%.0f",($wh)*3600/$tottime)+0);
      }
    }
    $measure{charging}=($STATUS eq "CHARGE"?1:0);
    if($measure{charging} || ($wh>$LAST_WH)) {
      $currkwh=sprintf("%0.3f",($wh-$LAST_WH)*0.001);
    } 
    else {
      $currkwh=sprintf("%0.3f",($wh-$prevLAST_WH)*0.001);
    }
    if($ver<=7) {
      if($#power>0) { unshift(@powerdis,$power); }
      if($#volt>0) { unshift(@volt,$volt); }
      if($#current>0) { unshift(@currentdis,$current); }
      my(@data);
      if(length($onlycontext)>0) { @data=($onlycontext); }
      my $tid=$currTransactionFull;
      if($tid ne $payload->{transactionId}) {
	$tid="$payload->{transactionId}/$tid";
      }
      my $logwh=$absolute_wh;
      if($absolute_wh!=$wh) {
	$logwh="$absolute_wh/$wh";
      }
      my $logoff=$offered;
      if(length($powerOffered)>0) {
        $logoff.="/$powerOffered";
      }
      DataLog("charge",$metertime,join("/",@volt),join("/",@currentdis),$logoff,join("/",@powerdis),$logwh,$tid,@data);
    }
    $nowverb=$now;
    my $tid=$payload->{transactionId};
    if($tid eq $currTransaction) {
      $tid=$currTransactionFull;
    }
    if($currSub>0) {
      if($currkwh>0) {
	$kwh="$currkwh/".sprintf("%.1f",$kwh);
      }
      else {
	$kwh="/$kwh";
      }
    }
    if(length($temperature)>0) { $context=" Temp=".($temperature+0).$context; }
    if(length($power_factor)>0) { $context=" PowF=".($power_factor+0).$context; }
    if(length($frequency)>0) { $context=" Frq=".($frequency+0).$context; }
    my $v3=$volt;
    $measure{power}=MQTT_Power($power+0);
    $measure{voltage}=$volt+0;
    $measure{current}=$current+0;
    if($volt3c>0) { 
      $v3.="/$volt3";
      $measure{voltage3phase}=$volt3+0;
    }
    $measure{transactionId}=$payload->{transactionId};
    $measure{transaction}=$tid;
    $measure{transactionSub}="";
    if($tid=~m/-/) {
      $measure{transactionSub}=substr($tid,index($tid,"-")+1)+0;
    }
    $measure{timestart_unix}=$START_TIME;
    $measure{timestart}=Zulu($START_TIME);
    $measure{timestart_session_unix}=$START_SESSION;
    $measure{timestart_session}=Zulu($START_SESSION);
    $measure{elapsed}=sprintf("%.3f",$now-$START_TIME)+0.0;
    $measure{elapsed_human}=TimeToHMS($measure{elapsed});
    $measure{elapsed_session}=sprintf("%.3f",$now-$START_TIME+$LAST_SPAN)+0.0;
    $measure{elapsed_session_human}=TimeToHMS($measure{elapsed_session});
    $measure{max_energy}=MQTT_Energy($ACTIVE_MAX_ENERGY_SESSION);
    if($globalwh>0 && length($measure{energy_global})==0) {
      $measure{energy_global}=MQTT_Energy($globalwh);
    }

    if($measure{charging} && $wh<=$LAST_WH) {
      $whwrong++;
      if($wh<$LAST_WH) { $whwrong=10; }
      if($whwrong>3) {
        verbose(10,"Warning, energy less or equal than previous: curr=$wh, last=$LAST_WH, global=$GLOBAL_WH, absolute=$absolute_wh\n");
	if($VERBOSE<$ver{MeterValues}) {
	  verbose(1,"MeterValues: ".encode_json($payload)."\n");
	}
      }
    }
    else {
      $whwrong=0;
    }

    if($measure{energy}>0) {
      if($globalwh>0 && length($measure{energy_global})==0) {
        $measure{energy_global}=MQTT_Energy($globalwh);
      }
      MQTT_PublishSession($wallbox,\%measure);
      %lastmeasure=%measure;
    }
    else {
      $lastmeasure{charging}=0;
      $lastmeasure{power}=0;
      $lastmeasure{current}=0;
      $lastmeasure{offered}=$measure{offered};
      $lastmeasure{voltage}=$measure{voltage};
      MQTT_PublishSession($wallbox,\%lastmeasure);
    }
    if(length($powerOffered)>0) {
      $lastPowerOffered=$powerOffered;
      $powerOffered=sprintf("/%.2fkW",$powerOffered*0.001);
    }
    my $dispcurr=sprintf("%.2f",$current);
    if($currentact>1) {
      $dispcurr.="*$currentact";
    }

    my $dispev="";
    if(defined($myev{soc}) && ($now-$myev{timestamp_unix}<EvParam("EV_MQTT_TIMEOUT"))) {
      $dispev.=" SOC=$myev{soc}";
      if(defined($myev{power})) {
	$dispev.=" EP=$myev{power}";
      }
      if(defined($myev{temperature})) {
	$dispev.=" BT=$myev{temperature}";
      }
      if(defined($myev{outdoor})) {
	$dispev.=" Out=$myev{outdoor}";
      }
      if(defined($myev{indoor})) {
	$dispev.=" In=$myev{indoor}";
      }
    }
    verbose($ver,"CHG* V=$v3 A=$dispcurr (O=$offered$powerOffered) P=$power kWh=$kwh [T=$tid]$dispev$timestamp$context$addcontext\n");
    if($BASELOAD<0) {
      my $amp=$currSet;
      if($offered>$amp) { $amp=$offered; }
      my $homepower=abs($amp-$current)*ActVolt();
      if($current==0 && $BASELOAD==-1) { 
	# Charging not yet started, set an hypotetical baseload of 2A
	$homepower=$FALLBACK_BASELOAD;
	if($homepower==0) { $homepower=400; }
      }
      DataTransfer({"now"=>$now,"vendorId"=>"localchg","messageId"=>"local","data"=>"{\"type\": \"BaseLoad\", \"power\": \"$homepower\" }"});
    }
  }
  return("");
}

if($recalculate eq "") {
  $recalculate=10*36;
  $lastrecaltime=time();
}

sub PointDef
{
  my ($value,$point,$mult)=@_;
  if(length($value)==0) { return($value); }
  if(length($mult)>0) { 
    $value=$value*$mult;
  }
  return(sprintf("%.${point}f",$value));
}

sub PVDataTransfer
{
  # Photovoltaic meter
  my ($pv)=@_;
  my $now=Now($pv->{timestamp_unix});
  # If power is not defined, try to guess from energy
  %mypv=%{$pv};
  if(!defined($mypv{power}) && defined($mypv{energy})) {
    if($lastpv==0) {
      # Set now the time
      $lastpv=$now;
      $lastpvenergy=$mypv{energy};
    }
    elsif(($now-$lastpv)>=60) {
      $lastpvpower=($mypv{energy}-$lastpvenergy)*3600/($now-$lastpv);
      $lastpv=$now;
      $lastpvenergy=$mypv{energy};
    }
    $mypv{power}=$lastpvpower;
  }
  else {
    $lastpv=$now;
    $lastpvpower=$mypv{power};
  }
  DataLog("solar",$now,
          PointDef($mypv{power},1),
	  PointDef($mypv{voltage},1),
	  PointDef($mypv{current},2),
          PointDef($mypv{frequency},3),
	  PointDef($mypv{energy},3,0.001),
          PointDef($mypv{efficiency},2),
	  PointDef($mypv{temperature},1),
	  PointDef($mypv{humidity},1));
}

sub EVDataTransfer
{
  # EV data
  my ($pay,$ev)=@_;
  my $now=Now($pay->{timestamp_unix});
  if(length($lastPower)>0) {
    if($pay->{power}==0) {
      $lastWallboxPower=$lastEvPower=$pay->{efficiency}=0;
    }
    else {
      if($lastEvPower==0) {
        $lastEvPower=$pay->{power};
      }
      else {
        $lastEvPower=$lastEvPower*0.95+$pay->{power}*0.05;
      }
      if($lastWallboxPower==0) {
        $lastWallboxPower=$lastPower;
      }
      else {
        $lastWallboxPower=$lastWallboxPower*0.95+$lastPower*0.05;
      }
      $pay->{efficiency}=sprintf("%.1f",$lastEvPower/$lastPower*100)+0;
      if($pay->{efficiency}>100) {
        $pay->{efficiency}=100;
      }
    }
  }
  %myev=%{$pay};
  if($myev{soc}>0 || $myev{power}>0 || $myev{remain}>0) {
    DataLog("ev",$now,
	  $ev,
          $myev{soc},
          $myev{charging},
          $myev{remain},
          $myev{power},
	  $myev{voltage},
	  $myev{current},
	  $myev{energy},
	  $myev{charge},
	  $myev{ac_power},
	  $myev{ac_voltage},
	  $myev{ac_current},
	  $myev{battemp},
	  $myev{outdoor},
	  $myev{indoor},
	 );
  }
}

#2023-11-27 23:47:08.114111 - [RX] <= [2, "1728068", "DataTransfer", 
#{"vendorId": "abc", "messageId": "232", "data": "{\"type\": \"MeterTransfer\", \"timestamp\": \"2023-11-27T22:47:07.000Z\", 
# \"sampledValue\": [
#  {\"measurand\": \"Voltage.L1\", \"accuracy\": \"1\", \"unit\": \"V\", \"value\": 2254}, 
#  {\"measurand\": \"Current.L1\", \"accuracy\": \"2\", \"unit\": \"A\", \"value\": 1363}, 
#  {\"measurand\": \"Active.Power.ALL\", \"accuracy\": \"2\", \"unit\": \"W\", \"value\": 302184}
# ]
#}"}]


sub DataTransfer
{
  my ($payload,$sock)=@_;
  my ($meter,$sample,$volt,$voltc,@power,$powerc,@volt,@current,$ln,@line,$current,$currentc,$logdata,$power,$acc,$t,$limit,$immediate,$now,$fetchpower);
  my ($newOffered,$newPower);
  eval {
    $now=Now($payload->{now});
    $meter=decode_json($payload->{data});
    $voltacc=1;
    $currentacc=2;
    $logdata=1;
    if($currLActive<1) { $currLActive=1; }
    if($meter->{type} eq "MeterTransfer")
    {
      $sample=$meter->{sampledValue};
      foreach(@{$sample})
      {
	$meas=$_->{measurand};
	$value=$_->{value};
	$acc=$_->{accuracy};
	if($acc>0) {
	  if($value<0) {
	    if(length($value)<=($acc+1)) {
	      $value=substr($value,0,1).("0" x ($acc+2-length($value))).substr($value,1);
	    }
	  }
	  if(length($value)<($acc+1)) { 
	    $value=("0" x ($acc+1-length($value))).$value;
	  }
	  $value=substr($value,0,-$acc).".".substr($value,-$acc);
	}
	($ln)=($meas=~m/\.L(\d+)/);
	if($meas=~m/Voltage.L/) { 
	  $line[$ln-1]=$ln; 
	  $volt[$ln-1]=$value; 
	  $volt+=$value; 
	  $voltc++; 
	  if($acc>0) {
	    $voltacc=$acc; 
	  }
	}
	elsif($meas=~m/Current.L/) { 
	  $current[$ln-1]=$value; 
	  $current+=$value; 
	  $currentc++; 
	  if($acc>0) {
	    $currentacc=$acc;
	  }
	}
	elsif($meas=~m/Power.L/) { 
	  $power[$ln-1]=$value; 
	  $powerc++; 
	}
	elsif($meas eq "Active.Power.ALL") { 
	  $power=$value;
        }
      }
      if(length($power)>0) {
        $lastmeter=$now;
      }
    }
    elsif($meter->{type} eq "BaseLoad")
    {
      if($meter->{power}>0) {
        $power=$meter->{power}+$lastPower;
      }
      else {
	# If BASELOAD is not defined, try to keep very conservative,
	# just to allow minimum charge (~1300W)
        $power=2600+$lastPower;
      }
      $logdata=0;
      $lastmeter=-$now;
    }

    if(length($power)==0 && $powerc>0) {
      for($i=0;$i<$powerc;$i++) {
        $power+=$power[$i];
      }
    }
    if(length($power)>0) {
      if($voltc==0) {
        $volt=ActVoltFormatted();
	@line=("1");
	@volt=($volt);
      }
      elsif($voltc>1) { $volt=$volt/$voltc; }
      $volt=sprintf("%.${voltacc}f",$volt);
      if($currentc==0 && $volt>0) {
        $current=sprintf("%.${currentacc}f",$power/$volt);
	@current=($current);
      }
      $current=sprintf("%.${currentacc}f",$current);

      if($ADD_WALLBOX_POWER_TO_METER) { 
        # Be careful, and check if charging is in progress
	if($STATUS =~ m/CHARG/) {
	  $power+=$lastPower;
	  $current+=$lastCurrent;
        }
      }

      $currPower=$power;

      if(length($avgPower)==0) {
	$avgPower=$power;
	$lastavgmeter=$now-30;
      }
      $metersec=$now-$lastavgmeter;
      if($recalculate>0) {
	if($recalculate>$WAIT_CHANGE) { $recalculate=$WAIT_CHANGE; }
        if($AVG_CHANGING_SEC==0) {
	  $AVG_CHANGING_SEC=36;
	}
	$avgPower=($avgPower*$AVG_CHANGING_SEC+$power*$metersec)/($AVG_CHANGING_SEC+$metersec);
	if($lastrecaltime==0) { $lastrecaltime=$now; }
	$recalculate-=int($now-$lastrecaltime);
	if($recalculate<0) { $recalculate=0; }
	$lastrecaltime=$now;
      }
      else {
        if($AVG_HISTORIC_SEC==0) {
	  $AVG_HISTORIC_SEC=900;
	}
	$avgPower=($avgPower*$AVG_HISTORIC_SEC+$power*$metersec)/($AVG_HISTORIC_SEC+$metersec);
      }
      $avgPowerInc=$avgPowerDec=$avgPower;
      if($NO_AVERAGE & 1) { $avgPowerInc=$power; }
      if($power<$avgPower) {
        # if current power is below average power, use it for decreasing
	$avgPowerDec=$power;
      }
      elsif($NO_AVERAGE & 2) { 
	if(CurrOffered()>$MINPOWER && $smartcharging>0) {
          $avgPowerDec=$power;
	}
      }
      #my $currday=DayS($now);
      $lastavgmeter=$now;
      my $avgmeter=sprintf("%.0f",$avgPower);
      #my $meterpower=sprintf("%8s %5s",$power,$avgmeter);
      MQTT_PublishMeter($now,$power,$volt,$current,$avgmeter,\@line,\@volt,\@current,\@power);
      if($logdata) {
        DataLog("meter",$now,join("/",@volt),join("/",@current),$power,$avgmeter,$STATUS);
      }
      #DataLog("meter",$now,@volt,@current,$power,$avgmeter,($lastmeterSTATUS ne $STATUS||$lastmeterday ne $currday?$STATUS:""));
      #$lastmeterSTATUS=$STATUS;
      #$lastmeterday=$currday;
      $nowverb=$now;

      my $pvstatus="";
      if($lastgridtime>0 && $START_TIME>0 && $STATUS eq "CHARGE") {
	if($logdata) {
	  UpdatePVEnergy($now,$power);
	}
	my $currwh=$lastWh-$LAST_WH;
	if($currwh>0 && $pvwh>0) {
	  $pvstatus=sprintf(" pv=%.1f%%",100.0*$pvwh/$currwh);
	}
        if(($now-$lastgridsave)>600) {
	  SaveConf(); # Save every 10 minutes
	  $lastgridsave=$now;
	}
      }
      $lastgrid=$power;
      $lastgridtime=$now;

      my $showstatus=ShowStatus();
      my $prodstatus="";
      if($lastpv>0 && defined($mypv{power})) {
        $prodstatus="Solar=".sprintf("%.1f",$mypv{power})." ";
      }
      $temphum="";
      if(defined($mypv{temperature})) {
	$temphum.=" T=$mypv{temperature}";
      }
      if(defined($mypv{humidity})) {
	$temphum.=" H=$mypv{humidity}";
      }
      if($temphum eq $lasttemphum) {
	$temphum="";
      }
      else {
	$lasttemphum=$temphum;
      }
      verbose(7,"L".join("",@line)." * V=".join("/",@volt)." A=".join("/",@current)." W=$power ".$prodstatus.
                "($avgmeter, $showstatus".($recalculate>0?", ${recalculate}s":"").")".
		 ($smartcharging<0?" $smartcharging":"")."$pvstatus$temphum\n");
      if($voltc>0) {
        $meter_currVolt=$currVolt=$volt;
      }
      #return; # temporary to test $smartcharging<=0
      $newOffered=-1;
      $lastcurrSet=$currSet;
      if($STATUS eq "STOP" && $canincrease<=0) {
        # If smartcharging not available or USE_STOP_AS_SUSPEND is set, the message
	# MeterValues will no more arrives, so we have to set canincrease=1 here
	$canincrease++;
      }
      # Some EVs do not accept charging after RemoteStart (e.g. battery full):
      # wallbox stays in STOP/SUSPENDSTART without ever sending "Charging" status.
      # Detect this case and switch to STOPEV to stop retrying.
      if($USE_STOP_AS_SUSPEND && $STATUS eq "STOP" && $SUBSTATUS eq "SUSPENDSTART"
         && length($currTransaction)>0) {
        if($suspstart_time<=0) {
          $suspstart_time=$now;
        }
        elsif(($now-$suspstart_time)>180) {
          verbose(3,"WARNING: STOP/SUSPENDSTART persisted >180s, EV not accepting charge, switching to STOPEV\n");
          $STATUS="STOPEV";
          StopCharging();
          $suspstart_time=0;
        }
      }
      else {
        $suspstart_time=0;
      }
      if(length($GRID_LIMIT)>0) {
	if($STATUS eq "CHARGE") {
	  if($power>$GRID_LIMIT) {
	    # Immediately set a lower limit if GRID LIMIT exceeded (should never occour if
	    # meter limits are correctly set on Wallbox)
	    if($currOffered>0) {
	      if($smartcharging>0) {
		$newPower=intPower(PowerOffered()-($power-$GRID_LIMIT)*2);
		$newOffered=CurrOffered()-(TruncFineStep(($power-$GRID_LIMIT)/$volt)*2+1);
		if($lastover>0) {
		  $newOffered=TruncFineStep($newOffered/2);
		  $newPower=intPower($newPower/2);
		  if($lastover<2 && $newOffered<$WBMINPOWER) {
		    # Give a last chance...
		    $newOffered=$WBMINPOWER;
		    $newPower=intPower(WallboxCurrAdd($WBMINPOWER)*MaxActVolt());
		  }
		}
		elsif($newOffered<$WBMINPOWER) { 
		  # Try the first time with minimum (wallbox could not yet updated power/offered)
		  $newOffered=$WBMINPOWER;
		  $newPower=intPower(WallboxCurrAdd($WBMINPOWER)*MaxActVolt());
		}
		if($newOffered<$WBMINPOWER) {
		  $newOffered=0;
		  $newPower=0;
		}
		verbose(3,"WARNING: grid limit EXCEEDED ($lastover), reducing to $newOffered [$newPower]\n");
	      }
	      else {
		verbose(3,"WARNING: grid limit EXCEEDED ($lastover), stop charging\n");
		$newOffered=0;
		$newPower=0;
	      }
	      $transaction_started=0;
	      $immediate=1;
	      $recalculate=0;
	      $currSet=-1;
	      $lastover++;
	      $canincrease=-4;
	    }
	  }
	  else {
	    $lastover=0;
	  }
	}
	else {
	  if($power>$GRID_LIMIT) {
	    if($lastover==0 && length($WARNMAIL)>0) {
	      verbose(3,"WARNING: grid limit EXCEEDED ($lastover), sending email\n");
	      SendMail("WARNING: grid limit EXCEEDED ($power)",$WARNMAIL,$WARNMAIL,"WARNING: grid limit ($GRID_LIMIT) EXCEEDED: $power\n\nREDUCE LOAD IMMEDIATELY!!\n");
	    }
	    else {
	      verbose(3,"WARNING: grid limit EXCEEDED ($lastover)\n");
	    }
	    $lastover++;
	  }
	  else {
	    $lastover=0;
	  }
	}
	# First of all, check grid limits
	if($GRID_OVER_START<=0) {
	  if($power>$GRID_LIMIT_SAFE || $avgPower>$GRID_LIMIT_SAFE) {
	    verbose(10,"Grid safe limit exceeded, setting start time\n");
	    $GRID_OVER_START=$now;
	    $GRID_OVER_PAUSE=0;
	    if($newOffered<0) {
	      $canincrease=0;
	    }
	    SaveConf();
	  }
	}
	else {
	  if(($now-$GRID_OVER_START)>$GRID_LIMIT_REDUCETIME) {
	    if($power>$GRID_LIMIT_SAFE) {
	      if($GRID_OVER_PAUSE>0) {
	        $GRID_OVER_PAUSE+=$GRID_LIMIT_RESTART_PAUSE;
		if($GRID_OVER_PAUSE>$now) { $GRID_OVER_PAUSE=$now; }
	      }
	      else {
	        $GRID_OVER_PAUSE=$now;
	      }
	      if($currOffered>0 && $newOffered<0) {
		if($smartcharging>0) {
		  $newPower=intPower(PowerOffered()-($power-$GRID_LIMIT_SAFE+2*ActVoltWallbox()));
		  $newOffered=CurrOffered()-(TruncFineStep(($power-$GRID_LIMIT_SAFE)/$volt)+2);
		  if($newOffered<$WBMINPOWER) { 
		    if(($GRID_OVER_PAUSE-$GRID_OVER_START)<$GRID_LIMIT_MAXTIME) {
		      $newOffered=$WBMINPOWER;
		      $newPower=intPower(WallboxCurrAdd($WBMINPOWER)*ActVoltWallbox());
		    }
		    else {
		      $newOffered=0;
		      $newPower=0;
		    }
		  }
		}
		else {
		  $newOffered=0;
		  $newPower=0;
		}
		$recalculate=0;
		if(CurrOffered()!=$newOffered) {
		  $currSet=-1;
	        }
	      }
	      my $co=CurrOfferedFull();
	      verbose(10,"Grid over safe limit over time, pausing and reducing power to $newOffered [$newPower] (curr=$co)\n");
	      SaveConf();
	    }
	    elsif($GRID_OVER_PAUSE>0 && $power>$GRID_LIMIT_SAFE_REDUCE) {
	      # Reduce the power to avoid grid safe limit to be overtaken again
	      if($currOffered>0 && $newOffered<0) {
		if($smartcharging>0) {
		  $newPower=intPower(PowerOffered()-($power-$GRID_LIMIT_SAFE_REDUCE+ActVoltWallbox()));
		  $newOffered=CurrOffered()-(TruncFineStep(($power-$GRID_LIMIT_SAFE_REDUCE)/$volt)+1);
		  if($newOffered<$WBMINPOWER) { 
		    $newOffered=0;
		    $newPower=0;
		  }
		  $recalculate=0;
		  $currSet=-1;
	          verbose(10,"Reduce power to $newOffered [$newPower] to avoid reaching grid safe limit\n");
		}
	      }
	    }
	    if($GRID_OVER_PAUSE!=0) {
	      # Check if we are still over safe:
	      if(($now-abs($GRID_OVER_PAUSE)) > TimePerc($GRID_LIMIT_PAUSE,abs($GRID_OVER_PAUSE)-$GRID_OVER_START)) {
		verbose(10,"Grid paused below time limit, resetting counters\n");
		$GRID_OVER_PAUSE=0;
		$GRID_OVER_START=0;
		$transaction_started=$MAXPOWER;
		SaveConf();
	      }
	      elsif($newOffered<0 && $transaction_started<=0) {
	        $canincrease=0;
	      }
	    }
	    else {
	      verbose(10,"Grid over safe limit over time, pausing\n");
	      $GRID_OVER_PAUSE=$now;
	      SaveConf();
	    }
	  }
	  else {
	    if($power<$GRID_LIMIT_SAFE && $avgPower<$GRID_LIMIT_SAFE) {
	      if($GRID_OVER_PAUSE!=0) {
		# Check if we are still over safe:
	        if(($now-abs($GRID_OVER_PAUSE)) > TimePerc($GRID_LIMIT_PAUSE,abs($GRID_OVER_PAUSE)-$GRID_OVER_START)) {
		  verbose(10,"Grid paused below safe limit, resetting counters\n");
		  $GRID_OVER_PAUSE=0;
		  $GRID_OVER_START=0;
		  $transaction_started=$MAXPOWER;
		  SaveConf();
		}
		elsif($GRID_OVER_PAUSE>0 && $newOffered<0 && 
		      ($power>($GRID_LIMIT_SAFE-$volt) || $avgPower>($GRID_LIMIT_SAFE-$volt)) &&
		      $transaction_started<=0
		     ) {
	          $canincrease=0;
		}
	      }
	      else {
		$GRID_OVER_PAUSE=$now;
		if(Ampere($FIXED)>=$MAXPOWER && $newOffered<0) {
		  if($transaction_started<=0) {
		    if($currSet<0) { $currSet=0; }
		    $newOffered=$currSet;
		    $newPower=intPower(WallboxCurrAdd($currSet)*ActVoltWallbox());
		  }
		}
		else {
		  $GRID_OVER_PAUSE=-$GRID_OVER_PAUSE;
		}
		SaveConf();
	      }
	    }
	    elsif($GRID_OVER_PAUSE!=0) {
	      $GRID_OVER_PAUSE=0;
	      SaveConf();
	    }
	  }
	}
      }
      $t1=$t2=0;
      if($GRID_OVER_START>0) { $t1=int($now-$GRID_OVER_START); }
      if($GRID_OVER_PAUSE>0) { $t2=int($now-$GRID_OVER_PAUSE); }
      if($newOffered>=0) {
	verbose(11,"GRID=$t1 - ${t2}: no=$newOffered [$newPower], cs=$currSet, ci=$canincrease, ts=$transaction_started\n");
      }

      if(0) { # TO-DO: DISABLE FOR NOW, NOT TESTED
      if($canincrease>0 && length($MAXVOLTAGE)>0) {
        # Check if we reached the maximum voltage
	if($volt>=$MAXVOLTAGE) {
	  $canincrease=100;
	  if($STATUS=~m/STOP|SUSPEND/) {
	    $newPower=intPower(WallboxCurrAdd(MinPowerCharging())*ActVoltWallbox());
	    $newOffered=MinPowerCharging();
	    if($STATUS eq "STOP" && !($SUBSTATUS=~m/SUSPEND/)) {
	      # Remote Start
	      StartStop($newOffered,$newPower);
	    }
	  }
	  elsif($STATUS eq "CHARGE") {
	    $newOffered=CurrOffered()+WallboxMainStep();
	    $newPower=intPower(PowerOffered()+WallboxCurrAdd(WallboxMainStep())*ActVoltWallbox());
	  }
	}
      }
      }

      # Check if maximum energy reached:
      if($ACTIVE_MAX_ENERGY_SESSION>0) {
        if($lastWh>=$ACTIVE_MAX_ENERGY_SESSION) {
	  $canincrease=0;
	  if($STATUS eq "CHARGE") {
	    $newOffered=0;
	    $newPower=0;
	    verbose(11,"Maximum energy reached ($ACTIVE_MAX_ENERGY_SESSION), session suspended.\n");
	  }
	}
      }

      if(length($myev{soc})>0) {
        # Car still connected
        my $soclimit=EvParam("EV_SOC_LIMIT");
	if($soclimit>0 && $myev{soc}>=$soclimit) {
	  $canincrease=0;
	  if($STATUS eq "CHARGE") {
	    $newOffered=0;
	    $newPower=0;
	    verbose(11,"SOC limit reached ($myev{soc}>=$soclimit), session suspended.\n");
	  }
	}
      }

      # Check if power could be increased:
      #verbose(11,"NEWOFFERED=$newOffered [$newPower] // CANINCREASE=$canincrease\n");
      if($canincrease>0) {
	if($smartcharging>0) {
          if(!($SUBSTATUS=~m/SUSPEND/) && $STATUS=~m/STOP|AVAIL/) { $canincrease=0; }
	}
	elsif($smartcharging<-1) {
	  # Charging was stopped by RFID card: do not allow restart
	  $canincrease=0;
	}
	else {
          if(substr($STATUS,0,4) ne "STOP") { $canincrease=0; }
	}
      }
      else {
        verbose(13,"canincrease=$canincrease [$STATUS]\n");
      }
      #$avgincdec=0;
      #$avgPower-=$avgincdec;
      #$power-=$avgincdec;
      #verbose(11,"Simulated AVG Power: $avgPower -- $newOffered [$newPower]\n");
      if($FIXED eq "0") { # Don't increase/start if immediately suspend profile (FIXED=0) is set
        $canincrease=0;
      }
      if($newOffered<0 && $canincrease>0) {
	if($currSet<$MAXPOWER && (length($FIXED)==0 || $currSet<Ampere($FIXED) || CheckAvg(1))) {
	  if($FIXED>0 && $currSet<$WBMINPOWER) {
	    if($smartcharging>0 && $GRID_LIMIT>0) {
	      $newPower=intPower(PowerOffered()+$GRID_LIMIT-$power);
	      $newOffered=RoundFineStep(($GRID_LIMIT-$power)/$volt)+CurrOffered();
	      if($newOffered>=$WBMINPOWER) {
		if($newOffered>Ampere($FIXED)) { $newOffered=Ampere($FIXED); }
		if($newPower>Power($FIXED,ActVoltWallbox())) { $newPower=Power($FIXED,ActVoltWallbox()); }
	      }
	      elsif($newOffered<0) { 
	        $newOffered=0;
	        $newPower=0;
	      }
	      my $co=CurrOfferedFull();
	      verbose(($recalculate>0?14:11),"FIXED=$FIXED, CURRSET=$currSet, CO=$co, NO=$newOffered [$newPower]\n");
	    }
	    else {
	      $newOffered=Ampere($FIXED);
	      $newPower=Power($FIXED,ActVoltWallbox());
	    }
	  }
	  elsif($smartcharging>0) {
	    if($FIXED>0) {
	      if(IsUnitWatt()) {
	        if((PowerWallbox($FIXED)-PowerOffered())>=(WallboxMainStep()*ActVoltWallbox())) { 
		  $fixedinc++;
		}
		else {
		  $fixedinc=0;
		}
	      }
	      else {
	        if((CurrOffered()+WallboxMainStep())<=Ampere($FIXED)) {
		  $fixedinc++;
		}
		else {
		  $fixedinc=0;
		}
	      }
	      if($fixedinc>2 || CheckAvg(1)) {
		if($GRID_LIMIT>0) {
		  $limit=$GRID_LIMIT-$volt-$GRID_LIMIT_TOLERANCE;
	        }
		else {
		  $limit=Power($MAXPOWER,$volt);
		}
	      }
	      else {
	        $limit=0;
	      }
	    }
	    else {
	      $fixedinc=0;
	      if($currOffered==0 || $STATUS eq "STOP") {
		$limit=Power($MINPOWER_START,$volt);
	      }
	      else {
		$limit=Power($MINPOWER_INCREASE,$volt);
	      }
	    }
            verbose(16,"Checking INC LIMIT $limit > $avgPowerInc (MPC=".MinPowerCharging().")\n");
	    my $minpowerincrease=0;
	    if(CurrOffered()<MinPowerCharging() && $currSet<MinPowerCharging() && $STATUS eq "CHARGE") {
	      # Check if we are not exceeding grid limit with increment:
	      if($GRID_LIMIT<=0 || ($power+$volt)<($GRID_LIMIT-$GRID_LIMIT_TOLERANCE)) {
		# Check also that we are not in grid over safe pause:
	        if($GRID_OVER_PAUSE<=0) {
		  # Check also that we are not over the suspend limit
		  my $declimit=Power($MAXPOWER_SUSPEND,$volt);
		  if($avgPowerDec<$declimit && $power<$declimit) {
	 	    $minpowerincrease=1;
		  }
	        }
	      }
	    }
	    if(($avgPowerInc<$limit && $power<$limit) || ($minpowerincrease)) {
	      if($STATUS eq "STOP" || $currOffered==0 || $lastCurrent==0) {
	        if($FIXED>0) {
		  $newPower=Power($FIXED,$volt);
		  $newOffered=Ampere($FIXED);
		  if($GRID_LIMIT>0) {
		    if(($power+$newPower)>($GRID_LIMIT-$GRID_LIMIT_TOLERANCE)) {
		      $newPower=intPower($GRID_LIMIT-$power-$GRID_LIMIT_TOLERANCE);
		      $newOffered=TruncFineStep(($GRID_LIMIT-$power)/$volt+1);
		    }
		  }
		}
		else {
	          $newPower=intPower(WallboxCurrAdd(MinPowerCharging())*ActVoltWallbox());
	          $newOffered=MinPowerCharging();
	        }
	      }
	      else {
	        $newPower=PowerOffered();
	        $newOffered=CurrOffered();
		if(IsUnitWatt()) {
		  # Try to compensate imprecision of current/power conversion
		  if($newOffered<$lastSet && ($lastSet-$newOffered)<(WallboxMainStep()*3)) {
		    $newOffered=$lastSet;
		  }
		  if($newPower<$powerSet && ($powerSet-$newPower)<(WallboxMainStep()*3*ActVoltWallbox())) {
		    $newPower=$powerSet;
		  }
		}
		$newOffered+=WallboxMainStep();
		$newPower=intPower($newPower+WallboxCurrAdd(WallboxMainStep())*ActVoltWallbox());
	      }
	      if($newOffered<$WBMINPOWER) { 
	        $newOffered=$WBMINPOWER;
	      }
	      if($newPower<($WBMINPOWER*ActVoltWallbox())) { 
	        $newPower=intPower(WallboxCurrAdd($WBMINPOWER)*ActVoltWallbox());
	      }
	      if($newOffered>$MAXPOWER) { $newOffered=$MAXPOWER;}
	      #$currSet=-1;
	      if(CheckAvg(1)>=10) {
	        $recalculate=0;
	      }
	      if(CheckAvg(0.1)) {
	        $transaction_started=$MAXPOWER;
	      }
	      if(CurrOffered()>=$MINPOWER && CurrOffered()<MinPowerCharging()) {
	        verbose(($recalculate>0?14:($SUBSTATUS eq "SUSPENDSTART"?13:11)),"Increasing to $newOffered [$newPower] (CHARGING_MINPOWER)\n");
	      }
	      else {
	        verbose(($recalculate>0?14:($SUBSTATUS eq "SUSPENDSTART"?13:11)),"Increasing to $newOffered [$newPower] (".sprintf("%.1f",$avgPowerInc)." < $limit)\n");
	      }
	    }
	  }
	}
      }

      # Check if power should be decreased:
      # For test: simulate solar panels
      if(($STATUS eq "CHARGE" || ($smartcharging<=0 && !CheckStop())) && $newOffered<0) {
	my $localOffered=CurrOffered();
	my $localPower=PowerOffered();
	if(IsUnitWatt()) {
	  # Try to compensate imprecision of current/power conversion
	  if($localOffered>$lastSet && ($localOffered-$lastSet)<(WallboxMainStep()*3)) {
	    $localOffered=$lastSet;
	  }
	  if($localPower>$powerSet && ($localPower-$powerSet)<(WallboxMainStep()*3*ActVoltWallbox())) {
	    $localPower=$powerSet;
	  }
	}
        verbose(16,"$STATUS $smartcharging $newOffered\n");
	if($FIXED eq "0") { # Suspend immediately
	  if($currOffered>0 || $smartcharging<=0) {
	    $recalculate=0;
	    $newOffered=0;
	    $newPower=0;
	    $currSet=-1;
	  }
	}
	elsif(length($FIXED)==0) {
	  if($localOffered<=MinPowerCharging()) { $limit=Power($MAXPOWER_SUSPEND,$volt); }
	  else { $limit=Power($MAXPOWER_REDUCE,$volt); }
	  #verbose(16,"CHECK DEC $avgPower -- $limit ($MAXPOWER_SUSPEND, $MAXPOWER_REDUCE [$FIXED])\n");
	  if($avgPowerDec>$limit && $power>$limit) {
	    if($smartcharging>0) {
	      $newOffered=$localOffered-WallboxMainStep();
	      $newPower=intPower($localPower-(WallboxMainStep()-WallboxCurrAdd(0.001))*ActVoltWallbox());
	      if(IsUnitWatt()) {
		# The current offered could be a little bit less than MAINSTEP (e.g. currOfferd=6.89),
		# so the newOffered will be lower than MINPOWER. If the lastSet was greater than
		# MINPOWER, set the newOffered as MINPOWER. Do not use $currOffered because if could
		# be greater than MAINSTEP and you will never suspend charging.
		if($newOffered<MinPowerCharging() && $lastSet>MinPowerCharging()) {
		  $newOffered=MinPowerCharging();
		  if($newPower<(MinPowerCharging()*ActVoltWallbox())) {
		    $newPower=intPower(WallboxCurrAdd(MinPowerCharging())*ActVoltWallbox());
		  }
		}
	      }
	      if($newOffered<MinPowerCharging()) { 
	        $newOffered=0;
	        $newPower=0;
	        $currSet=-1;
	      }
	      verbose(($recalculate>0?14:11),"Decreasing to $newOffered [$newPower] (".sprintf("%.1f",$avgPowerDec)." > $limit) [$currSet]\n");
	    }
	    else {
	      $newOffered=0;
	      $newPower=0;
	      verbose(($recalculate>0?14:11),"Stopping charging (".sprintf("%.1f",$avgPowerDec)." > $limit)\n");
	    }
	  }
	}
	else {
	  if($FIXED>0) {
	    if(IsUnitWatt()) {
	      if((PowerOffered()-PowerWallbox($FIXED))>=(WallboxMainStep()*ActVoltWallbox())) { 
		$fixeddec++;
	      }
	      else {
	        $fixeddec=0;
	      }
	    }
	    else {
	      if((CurrOffered()-WallboxMainStep())>=Ampere($FIXED)) {
		$fixeddec++;
	      }
	      else
	      {
	        $fixeddec=0;
	      }
	    }
	  }
	  else {
	    $fixeddec=0;
	  }
	  #verbose(16,"HERE ... $FIXED ($fixeddec) checking dec CS=$lastSet CO=".CurrOffered()." PS=$powerSet PO=".PowerOffered()."\n");
	  if(($fixeddec>2 || CheckAvg(-1)) && CurrOffered()>$WBMINPOWER) {
	    $newOffered=CurrOffered()-WallboxMainStep();
	    $newPower=intPower(PowerOffered()-(WallboxMainStep()-WallboxCurrAdd(0.001))*ActVoltWallbox());
	    if($newOffered<$WBMINPOWER) { 
	      $newOffered=$WBMINPOWER;
	    }
	    if($newPower<($WBMINPOWER*ActVoltWallbox())) { 
	      $newPower=intPower(WallboxCurrAdd($WBMINPOWER)*ActVoltWallbox());
	    }
	    my $co=CurrOfferedFull();
	    if(CheckAvg(-1)) {
	      if(CheckAvg(-1)>=10) {
		$recalculate=0;
	      }
	      if(CheckAvg(-0.1)) {
		$transaction_started=$MAXPOWER;
	      }
	      verbose(($recalculate>0?14:11),"Decreasing to $newOffered [$newPower] to compensate for FIXED avg (".sprintf("%.2fA/%.0fW",${avgA},${avgW})." > $FIXED) [$co]\n");
	    }
	    else {
	      verbose(($recalculate>0?14:11),"Decreasing to $newOffered [$newPower] reach FIXED $FIXED\n");
	    }
	  }
	}
      }

      #$avgPower+=$avgincdec;
      #$power+=$avgincdec;

      if($recalculate<=0 && defined($smartcharging)) {
	verbose(13,"currSet=$currSet, newOffered=$newOffered, newPower=$newPower (ts=$transaction_started, js=$justset)\n");
	if(length($currTransaction)==0 && $currSet>0) {
	  undef($currSet);
	}
	if($newOffered>=0 && $newOffered==$currSet) {
	  $justset++;
	  if($justset>5) {
	    # Maybe something wrong when setting new profile, do again
	    verbose(10,"Maybe something wrong on previous current setting, do it again ($currSet)\n");
	    $currSet=-1;
	  }
	}
	if($newOffered>=0) {
	  if($newOffered!=$currSet) {
	    $justset=0;
	    if($currTransaction==0) {
	      # Started by free-vending mode, enable quick-start:
	      $transaction_started=$MAXPOWER;
	    }

	    if($transaction_started>0) {
	      verbose(10,"Quick start back-counter=$transaction_started (WOS=$WAIT_ON_START)\n");
	      $recalculate=$WAIT_ON_START;
	      $lastrecaltime=$now;
	      $transaction_started--;
	      if($newOffered<$WBMINPOWER || $newOffered>=$MAXPOWER || (length($FIXED)>0 && $newOffered>=Ampere($FIXED)))
	      {
		verbose(10,"Resetting back-counter ($transaction_started)\n");
		$transaction_started=0;
	      }
	    }
	    else {
	      $recalculate=$WAIT_CHANGE;
	      $lastrecaltime=$now;
	    }
	    if($smartcharging>0) {
	      # Some wallbox rejects TxProfile when session is in STOP/SUSPENDSTART state.
	      # Skip NewOffered (which would send TxProfile) and use DefaultLimit only.
	      # Only applies when currTransaction exists (session open but suspended).
        # Allow RemoteStop when offered < WBMINPOWER in SUSPENDSTART
        if($USE_STOP_AS_SUSPEND && $STATUS eq "STOP" && $SUBSTATUS eq "SUSPENDSTART" && length($currTransaction)>0 && $newOffered>=$WBMINPOWER) {
	        verbose(7,"NewOffered skipped from main loop: STOP/SUSPENDSTART\n");
	        DefaultLimit($newOffered,PowerWallboxMax($newOffered));
	        $lastSet=$currSet=$newOffered;
	        $powerSet=$newPower;
	        $canincrease=-2;
	        MQTT_PublishLimit($wallbox,{});
	      }
	      else {
	        NewOffered($newOffered,$newPower,$currTransaction,$immediate);
	      }
	    }
	    elsif($newOffered==0 || $smartcharging>=-1) {
	      # Start only if not stopped by RFID
              SubStatus($newOffered);
	      StartStop($newOffered,$newPower,$currTransaction,$immediate);
	    }
	  }
	}
	elsif($transaction_started>0 && $canincrease>=0 && $currSet>0) {
	  verbose(13,"Decreasing quick start back-counter ($transaction_started, newOffered=$newOffered [$newPower], currSet=$currSet, canincrease=$canincrease)\n");
	  #$transaction_started=0;
	  $transaction_started--;
	}
      }
    }
  };
  return("\"status\": \"Accepted\"");
}

sub DefVal
{
  my($val,$def)=@_;
  if(!defined($val) || length($val)==0) { return($def); }
  return($val);
}

sub DefValAdd
{
  my($val,$def,$add,$defadd)=@_;
  $val=DefVal($val,$def);
  if($val=~m/^[\+-]/) { 
    $val+=DefVal($add,$defadd);
  }
  return($val);
}

sub FixValue {
  my($param,$value)=@_;
  if($param =~ m/GRID_LIMIT_.*TIME|GRID_LIMIT.*PAUSE|STOP_ON_SUSPENDEV/) {
    # Convert to seconds
    $value=TimeSecPerc($value);
  }
  return($value);
}

sub DefSmart
{
  my($smart,$param)=@_;
  my($value);
  if($param eq "GRID_LIMIT_SAFE_REDUCE") {
    return(DefValAdd($smart->{$param},$default{$param},
                     $smart->{GRID_LIMIT_SAFE},$default{GRID_LIMIT_SAFE}));
  }
  elsif($param=~m/^MAXPOWER|^MINPOWER|^FIXED/) {
    return($smart->{$param});
  }
  else {
    $value=FixValue($param,DefVal($smart->{$param},$default{$param}));
    return($value);
  }
}

sub CheckChanged
{
  my $smart=shift;
  my (@params)=@_;
  my ($i,$value,$param);
  for($i=0;$i<=$#params;$i++) {
    $param=$params[$i];
    #eval("\$value=\$$param");
    $value=${$param};
    if($value ne DefSmart($smart,$param)) {
      return(1);
    }
  }
  return(0);
}

sub SetSmart
{
  my $smart=shift;
  my (@params)=@_;
  my ($i,$value);
  for($i=0;$i<=$#params;$i++) {
    $param=$params[$i];
    $value=DefSmart($smart,$param);
    #eval("\$$param=\$value");
    ${$param}=$value;
  }
}

sub FixEnergy {
  my $e=shift;
  if($e=~m/kWh/i) {
    return($e*1000);
  }
  elsif($e=~m/Wh/) {
    return($e+0);
  }
  elsif($e<1000) {
    return($e*1000);
  }
  return($e+0);
}

sub SetMaxEnergy {
  $ACTIVE_MAX_ENERGY_SESSION=FixEnergy($MQTT_MAX_ENERGY_SESSION);
  if($ACTIVE_MAX_ENERGY_SESSION==0) {
    $ACTIVE_MAX_ENERGY_SESSION=FixEnergy($MAX_ENERGY_SESSION);
  }
}

sub Cmd
{
  my ($sock,$i)=@_;
  my ($buffer,$s,$section,@s,@time,$t,$wrange,$trange,$desc,$last_limit);
  my ($k,$changed,$param);
  my $now=time();
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($now);
  $mon++; $year+=1900;
  $sec+=$min*60+$hour*3600;

  @s=stat($cfg_file);
  if($s[9]>$last_cfg_file || $last_year!=$year) {
    $read_trans=0;
    @oldkeys=@confkey;
    @allowed_phases=();
    ReadConf();
    $last_year=$year; # Already done in ReadConf(), just to be sure
    if($s[9]>$last_cfg_file) {
      MQTT_HA();
      MQTT_ReConf();
    }
    $last_cfg_file=$s[9];
    if(join(" ",@oldkeys) ne join(" ",@confkey)) {
      verbose(10,"OLD=".join(" ",@oldkeys)."\n");
      verbose(10,"NEW=".join(" ",@confkey)."\n");
      # Configuration keys changed, trigger BootNotification to set keys
      my $uuid=GenUUID();
      $buffer="[2,\"$uuid\", \"TriggerMessage\", {\"requestedMessage\": \"BootNotification\"}]";
      PushQueue($buffer,"TriggerMessage.*BootNotification");
    }
  }
  else {
    # Be sure default params are set:
    if(length($WBMINPOWER)==0) {
      SetDefaultParams();
    }
  }

  if(Holiday($mon,$mday)) { $wday=0; }

  #$timeslot=TimeSlot($sec,$wday); # Global variable, no more useful since used only when updating energy counters, 
                                   # and the calculation of time slot is done inside the function UpdatePVEnergy.

  if(-f "$basedir/cmd.dat") {
    if(open(C,"$basedir/cmd.dat"))
    {
      while(<C>) {
        $buffer.=$_;
      }
      close(C);
      PushQueue($buffer);
    }
    unlink("$basedir/cmd.dat");
  }
  elsif($bootok<=0 && $bootok>=-20 && (time()-$boottime)>150) {
    my $uuid=GenUUID();
    $buffer="[2,\"$uuid\", \"TriggerMessage\", {\"requestedMessage\": \"BootNotification\"}]";
    $boottime=time();
    PushQueue($buffer,"TriggerMessage.*BootNotification");
    $uuid=GenUUID();
    $buffer="[2,\"$uuid\", \"TriggerMessage\", {\"requestedMessage\": \"StatusNotification\"}]";
    PushQueue($buffer,"TriggerMessage.*StatusNotification");
    if($QUEUE_WAIT_BOOT==0) { $QUEUE_WAIT_BOOT=10; }
    $queue_wait=$QUEUE_WAIT_BOOT;
    $STATUS="Updating";
    $bootok--;
  }

  if($#allowed_phases<0) {
    # Check the number of phases allowed to set:
    @switch_phase_up=();
    @switch_phase_down=();
    for($s=0;$s<$nsmart;$s++) {
      $section=$smart[$s];
      if(!CheckPresence($smart{$section},@wallbox_params)) { next; }
      if(length($smart{$section}{WALLBOX_NPHASES})) {
	@allowed_phases=split(",",$smart{$section}{WALLBOX_NPHASES});
	if(length($smart{$section}{WALLBOX_CURRENT_SWITCH_PHASE_UP})>0) {
	  @switch_phase_up=split(",",$smart{$section}{WALLBOX_CURRENT_SWITCH_PHASE_UP});
	}
	else {
	  for($k=0;$k<$#allowed_phases;$k++) {
	    $switch_phase_up[$k]=$MINPOWER*$allowed_phases[$k+1];
	  }
	}
	if(length($smart{$section}{WALLBOX_CURRENT_SWITCH_PHASE_DOWN})>0) {
	  @switch_phase_down=split(",",$smart{$section}{WALLBOX_CURRENT_SWITCH_PHASE_DOWN});
	}
	else {
	  for($k=1;$k<=$#allowed_phases;$k++) {
	    $switch_phase_down[$k]=$MINPOWER*$allowed_phases[$k];
	  }
	}
      }
      else {
	@allowed_phases=(0);
      }
    }
  }
  if($MQTT_started_published<0) {
    # Check if we have to stop pre-charging
    if((Now()-abs($MQTT_started_published))>120) {
      StopCharging();
    }
  }

  if($STATUS eq "STOPEV" && $STOP_ON_SUSPENDEV>0 && length($currTransaction)>0) {
    if($stopev_start<=0) {
      $stopev_start=time();
    }
    elsif((time()-$stopev_start)>$STOP_ON_SUSPENDEV) {
      verbose(5,"EV had suspended charging for more than $STOP_ON_SUSPENDEV seconds, sending RemoteStopTransaction ($currTransaction)\n");
      $SUBSTATUS="";
      StartStop(0,0,$currTransaction); 
      if(length($FIXED)>0) {
	if($deflimit ne $FIXED) { DefaultLimit($FIXED,PowerWallboxMax($FIXED)); }
      }
      else {
	if($deflimit!=MinDefLimit() || WallboxParam("WALLBOX_SET_LIMIT_ZERO_ON_STOP")) { DefaultLimit(WallboxLimitZero(),1000); }
      }
      $stopev_start=-2;
    }
  }
  else {
    $stopev_start=-1;
  }

  # Check for PV shutdown
  if($PV_MQTT_TIMEOUT>0 && $lastpv>0 && defined($mypv{power})) {
    if(($now-$lastpv)>$PV_MQTT_TIMEOUT) {
      %mypv=();
    }
  }

  # If smartcharging not defined, it means that no wallbox connected to Websocket/OCPP,
  # but there could be a connected wallbox via MQTT only.
  if(!defined($smartcharging) && (time()-$boottime)<600 && length(WallboxParam("WALLBOX_MQTT_GET_BASE"))==0) { return; }

  # GRID LIMITS:
  for($s=0;$s<$nsmart;$s++) {
    $section=$smart[$s];
    if(!CheckTag($smart{$section}{ENABLE})) { next; }
    if(!CheckPresence($smart{$section},@grid_params)) { next; }

    @time=@{$smart{$section}{TIME}};
    if($#time<0) { @time=("0-86400"); }

    for($t=0;$t<=$#time;$t++)
    {
      ($trange,$wrange)=split('@',$time[$t]);
      if(length($wrange)==0) { $wrange=$smart{$section}{WEEKDAY}; }
      verbose(19,"Checking $section ($currGrid) $GRID_LIMIT $trange ($sec) $wrange ($wday) $smart{$section}{YEARDAY} ($yday)\n");

      if(InRange($wrange,$wday) 
	 && InRange($trange,$sec,1) 
	 && InRange($smart{$section}{YEARDAY},$yday)
	)
      {
	# Check if something is changed:
	$currGrid=$section;
	if(CheckChanged($smart{$section},@grid_params))
	{
	  $last_limit=$GRID_LIMIT;
	  SetSmart($smart{$section},@grid_params);
	  verbose(7,"Setting grid limits '$section' profile: MAX=$GRID_LIMIT/$GRID_LIMIT_SAFE($GRID_LIMIT_SAFE_REDUCE), TIME=$GRID_LIMIT_MAXTIME/$GRID_LIMIT_REDUCETIME/$GRID_LIMIT_PAUSE/$GRID_LIMIT_RESTART_PAUSE\n");
	  MQTT_ActiveGrid();
	  MQTT_PublishLimit($wallbox,{});
	}
	last;
      }
    }
    if($t<=$#time) { last; }
  }
  if($s==$nsmart) {
    # No grid profile active, set maximum
    $currGrid="";
    if(CheckChanged(\%default,@grid_params))
    {
      $last_limit=$GRID_LIMIT;
      SetSmart(\%default,@grid_params);
      verbose(7,"Setting default grid limits: MAX=$GRID_LIMIT/$GRID_LIMIT_SAFE($GRID_LIMIT_SAFE_REDUCE), TIME=$GRID_LIMIT_MAXTIME/$GRID_LIMIT_REDUCETIME/$GRID_LIMIT_PAUSE/$GRID_LIMIT_RESTART_PAUSE\n");
      MQTT_ActiveGrid();
      MQTT_PublishLimit($wallbox,{});
    }
  }

  if($GRID_LIMIT_SAFE>0 && $GRID_LIMIT_SAFE_REDUCE>0 && $GRID_LIMIT_SAFE>$GRID_LIMIT_SAFE_REDUCE) {
    $GRID_LIMIT_TOLERANCE=($GRID_LIMIT_SAFE-$GRID_LIMIT_SAFE_REDUCE);
  }
  else {
    $GRID_LIMIT_TOLERANCE=50;
  }

  if(defined($last_limit))
  {
    if($GRID_LIMIT>$last_limit) {
      # Setting quick increase of power
      $transaction_started=$MAXPOWER;
      $recalculate=0;
    }
    elsif($GRID_LIMIT<$last_limit) {
      if($currOffered>0 && $currPower>$GRID_LIMIT) {
        # Decrease power to avoid grid-limit warning suspend
	my $newPower=intPower(PowerOffered()-($currPower-$GRID_LIMIT+2*ActVoltWallbox()));
	if($newPower<($WBMINPOWER*ActVoltWallbox())) {
	  $newPower=intPower(WallboxCurrAdd($WBMINPOWER)*ActVoltWallbox());
	}
	my $newOffered=CurrOffered()-TruncFineStep(($currPower-$GRID_LIMIT)/ActVoltWallbox()+2);
	if($newOffered<$WBMINPOWER) {
	  $newOffered=$WBMINPOWER;
	}
	NewOffered($newOffered,$newPower,$currTransaction,1);
      }
    }
  }

  # Check for Base Load:
  for($s=0;$s<$nsmart;$s++) {
    $section=$smart[$s];
    if(!CheckTag($smart{$section}{ENABLE})) { next; }
    if(!CheckPresence($smart{$section},@baseload_params)) { next; }

    @time=@{$smart{$section}{TIME}};
    if($#time<0) { @time=("0-86400"); }

    for($t=0;$t<=$#time;$t++)
    {
      ($trange,$wrange)=split('@',$time[$t]);
      if(length($wrange)==0) { $wrange=$smart{$section}{WEEKDAY}; }
      verbose(19,"BaseLoad $section: $trange ($sec) $wrange ($wday) $smart{$section}{YEARDAY} ($yday)\n");
      if(InRange($wrange,$wday) 
	 && InRange($trange,$sec,1) 
	 && InRange($smart{$section}{YEARDAY},$yday)
	)
      {
	# Check if something was changed:
        $currBaseload=$section;
	if(CheckChanged($smart{$section},@baseload_params))
	{
	  SetSmart($smart{$section},@baseload_params);
	  verbose(8,"Setting baseload '$section' to $BASELOAD\n");
	  MQTT_ActiveBaseload();
          MQTT_PublishLimit($wallbox,{});
	}
	last;
      }
    }
    if($t<=$#time) { last; }
  }
  if($s==$nsmart) {
    # No baseload profile active, switch to default
    $currBaseload="";
    if(CheckChanged(\%default,@baseload_params))
    {
      SetSmart(\%default,@baseload_params);
      verbose(8,"Setting default baseload ($BASELOAD)\n");
      MQTT_ActiveBaseload();
      MQTT_PublishLimit($wallbox,{});
    }
  }

  if(length($MQTT_FIXED)>0 && $MQTT_STARTED>0) {
    # Custom MQTT power handling
    if($FIXED ne $MQTT_FIXED) {
      verbose(8,"Setting FIXED value $MQTT_FIXED from MQTT\n");
      $FIXED=$MQTT_FIXED;
    }
  }
  else {
    # Check for Smart Charging:
    for($s=0;$s<$nsmart;$s++) {
      $section=$smart[$s];
      if(!CheckTag($smart{$section}{ENABLE}) || 
	length($smart{$section}{MAXPOWER_SUSPEND}.$smart{$section}{FIXED})==0) 
	{ next; }
      @time=@{$smart{$section}{TIME}};
      if($#time<0) { @time=("0-86400"); }

      for($t=0;$t<=$#time;$t++)
      {
	($trange,$wrange)=split('@',$time[$t]);
	if(length($wrange)==0) { $wrange=$smart{$section}{WEEKDAY}; }
	verbose(19,"Checking $section ($currProfile): $trange ($sec) $wrange ($wday) $smart{$section}{YEARDAY} ($yday)\n");

	if(InRange($wrange,$wday) 
	   && InRange($trange,$sec,1) 
	   && InRange($smart{$section}{YEARDAY},$yday)
	  )
	{
	  # Check if something is changed:
	  if(CheckChanged($smart{$section},@profile_params) ||
	     $currProfile ne $section
	    )
	  {
	    SetSmart($smart{$section},@profile_params);
	    if(length($FIXED)>0) {
	      $desc="FIXED=$FIXED (T=$currTransaction)";
	      if($smartcharging>0) {
		my $alreadyset=0;
		if((!CheckStop() || $USE_STOP_AS_SUSPEND) && length($currTransaction)) {
		  my $newOffered=Ampere($FIXED);
		  my $newPower=PowerWallbox($FIXED);
		  if($FIXED!=0) {
		    if($GRID_LIMIT>0) {
		      # Limit the maximum current to the actual grid limit
    		      my $power=$newPower-PowerOffered();
    		      if(($currPower+$power)>($GRID_LIMIT-$GRID_LIMIT_TOLERANCE)) {
	                my $co=CurrOfferedFull();
			$newPower=intPower($GRID_LIMIT-$currPower+PowerOffered()-$GRID_LIMIT_TOLERANCE);
			verbose(17,"GL=$GRID_LIMIT, CP=$currPower, CO=$co, V=".MaxActVolt()."\n");
			$newOffered=TruncFineStep(($GRID_LIMIT-$currPower)/MaxActVolt()+1+CurrOffered());
		      }
		    }
		    SetTransactionFull();
		  }
		  if(!$USE_STOP_AS_SUSPEND || !CheckStop() || $FIXED>0) {
		    if($USE_STOP_AS_SUSPEND && CheckStop()) {
		      $alreadyset=1;
		    }
		    NewOffered($newOffered,$newPower,$currTransaction);
		  }
		}
		if(!$alreadyset) {
		  if(CheckStop() && WallboxParam("WALLBOX_SET_LIMIT_ZERO_ON_STOP")) { DefaultLimit($FIXED,PowerWallboxMax($FIXED),1000); }
		  elsif($deflimit ne $FIXED) { DefaultLimit($FIXED,PowerWallboxMax($FIXED)); }
	        }
	      }
	      else {
		if(($FIXED>0 && $STATUS eq "STOP" && $smartcharging>=-1)||($FIXED==0 && !CheckStop())) {
		  if($FIXED>0) {
		    SetTransactionFull();
		  }
		  SubStatus();
		  StartStop($FIXED,PowerWallboxMax($FIXED));
		}
	      }
	    }
	    else {
	      $desc="MAX=$MAXPOWER_SUSPEND/$MAXPOWER_REDUCE, MIN=$MINPOWER_START/$MINPOWER_INCREASE";
	      if(CheckStop()) { DefaultLimit(0,0,1000); }
	      elsif($deflimit!=MinDefLimit()) { DefaultLimit(0,0); }
	    }
	    verbose(7,"Setting ".($smartcharging>0?"smart ":"")."charging '$section' profile: $desc, WAIT=$WAIT_CHANGE\n");
	    if($STATUS eq "SUSPEND" || ($STATUS eq "STOP" && $USE_STOP_AS_SUSPEND) || $currProfile ne $section) {
	      $transaction_started=$MAXPOWER;
	    }
	    $currProfile=$section;
	    MQTT_ActiveProfile();
            MQTT_PublishLimit($wallbox,{});
	  }
	  last;
	}
      }
      if($t<=$#time) { last; }
    }
    if($s==$nsmart) {
      # No smart charging profile active, set maximum
      $currProfile="";
      if(CheckChanged(\%default,@profile_params))
      {
	SetSmart(\%default,@profile_params);
	verbose(7,"No active profiles, always charge at maximum power ($MAXPOWER)\n");
        MQTT_ActiveProfile();
	MQTT_PublishLimit($wallbox,{});
      }
    }
  }

  if($bootok>0 && $BASELOAD>=0) {
    # Check if we have meter, otherwise simulate
    if($lastmeter==0) {
      # Not yet defined, do it now (allow 100 seconds to arrive DataTransfer message)
      $lastmeter=-$now-60;
    }
    elsif($lastmeter<0) {
      if(($now-abs($lastmeter))>40) {
        DataTransfer({"now"=>$now,"vendorId"=>"localemu","messageId"=>"local","data"=>"{\"type\": \"BaseLoad\", \"power\": \"$BASELOAD\" }"});
      }
    }
  }
}

$func_loaded=time();

#SetTransactionFull();
#verbose(3,"TRANSACTION: $TRANSACTION ($currSub // $currTransaction // $currTransactionFull) $LAST_WH ($prevLAST_WH) $LAST_SPAN PV=$LAST_PV / ST=$START_TIME / SS=$START_SESSION / AT=$LAST_AVGACOUNT * $LAST_AVGASUM\n");

#RESETTING Incorrect subsession increase after restart (bug now fixed):
#SaveConf();
#system("cp -p trans.ini trans.ini.securebackup");
##$avgAsum+=$LAST_AVGASUM; 
#$LAST_AVGASUM=0;
##$avgAcount+=$LAST_AVGACOUNT; 
#$LAST_AVGACOUNT=0;
##$avgCURsum+=$LAST_AVGCURSUM; 
#$LAST_AVGCURSUM=0;
#$lastchgwh-=$LAST_WH;
#$LAST_WH=0;
#$LAST_SPAN=0;
##$pvwh+=$LAST_PV;
#$LAST_PV=0;
#for(my $i=0;$i<=$#timeslot;$i++) { 
#  #$tswh[$i]+=$LAST_TSWH[$i]; 
#  $LAST_TSWH[$i]=0;
#  #$pvwh[$i]+=$LAST_PVWH[$i]; 
#  $LAST_PVWH[$i]=0;
#}
#$START_SESSION=1770541833;
#$currTransaction=227;
#$currSub=8;
#SetTransactionFull();
#$START_TIME=$START_SESSION;
#$SUBSTATUS="SUSPENDSTART";
#print "ST=$START_TIME - SS=$START_SESSION\n";
#SaveConf();

1;
