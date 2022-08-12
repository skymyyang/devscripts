# -*- coding: utf-8 -*-
# This file is auto-generated, don't edit it. Thanks.
import sys
import math
import subprocess
import datetime
import os

from alibabacloud_alidns20150109.client import Client as Alidns20150109Client
from alibabacloud_tea_openapi import models as open_api_models
from alibabacloud_alidns20150109 import models as alidns_20150109_models


class Implement_sync_alibaba_dns:
    def __init__(self):
        pass

    @staticmethod
    def create_client(
        access_key_id: str,
        access_key_secret: str,
    ) -> Alidns20150109Client:
        """
        使用AK&SK初始化账号Client
        @param access_key_id:
        @param access_key_secret:
        @return: Client
        @throws Exception
        """
        config = open_api_models.Config(
            # 您的AccessKey ID,
            access_key_id=access_key_id,
            # 您的AccessKey Secret,
            access_key_secret=access_key_secret
        )
        # 访问的域名
        config.endpoint = f'alidns.cn-hangzhou.aliyuncs.com'
        return Alidns20150109Client(config)

    def is_dns_exist(self, dns_rr, dns_type, dns_domain_name):
        try:
            args = [r"powershell.exe", r"c:\scripts\handle_dns.ps1", "SEARCH" ,dns_type, dns_rr, dns_domain_name]
            proc = subprocess.Popen(args, stdout=subprocess.PIPE)
            if proc.wait() == 0:
                ad_dns_value = proc.stdout.read().decode('utf-8').strip()
                return ad_dns_value
            else:
                return False
        except Exception as e:
            print(e)
            return ""

    def main(self):
        accessKeyId = "xxxxxxxxxxxxxxxxx"
        accessKeySecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        domain = "xxxxxx.com"
        start_date = (datetime.datetime.now() - datetime.timedelta(minutes=10)).strftime("%Y-%m-%dT%H:%M:%SZ")
        end_date = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%SZ")
        file_name = "time.txt"
        if (os.path.exists(file_name)):
            with open(file_name, 'rt') as f:
                try:
                    tmp_date = f.read()
                    datetime.datetime.strptime(tmp_date, "%Y-%m-%dT%H:%M:%SZ")
                    start_date = tmp_date
                except ValueError:
                    print("Not getting the correct time")
            with open(file_name, 'wt') as f:
                f.write(end_date)
        client = Implement_sync_alibaba_dns.create_client(accessKeyId, accessKeySecret)
        describe_record_logs_request = alidns_20150109_models.DescribeRecordLogsRequest(
            domain_name=domain,
            start_date = start_date,
            end_date = end_date
        )
        # 复制代码运行请自行打印 API 的返回值
        summary = client.describe_record_logs(describe_record_logs_request)
        total_count = summary.body.total_count
        page_size = summary.body.page_size
        page_count = math.ceil(total_count / page_size)
        for i in range(page_count):
            record = client.describe_record_logs(alidns_20150109_models.DescribeRecordLogsRequest(
                domain_name=domain,
                start_date=start_date,
                end_date=end_date,
                page_number=page_count-i)).body.record_logs.record_log
            for single_record in reversed(record):
                handle_func = single_record.action
                key_msg = single_record.message.split("record.")[-1].split("changed to")[-1].strip().split(" ")
                dns_type = key_msg[0]
                dns_rr = key_msg[2]
                dns_domain_name = domain
                dns_value = key_msg[4]

                if(handle_func == "DEL"):
                    args = [r"powershell.exe", r"c:\scripts\handle_dns.ps1", handle_func, dns_type, dns_rr,
                            dns_domain_name, dns_value]
                    proc = subprocess.Popen(args, stdout=subprocess.PIPE)
                    if proc.wait() == 0:
                        msg = proc.stdout.read().decode('utf-8').strip()
                        print(msg)
                    else:
                        print("fail %s dns_type:%s, dns_rr:%s, dns_domain_name:%s, dns_value:%s" % (handle_func,
                                dns_type, dns_rr, dns_domain_name, dns_value))
                elif(handle_func == "ADD"):
                    ad_dns_value = self.is_dns_exist(dns_rr, dns_type, dns_domain_name)
                    if(ad_dns_value != dns_value):
                        args = [r"powershell.exe", r"c:\scripts\handle_dns.ps1", handle_func, dns_type, dns_rr,
                                dns_domain_name, dns_value]
                        proc = subprocess.Popen(args, stdout=subprocess.PIPE)
                        if proc.wait() == 0:
                            msg = proc.stdout.read().decode('utf-8').strip()
                            print(msg)
                        else:
                            print("fail %s dns_type:%s, dns_rr:%s, dns_domain_name:%s, dns_value:%s" % (handle_func,
                                    dns_type, dns_rr, dns_domain_name, dns_value))
                elif (handle_func == "UPDATE" and dns_type == "CNAME" and ad_dns_value != (dns_value + ".")):
                    args = [r"powershell.exe", r"c:\scripts\handle_dns.ps1", "UPDATE", dns_type, dns_rr,
                            dns_domain_name, dns_value+"."]
                    proc = subprocess.Popen(args, stdout=subprocess.PIPE)
                    if proc.wait() == 0:
                        msg = proc.stdout.read().decode('utf-8').strip()
                        print(msg)
                    else:
                        print("fail update dns_type:%s, dns_rr:%s, dns_domain_name:%s, dns_value:%s" % (dns_type,
                                dns_rr, dns_domain_name, dns_value))
                elif (handle_func == "UPDATE"):
                    ad_dns_value = self.is_dns_exist(dns_rr, dns_type, dns_domain_name)
                    if (ad_dns_value != dns_value):
                        args = [r"powershell.exe", r"c:\scripts\handle_dns.ps1", handle_func, dns_type, dns_rr,
                                dns_domain_name, dns_value]
                        proc = subprocess.Popen(args, stdout=subprocess.PIPE)
                        if proc.wait() == 0:
                            msg = proc.stdout.read().decode('utf-8').strip()
                            print(msg)
                        else:
                            print("fail %s dns_type:%s, dns_rr:%s, dns_domain_name:%s, dns_value:%s" % (handle_func,
                                    dns_type, dns_rr, dns_domain_name, dns_value))
                else:
                    pass

if __name__ == '__main__':
    implement_sync_alibaba_dns = Implement_sync_alibaba_dns()
    implement_sync_alibaba_dns.main()
