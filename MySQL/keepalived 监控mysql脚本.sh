#!/bin/bash
MYSQL=/usr/local/mysql/bin/mysql        
MYSQL_HOST=localhost
MYSQL_USER=root
MYSQL_PASSWORD='123456'
CHECK_TIME=4
#mysql  is working MYSQL_OK is 1 , mysql down MYSQL_OK is 0
MYSQL_OK=1
function check_mysql_helth (){
    $MYSQL -h $MYSQL_HOST -u $MYSQL_USER -p${MYSQL_PASSWORD} -e "show status;" >/dev/null 2>&1
    if [ $? = 0 ] ;then
    MYSQL_OK=1
    else
    MYSQL_OK=0
    fi
    return $MYSQL_OK
}
while [ $CHECK_TIME -ne 0 ]
do
    let "CHECK_TIME -= 1"
    check_mysql_helth
if [ $MYSQL_OK = 1 ] ; then
    CHECK_TIME=0
    exit 0
fi
if [ $MYSQL_OK -eq 0 ] &&  [ $CHECK_TIME -eq 0 ]
then
    systemctl stop keepalived.service
    exit 1
fi
sleep 1
done