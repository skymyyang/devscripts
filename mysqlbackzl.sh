#!/bin/bash
Host="localhost"
pass='123456'
name="root"
DATE=`date +"%Y%m%d%H"`
WAN_DIR="/opt/wan_dir"
ZENG_DIR="/opt/zeng_dir"
DATA_DIR="/data/"
MYSQL_BIN="/usr/local/mysql/bin"
error_log="/tmp/backup_error_$DATE.log"
backup_log="/tmp/backup_$DATE.log"
gzdumpfile="$DATE.sql.zip"
db="/var/log/backup_$DATE.txt"
cd $DATA_DIR
#ls -l $DATA_DIR | grep "^d" | awk -F " " '{print $9}' >> $db
ls $DATA_DIR | grep "^mfg" | awk -F " " '{print $1}' >>$db
function wan() {
cd $WAN_DIR
    for dbname in $(cat $db)
    do
       /usr/local/mysql/bin/mysqldump --flush-logs -u$name -p$pass --set-gtid-purged=OFF --skip-lock-tables --quick $dbname > $dbname.sql
        if [ $? = 0 ]
        then
             /usr/bin/zip -rm $dbname.$gzdumpfile $dbname.sql
        else
             echo "Backup MySQL fail" >>$error_log
        fi
    done
#完全备份后删除本地增量备份文件，只保留最近一个星期的增量备份文件
find /opt/zeng_dir -name "*.sql.zip"  -mtime +5 -delete 
#将备份好的上传到FTP服务器
cd $WAN_DIR
for db_back in $(cat $db)
do
             lftp -u admin,123456 sftp://192.168.180.7 <<EOF
             cd /200.64/wan
             lcd /opt/wan_dir/
             put $db_back.$gzdumpfile
             exit
EOF
done
}
function zeng() {
TIME=$(date "-d 10 day ago" +%Y-%m-%d %H:%M:%S) 
StartTime=$(date "-d 1 day ago" +"%Y-%m-%d %H:%M:%S")
Start="--start-datetime"
#删除10天前的二进制文件
/usr/local/mysql/bin/mysql -u$name -p$pass -e "purge master logs before ${TIME}" && echo "delete 10 days before log" | tee -a $backup_log
filename=`cat $DATA_DIR/mster-bin.index | awk -F "/" '{print $2}'`
cd $ZENG_DIR

for i in $filename
do
     echo "$StartTime start backup binlog" >> $backup_log

     for db_name in $(cat $db)
     do
           /usr/local/mysql/bin/mysqlbinlog -u$name -p$pass --skip-gtids -d $db_name $Start="$StartTime" $DATA_DIR/$i >> $db_name.$DATE.sql
        if [ $? = 0 ]
        then
             /usr/bin/zip -rm $db_name.$gzdumpfile $db_name.$DATE.sql
        else
             echo "Backup MySQL fail" >>$error_log
        fi
     done
done
find /tmp -name "*.log" -name +15 -delete 
#删除上次备份的完整备份的文件
find /opt/wan_dir -name "*.sql.zip"  -mtime +5 -delete 
#将备份好的上传到FTP服务器
cd $ZENG_DIR
for db_back in $(cat $db)
do
             lftp -u liyang,12345QAZxsw sftp://192.168.180.7 <<EOF
             cd /200.64/zeng
             lcd /opt/zeng_dir/
             put $db_back.$gzdumpfile
             exit
EOF
done
}
backfile=`ls /opt/wan_dir | wc -l`
if [ $backfile != 0 ]
then
    echo "完整备份已经存在，现在进行增量备份"
    sleep 10
    zeng
else
    echo "还没进行完整备份，现在进行完整备份"
    sleep 30
    wan
fi
