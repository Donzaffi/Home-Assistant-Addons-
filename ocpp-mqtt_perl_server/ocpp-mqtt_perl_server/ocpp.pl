#!/usr/bin/perl
#
# SPDX-FileCopyrightText: 2023-2025 Luca Bonissi <wallbox@bonissi.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

#####################################################
####                                            #####
####  OCPP protocol server / ocpp 1.6j          #####
####                                            #####
####  JSON over Web Socket                      #####
####                                            #####
#####################################################

BEGIN {
 push(@INC,".");
};

use Time::HiRes qw(time sleep);
use Time::Local;

#use JSON;
use JSON::Tiny qw(decode_json encode_json);
use Net::MQTT::Simple;

use Fcntl;
use Socket;
use Symbol qw(gensym qualify);
use MIME::Base64;
use Digest::SHA qw(sha1);
use Errno qw(EINTR EAGAIN);
use POSIX;

$GUID="258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

$OS=$^O;

if($OS=~m/MSWin/) { $OS="Win"; }

############################
##### GLOBAL VARIABLES #####
############################

$VERSION{MAIN}="1.9919";

# LOGGING
$log_filename="ocpp.log";
$log_size=10_000_000;
$log_versions=50;
$log_opened=0;

$VERBOSE=9;

$charge_log="charge.log";

$basedir="/dev/shm/ocpp";

$datadir="";


$ini_library="ocpp_ini.pm";
$websocket_library="ocpp_ws.pm";
$mqtt_library="ocpp_mqtt.pm";
$func_library="ocpp_func.pm";

# Listen address and port
$listen_addr="0.0.0.0";
$listen_port[0]=9000;
$listen_port[1]=9001;

$MINPOWER=6;
$MAXPOWER=32;

$default{WAIT_CHANGE}=10;
$default{WAIT_ON_START}=1;
$default{AVG}=0;
$default{AVG_DEV}=0.05;
$default{AVG_HISTORIC_SEC}=900;
$default{AVG_CHANGING_SEC}=36;

$MAXPOWER_SUSPEND=$default{MAXPOWER_SUSPEND}=$MAXPOWER;
$MAXPOWER_REDUCE=$default{MAXPOWER_REDUCE}=$MAXPOWER;
$MAXPOWER_START=$default{MAXPOWER_START}=$MAXPOWER;
$MAXPOWER_INCREASE=$default{MAXPOWER_INCREASE}=$MAXPOWER;
$FIXED=$default{FIXED}=$MAXPOWER;

$VOLT_AVG=230;

$WAITDATA_TIMEOUT=10;
$MAX_OCPP_MQTT_WAIT=0.5;

@queue=();

# Smart charging
@smart=();
%smart=();


#############################
##### SIGNAL AND STDOUT #####
#############################

$|=1; # auto-flush stdout
$numsock=2;
$numclient=0;

sub sigquit {
  my ($sig)=@_;
  verbose(1,"Caught a SIG$sig. Close opened socket and quit.\n");
  SaveConf();
  CleanShutdown();
  close(PLOG);
  exit(0);
}

sub sigignore {
  my ($sig)=@_;
  $err=1;
  verbose(1,"Caught a SIG$sig, ignoring\n");
}

sub sigpipe {
  my ($sig)=@_;
  my ($i);
  $err=1;
  verbose(1,"Caught a SIG$sig, close all current connections\n");
  for($i=0;$i<$numclient;$i++) {
    if($connected[$i]) {
      verbose(4,"Closing connection $i\n");
      close($client[$i]);
      $connected[$i]=0;
    }
  }
}

$SIG{PIPE}=\&sigpipe;
$SIG{TERM}=\&sigquit;
$SIG{QUIT}=\&sigquit;
$SIG{INT}=\&sigquit;
#$SIG{HUP}=\&sigignore;
$SIG{HUP}=\&sigquit;
#$SIG{TSTP}=\&sigquit;


#########################
##### CONFIGURATION #####
#########################


sub LoadFunc 
{
  my $file=shift;
  my @s=stat($file);
  if($s[9]>$func_loaded{$file}) {
    $code="";
    if(open(F,$file)) {
      while(<F>) {
	$code.=$_;
      }
      close(F);
    }
    eval($code);
    $func_loaded{$file}=$s[9];
  }
}

sub LoadLib {
  LoadFunc($ini_library);
  LoadFunc($websocket_library);
  LoadFunc($mqtt_library);
  LoadFunc($func_library);
  Version();
}


###################
###   M A I N   ###
###################

$uptime=time();

$cfg_file=shift;
if(length($cfg_file)==0) { $cfg_file="ocpp.ini"; }
$trans_file=shift;
if(length($trans_file)==0) { $trans_file="trans.ini"; }

LoadLib();

verbose(3,"Reading conf...\n");
# Reading configuration and Constants
ReadConf();


eval {
  MQTT_CheckConn();
};

#if($OS ne "Win") {
#  #Setting NONBLOCK operation fro STDIN (if used)
#  $oldflag=fcntl(STDIN,F_GETFL,$packed);
#  fcntl(STDIN,F_SETFL,$oldflag+O_NONBLOCK) || print STDERR "fcntl: $!";
#}

#$json = JSON->new->allow_nonref;

$numclient=0;
for(;;)  # Infinite loop
{
  eval {
    OCPP_OpenSocket();
  };
  #verbose(3,"Accepting connection on $listen_hostname [$listen_hostaddr], port $listen_port...\n");

  $err=0;
  #$select_timeout=0.002;
  $select_timeout=1;

  verbose(5,"Ready.\n");

  $lastrec=-1;
  while($err<=0) {
    $now=time();
    if(($now-$lastload)>$WAIT_DATATIMEOUT) {
      LoadLib();
      $lastload=$now;
    }

    eval {
      MQTT_CheckConn();
    };
    eval {
      MQTT_HandleTopic();
    };

    eval {
      OCPP_GetMsg();
    };

  }

  OCPP_Exit();

  sleep(2);
}

###### END #####
