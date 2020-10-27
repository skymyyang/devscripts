#!/bin/bash


FD=`ls -l /webSite/ | grep "aixuan*" | awk -F " " '{print $9}'`


modifyconfig(){
    for fd in $FD
    do
      find $fd/ -name app-placeholder.properties | xargs sed -i "s/db_url_core=core.example.mysql:3306/192.168.1.200:3306/g"
    done
}