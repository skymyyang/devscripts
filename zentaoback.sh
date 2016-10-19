#!/bin/bash
DB_NAME="zentaodata"
BCK_DIR="/home/backup"
DATE=`date "+%Y.%m.%d.%H"`
cd $BCK_DIR
zip -r  $DB_NAME.$DATE.zip /var/www/html/zentaopms/www/data/*
for db_back in $DB_NAME
do
             lftp -u admin,123456 sftp://192.168.180.7 <<EOF
             cd /180.30/data
             lcd $BCK_DIR
             put $DB_NAME.$DATE.zip
             exit
EOF
done
