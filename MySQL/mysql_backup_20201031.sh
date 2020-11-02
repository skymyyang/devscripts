#!/bin/bash
#定义常用变量

MYSQL_USER="root"
MYSQL_PASS="123456"
DATE=$(date +"%Y%m%d%H")
MYSQL_BIN="/usr/local/mysql/bin"
BACK_DIR="/backup"

function wan_back() {
  for dbname in $(ls /usr/local/mysql/data/ | grep "^ainimei"); do
    ${MYSQL_BIN}/mysqldump -u${MYSQL_USER} -p${MYSQL_PASS} -B ${dbname} | gzip >${BACK_DIR}/${dbname}.${DATE}.sql.gz 
    if [ $? -eq 0 ]; then
      /usr/bin/scp ${BACK_DIR}/${dbname}.${DATE}.sql.gz root@172.16.0.50:/backup 
      find /backup -name "*.sql.gz" -mtime +30 -delete

    else
      echo "backup failed" >>/tmp/mysqlbackup_error.log
    fi
  done

}

wan_back
