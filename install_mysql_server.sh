#!/bin/sh

#  install_mysql_server.sh
#  
#
#  Created by HSP SI Viet Nam on 5/5/14.
#

#Disabled Firewall And Basic Configure Server
service NetworkManager stop
service network start
chkconfig NetworkManager off
chkconfig network on
service firewalld stop
chkconfig firewalld off
service iptables stop
chkconfig iptables off
service ntpd stop
chkconfig ntpd off


#Configure MySQL Server
echo "Install Mysql-Server"
echo "Please! wait......"
yum -y remove mysql* mysql-*
yum -y install mysql mysql-server MySQL-python mlocate
updatedb
linkmycnf=`locate my.cnf`
sed -i 's/bind-address/\#bind-address/g' $linkmycnf
sed -i '/\[mysqld\]/a character-set-server = utf8' $linkmycnf
sed -i '/\[mysqld\]/a init-connect = "SET NAMES utf8"' $linkmycnf
sed -i '/\[mysqld\]/a collation-server = utf8_general_ci' $linkmycnf
sed -i '/\[mysqld\]/a default-storage-engine = innodb' $linkmycnf
service mysqld start
chkconfig mysqld on
cat $linkmycnf

#create user