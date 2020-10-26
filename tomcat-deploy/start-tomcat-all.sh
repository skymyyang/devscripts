
#!/bin/sh

export JAVA_HOME=/usr/local/jdk1.8.0_121;
export CLASS_PATH=$JAVA_HOME/lib:$JAVA_HOME/jre/lib;
export PATH=.:$PATH:$JAVA_HOME/bin:/usr/local/mysql/bin;

tomcat_base=/usr/local/server/tomcatall
TOMCAT_PATH=${tomcat_base}/bin

ls_date=`date +%Y-%m-%d`
CLP="export JAVA_HOME=/usr/local/jdk1.8.0_121; export CLASS_PATH=$JAVA_HOME/lib:$JAVA_HOME/jre/lib; export PATH=.:$PATH:$JAVA_HOME/bin:/usr/local/mysql/bin;"
CMD="$tomcat_base/bin/startup.sh; sleep 1; tail -f $tomcat_base/logs/catalina_all.${ls_date}.log"


echo "==================================启动TOMCAT======================================="

sh $tomcat_base/bin/startup.sh
sleep 1
tail -20 $tomcat_base/logs/catalina_all.${ls_date}.log

echo "**********************************TOMCAT启动完成***********************************"


