#!/bin/bash

# SPDX-FileCopyrightText: 2023-2026 Luca Bonissi <wallbox@bonissi.it>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

cd `dirname $0`

rot=9
while [ $rot -gt 0 ]
do
  let prev=$rot-1
  if [ $prev -eq 0 ]
  then
    prev=""
  else
    prev=".$prev"
  fi
  next=".$rot"
  if [ -f "ocpp.log.err$prev" ]
  then
    \mv "ocpp.log.err$prev" "ocpp.log.err$next"
  fi
  let rot=$rot-1
done

nohup ./ocpp.pl > /dev/null 2> ocpp.log.err &
