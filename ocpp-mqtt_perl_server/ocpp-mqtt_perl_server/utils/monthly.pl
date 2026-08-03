#!/usr/bin/perl
#
# SPDX-FileCopyrightText: 2023-2025 Luca Bonissi <wallbox@bonissi.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

#StartTime	EndTime	Durat.	kWh	AvgKW	AvgA	PV	PV%	Cost	Euro/kWh
#231125-12:54	12:56	0h02'	0.102	3.01kW	--	0.042	41%	0.02	0.166	P=0.00	G=0.01	2.1	1.8	0	871.4%	746.9%


while(<>) {
  if(!m/^\d/) { next; }
  ($st,$et,$dur,$kwh,$kw,$A,$pv)=split("\t");
  if($kwh<0) { 
    # V2L, skip
    next;
  }
  if(length($et)==0) {
    # From aurora
    $format="aurora";
    ($st,$kwh)=split;
    $st=substr($st,2);
  }
  $mon=substr($st,2,2);
  $pv[$mon]+=$pv;
  $kwh[$mon]+=$kwh;
}

if($format eq "aurora") {
  print "MON\tGEN\n";
}
else {
  print "MON\t%\tTOT\tPV\n";
}
for($i=1;$i<=12;$i++) {
  if($kwh[$i]>0) {
    if($format eq "aurora") {
      print "$i\t$kwh[$i]\n";
    }
    else {
      $p=sprintf("%.1f",$pv[$i]*100/$kwh[$i]);
      print "$i\t$p\t$kwh[$i]\t$pv[$i]\n";
    }
  }
}

