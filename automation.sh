#!/bin/bash

# Declare variables here
myname='punya'
s3_bucket='upgrad-punya'
timestamp=$(date '+%d%m%Y-%H%M%S')
# Script Starts here
# Task 1
sudo apt-get update -y
if !(systemctl --all --type service | grep  "apache2");
then
    sudo apt-get install apache2 -y
fi
sudo service apache2 status
if [ $? != 0 ];
then
	sudo service apache2 start
fi
if (sudo systemctl status apache2.service | grep 'disabled');
then
	sudo systemctl enable apache2.service
fi
# Task 2
tar -czvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
# Task 3
myhtml='/var/www/html/inventory.html'
size=`du -sh /tmp/${myname}-httpd-logs-${timestamp}.tar | awk {'print $1'}`
logtype='httpd-logs'
filetype='tar'
cronfile='/etc/cron.d/automation'
if [ ! -e $myhtml ]
then
  echo '<!doctype html> 
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Inventory Webpage</title>
</head>
<body>
  <p><b>Log Type</b> &emsp;  <b>Time Created</b> &emsp;       <b>Type</b> &emsp;     <b>Size</b></p>
</body>
</html> ' >> $myhtml       
fi
sudo sed -i "9 i <p>$logtype &emsp;  $timestamp &emsp;       $filetype &emsp;     $size</p>"  /var/www/html/inventory.html

if [ ! -e $cronfile ]
then
	echo '0 0 * * * root /root/Automation_Project/automation.sh' >> $cronfile
fi
