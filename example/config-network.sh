#!/bin/bash
#
Nic_Name=`cat /proc/net/dev | awk '{i++; if(i>2){print $1}}' | sed 's/^[\t]*//g' | sed 's/[:]*$//g' | grep -v "lo"  | head -n 1`
# Note: This is fixed and does not need to be changed
sed -i "s/    ens136/    ${Nic_Name}/g" /etc/netplan/00-installer-config.yaml