#!/usr/bin/python
# coding=utf-8

#python2

import json
import os
import sys
import datetime
import urllib2
from aliyunsdkcore import client
from aliyunsdkrds.request.v20140815.DescribeBackupsRequest import DescribeBackupsRequest


if (len(sys.argv) != 5):
	print  'use help:'
	print '''
		get_rds_backup.py rm-xxxxxxx  xxxxxxx xxxxxxxxx  /mnt/
		get_rds_backup.py  RDS实例ID   key  secret  备份保存位置
		key: Access Key ID
		secret:Access Key Secret 
		默认下载昨天的备份，时间可以修改，对应脚本中的变量 starttime 和 endtime
		'''
	sys.exit(0)

key = sys.argv[2]
key_secret = sys.argv[3]
rds_id = sys.argv[1]
back_path = sys.argv[4]
#back_path = "/mnt/"
yesterday = str(datetime.date.today() + datetime.timedelta(days=-1))
today = str(datetime.date.today())
starttime = yesterday + "T00:00Z"
print yesterday,today
endtime = today + "T00:00Z"
#key = ''
#key_secret = ''
region = "cn-hangzhou"
#rds_id = ['rmmhlc,'rm-mc']


def download_rds_backfile(instanceid):

        clt = client.AcsClient(key, key_secret, region)
        req_bakup = DescribeBackupsRequest()
        req_bakup.set_DBInstanceId(instanceid)
        req_bakup.set_accept_format('json')
        req_bakup.set_StartTime(starttime)
        req_bakup.set_EndTime(endtime)
        backup = clt.do_action_with_exception(req_bakup)
      #  print (backup)
        jsload = json.loads(backup)
        num = jsload["PageRecordCount"]
        print "backfiles:" + str(num)
        i = 0
        while i < num:

                bak_url = jsload["Items"]["Backup"][i]["BackupDownloadURL"]
                bak_host = jsload["Items"]["Backup"][i]["HostInstanceID"]
                bak_id = jsload["Items"]["Backup"][i]["BackupId"]
                print "BackupId:" + str(bak_id), "HostInstanceID:" + str(bak_host), "downloadurl:" + bak_url
                save_name = back_path + bak_url.split('?')[0].split('/')[-1]
                u = urllib2.urlopen(bak_url)
                f_header = u.info()
                bak_size = int(f_header.getheaders("Content-Length")[0])
                print "backup file size: %s M ,fime nema: %s" % (bak_size / 1024 / 1024, save_name)

                with open(save_name, "wb") as f:

                        file_size_dl = 0
                        block_sz = 8192
                        while True:
                                buffer = u.read(block_sz)
                                if not buffer:
                                        break

                                file_size_dl += len(buffer)
                                f.write(buffer)
                                status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / bak_size)
                                # status = status + chr(8) * (len(status) + 1)
                                print status
                i = i + 1
                print "download complet!"


download_rds_backfile(rds_id)