#!/bin/bash
proc_name="/usr/local/src/go_filewb/go_filewb"                               # 进程名  
file_name=/tmp/filejk.log
pid=0
proc_num()                                             # 计算进程数  
{
    num=`ps -ef | grep $proc_name | grep -v grep | wc -l`
    return $num
}

proc_id()                                               # 进程号  
{
    pid=`ps -ef | grep $proc_name | grep -v grep | awk '{print $2}'`
}
proc_num
number=$?
if [ $number -eq 0 ]                                    # 判断进程是否存在  
then
    /usr/local/src/go_filewb/go_filewb -cfg=/usr/local/src/go_filewb/config.ini &
    /bin/sh /root/sms.sh  15******37 " " "The FileWeb server is restart!"
    proc_id                                               # 获取新进程号  
    echo `The RQuery is down now` >> $file_name
    echo ${pid}, `date` >>  $file_name
fi