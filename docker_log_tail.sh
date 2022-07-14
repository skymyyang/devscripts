#!/bin/bash


#当容器异常退出,且立即删除时,通过循环打印出容器的终端日志,方便排错.
a=0
while [ $a  -eq 0 ]
do
  DOCKER_ID=`docker ps -a --no-trunc | grep busybox | awk '{print $1}'`
  if [ -z "$DOCKER_ID" ]
  then
      echo "未获取到容器ID"
  else
      #ls /var/lib/docker/containers/${DOCKER_ID}/${DOCKER_ID}-json.log
      echo $DOCKER_ID
      docker logs -f $DOCKER_ID
      #cp /var/lib/docker/containers/${DOCKER_ID}/${DOCKER_ID}-json.log /usr/local/src/
      #cat /usr/local/src/${DOCKER_ID}-json.log
      a=1
  fi
done