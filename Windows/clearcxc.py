# -*- coding: utf-8 -*-

#Windows下IIS对应站点的应用程序池经常挂掉，也没有找到原因，就写了个循环，去判断应用程序池是否挂掉，挂掉的话，进行重启
#将此脚本添加到Windows的计划任务即可

import os
import pycurl
import sys

def qccxc(apppool):
    os.chdir(u"C:\Windows\System32\inetsrv")
    res = os.popen("appcmd.exe list apppool")
    print(res.read())
    ref = os.popen(u"appcmd.exe stop apppool /apppool.name:%s"  %(apppool))
    print(ref.read())
    status = os.popen(u"appcmd.exe start apppool /apppool.name:%s"  %(apppool))
    print(status.read())
    


def testzhan(apppool):
    url = "http://" + apppool
    c = pycurl.Curl()
    c.setopt(pycurl.URL, url) #定义请求的url常量
    c.setopt(pycurl.CONNECTTIMEOUT, 5) #定义请求连接的等待时间
    c.setopt(pycurl.TIMEOUT, 10) #定义请求超时时间
    c.setopt(pycurl.MAXREDIRS, 1) #指定HTTP重定向的最大数为1
    c.setopt(pycurl.FORBID_REUSE, 1) #完成交互后强制断开连接不重用
    c.setopt(pycurl.NOPROGRESS, 1)  #屏蔽下载进度条
    c.setopt(pycurl.DNS_CACHE_TIMEOUT,30)  #设置DNS的信息时间为30秒
    indexfile = open(os.path.dirname(os.path.realpath(__file__))+"/content.txt", "wb")
    c.setopt(pycurl.WRITEHEADER, indexfile)
    c.setopt(pycurl.WRITEDATA, indexfile)
    try:
        c.perform()
    except Exception as e:
        print("connection error:" + str(e))
        indexfile.close()
        c.close()
        qccxc(apppool)
    HTTP_CODE = c.getinfo(c.HTTP_CODE)
    if HTTP_CODE == 200:
        print(apppool + " is ok")
        indexfile.close()
        c.close()
    else:
        indexfile.close()
        c.close()
        qccxc(apppool)

if __name__ == "__main__":
    testzhan("zuowen.mofangge.com")
    testzhan("m.mofangge.com")
    testzhan("www.mofangge.com")
    sys.exit()