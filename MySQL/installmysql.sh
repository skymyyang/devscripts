#!/bin/bash
yum -y install yum-utils
sleep 5
echo "yum-utils install successful,开始安装mysql yum 源"
yum install https://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm -y
echo "mysql yum 源安装成功"
sleep 5
yum-config-manager --disable mysql56-community
yum-config-manager --enable mysql57-community-dmr
echo "激活mysql5.7的源,开始mysql安装"
sleep 5
yum install mysql mysql-devel mysql-server mysql-utilities -y
echo "安装成功"
sleep 5
echo "修改配置文件，取消密码登陆"
sed -i -e '/\[mysqld\]/a\skip-grant-tables' /etc/my.cnf
sed -i -e '/\[mysqld\]/a\character-set-server=utf8' /etc/my.cnf
sleep 3
echo "启动MYSQL"
systemctl start mysqld
systemctl enable mysqld
sleep 5
echo "修改MYSQL密码"
mysql -uroot -e "update mysql.user set authentication_string=password(123456) where user='root' and Host = 'localhost';"
sed -i 's/skip-grant-tables/#skip-grant-tables/' /etc/my.cnf
systemctl restart mysqld
sleep 3
echo "输入新密码，密码必须符合复杂程度要求"
mysqladmin -uroot -p123456 password
systemctl restart mysqld
echo "Sucessful! Please use new password sing in !!!"
