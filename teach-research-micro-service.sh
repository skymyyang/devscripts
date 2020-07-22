#!/bin/bash


JAVA_HOME=/usr/local/jdk1.8.0_181
JRE_HOME=$JAVA_HOME/jre
PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
CLASSPATH=:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib/dt.jar
export JAVA_HOME JRE_HOME PATH CLASSPATH


PROJECT_HOME=/usr/local/app
PROJECT_PORT=8202
PROJECT_NAME="teach-research-micro-service"
SOURCE_DIR=/data/jar

BACKUP_DIR=/data/backup


#备份旧的项目

[ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR} || echo "BACKUP_DIR is existing!"

cp ${PROJECT_HOME}/${PROJECT_NAME}.jar "${BACKUP_DIR}"/"${PROJECT_NAME}"_`date +%Y-%m-%d-%H:%M:%S`.jar



app_stop() {

    #kill -9 方式
    netstat  -nlpt|grep ${PROJECT_PORT} > /dev/null
    codeResult=$?
    if [ $codeResult -eq 0 ];then
        ss -n -t -l -p | grep $PROJECT_PORT | column -t | awk -F ',' '{print $(NF-1)}' | awk -F '=' '{print $NF}' | xargs kill -9
        echo "kill service....."
    else
        echo "service having killed"
    fi
}

app_stop

sleep 3

app_start() {
    cp /data/jar/$PROJECT_NAME.jar $PROJECT_HOME
    nohup java -jar $PROJECT_HOME/${PROJECT_NAME}.jar > /dev/null 2 >&1 &
}

check_service_status() {
    ss -n -t -l -p | grep $PROJECT_PORT > /dev/null
    codeResult=$?
    if [ $codeResult -eq 0 ];then
        echo "service is running"
    else
        echo "service is shutdown;now start..."
        app_start
    fi
}
check_service_status
