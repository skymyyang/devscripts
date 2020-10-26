#!/bin/bash
#定义当前时间
current_time=`date +"%Y-%m-%d"`
IP=$(/sbin/ifconfig eth0 | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}')
info=${IP}_${current_time}
MYSQL_VERSION="5.6.34"
REMOTE_BAKDIR=${IP}
innobackupex --defaults-file=/etc/my.cnf  --user=root --password=123456 --socket=/tmp/mysql.sock  /bak/backup/mysql > /bak/logs/extrabackup_mysql.log 2>&1
cd /bak/backup/mysql/
zip -rmqo ${info}_mysqlbak.${MYSQL_VERSION}.zip ./* -x "./*.zip"

#tar zcvf /bak/${info}_mysql.tar.gz ./mysql > /bak/${info}_mysql.log 2>&1
#cd /usr/local/
#tar zcvf /bak/${info}_nginx.tar.gz ./nginx --exclude ./nginx/logs   > /bak/${info}_nginx.log 2>&1
#tar zcvf /bak/${info}_tomcat.tar.gz ./server --exclude ./server/tomcatall/logs > /bak/${info}_tomcat.log 2>&1
#tar zcvf /bak/${info}_jdk.tar.gz    ./jdk1.8.0_121  > /bak/${info}_jdk.log 2>&1
lftp -u root,123456 sftp://192.168.50.248 <<EOF
lcd /bak/backup/mysql/
cd /bak/${REMOTE_BAKDIR}
put ${info}_mysqlbak.${MYSQL_VERSION}.zip
exit
EOF

find /bak/backup/mysql/*.zip -mtime +7 -delete
