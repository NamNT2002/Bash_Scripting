#!/bin/sh

#  static_ip.sh
#  
#
#  Created by HSP SI Viet Nam on 5/5/14.
#
ip link show | awk '{print $2}' | grep eth | sed 's/://' > list_allinterface.txt
for interface in $( cat list_allinterface.txt );
do ipadd=`/sbin/ifconfig $interface | grep inet | awk '{print $2}' | sed 's/addr://'`
netmask=`ifconfig $interface | grep Mask | awk '{print $4}' | sed 's/Mask://'`
kieu=`cat /etc/sysconfig/network-scripts/ifcfg-$interface | grep BOOTPROTO | sed 's/BOOTPROTO=//'`
if [ "$kieu" = "none" ]; then
kieu=static
fi
echo "interface $interface  -  Dia Chi IP: $ipadd  -  Subnet Mask: $netmask  -  Kieu: $kieu";
done
DF_GATEWAY=`route -n | grep 'UG[ \t]' | awk '{print $2, $8}'`
echo "Default gateway $DF_GATEWAY"

#Setup Static Ipaddress.
cat list_allinterface.txt > listeth
echo "Exit..." >> listeth
list=`cat listeth`
PS3="Setup Static IP ADDRESS For Interface:"
select name in $list
do
    break
done
if [ "$name" = "" ]; then
    echo "Error in entry."
    exit 1
fi
if [ "$name" = "Exit..." ]; then
echo "Exit...."
exit 1
fi
echo "You Setup Interface $name ."
echo ""
read -p"IP Address: " ipadds
echo ""
if [ "$ipadds" = "" ]; then

    echo "IP Address not null"
    exit $1
fi
echo ""
read -p"Subnet Mask: " subnetmask
if [ "$subnetmask" = "" ]; then
    echo "Subnet Mask not null"
    exit 1
fi
echo ""
echo "Default Gateway:"
read -p"(You can input Enter if you not set default gateway....): " dfw


if [ "$dfw" = "" ]; then
cat > /etc/sysconfig/network-scripts/ifcfg-$name << eof
DEVICE=$name
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=none
IPADDR=$ipadds
NETMASK=$subnetmask
DNS1=8.8.8.8
DEFROUTE=yes
PEERDNS=no
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System $name"
eof
echo "reset network interface"
echo "please waiting 3s ...."
ifdown $name && ifup $name
sh static_ip.sh
exit 1
fi

cat > /etc/sysconfig/network-scripts/ifcfg-$name << eof
DEVICE=$name
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=none
IPADDR=$ipadds
NETMASK=$subnetmask
GATEWAY=$dfw
DNS1=8.8.8.8
DEFROUTE=yes
PEERDNS=no
PEERROUTES=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="System $name"
eof
echo "reset network interface"
echo "please waiting 3s ...."
ifdown $name && ifup $name
sh static_ip.sh
exit 1