#!/bin/bash

# install the smartctl package first! (apt-get install smartctl)
#
# Script to quickly scan the S.M.A.R.T. health status of all your hard drive devices in Linux (at least all the ones from /dev/sda to /dev/sdzz). 
# You need smartctl installed on your system for this script to work, and your hard drives need to have S.M.A.R.T. capabilities (they probably do).
#

if sudo true
then
   true
else
   echo 'Root privileges required'

   exit 1
fi

for drive in /dev/sd[a-z] /dev/sd[a-z][a-z]
do
   if [[ ! -e $drive ]]; then continue ; fi

   echo -n "$drive "

   smart=$(
      sudo smartctl -H $drive 2>/dev/null |
      grep '^SMART overall' |
      awk '{ print $6 }'
   )

   [[ "$smart" == "" ]] && smart='unavailable'

   echo "$smart"

done
