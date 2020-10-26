#!/bin/bash
#mongodb数据库备份脚本
#数据库名称
DB_NAME="question"
#数据库账户
DB_USER="questionuser"
#数据库密码
DB_PASS="123456"
#mongodb bin目录位置
BIN_DIR="/usr/mongo/bin/"
BCK_DIR="/var/backupdb/"
#时间格式
DATE=`date "+%Y.%m.%d.%H"`
#备份语句
$BIN_DIR/mongodump --host 127.0.0.1 --port 11000 --out $BCK_DIR/$DATE -u $DB_USER -p $DB_PASS
#进行压缩
zip -rqm $BCK_DIR/$DB_NAME-$DATE.zip $BCK_DIR/$DATE
#上传到sftp
cd $BCK_DIR
for db_back in $DB_NAME
do
             lftp -u skymyyang,123456 sftp://192.168.110.7 <<EOF
             cd /188.39/wan
             lcd $BCK_DIR
             put $db_back-$DATE.zip
             exit
EOF
done
#删除5天前文件
find /var/backupdb/* -mtime +5 -delete
