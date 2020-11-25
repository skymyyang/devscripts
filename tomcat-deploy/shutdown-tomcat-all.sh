#!/bin/bash

export JAVA_HOME=/usr/local/jdk1.8.0_121
export CLASS_PATH=$JAVA_HOME/lib:$JAVA_HOME/jre/lib
export PATH=.:$PATH:$JAVA_HOME/bin:/usr/local/mysql/bin

tomcat_base=/usr/local/server/tomcatall
TOMCAT_PATH=${tomcat_base}/bin

echo "TOMCAT_PATH is $TOMCAT_PATH"

PID=`ps aux | grep ${tomcat_base} | grep java | awk '{print $2}'`

if [ -n "$PID" ]; then
        echo "Try to shutdown Tomcat: $PID"
        sh "$TOMCAT_PATH/shutdown.sh"
                sleep 1
fi

for((i=0;i<10;i++))
do
        PID2=`ps aux | grep ${tomcat_base} | grep java | awk '{print $2}'`
            
        if [ -n "$PID2" ]; then
                        if [ $i -ge 9 ] ; then
                                echo "Try to kill Tomcat: $PID2"
                                ((i--))
                                kill -9 $PID2
                        else
                                echo "wait to kill Tomcat: $PID2"
                        fi
                        sleep 1
        else 
                echo "Tomcat is closed"
                break
        fi
done


