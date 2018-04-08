#!/usr/bin/env bash
#centos同步阿里云时间服务器，自动配置脚本
yum install chrony -y >/dev/null 2>&1
if [ $? -eq 0 ]; then
  sed -i "s/0.centos.pool.ntp.org/ntp.aliyun.com/" /etc/chrony.conf && sed -i "/centos.pool.ntp.org/d" /etc/chrony.conf
  else
  echo "The service yum install is failed!"
fi
systemctl enable chronyd
systemctl restart chronyd
if [ $? -eq 0 ]; then
  chronyc tracking
fi
