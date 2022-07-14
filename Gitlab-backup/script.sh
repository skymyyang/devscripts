#!/bin/bash

/opt/gitlab/bin/gitlab-backup create CRON=1
DATE=`date +"%Y_%m_%d"`
GITLAB_VERSION="13.12.0"
BACKUP_NAME="gitlab_backup.tar"
# 1651082524_2022_04_28_13.12.0_gitlab_backup.tar
BACKUP_FILE_NAME=`find /var/opt/gitlab/backups/* -name "*_${DATE}_${GITLAB_VERSION}_${BACKUP_NAME}"`
BACKUP_LOG="/tmp/backup.log"
#echo ${BACKUP_FILE_NAME}
if [ -f "${BACKUP_FILE_NAME}" ]; then
    lftp -u root,'123456' -p 22 sftp://192.168.1.2 <<EOF
    cd /bak/gitlab/backup
    put ${BACKUP_FILE_NAME}
    exit
EOF
else
    echo "${DATE}_File dose not exists!" >> ${BACKUP_LOG}
fi