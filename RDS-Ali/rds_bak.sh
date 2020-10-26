#!/bin/bash

accesskeyid=LTAI4FifHy
accesskeysecret=54Q6nMbRT1YX0ZLmYjF 
dir_name=$(date +%Y%m%d%H%M)
mkdir /bak/rds/$dir_name
db="rm-2ze328710n6ul33kw rm-2ze0yn0xl86dc4l0o"
for i in $db;
do
python /bak/rds/get_rds_backup.py $i $accesskeyid $accesskeysecret /bak/rds/$dir_name/ > /bak/rds/$dir_name/$i.log 2>&1
echo $i;
done

#delete x days before directory
list_alldir(){
    for file2 in `ls -a $1`
    do
        if [ x"$file2" != x"." -a x"$file2" != x".." ];then
            if [ -d "$1/$file2" ];then
                if [ $file2 -lt $dir ];then
                    rm -rf $1/$file2
                fi
            fi
        fi
    done
}
dir=$(date -d "-15 days" +%Y%m%d%H%M)
list_alldir /bak/rds