#!/bin/sh

#安装MongoDB
cat /etc/yum.repos.d/mongodb.repo <<EOF
[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://mirrors.aliyun.com/mongodb/yum/redhat/\$releasever/mongodb-org/4.0/x86_64/
gpgcheck=0
enabled=1
EOF
yum install -y mongodb-org
systemctl enable mongod
systemctl start mongod
#安装nodejs
curl -sL https://rpm.nodesource.com/setup_10.x | bash - && yum install -y nodejs
npm -v
node -v
npm install -g yapi-cli --registry https://registry.npm.taobao.org

