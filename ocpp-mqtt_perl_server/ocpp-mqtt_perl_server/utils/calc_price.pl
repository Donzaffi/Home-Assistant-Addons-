#!/usr/bin/perl
#
# SPDX-FileCopyrightText: 2023-2025 Luca Bonissi <wallbox@bonissi.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

use Time::Local;

$VERSION="0.02";

$charge=shift;
$pvperc=shift;
$price="price.txt";
$gseprice="gse_price.csv";
$pvlog="pv.log";

$kwh_file="kwh.txt";

sub TimeSecKwh {
  my $t=shift;
  my ($year,$mon,$mday,$hh,$mm);
  $year=substr($t,0,4);
  $mon=substr($t,4,2);
  $mday=substr($t,6,2);
  $hh=substr($t,9,2);
  $mm=substr($t,12,2);
  $t=timelocal(0,$mm,$hh,$mday,$mon-1,$year);
  return($t);
}

sub duplast {
  my($v,$last,$hist,$tag)=@_;
  $v=~s/ //g;
  if(length($v)==0 || $v eq "*") {
    $v=$last;
  }
  else {
    $v=$v+$$hist;
  }
  if($v<$last) { # Reset counters bug...
    print STDERR "$dt - $odo) WARNING: counter $tag reset ($v / $last / $$hist)...\n";
    $v=$v-$$hist;
    $$hist=$last;
    $v+=$$hist;
  }
  return($v);
}

$hcec=$hced=$hackwh=$hdctime=$hccc=$hccd=0;

sub LoadkWh {
  my $k=0;
  if(open(K,"$kwh_file")) {
    #Date____-Time___ 	Odo	SOC/SOCBMS/KM	REMkWh	V	CEC	CED	CCC	CCD	TBatt	BattAVG	TOutIn	AC(kWh)	Count	DC(Tm)	Count	HourAC	HourDC	TMotInv	TCool21	TEvap
    while(<K>)
    {
      chop;
      if(!m/^\d/) { next; }
      ($dt,$odo,$soc,$remain,$voltage,$cec,$ced,$ccc,$ccd,$tbatt,$battavg,$toutin,$ackwh,$account,$dctime,$dccount)=split("\t");
      if($soc=~m|/.*/|) {
        ($soc)=($soc=~m|(.*/.*?)/|);
      }
      $cec=duplast($cec,$lastcec,\$hcec,"CEC");
      $ced=duplast($ced,$lastced,\$hced,"CED");
      $ccc=duplast($ccc,$lastccc,\$hccc,"CCC");
      $ccd=duplast($ccd,$lastccd,\$hccd,"CCD");
      $ackwh=duplast($ackwh,$lastackwh,\$hackwh,"ACKWH");
      $dctime=duplast($dctime,$lastdctime,\$hdctime,"DCTIME");
      $kwh[$k]{time}=TimeSecKwh($dt);
      $kwh[$k]{tstart}=$kwh[$k]{time}-60;
      $kwh[$k]{tend}=$kwh[$k]{time}+60;
      $kwh[$k]{remain}=$remain;
      $kwh[$k]{cec}=$cec;
      $kwh[$k]{ced}=$ced;
      $kwh[$k]{ccc}=$ccc;
      $kwh[$k]{ccd}=$ced;
      $kwh[$k]{ackwh}=$ackwh;
      $kwh[$k]{dc}=$dctime;
      $kwh[$k]{soc}=$soc;
      if($battavg=~m/\./) {
        # Reduce length
	$point=$battavg;
	$point=~s/^.*?\.//;
	$battavg=~s/\..*/./;
	if($point<5) {
	  chop($battavg);
	}
      }
      $kwh[$k]{temp}=$battavg;
      ($out,$in)=split("/",$toutin);
      $kwh[$k]{out}=$out;
      #print "$dt\t$ackwh\t$dctime\n";

      $lastcec=$cec;
      $lastced=$ced;
      $lastccc=$ccc;
      $lastccd=$ccd;
      $lastackwh=$ackwh;
      $lastdctime=$dctime;
      $lastremain=$remain+0;
      $k++;
    }
    close(K);
  }
}

sub FlushkWh 
{
  if($lastkwh>0) {
    $ac=sprintf("%d",($kwh[$ke]{ackwh}-$kwh[$k]{ackwh}));
    $cec=sprintf("%.1f",($kwh[$ke]{cec}-$kwh[$k]{cec}));
    $ccc=sprintf("%.1f",($kwh[$ke]{ccc}-$kwh[$k]{ccc}));
    $rem=sprintf("%d",($kwh[$ke]{remain}-$kwh[$k]{remain}));
    $dc=sprintf("%d",($kwh[$ke]{dc}-$kwh[$k]{dc}));
    if($lastkwh>0) {
      $effcec=sprintf("%.1f%%",100*$cec/$lastkwh);
      $effrem=sprintf("%.1f%%",0.1*$rem/$lastkwh);
    }
    else {
      $effcec="";
      $effrem="";
    }
    $totac+=$ac;
    $totcec+=$cec;
    $totccc+=$ccc;
    $totrem+=$rem;
    $totdc+=$dc;
    $temp1="$kwh[$ke]{temp}/$kwh[$k]{temp}";
    $temp2="$kwh[$ke]{out}/$kwh[$k]{out}";
    if(length($temp2)>=8) { $temp2=~s/\.5/./g; }
    if($lasttime>0) {
      $kw=sprintf("%.2f",$lastkwh*3600/$lasttime);
    }
    else {
      $kw=0;
    }
    print "Flushing [ $kwh[$k]{soc} ]\t$lastStart\t$lastkwh\t$cec\t$rem\t$ac\t$kw\t$effcec\t$effrem\t$ccc\t$temp1\t$temp2\n";
  }
  $lastkwh=0;
  $lasttime=0;
}


if(length($charge)==0 || length($price)==0) {
  print STDERR "Usage: $0 <charge_log_file>\n";
  exit(1);
}

LoadkWh();

if(!open(P,$price)) 
{
  print STDERR "Error opening price file $price: $!\n";
  exit(1);
}

while(<P>)
{
  chop;
  #YEARMM	PF1	PF2	PF3	GF1	GF2	GF3	CUS
  ($YEARMM,$PF1,$PF2,$PF3,$GF1,$GF2,$GF3,$CUS)=split("\t");
  $price{$YEARMM}{pf1}=$PF1;
  $price{$YEARMM}{pf2}=$PF2;
  $price{$YEARMM}{pf3}=$PF3;
  $price{$YEARMM}{gf1}=$GF1;
  $price{$YEARMM}{gf2}=$GF2;
  $price{$YEARMM}{gf3}=$GF3;
  $price{$YEARMM}{cus}=$CUS;
  %lastprice=%{$price{$YEARMM}};
}
close(P);

if(!open(P,$pvlog)) 
{
  print STDERR "Error opening PV log file $pvlog $!\n";
  exit(1);
}
while(<P>)
{
  chop;
  #DATE-----HR	TID	Tot	PV	Grid
  #20231109-22	1	2	0	2
  ($date,$tid,$tot,$pv,$grid)=split("\t");
  (${YEARMMDD},$h)=split("-",$date);
  $h=$h+0;
  $date="${YEARMMDD}_$h";
  $price{$date}=-10000;
  push(@{$pv{$tid}},"$date\t$pv\t$grid");
}
close(P);

if(!open(P,$gseprice)) 
{
  print STDERR "Error opening GSE price file $gseprice: $!\n";
  exit(1);
}
while(<P>)
{
  chop;
  ($YEARMMDD,$h,$p)=split("\t");
  $h=$h-1;
  $date="${YEARMMDD}_$h";
  if(exists($price{$date})) {
    $price{$date}=$p*0.001;
  }
}
close(P);

# Elaborate PV price
foreach $k (keys %pv) {
  $p=0;
  @pv=@{$pv{$k}};
  for($i=0;$i<=$#pv;$i++) {
    ($date,$pv,$grid)=split("\t",$pv[$i]);
    $p+=$price{$date}*$pv;
  }
  $pvprice{$k}=$p;
}

if(!open(C,$charge)) {
  print STDERR "Error opening charge file $charge $!\n";
  exit(1);
}

$ke=1;
$k=0;
print "StartTime\tEndTime\tDurat.\tkWh\tAvgKW\tAvgA\tPV\tPV%\tCost\tEuro/kWh\n";
#  print substr($StartTime,11)."\t",substr($EndTime,18),"\t$time\t$kWh\t$avgkW\t$avgA\t$PV\t".sprintf("%.0f%%\t%.2f\t%.3f\t%s",$ppv,$cost,$costkwh)."\n";
while(<C>)
{
  chop;
  ($TransID,$StartTime,$EndTime,$TkWh,$Ttime,$TavgkW,$kWh,$time,$avgkW,$avgA,$PV,$F1,$F2,$F3,$Cost)=split("\t");
  if(m/^#/ || !($StartTime=~m/^\d/)) {
    next;
  }
  $sub++;
  if(!($TransID=~m/\d-/)) {
    $sessions++;
  }
  # Get the current kwh index
  while($k<$#kwh && $kwh[$k+1]{tstart}<$StartTime && $kwh[$k+1]{tend}<$EndTime) {
    # Flush last car's kwh
    FlushkWh();
    $k++;
  }
  while($ke<=$#kwh && $kwh[$ke]{tend}<$EndTime) {
    $ke++;
  }
  $lastkwh+=$kWh;
  $lasttime+=$EndTime-$StartTime;
  $ac=sprintf("%d",($kwh[$ke]{ackwh}-$kwh[$k]{ackwh}));
  $cec=sprintf("%.1f",($kwh[$ke]{cec}-$kwh[$k]{cec}));
  $rem=sprintf("%d",($kwh[$ke]{remain}-$kwh[$k]{remain}));
  if($lastkwh>0) {
    $effcec=sprintf("%.1f%%",100*$cec/$lastkwh);
    $effrem=sprintf("%.1f%%",0.1*$rem/$lastkwh);
  }
  else {
    $effcec="";
    $effrem="";
  }
  if(index($PV,"/")>=0) {
    @pvval=split("/",$PV);
  }
  else {
    @pvval=($PV);
  }
  @fslot=($F1,$F2,$F3);
  for($i=0;$i<3;$i++) {
    if($fslot[$i] eq "-") {
      $pvslot[$i]=0;
    }
    else {
      $pvslot[$i]=shift(@pvval);
    }
  }
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($StartTime+0);
  $ym=sprintf("%04d%02d",$year+1900,$mon+1);
  if(!defined($pricelocal=$price{$ym})) {
    $pricelocal=\%lastprice;
  }
  $cost=0;
  $ckwh=$PV;
  for($i=0;$i<3;$i++) {
    $i1=$i+1;
    #$cost+=$pvslot[$i]*$pricelocal->{"pf$i1"};
    $mycost=$fslot[$i]*($pricelocal->{"gf$i1"}-$pricelocal->{cus});
    $cost+=$mycost;
    $kwhslot[$i]+=$fslot[$i];
    $costslot[$i]+=$mycost;
    $ckwh+=$fslot[$i];
  }
  $gridcost=$cost;
  $pvcost=$pvprice{$TransID}*1.052;
  $costpv+=$pvcost;
  $cost+=$pvcost;
  if(sprintf("%.3f",$ckwh) ne sprintf("%.3f",$kWh)) {
    print "** WARNING: $ckwh <> $kWh for $StartTime\n";
  }
  $totcost+=$cost;
  $totkwh+=$kWh;
  $totpv+=$PV;
  $costkwh=0;
  $ppv=0;
  if($kWh>0) { 
    $costkwh=$cost/$kWh; $ppv=$PV/$kWh*100; $tottime+=$EndTime-$StartTime;
    if($pvperc<=0) { $pvperc=10; }
    if($ppv>$pvperc) { 
      $pvtime+=$EndTime-$StartTime;
      $pvtimekwh+=$PV;
      $pvtimetotkwh+=$kWh;
    }
  }
  #print "$StartTime\tt$kWh\t$PV\t".sprintf("%.0f%%\t%.2f\t%.3f\t%s",$ppv,$cost,$costkwh)."\n";
  $time=~s/:/h/;
  $time=~s/$/'/;
  print substr($StartTime,11)."\t",substr($EndTime,18),"\t$time\t$kWh\t$avgkW\t$avgA\t$PV\t".sprintf("%.0f%%\t%.2f\t%.3f\tP=%.2f\tG=%.2f\t%.1f\t%.1f\t%d\t$effcec\t$effrem",$ppv,$cost,$costkwh,$pvcost,$gridcost,$cec,$rem*0.001,$ac)."\n";
  $lastStart=substr($StartTime,11);
}
close(C);
FlushkWh();

print "\nTOT     = $totkwh kWh\n";
if($totkwh>0) {
    $effcec=sprintf("%.1f%%",100*$totcec/$totkwh);
    $effrem=sprintf("%.1f%%",0.1*$totrem/$totkwh);
    $effac=sprintf("%.1f%%",100*$totac/$totkwh);
}
$totrem=sprintf("%.1f",$totrem*0.001);
print "TOT CEC = $totcec kWh - $effcec\n";
print "TOT BAT = $totrem kWh - $effrem\n";
print "TOT AC  = $totac kWh - $effac\n";
$e=0;
if($totpv>0) { $e=$costpv/$totpv; }
print "TOT PV  = $totpv kWh ".sprintf("%.1f",100*$totpv/$totkwh)."% (".sprintf("%.2f Euro - %.3f E/kWh",$costpv,$e).")\n";
$totgrid=0;
$costgrid=0;
for($i=0;$i<3;$i++) {
  $e=0;
  if($kwhslot[$i]>0) { $e=$costslot[$i]/$kwhslot[$i]; }
  $totgrid+=$kwhslot[$i];
  $costgrid+=$costslot[$i];
  print "F".($i+1)."      = $kwhslot[$i] kWh (".sprintf("%.2f Euro - %.3f E/kWh",$costslot[$i],$e).")\n";
}
$e=0;
if($totgrid>0) { $e=$costgrid/$totgrid; }
print "TOTGRID = $totgrid kWh (".sprintf("%.2f Euro - %.3f E/kWh",$costgrid,$e).")\n";
$avgcost=$totcost/$totkwh;
print "TOTCOST = ".sprintf("%.2f Euro -- %.3f E/kWh - CEC. %.3f -  BAT %.3f",$totcost,$avgcost,$avgcost/$effcec*100,$avgcost/$effrem*100)."\n";
$h=int($tottime/3600);
$m=int(($tottime-$h*3600)/60+0.5);
printf("TOTTIME = %d:%02d\n",$h,$m);
printf("SESSIONS= $sessions/$sub\n");
if($tottime>0) {
  printf("AVGPOWER= %.1f kW\n",$totkwh*3600/$tottime);
  if($sessions>0) {
    $time=($tottime)/$sessions;
    $h=int($time/3600);
    $m=int(($time-$h*3600)/60+0.5);
    printf("AVGTIME = %d:%02d\n",$h,$m);
  }
}
$h=int($pvtime/3600);
$m=int(($pvtime-$h*3600)/60+0.5);
printf("PVTIME  = %d:%02d\n",$h,$m);
printf("PVTKWH  = %.1f (tot=%1.f)\n",$pvtimekwh,$pvtimetotkwh);
if($pvtime>0) {
  printf("AVGPV   = %.1f kW\n",$pvtimekwh*3600/$pvtime);
}
