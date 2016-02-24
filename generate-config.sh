#!/bin/sh

#this script use to generate configuration from rtConfig template file
#running the router in vm (Ubuntu-Dynagen); ip address 192.168.56.106
#make sure your are running tftp server on 192.168.56.1
#interface on vboxnet0

if [ ! $# == 1 ]; then
        echo "Usage: $0 please pass the cfg file as parameter"
	exit
fi

CONFIG_FILE="$1"

#fetch IRR objects; we are using apnic.net IRR database
rtconfig -protocol bird -cisco_use_prefix_lists -config cisco -h whois.apnic.net < $CONFIG_FILE > /private/tftpboot/output.cfg
echo "config generated!"
echo "uploaded in tftp path /private/tftpboot"
echo 
echo "setting SNMP variable"

#generate random no for SNMP variable first
n=$RANDOM
# display random number between 10 and 200.
RANDOMSNMP=$((RANDOM%200+10))

#set SNMP parameters and upload config to router from tftp server
snmpset -v 2c -c APNIC 192.168.56.106 1.3.6.1.4.1.9.9.96.1.1.1.1.2.$RANDOMSNMP i 1
snmpset -v 2c -c APNIC 192.168.56.106 1.3.6.1.4.1.9.9.96.1.1.1.1.3.$RANDOMSNMP i 1
snmpset -v 2c -c APNIC 192.168.56.106 1.3.6.1.4.1.9.9.96.1.1.1.1.4.$RANDOMSNMP i 4
snmpset -v 2c -c APNIC 192.168.56.106 1.3.6.1.4.1.9.9.96.1.1.1.1.5.$RANDOMSNMP a 192.168.56.1
snmpset -v 2c -c APNIC 192.168.56.106 1.3.6.1.4.1.9.9.96.1.1.1.1.6.$RANDOMSNMP s output.cfg
snmpset -v 2c -c APNIC 192.168.56.106 1.3.6.1.4.1.9.9.96.1.1.1.1.14.$RANDOMSNMP i 1

#call progress script
sh ./progress.sh
