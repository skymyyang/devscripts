#!/bin/sh
# File: /www/mysql/backup.sh
#数据库名称
DB_NAME="skymyyang_crm"
#数据库用户名
DB_USER="root"
#数据库密码
DB_PASS="123456"
#bin目录
BIN_DIR="/usr/local/mysql/bin"
#备份目录
BCK_DIR="/home/backup"
#日期格式
DATE=`date "+%Y-%m-%d-%H"`
cd $BCK_DIR
#执行备份
$BIN_DIR/mysqldump -u$DB_USER -p$DB_PASS $DB_NAME  > $DB_NAME.$DATE.sql
#压缩备份
zip -rm $DB_NAME.$DATE.zip $DB_NAME.$DATE.sql
cd $BCK_DIR
#上传到SFTP
for db_back in $DB_NAME
do
             lftp -u liyang,123456 sftp://192.168.110.7 <<EOF
             cd /200.31/wan
             lcd $BCK_DIR
             put $DB_NAME.$DATE.zip
             exit
EOF
done
#删除5天前的备份
find /home/backup/* -mtime +5 -delete
