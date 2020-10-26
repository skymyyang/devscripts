#!/bin/bash

#每天凌晨1点执行该文件

#配置IP后缀
IPHZ="1.65"
#配置Tomcat基础路径
TOMCAT_BASE=/usr/local/server/tomcatall
#获取当前时间
DATE_TIME=$(date +%Y%m%d_%H%M)

cd ${TOMCAT_BASE}/logs/

#获取日志并压缩，然后判断是否成功，成功之后进行上传,然后删除
find ${TOMCAT_BASE}/logs/ -name "*.log" -mtime +7 | xargs zip -rq logs_${IPHZ}_${DATE_TIME}.zip
if [ $? -ne 0 ];then
    echo "备份失败！"
else
    lftp -p 22 -u root,'123456' sftp://192.168.1.1/bak/alilogsbackup/logs_192.168.1.65 <<EOF
    put logs_${IPHZ}_${DATE_TIME}.zip
    exit
EOF
find ${TOMCAT_BASE}/logs/ -name "*.log" -mtime +7 -delete
fi
