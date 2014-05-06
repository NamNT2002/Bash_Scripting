#!/bin/sh

#  setup_interface.sh
#  
#
#  Created by HSP SI Viet Nam on 5/6/14.
#
ip link show | grep BROADCAST,MULTICAST | awk '{print $2}' | sed 's/://' > list_allinterface.txt
for interface in $( cat list_allinterface.txt );
do ipadd=`/sbin/ifconfig $interface | grep inet | awk '{print $2}' | sed 's/addr://'`
macaddr=`ip link show eth1 | grep link/ether | awk '{print $2}'`
netmask=`ifconfig $interface | grep Mask | awk '{print $4}' | sed 's/Mask://'`
kieu=`cat /etc/sysconfig/network-scripts/ifcfg-$interface | grep BOOTPROTO | sed 's/BOOTPROTO=//'`
if [ "$kieu" = "none" ]; then
kieu=static
fi
echo "interface $interface  -  Dia Chi IP: $ipadd  -  Subnet Mask: $netmask  -  Kieu: $kieu  - MAC Addr - $macaddr";
done
DF_GATEWAY=`route -n | grep 'UG[ \t]' | awk '{print $2, $8}'`
echo "=============================="
echo "Default gateway $DF_GATEWAY"

