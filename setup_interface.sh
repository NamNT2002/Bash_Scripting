#!/bin/sh

#  setup_interface.sh
#  
#
#  Created by HSP SI Viet Nam on 5/6/14.
#
clear

#Lấy tên các interface hiện có trên Server.
#ip link show >> lấy thông tin các interface có trên Server.
#grep >> tìm và hiển thị dòng có các chuỗi cần tìm (ở đây BROADCAST,MULTICAST là chuỗi cần tìm)
#awk >> hiển thị ra màn hình cột cần hiển thị (trong 1 dòng, các cột được phân biệt bởi dấu "cách"
#sed >> tìm chuỗi và thay đổi chuỗi cần tìm thành chuỗi khác.
ip link show | grep BROADCAST,MULTICAST | awk '{print $2}' | sed 's/://' > list_allinterface.txt

#Vòng lặp "for in; do ; done"
#Trong vòng lặp for, tất cả mọi công việc được thực hiện từ "do" đến "done" được coi là 1 vòng.
#Khi chạy đến "done" thì vòng for sẽ chuyển sang chuỗi (string) tiếp theo.
#Cứ sau 1 dấu "cách" thì "for" sẽ hiểu là 1 chuỗi khác.
#Vòng lặp for sẽ chạy đi chạy lại đến chuỗi cuối cùng thì sẽ dừng lại.
#Nếu muốn chiều ra (output) của một lệnh là chuỗi để vòng lặp "for" thực hiện thì lệnh đó sẽ phải nằm trong "$( command )"
#Tại đây interface được hiểu là 1 biến, giá trị của interface sẽ được gán lần lượt bằng các chuỗi bởi lệnh "cat" lấy ra.
for interface in $( cat list_allinterface.txt );
do ipadd=`/sbin/ifconfig $interface | grep inet | awk '{print $2}' | sed 's/addr://'`
macaddr=`ip link show $interface | grep link/ether | awk '{print $2}'`
netmask=`ifconfig $interface | grep Mask | awk '{print $4}' | sed 's/Mask://'`
kieu=`cat /etc/sysconfig/network-scripts/ifcfg-$interface | grep BOOTPROTO | sed 's/BOOTPROTO=//'`

#Điều kiện "if điều kiện; then fi"
#Nếu cài này mà như thế này thì nó sẽ như thế này. Và "fi" là để kết thúc điều kiện đó.
if [ "$kieu" = "none" ]; then
kieu=static
fi
#end if
#Thông tin hiển thị ra ngoài màn hình tương ứng với mỗi 1 vòng lặp for
echo "Cong $interface  -  Dia Chi IP: $ipadd  -  Subnet Mask: $netmask  -  Kieu: $kieu  - MAC Addr - $macaddr";
#
#Kết thúc vòng lặp for
#Lưu ý: tại lệnh "command" cuối cùng fai kết thúc bởi dấu ";" thì vòng lặp for mới có thể đóng được.
done
#End for

#Lấy thông tin default route trên Server
#route -n >> hiển thị bảng định tuyến hiện tại trên server.
#Tại đây dòng có ký tự "UG" sẽ được hiểu là cổng mặc định để ra internet hoặc để tới các dải mạng mà nó chưa biết.
#awk lấy dữ liệu cả 2 cột thứ 2 và thứ 8
DF_GATEWAY=`route -n | grep 'UG[ \t]' | awk '{print $2, $8}'`
echo "=============================="
echo "Default gateway $DF_GATEWAY"
echo ""
echo ""
echo "Can you configure interface?"

#configure interface
#
PS3="Please, choose number: "
select yn in "yes" "no";
do
    break
done
if [ "$yn" = "no" ]; then
exit 1
fi
echo ""

#setup interface
echo "Setup Static IP ADDRESS For Interface"
listcase=`cat list_allinterface.txt`
PS3="Please, choose number: "
select name in $listcase "Exit....."
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
echo ""
echo "You choose setup Interface $name ."
echo ""

#choose DHCP Configure
echo "You want to configure static or dhcp?"
PS3="Please, choose number: "
select ncf in "DHCP" "Static" "Exit....."
do
    break
done
if [ "$ncf" = "Exit....." ]; then
echo "Goodbye!"
exit 1
fi
if [ "$ncf" = "" ]; then
echo "Error in entry."
exit 1
fi

#setup interface dhcp
if [ "$ncf" = "DHCP" ]; then
cat > /etc/sysconfig/network-scripts/ifcfg-$name << eof
DEVICE=$name
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=dhcp
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
sh setup_interface.sh
exit 1
fi

#static ip address
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
sh setup_interface.sh
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
sh setup_interface.sh
exit 1

