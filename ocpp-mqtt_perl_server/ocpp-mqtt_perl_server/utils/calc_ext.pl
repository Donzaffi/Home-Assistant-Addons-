#!/usr/bin/perl
#
# SPDX-FileCopyrightText: 2023-2025 Luca Bonissi <wallbox@bonissi.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

use Time::Local;

$file=shift;
$filter=shift || "[ASQFUHT]|^-";

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
  my($v,$last)=@_;
  $v=~s/ //g;
  if(length($v)==0 || $v eq "*") {
    $v=$last;
  }
  else {
    $v=$v+0;
  }
  return($v);
}

sub LoadkWh {
  my $k=0;
  if(open(K,"$kwh_file")) {
    #Date____-Time 	Odo	SOC/SOCBMS/KM	REMkWh	V	CEC	CED			TBatt	BattAVG	TOutIn	AC(kWh)	Count	DC	Count	HourAC	HourDC	TMotInv	TCool21	TEvap
    #Date____-Time___ 	Odo	SOC/SOCBMS/KM	REMkWh	V	CEC	CED	CCC	CCD	TBatt	BattAVG	TOutIn	AC(kWh)	Count	DC(Tm)	Count	HourAC	HourDC	TMotInv	TCool21	TEvap
    while(<K>)
    {
      chop;
      if(!m/^\d/) { next; }
      ($dt,$odo,$soc,$remain,$voltage,$cec,$ced,$ccc,$ccd,$tbatt,$battavg,$toutin,$ackwh,$account,$dctime,$dccount)=split("\t");
      $cec=duplast($cec,$lastcec);
      $ced=duplast($ced,$lastced);
      $ackwh=duplast($ackwh,$lastackwh);
      $dctime=duplast($dctime,$lastdctime);
      $kwh[$k]{time}=TimeSecKwh($dt);
      $kwh[$k]{tstart}=$kwh[$k]{time}-60;
      $kwh[$k]{tend}=$kwh[$k]{time}+60;
      $kwh[$k]{remain}=$remain;
      $kwh[$k]{cec}=$cec;
      $kwh[$k]{ced}=$ced;
      $kwh[$k]{ackwh}=$ackwh;
      $kwh[$k]{dc}=$dctime;
      #print "$dt\t$ackwh\t$dctime\n";

      $lastcec=$cec;
      $lastced=$ced;
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
  if($lastkwh>0 && $lastkwh_tot>0) {
    my $factor=1;
    if($lastkwh!=$lastkwh_tot) {
      $factor=$lastkwh/$lastkwh_tot;
    }
    $ac=sprintf("%d",($kwh[$ke]{ackwh}-$kwh[$k]{ackwh})*$factor);
    $cec=sprintf("%.1f",($kwh[$ke]{cec}-$kwh[$k]{cec})*$factor);
    $rem=sprintf("%d",($kwh[$ke]{remain}-$kwh[$k]{remain})*$factor);
    $dc=sprintf("%d",($kwh[$ke]{dc}-$kwh[$k]{dc})*$factor);
    $totac+=$ac;
    $totcec+=$cec;
    $totrem+=$rem;
    $totdc+=$dc;
    #print "Flushing\t$cec\t$rem\t$ac\t$dc\n";
  }
  $lastkwh=$lastkwh_tot=0;
}

if($filter=~m/^-/) {
  $filter="^\\d+$filter";
}
if($filter eq "F") {
  # Maybe you want only Fast, not Fast+
  $filter="F[\\d\\*]*\$";
}
if($filter eq "F+") {
  # Maybe you want only Fast, not Fast+
  $filter="F\\+";
}

LoadkWh();

if(!open(F,$file)) {
  print STDERR "Cannot open file $file: $!\n";
  exit 1;
}

print "FILTER=$filter\n";

#$head=<F>; # Head automatically skipped
print "StartTimeTxt\tEndTimeTxt\tDurat.\tkWh\tAvgKw\n";
$k=0;
$ke=1;
$count=0;
while(<F>)
{
 chop;
 ($TransID,$StartTime,$EndTime,$kWh,$time,$avgkW,$avgA,$Cost,$Card,$Station)=split("\t");
 if(m/^#|^Trans/) { next; }
 $TransID=~s/ //g;
 $calccar=1;
 $addcount=1;
 $test=0;
 if(substr($EndTime,0,1) eq "-" || $TransID eq "-") {
   $calccar=0;
   $addcount=0;
 }
 if($TransID=~m/\!$/) {
   if(($StartTime-$lastjoin)<(8*60*60)) {
     $addcount=0;
   }
   $lastjoin=$EndTime;
 }
 if($calccar) {
   if($TransID=~m/\*$/) {
     $addcount=0;
     $test=1;
   }
   # Get the current kwh index
   while($k<$#kwh && $kwh[$k+1]{tstart}<$StartTime) {
     # Flush last car's kwh
     FlushkWh();
     $k++;
   }
   while($ke<=$#kwh && $kwh[$ke]{tend}<$EndTime) {
     $ke++;
   }
 }
 if($TransID=~m/$filter/) {
   #print "C=$Cost / $time / $_\n";
   $ac=sprintf("%d",($kwh[$ke]{ackwh}-$kwh[$k]{ackwh}));
   $cec=sprintf("%.1f",($kwh[$ke]{cec}-$kwh[$k]{cec}));
   $rem=sprintf("%d",($kwh[$ke]{remain}-$kwh[$k]{remain}));
   $dc=sprintf("%d",($kwh[$ke]{dc}-$kwh[$k]{dc}));
   ($st,$stt)=split(" ",$StartTime);
   ($et,$ett)=split(" ",$EndTime);
   print "$stt\t$ett\t$time";
   if($test) { print "*"; }
   print "\t$kWh";
   $tt=$EndTime-$StartTime;
   if($tt<=0) { $avg="-"; }
   else { $avg=sprintf("%.2f",$kWh*3600/$tt); }
   #print "\t$tt";
   print "\t$avg";
   if($Cost==0) {
     $totkwh_f+=$kWh;
   }
   if($addcount) { $count++; }
   if($calccar) {
     print "\t";
     if($tt>0) {
       printf("%.2f",$kWh/($tt/3600));
     }
     $tottime+=$tt;
     $lastkwh+=$kWh;
     print "\t$cec\t$rem\t$ac\t$dc\t$count";
     if($kWh>0) {
       $effcec=sprintf("%.1f%%",100*$cec/$kWh);
       $effrem=sprintf("%.1f%%",0.1*$rem/$kWh);
       print "\t$effcec\t$effrem";
     }
     if($test) { 
       $testtime+=$EndTime-$StartTime; 
       $testcount++;
       $testkwh+=$kWh;
     }
   }
   print "\n";
   $totkwh+=$kWh;
   $totcost+=$Cost;
 }
 if($calccar) {
   $lastkwh_tot+=$kWh;
 }
}
close(F);
FlushkWh();

$effcec=$effrem="";
if($totkwh>0) {
  $effcec=sprintf("%.1f%%",100*$totcec/$totkwh);
  $effrem=sprintf("%.1f%%",0.1*$totrem/$totkwh);
}
printf("TOT kWh  = %.3f\n",$totkwh);
printf("kWh free = %.3f\n",$totkwh_f);
printf("kWh paid = %.3f\n",$totkwh-$totkwh_f);
printf("TEST kWh = %.3f\n",$testkwh);
printf("\n");
printf("TOT CEC  = %.3f (eff. %s)\n",$totcec,$effcec);
printf("TOT BAT  = %.3f (eff. %s)\n",$totrem*0.001,$effrem);
printf("TOT AC   = %d\n",$totac);
printf("TOT DC   = %d\n",$totdc);
$ck=$ckp=0;
if($totkwh>0) { 
  $ck=$totcost/$totkwh;
}
if(($totkwh-$totkwh_f)>0) { 
  $ckp=$totcost/($totkwh-$totkwh_f);
}
$time=$tottime;
$h=int($time/3600);
$m=int(($time-$h*3600)/60+0.5);
printf("TIME     = %d:%02d\n",$h,$m);
$time=$testtime;
$h=int($time/3600);
$m=int(($time-$h*3600)/60+0.5);
printf("TEST TIME= %d:%02d\n",$h,$m);
printf("SESSIONS = $count\n");
printf("TESTS    = $testcount\n");
if($count>0) {
$time=($tottime-$testtime)/$count;
$h=int($time/3600);
$m=int(($time-$h*3600)/60+0.5);
if($tottime>0) {
printf("AVGPOWER = %.1f\n",$totkwh*3600/$tottime);
}
printf("AVGTIME  = %d:%02d\n",$h,$m);
}
printf("paid Cost= %.2f (charged %.2f - %.2f E/kWh // real %.2f - %.2f E/kWh)\n",$totcost,$ck,$ckp,$ck*100/$effrem,$ckp*100/$effrem);
