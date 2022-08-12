# -*- coding: utf-8 -*-
# This file is auto-generated, don't edit it. Thanks.
import sys
import math
import subprocess

from alibabacloud_alidns20150109.client import Client as Alidns20150109Client
from alibabacloud_tea_openapi import models as open_api_models
from alibabacloud_alidns20150109 import models as alidns_20150109_models


class Sync_alibaba_dns_all:
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
        accessKeyId = "xxxxxxxxxxxxxxxxxxxxxxxxx"
        accessKeySecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        domain = "xxxxxx.com"
        client = Sync_alibaba_dns_all.create_client(accessKeyId, accessKeySecret)
        describe_domain_records_request = alidns_20150109_models.DescribeDomainRecordsRequest(
            domain_name=domain
        )
        # 复制代码运行请自行打印 API 的返回值
        # client.describe_domain_records(describe_domain_records_request)
        summary = client.describe_domain_records(describe_domain_records_request)
        # print(summary.body.domain_records.record)
        # for j in summary.body.domain_records.record:
        #     print(j.rr)
        total_count = summary.body.total_count
        page_size = summary.body.page_size
        page_count = math.ceil(total_count/page_size)
        for i in range(page_count):
            record = client.describe_domain_records(alidns_20150109_models.DescribeDomainRecordsRequest(
                domain_name=domain,
                page_number=i+1)).body.domain_records.record
            for single_record in record:
                dns_type = single_record.type
                dns_rr = single_record.rr
                dns_domain_name = single_record.domain_name
                dns_value = single_record.value
                ad_dns_value = self.is_dns_exist(dns_rr, dns_type, dns_domain_name)
                if(ad_dns_value == "False"):
                    args = [r"powershell.exe", r"c:\scripts\handle_dns.ps1", "ADD" ,dns_type, dns_rr,
                            dns_domain_name, dns_value]
                    proc = subprocess.Popen(args, stdout=subprocess.PIPE)
                    if proc.wait() == 0:
                        msg = proc.stdout.read().decode('utf-8').strip()
                        print(msg)
                    else:
                        print("fail add dns_type:%s, dns_rr:%s, dns_domain_name:%s, dns_value:%s" % (dns_type, dns_rr,
                                dns_domain_name, dns_value))
                elif(dns_type == "CNAME" and ad_dns_value != (dns_value+".")):
                    args = [r"powershell.exe", r"c:\scripts\handle_dns.ps1", "UPDATE", dns_type, dns_rr,
                            dns_domain_name, dns_value]
                    proc = subprocess.Popen(args, stdout=subprocess.PIPE)
                    if proc.wait() == 0:
                        msg = proc.stdout.read().decode('utf-8').strip()
                        print(msg)
                    else:
                        print("fail update dns_type:%s, dns_rr:%s, dns_domain_name:%s, dns_value:%s" % (dns_type,
                                dns_rr, dns_domain_name, dns_value))
                elif(ad_dns_value != dns_value):
                    args = [r"powershell.exe", r"c:\scripts\handle_dns.ps1", "UPDATE", dns_type, dns_rr,
                            dns_domain_name, dns_value]
                    proc = subprocess.Popen(args, stdout=subprocess.PIPE)
                    if proc.wait() == 0:
                        msg = proc.stdout.read().decode('utf-8').strip()
                        print(msg)
                    else:
                        print("fail update dns_type:%s, dns_rr:%s, dns_domain_name:%s, dns_value:%s" % (dns_type,
                                dns_rr, dns_domain_name, dns_value))
                else:
                    pass
                


if __name__ == '__main__':
    sync_alibaba_dns_all = Sync_alibaba_dns_all()
    sync_alibaba_dns_all.main()
