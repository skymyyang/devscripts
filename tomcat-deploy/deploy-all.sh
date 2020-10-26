#!/bin/bash

echo "###################################################################################"
echo "设置变量"
echo "###################################################################################"
DEPLOY_OUT_PATH=/opt/deploy/out
WEBSITE_PATH=/webSite
#WEBSITE_PATH=/opt/backup
BACKUP_PATH=/opt/backup
DATE_TIME=$(date +%Y%m%d_%H%M%S)
echo "DEPLOY_OUT_PATH=$DEPLOY_OUT_PATH"
echo "WEBSITE_PATH=$WEBSITE_PATH"
echo "BACKUP_PATH=$BACKUP_PATH"
echo "DATE_TIME=$DATE_TIME"

echo "###################################################################################"
echo "开始关闭TOMCAT"
echo "###################################################################################"
sleep 1
sh /opt/deploy/shutdown-tomcat-all.sh

echo "###################################################################################"
echo "开始解压zip文件"
echo "###################################################################################"
sleep 1
#unzip /opt/deploy/ainima.zip -d $DEPLOY_OUT_PATH
unzip -O UTF-8 /opt/deploy/ainima.zip -d $DEPLOY_OUT_PATH


echo "###################################################################################"
echo "开始备份老的项目"
echo "###################################################################################"
sleep 1
mkdir -p $BACKUP_PATH/$DATE_TIME
for filename in $(ls $DEPLOY_OUT_PATH); do
        echo "备份: $WEBSITE_PATH/$filename $BACKUP_PATH/$DATE_TIME"
        mv $WEBSITE_PATH/$filename $BACKUP_PATH/$DATE_TIME
done


echo "开始替换当前项目的配置文件"
sleep 1
for filename in $(ls $DEPLOY_OUT_PATH); do
        echo "替换: $DEPLOY_OUT_PATH/$filename"
        #find $DEPLOY_OUT_PATH/$filename -name app-placeholder.properties | xargs sed -i "s/=123456/=aix123456/g"

	# core
        find $DEPLOY_OUT_PATH/$filename -name app-placeholder.properties | xargs sed -i "s/db_username_core=root/db_username_core=mysql_user/g"
        find $DEPLOY_OUT_PATH/$filename -name app-placeholder.properties | xargs sed -i "s/db_password_core=123456/db_password_core=a123456/g"
        find $DEPLOY_OUT_PATH/$filename -name app-placeholder.properties | xargs sed -i "s/rm-01.mysql.rds.aliyuncs.com:3306/rm-2ze41bqhb785x6xn7.mysql.rds.aliyuncs.com:3306/g"
        #find $DEPLOY_OUT_PATH/$filename -name app-placeholder.properties | xargs sed -i "s/db_name_core=ainima_openapp_db/db_name_core=ainima_openapp_db/g"

	# core-old
	find $DEPLOY_OUT_PATH/$filename -name component-sql.xml | xargs sed -i 's/value="root"/value="mysql_user"/g'
	find $DEPLOY_OUT_PATH/$filename -name component-sql.xml | xargs sed -i 's/value="123456"/value="a123456"/g'
	find $DEPLOY_OUT_PATH/$filename -name component-sql.xml | xargs sed -i 's/core.example.mysql:3306/192.168.1.200:3306/g'


	# manage
        find $DEPLOY_OUT_PATH/$filename -name app-placeholder.properties | xargs sed -i "s/db_username_manage=root/db_username_manage=mysql_user/g"
        find $DEPLOY_OUT_PATH/$filename -name app-placeholder.properties | xargs sed -i "s/db_password_manage=123456/db_password_manage=a123456/g"
        find $DEPLOY_OUT_PATH/$filename -name app-placeholder.properties | xargs sed -i "s/db_url_manage=manage.example.mysql:3306/db_url_manage=192.168.1.200:3306/g"
        #find $DEPLOY_OUT_PATH/$filename -name app-placeholder.properties | xargs sed -i "s/db_name_manage=ainima_manage_db/db_name_manage=ainima_manage_db/g"


        #find $DEPLOY_OUT_PATH/$filename -name log4j.properties | xargs sed -i "s/rootLogger=INFO/rootLogger=ERROR/g"
        #find $DEPLOY_OUT_PATH/$filename -name app-property.inix | xargs sed -i "s/user_info_by_mock=true/user_info_by_mock=false/g"
        #find $DEPLOY_OUT_PATH/$filename -name app-property.inix | xargs sed -i "s/getReportByCodeSharding/getReportByCode/g"
done


echo "###################################################################################"
echo "移动当前项目到webSite"
echo "###################################################################################"
sleep 1
for file in /opt/deploy/out/*; do
        echo "MV $file"
        mv $file $WEBSITE_PATH/
        #sh /webSite/cpAll.sh $(basename $file)
        #echo $(basename $file)
done

#echo "###################################################################################"
#echo "开始分发项目"
#echo "###################################################################################"
#sleep 1
#for filename in $(ls $DEPLOY_OUT_PATH); do
#        #echo "备份: $WEBSITE_PATH/$filename $BACKUP_PATH/$DATE_TIME"
#        #mv $WEBSITE_PATH/$filename $BACKUP_PATH/$DATE_TIME
#       sh /webSite/cpAll.sh $filename
#done
#sh /webSite/cpAll.sh

echo "###################################################################################"
echo "清除out目录"
echo "###################################################################################"
sleep 1
rm -rf /opt/deploy/out/*

rm -rf /opt/deploy/ainima.zip
echo ""
echo "部署完成！！！"

sleep 1
echo "开始重新启动TOMCAT....."
#sleep 1
#sh /webSite/startAll.sh
sh /opt/deploy/start-tomcat-all.sh


