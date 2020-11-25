#!/bin/bash


#python36包的路径
VERSION="3.6.5"
PYTHON36=/opt/Python-${VERSION}.tgz

#安装依赖
yum install gcc libffi-devel zlib* openssl-devel -y

cd /opt
tar -zxvf Python-${VERSION}.tgz
cd Python-${VERSION}
./configure --prefix=/usr/local/python36
make && make install
cat <<EOF >> /etc/profile
export PATH=$PATH:/usr/local/python36/bin
EOF
source /etc/profile

which python3

#centos 7.8自带python3.6.8
