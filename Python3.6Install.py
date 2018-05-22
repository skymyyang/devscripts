#coding: utf-8

import os
import sys
if os.getuid() == 0:
    pass
else:
    print("Please use 'root' to excute this script...")
    sys.exit(1)
version = raw_input('请输入你想要安装的Python版本，现在只支持3.6了，因为Python2系统自带了：')
if version == '3.6':
    url = 'https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz'
else:
    print("你输入的版本号有误，请输入3.6")
    sys.exit(1)
print("Install the dependency package, Please wait a few minutes...")
depcmd = "yum install wget gcc make zlib-devel readline-devel bzip2-devel ncurses-devel sqlite-deve gdbm-devel xz-devel tk-devel"
depres = os.system(depcmd)
if depres != 0:
    print("The dependency package install is failed, pelease check your network!")
    sys.exit(1)
cmd = 'wget ' + url
res = os.system(cmd)

if res != 0:
    print("download is failed！ Please check your cmd and network!")
    sys.exit(1)
command = 'tar xf Python-3.6.5.tgz'
result = os.system(command=command)
if result != 0:
    os.system('rm Python-3.6.5.tgz -rf' )
    print("decompression is failed~~,Please check your packages.")
    sys.exit(1)
cmd = 'cd Python-3.6.5 && ./configure --prefix=/usr/local/python3.6 --enable-optimizations && make && make install'
res = os.system(cmd)

if res != 0:
    print("Compile failure, try again!")
    sys.exit(1)
linkcmd = "ln -s /usr/local/python3.6/bin/python3 /usr/bin/ && ln -s /usr/local/python3.6/bin/pip3 /usr/bin/"
res = os.system(linkcmd)
if res != 0:
    print("The python3.6 is install sucessful...,Please python3 to test......")
    sys.exit(0)





