#!/bin/sh

#  install_apache.sh
#  
#
#  Created by HSP SI Viet Nam on 5/5/14.
#
echo "Update soucer"
apt-get update
clear
echo "Update soucer Success Full"
echo "Install Apache - PHP"
echo "Please! Wait....."
sleep 3
apt-get -y remove apache2 apache2-* php5 php5-*
aptitude -y install apache2 php5 php5-cgi libapache2-mod-php5 \
php5-common php-pear php5-mysql

sed -i 's/\#AddHandler cgi-script \.cgi/AddHandler php5-script \.php/g' /etc/apache2/mods-enabled/mime.conf
sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/apache2/conf.d/security
sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/apache2/conf.d/security
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/conf.d/security


clear
echo "Apache Install Success Full"
apachev=`Server version: Apache/2.2.22 (Ubuntu)`
echo $apachev
phpv=`php -v | grep built | awk '{print $1 " " $2}'`
echo $phpv
echo ""
echo "Start Service Apache!"
echo "Wait....."
sleep 1
/etc/init.d/apache2 restart

cat > /var/www/index.html << eof
<head>
<title> CongTT Demo </title>
</head>
<body>
<center>
<br/>
<br/>
<br/>
<h1> Demo Website Install By Python</h1>
<h2><font color=blue>Create by CongTT</font></h2>
</center>
</body>
eof

cat > /var/www/phpinfo.php << eof
<\?php
phpinfo();
\?>
eof

echo "================================="
echo "Link web server:"
ip link show | awk '{print $2}' | grep eth | sed 's/://' > list_allinterface.txt
for interface in $( cat list_allinterface.txt );
do ipadd=`/sbin/ifconfig $interface | grep inet | awk '{print $2}' | sed 's/addr://'`
echo "http://$ipadd";
done

echo ""
echo "================================="
echo "About PHP:"
ip link show | awk '{print $2}' | grep eth | sed 's/://' > list_allinterface.txt
for interface in $( cat list_allinterface.txt );
do ipadd=`/sbin/ifconfig $interface | grep inet | awk '{print $2}' | sed 's/addr://'`
echo "http://$ipadd/phpinfo.php";
done

echo ""
exit 1
