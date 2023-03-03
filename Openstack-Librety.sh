手动搭建Openstack Librety-Debug


前言

本文档搭建的是ALL IN ONE（controller+compute放一节点上）的文档。openstack版本为Librety。



一、 环境准备

0. 前提准备

安装vmware workstation，虚拟出配置至少CPU 4c MEM 4G的虚拟机两块硬盘（200G+50G即可）+两个网卡（管理网+虚拟机私网）

安装CentOS7.2系统（最小化安装） + 关闭防火墙 + 关闭selinux
#systemctl stop firewalld.service
#systemctl disable firewalld.service

安装好相关工具，因为系统是最小化安装的，所以一些ifconfig vim等命令没有，运行下面的命令把它们装上：
# yum install net-tools wget vim -y

替换CentOS默认源，默认生产环境上不了外网，所以你得想办法用自己的内部Yum源，如果没有，需要搭建一个。让系统上网，然后运行下面命令：
cd /etc/yum.repos.d
#rm -rf *
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
这里用的是阿里的源。

1. 更改hostname
# hostnamectl set-hostname controller

2. 修改hosts文件
注意，这个192.168.188.128就是你的管理IP，第一块网卡的地址
# vim /etc/hosts 192.168.188.128 controller

3. 安装配置NTP
#yum install chrony -y
#sed -i 's/^restrict\ default\ nomodify\ notrap\ nopeer\ noquery/restrict\ default\ nomodify\ /' /etc/chrony.conf
#sed -i "/^# Please\ consider\ joining\ the\ pool/iserver\ ${HOSTNAME}\ iburst " /etc/chrony.conf

设置NTP开机启动
#systemctl enable chronyd.service
#systemctl start chronyd.service

4. 安装openstack的源
# yum install centos-release-openstack-liberty -y

5. 升级系统
# yum update -y

6.重启系统
# reboot

7.打快照

因为实验是在vmware workstation下做的，打快照是为了做备份，万一后面搭建错了，可以很快还原，然后接着搭建。


二、安装mariadb及rabbitmq

1. yum安装python-openstackclient和openstack-selinux
# yum install python-openstackclient -y
# yum install openstack-selinux -y


2. 安装数据库
# yum install mariadb mariadb-server python2-PyMySQL -y

3. 配置mariadb
# vim /etc/my.cnf.d/mariadb_openstack.cnf

写入内容如下：
# [mysqld] 
# innodb_file_per_table 
# default-storage-engine = innodb 
# collation-server = utf8_general_ci 
# init-connect = 'SET NAMES utf8' 
# character-set-server = utf8 
# bind-address = 192.168.188.128

4、启动数据库及设置开机启动
# systemctl enable mariadb.service
# systemctl start mariadb.service
# systemctl list-unit-files |grep mariadb.service

5. 配置并且同步数据
# mysql_secure_installation

先按回车，然后按Y，设置mysql密码，然后一直按y结束这里我们设置的密码是passw0rd

6. 安装rabbitmq-server
# yum install rabbitmq-server -y

7. 启动rabbitmq及设置开机启动
# systemctl enable rabbitmq-server.service
# systemctl start rabbitmq-server.service
# systemctl list-unit-files |grep rabbitmq-server.service  这条命令是查看rabbitmq服务有没有enable

8.创建openstack，注意将PASSWOED替换为自己的合适密码
# rabbitmqctl add_user openstack passw0rd

9.将openstack用户赋予权限
# rabbitmqctl set_permissions openstack ".*" ".*" ".*"

10. 看下监听端口 rabbitmq用的是5672端口
# netstat -ntlp |grep 5672

11 .查看RabbitMQ插件
# /usr/lib/rabbitmq/bin/rabbitmq-plugins list

12. 打开插件
# /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management


13. Firefox 访问RabbitMQ web界面

http://192.168.188.128:15672默认用户名密码：guest/guest

通过这个界面，我们能很直观的看到rabbitmq的运行和负载情况

三、安装keystone

从这步开始就是安装openstack的组件了，第一步通常是创建该组件用的数据库。

注意数据库密码都是passw0rd，这个你可以自己设定，但是第一次搭建，最好跟文档一致，熟悉了再去做其他更改。


1、创建keystone数据库
# mysql -uroot -ppassw0rd -e "CREATE DATABASE keystone;"

注意将passw0rd 替换为自己的数据库密码

2、创建数据库用户及赋予权限
#mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'passw0rd';"
#mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'passw0rd';"

注意将passw0rd 替换为自己的数据库密码

3、安装keystone相关软件包
# yum install openstack-keystone httpd mod_wsgi memcached python-memcached -y

注：memcached 是一个高性能的分布式内存对象缓存系统，用于动态Web应用以减轻数据库负载。

4、启动memcached，并设置开机启动
#systemctl enable memcached.service
#systemctl start memcached.service
#systemctl list-unit-files |grep memcached.service

5、安装openstack文件配置工具
# yum install -y openstack-utils

6、生成token
ADMIN_TOKEN=294a4c8a8a475f9b9836  直接给ADMIN_TOKEN赋予一个字符串变量，你也可以openssl生成

7、配置/etc/keystone/keystone.conf文件
#openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
#openstack-config --set /etc/keystone/keystone.conf database connection
mysql://keystone:passw0rd@$HOSTNAME/keystone
#openstack-config --set /etc/keystone/keystone.conf memcache servers localhost:11211
#openstack-config --set /etc/keystone/keystone.conf token provider uuid
#openstack-config --set /etc/keystone/keystone.conf token driver memcache
#openstack-config --set /etc/keystone/keystone.conf revoke driver sql
#openstack-config --set /etc/keystone/keystone.conf DEFAULT verbose True

8、同步keystone数据库
# su -s /bin/sh -c "keystone-manage db_sync" keystone

如果提示：No handlers could be found for logger "oslo_config.cfg" 忽略即可。

9、配置http服务
# sed -i "s/#ServerName www.example.com:80/ServerName ${HOSTNAME}/" /etc/httpd/conf/httpd.conf

10、创建/etc/httpd/conf.d/wsgi-keystone.conf ，并写入如下内容
# vim /etc/httpd/conf.d/wsgi-keystone.conf

添加下面内容：
Listen 5000
Listen 35357

<VirtualHost *:5000>

WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP} WSGIProcessGroup keystone-public

WSGIScriptAlias / /usr/bin/keystone-wsgi-public WSGIApplicationGroup %{GLOBAL} WSGIPassAuthorization On

<IfVersion >= 2.4> ErrorLogFormat "%{cu}t %M" </IfVersion>
ErrorLog /var/log/httpd/keystone-error.log
CustomLog /var/log/httpd/keystone-access.log combined

<Directory /usr/bin> <IfVersion >= 2.4>
Require all granted </IfVersion>

<IfVersion < 2.4> Order allow,deny Allow from all
</IfVersion>
</Directory>
</VirtualHost>

<VirtualHost *:35357>

WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP} WSGIProcessGroup keystone-admin

WSGIScriptAlias / /usr/bin/keystone-wsgi-admin WSGIApplicationGroup %{GLOBAL} WSGIPassAuthorization On

<IfVersion >= 2.4> ErrorLogFormat "%{cu}t %M" </IfVersion>
ErrorLog /var/log/httpd/keystone-error.log
CustomLog /var/log/httpd/keystone-access.log combined

<Directory /usr/bin> <IfVersion >= 2.4>
Require all granted </IfVersion> <IfVersion < 2.4>
Order allow,deny

Allow from all </IfVersion>
</Directory>
</VirtualHost>


11、启动httpd，并设置开机启动
#systemctl enable httpd.service
#systemctl start httpd.service
#systemctl status httpd.service
#systemctl list-unit-files |grep httpd.service

12、导入环境变量

export OS_TOKEN=294a4c8a8a475f9b9836 
export OS_URL=http://${HOSTNAME}:35357/v3 
export OS_IDENTITY_API_VERSION=3

13、创建keystone服务
# openstack service create --name keystone --description "OpenStack Identity" identity

14、创建endpoint
# openstack endpoint create --region RegionOne identity public http://${HOSTNAME}:5000/v2.0
# openstack endpoint create --region RegionOne identity internal http://${HOSTNAME}:5000/v2.0
# openstack endpoint create --region RegionOne identity admin http://${HOSTNAME}:35357/v2.0

15、创建admin项目
# openstack project create --domain default --description "Admin Project" admin

16、创建admin用户
# openstack user create --domain default admin --password admin
注意最后一个是admin用户的密码

17、创建admin角色及将admin用户赋予admin角色
# openstack role create admin
# openstack role add --project admin --user admin admin

18、创建service项目
# openstack project create --domain default --description "Service Project" service

19、创建demo项目
# openstack project create --domain default --description "Demo Project" demo


20、创建demo用户
# openstack user create --domain default demo --password demo
注意：demo为demo用户密码

21、创建user角色将demo用户赋予user角色
#openstack role create user
#openstack role add --project demo --user demo user

22、验证keystone
#unset OS_TOKEN OS_URL
#openstack --os-auth-url http://${HOSTNAME}:35357/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name admin --os-username admin token issue --os-password admin
#openstack --os-auth-url http://${HOSTNAME}:5000/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name demo --os-username demo token issue --os-password demo
注意：此处需要输入admin和demo的密码。

23、创建admin用户环境变量，创建/root/admin-openrc.sh 文件并写入如下内容
# vim /root/admin-openrc.sh
添加：
export OS_PROJECT_DOMAIN_ID=default 
export OS_USER_DOMAIN_ID=default 
export OS_PROJECT_NAME=admin 
export OS_TENANT_NAME=admin 
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_AUTH_URL=http://${HOSTNAME}:35357/v3 
export OS_IDENTITY_API_VERSION=3

24、创建demo用户环境变量，创建/root/demo-openrc.sh 文件并写入下列内容
# vim /root/demo-openrc.sh
添加：
export OS_PROJECT_DOMAIN_ID=default 
export OS_USER_DOMAIN_ID=default 
export OS_PROJECT_NAME=demo 
export OS_TENANT_NAME=demo 
export OS_USERNAME=demo
export OS_PASSWORD=demo
export OS_AUTH_URL=http://${HOSTNAME}:5000/v3 
export OS_IDENTITY_API_VERSION=3

四、安装glance

1、创建glance数据库
# mysql -uroot -ppassw0rd -e "CREATE DATABASE glance;"

2、创建数据库用户并赋予权限
#mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'passw0rd';"
#mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'passw0rd';"

3、创建glance用户及赋予admin权限
# source /root/admin-openrc.sh
# openstack user create glance --password passw0rd
# openstack role add --project service --user glance admin

4、创建image服务
# openstack service create --name glance --description "OpenStack Image service" image

5、创建glance的endpoint
# openstack endpoint create --region RegionOne image public http://${HOSTNAME}:9292
# openstack endpoint create --region RegionOne image internal http://${HOSTNAME}:9292
# openstack endpoint create --region RegionOne image admin http://${HOSTNAME}:9292

6、创建glance相关rpm包
# yum install openstack-glance python-glance python-glanceclient -y

7、修改glance配置文件/etc/glance/glance-api.conf
注意红色的密码设置
#openstack-config --set /etc/glance/glance-api.conf database connection mysql://glance:passw0rd@${HOSTNAME}/glance
#openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://${HOSTNAME}:5000
#openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://${HOSTNAME}:35357
#openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_plugin password
#openstack-config --set /etc/glance/glance-api.conf keystone_authtoken project_domain_id default
#openstack-config --set /etc/glance/glance-api.conf keystone_authtoken user_domain_id default
#openstack-config --set /etc/glance/glance-api.conf keystone_authtoken username glance
#openstack-config --set /etc/glance/glance-api.conf keystone_authtoken password passw0rd
#openstack-config --set /etc/glance/glance-api.conf keystone_authtoken project_name service
#openstack-config --set /etc/glance/glance-api.conf paste_deploy flavor keystone
#openstack-config --set /etc/glance/glance-api.conf glance_store default_store file
#openstack-config --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/
#openstack-config --set /etc/glance/glance-api.conf DEFAULT notification_driver noop
#openstack-config --set /etc/glance/glance-api.conf DEFAULT verbose True

8、修改glance配置文件/etc/glance/glance-registry.conf
#openstack-config --set /etc/glance/glance-registry.conf database connection mysql://glance:passw0rd@${HOSTNAME}/glance
#openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://${HOSTNAME}:5000
#openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_url http://${HOSTNAME}:35357
#openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_plugin password
#openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken project_domain_id default
#openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken user_domain_id default
#openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken project_name service
#openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken username glance
#openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken password passw0rd
#openstack-config --set /etc/glance/glance-registry.conf paste_deploy flavor keystone
#openstack-config --set /etc/glance/glance-registry.conf DEFAULT notification_driver noop
#openstack-config --set /etc/glance/glance-registry.conf DEFAULT verbose True

9、同步glance数据库
# su -s /bin/sh -c "glance-manage db_sync" glance

10、启动glance及设置开机启动
#systemctl enable openstack-glance-api.service openstack-glance-registry.service
#systemctl start openstack-glance-api.service openstack-glance-registry.service

11、将glance版本号写入环境变量中
echo " " >> /root/admin-openrc.sh && \ echo " " >> /root/demo-openrc.sh
echo "export OS_IMAGE_API_VERSION=2" | tee -a /root/admin-openrc.sh /root/demo-openrc.sh

12、下载测试镜像
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

13、上传镜像到glance
#source /root/admin-openrc.sh
#glance image-create --name "cirros-0.3.4-x86_64" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility public --progress

如果你做好了一个CentOS6.7系统的镜像，也可以用这命令操作，例：
# glance image-create --name "Centos6.7-x86_64" --file CentOS6.7-x86_64 --disk-format qcow2 --container-format bare -- visibility public --progress

查看镜像列表：
# glance image-list



五、安装Nova

1、创建nova数据库
# mysql -uroot -ppassw0rd -e "CREATE DATABASE nova;"

2、创建数据库用户并赋予权限
# mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'passw0rd';"
# mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'passw0rd';"

3、创建nova用户及赋予admin权限
# source /root/admin-openrc.sh
# openstack user create nova --password passw0rd
# openstack role add --project service --user nova admin

4、创建computer服务
# openstack service create --name nova --description "OpenStack Compute" compute

5、创建nova的endpoint
# openstack endpoint create --region RegionOne compute public http://${HOSTNAME}:8774/v2/%\(tenant_id\)s
# openstack endpoint create --region RegionOne compute internal http://${HOSTNAME}:8774/v2/%\(tenant_id\)s
# openstack endpoint create --region RegionOne compute admin http://${HOSTNAME}:8774/v2/%\(tenant_id\)s

6、安装nova相关软件
# yum install -y openstack-nova-api openstack-nova-cert openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler python-novaclient

7、配置nova的配置文件/etc/nova/nova.conf
#openstack-config --set /etc/nova/nova.conf database connection mysql://nova:passw0rd@${HOSTNAME}/nova
#openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend rabbit
#openstack-config --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host ${HOSTNAME}
#openstack-config --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
#openstack-config --set /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password passw0rd
#openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
#openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://${HOSTNAME}:5000
#openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_url http://${HOSTNAME}:35357
#openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_plugin password
#openstack-config --set /etc/nova/nova.conf keystone_authtoken project_domain_id default
#openstack-config --set /etc/nova/nova.conf keystone_authtoken user_domain_id default
#openstack-config --set /etc/nova/nova.conf keystone_authtoken project_name service
#openstack-config --set /etc/nova/nova.conf keystone_authtoken username nova
#openstack-config --set /etc/nova/nova.conf keystone_authtoken password passw0rd
#openstack-config --set /etc/nova/nova.conf DEFAULT my_ip 192.168.188.128
#openstack-config --set /etc/nova/nova.conf DEFAULT verbose True
#openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
#openstack-config --set /etc/nova/nova.conf DEFAULT security_group_api neutron
#openstack-config --set /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.NeutronLinuxBridgeInterfaceDriver
#openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
#openstack-config --set /etc/nova/nova.conf vnc vncserver_listen 192.168.188.128
#openstack-config --set /etc/nova/nova.conf vnc vncserver_proxyclient_address 192.168.188.128
#openstack-config --set /etc/nova/nova.conf vnc novncproxy_base_url http://192.168.188.128:6080/vnc_auto.html
#openstack-config --set /etc/nova/nova.conf glance host controller
#openstack-config --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
#openstack-config --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata

注意，替换IP，还有密码，文档红色以及绿色的地方。

8、同步nova数据
# su -s /bin/sh -c "nova-manage db sync" nova

9、启动nova服务并设置开机启动
# systemctl enable openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
# systemctl start openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
# systemctl status openstack-nova-api.service openstack-nova-cert.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service
# systemctl list-unit-files |grep openstack-nova-*

10、安装openstack-nova-compute和 sysfsutils服务
# yum install openstack-nova-compute sysfsutils -y

11、配置nova配置文件
如果你的是虚拟机环境：
# openstack-config --set /etc/nova/nova.conf libvirt virt_type qemu

如果你的是物理机环境：
# openstack-config --set /etc/nova/nova.conf libvirt virt_type kvm

12、启动compute服务及设置开机启动
#systemctl enable libvirtd.service openstack-nova-compute.service
#systemctl start libvirtd.service openstack-nova-compute.service
#systemctl status libvirtd.service openstack-nova-compute.service

13、验证nova服务
#source /root/admin-openrc.sh
#nova service-list
#nova endpoints
#nova image-list

六、安装Cinder

1、创建cinder数据库
# mysql -uroot -ppassw0rd -e "CREATE DATABASE cinder;"

2、创建数据库用户并赋予权限

#mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'passw0rd';"

#mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'passw0rd';"

3、创建cinder用户并赋予admin权限
# openstack user create --domain default cinder --password passw0rd
# openstack role add --project service --user cinder admin

4、创建volume服务
# openstack service create --name cinder --description "OpenStack Block Storage" volume
# openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2

5、创建endpoint
# openstack endpoint create --region RegionOne volume public http://${HOSTNAME}:8776/v1/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volume internal http://${HOSTNAME}:8776/v1/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volume admin http://${HOSTNAME}:8776/v1/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volumev2 public http://${HOSTNAME}:8776/v2/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volumev2 internal http://${HOSTNAME}:8776/v2/%\(tenant_id\)s
# openstack endpoint create --region RegionOne volumev2 admin http://${HOSTNAME}:8776/v2/%\(tenant_id\)s

6、安装cinder相关服务
# yum install openstack-cinder python-cinderclient -y

7、复制/usr/share/cinder/cinder-dist.conf为/etc/cinder/cinder.conf
# \cp /usr/share/cinder/cinder-dist.conf /etc/cinder/cinder.conf
# chown -R cinder:cinder /etc/cinder/cinder.conf

8、配置cinder配置文件
# openstack-config --set /etc/cinder/cinder.conf database connection mysql://cinder:passw0rd@${HOSTNAME}/cinder
# openstack-config --set /etc/cinder/cinder.conf DEFAULT rpc_backend rabbit
# openstack-config --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_host ${HOSTNAME}
# openstack-config --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_userid openstack
# openstack-config --set /etc/cinder/cinder.conf oslo_messaging_rabbit rabbit_password passw0rd
# openstack-config --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
# openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_uri http://${HOSTNAME}:5000
# openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://${HOSTNAME}:35357
# openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_plugin password
# openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_domain_id default
# openstack-config --set /etc/cinder/cinder.conf keystone_authtoken user_domain_id default
# openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_name service
# openstack-config --set /etc/cinder/cinder.conf keystone_authtoken username cinder
# openstack-config --set /etc/cinder/cinder.conf keystone_authtoken password passw0rd
# openstack-config --set /etc/cinder/cinder.conf DEFAULT my_ip 192.168.188.128
# openstack-config --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
# openstack-config --set /etc/cinder/cinder.conf DEFAULT verbose True

9、同步数据库
# su -s /bin/sh -c "cinder-manage db sync" cinder

10、配置nova配置文件
# openstack-config --set /etc/nova/nova.conf cinder os_region_name RegionOne

11、重启nova服务
# systemctl restart openstack-nova-api.service
# systemctl status openstack-nova-api.service

12、启动cinder服务，并设置开机启动
#systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
#systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service
#systemctl status openstack-cinder-api.service openstack-cinder-scheduler.service

13、安装qemu和 lvm2 
# yum install qemu lvm2 -y

14、启动lvm2-lvmetad和设置开机前启动
#systemctl enable lvm2-lvmetad.service
#systemctl start lvm2-lvmetad.service
#systemctl status lvm2-lvmetad.service

15、创建lvm
#fdisk -l
#pvcreate /dev/sdb
#vgcreate cinder-volumes /dev/sdb

16、安装openstack-cinder、targetcli 和python-oslo-policy
# yum install openstack-cinder targetcli python-oslo-policy -y

17、配置cinder配置文件
#openstack-config --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
#openstack-config --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
#openstack-config --set /etc/cinder/cinder.conf lvm iscsi_protocol iscsi
#openstack-config --set /etc/cinder/cinder.conf lvm iscsi_helper lioadm
#openstack-config --set /etc/cinder/cinder.conf DEFAULT glance_host ${HOSTNAME}
#openstack-config --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm
#openstack-config --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp

18、启动openstack-cinder-volume和target并设置开机启动
#systemctl enable openstack-cinder-volume.service target.service
#systemctl start openstack-cinder-volume.service target.service
#systemctl status openstack-cinder-volume.service target.service

19、验证cinder服务是否正常
#source /root/admin-openrc.sh
#cinder service-list

七、安装Neutron

1、创建neutron数据库
# mysql -uroot -ppassw0rd -e "CREATE DATABASE neutron;"

2、创建数据库用户并赋予权限
mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'passw0rd';"
mysql -uroot -ppassw0rd -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'passw0rd';"

3、创建neutron用户及赋予admin权限
# openstack user create neutron --password passw0rd
# openstack role add --project service --user neutron admin

4、创建network服务
# openstack service create --name neutron --description "OpenStack Networking" network

5、创建endpoint
# openstack endpoint create --region RegionOne network public http://${HOSTNAME}:9696
# openstack endpoint create --region RegionOne network internal http://${HOSTNAME}:9696
# openstack endpoint create --region RegionOne network admin http://${HOSTNAME}:9696

6、安装neutron相关软件
# yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge python-neutronclient -y

7、配置neutron配置文件/etc/neutron/neutron.conf
#openstack-config --set /etc/neutron/neutron.conf database connection mysql://neutron:passw0rd@${HOSTNAME}/neutron
#openstack-config --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
#openstack-config --set /etc/neutron/neutron.conf DEFAULT service_plugins router
#openstack-config --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
#openstack-config --set /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
#openstack-config --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host ${HOSTNAME}
#openstack-config --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid openstack
#openstack-config --set /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password passw0rd
#openstack-config --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
#openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://${HOSTNAME}:5000
#openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://${HOSTNAME}:35357
#openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_plugin password
#openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_domain_id default
#openstack-config --set /etc/neutron/neutron.conf keystone_authtoken user_domain_id default
#openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_name service
#openstack-config --set /etc/neutron/neutron.conf keystone_authtoken username neutron
#openstack-config --set /etc/neutron/neutron.conf keystone_authtoken password passw0rd
#openstack-config --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes True
#openstack-config --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes True
#openstack-config --set /etc/neutron/neutron.conf DEFAULT nova_url http://${HOSTNAME}:8774/v2
#openstack-config --set /etc/neutron/neutron.conf nova auth_url http://${HOSTNAME}:35357
#openstack-config --set /etc/neutron/neutron.conf nova auth_plugin password
#openstack-config --set /etc/neutron/neutron.conf nova project_domain_id default
#openstack-config --set /etc/neutron/neutron.conf nova user_domain_id default
#openstack-config --set /etc/neutron/neutron.conf nova region_name RegionOne
#openstack-config --set /etc/neutron/neutron.conf nova project_name service
#openstack-config --set /etc/neutron/neutron.conf nova username nova
#openstack-config --set /etc/neutron/neutron.conf nova password passw0rd
#openstack-config --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
#openstack-config --set /etc/neutron/neutron.conf DEFAULT verbose True

8、配置/etc/neutron/plugins/ml2/ml2_conf
# openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,vxlan
# openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge,l2population
# openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
# openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types vxlan
# openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks public
#openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_vxlan vni_ranges 1:1000
#openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True

9、配置/etc/neutron/plugins/ml2/linuxbridge_agent.ini
#openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings public:eno16777736
#openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan True
#openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 192.168.188.128
# openstack-config --set  /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population True
# openstack-config --set  /etc/neutron/plugins/ml2/linuxbridge_agent.ini agent prevent_arp_spoofing True
# openstack-config --set  /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup  enable_security_group True
# openstack-config --set  /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup  firewall_driver
neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

注意eno16777736是192.168.188.128 IP所在的网卡名，一般这里写管理IP的网卡名

10、配置 /etc/neutron/l3_agent.ini   
# openstack-config --set /etc/neutron/l3_agent.ini DEFAULT  interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver   
# openstack-config --set /etc/neutron/l3_agent.ini DEFAULT  external_network_bridge
# openstack-config --set /etc/neutron/l3_agent.ini DEFAULT  verbose True
11、配置/etc/neutron/dhcp_agent.ini    
# openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT  interface_driver
neutron.agent.linux.interface.BridgeInterfaceDriver   
# openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT  dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
# openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT  enable_isolated_metadata True
# openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT  verbose True
# openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT  dnsmasq_config_file /etc/neutron/dnsmasq-neutron.conf
# openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT  interface_driver neutron.agent.linux.interface.BridgeInterfaceDriver   


12、将dhcp-option-force=26,1450写入/etc/neutron/dnsmasq-neutron.conf
# echo "dhcp-option-force=26,1450" >/etc/neutron/dnsmasq-neutron.conf

13、配置/etc/neutron/metadata_agent.ini
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT auth_uri http://${HOSTNAME}:5000
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT auth_url http://${HOSTNAME}:35357
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT auth_region RegionOne
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT auth_plugin password
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT project_domain_id default
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT user_domain_id default
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT project_name service
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT username neutron
#openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT password passw0rd
#openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_ip ${HOSTNAME}
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret passw0rd
# openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT verbose True


14、配置/etc/nova/nova.conf
#openstack-config --set /etc/nova/nova.conf neutron url http://${HOSTNAME}:9696
#openstack-config --set /etc/nova/nova.conf neutron auth_url http://${HOSTNAME}:35357
#openstack-config --set /etc/nova/nova.conf neutron auth_plugin password
#openstack-config --set /etc/nova/nova.conf neutron project_domain_id default
#openstack-config --set /etc/nova/nova.conf neutron user_domain_id default
#openstack-config --set /etc/nova/nova.conf neutron region_name RegionOne
#openstack-config --set /etc/nova/nova.conf neutron project_name service
#openstack-config --set /etc/nova/nova.conf neutron username neutron
#openstack-config --set /etc/nova/nova.conf neutron password passw0rd
#openstack-config --set /etc/nova/nova.conf neutron service_metadata_proxy True
#openstack-config --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret passw0rd

15、创建软链接
# ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

16、同步数据库
# su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

17、重启nova服务，因为刚才改了nova.conf
#systemctl restart openstack-nova-api.service
#systemctl status openstack-nova-api.service

18、重启neutron服务并设置开机启动
#systemctl enable neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
#systemctl start neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
#systemctl status neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service

19、启动neutron-l3-agent.service并设置开机启动
#systemctl enable neutron-l3-agent.service
#systemctl start neutron-l3-agent.service
#systemctl status neutron-l3-agent.service

20、验证
#source /root/admin-openrc.sh
#neutron ext-list
#neutron agent-list

21、创建demo-key
#source /root/demo-openrc.sh
#nova keypair-add demo-key

22、设置安全组规则
设置这个是为了让创建的VM能被ping通以及SSH访问
#nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
#nova secgroup-add-rule default tcp 22 22 0.0.0.0/0

23、创建vxLan模式网络，让虚拟机能外出
a. 首先先执行环境变量
# source /root/admin-openrc.sh

b. 创建flat模式的public网络，注意这个public是外出网络，必须是flat模式的
# neutron --debug net-create --shared public --router:external True --provider:network_type flat --provider:physical_network public
执行完这步，在界面里进行操作，把public网络设置为共享和外部网络，创建后，结果为:

c.创建public网络子网，名为public-sub，网段就是192.168.188，并且IP范围是30-50（这个一般是给VM用的floating IP了），dns设置为8.8.8.8，网关为192.168.188.2
# neutron subnet-create public 192.168.188.0/24 --name public-sub --allocation-pool start=192.168.188.30,end=192.168.188.50 --dns-nameserver 8.8.8.8 --gateway 192.168.188.2

d.创建名为private的私有网络
# neutron net-create private --provider:network_type vxlan --router:external False --shared

e.创建名为internal-subnet的私有网络子网，网段为192.168.2.0，这个网段也是第二块网卡的网段，虚拟机之间走的网卡
# neutron subnet-create private --name internal-subnet --gateway 192.168.2.1 192.168.2.0/24

f.创建路由，我们在界面上操作
点击项目-->网络-->路由-->新建路由
路由名称随便命名，我这里写"router", 管理员状态，选择"上"(up)，外部网络选择"public"
点击"新建路由"后，提示创建router创建成功
接着点击"接口"-->"增加接口"
添加一个连接私网的接口，这里图中显示是10.0.0.0/24的，大家如果是按照此文档添加私网的话，应该显示是192.168.2.0/24
点击"增加接口"成功后，我们可以看到两个接口先是down的状态，过一会儿刷新下就是running状态（注意，一定得是运行running状态，不然到时候虚拟机网络会出不去）

24、检查网络服务
# neutron agent-list
看服务是否是笑脸

八、安装Dashboard

1、安装dashboard服务
# yum install openstack-dashboard httpd mod_wsgi memcached python-memcached -y

2、修改配置文件/etc/openstack-dashboard/local_settings
# vim /etc/openstack-dashboard/local_settings

2.1配置dashboard运行在controller上（controller为OS主机名） OPENSTACK_HOST = "controller"

2.2配置允许登陆dashboard的主机

ALLOWED_HOSTS = ['*', ]

2.3配置存储服务，添加下面内容：

CACHES = { 'default': {
'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
'LOCATION': '127.0.0.1:11211',
}
}
注意：注释掉其他的caches

2.4 配置默认用dashboard创建的用户默认角色
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

3、启动dashboard服务并设置开机启动
systemctl enable httpd.service memcached.service
systemctl restart httpd.service memcached.service systemctl status httpd.service memcached.service

到此，Openstack ALLINONE环境搭建完毕，打开firefox浏览器即可访问openstack界面！
大家搭建这个环境的时候，注意给虚拟机的内存最好是4G以上（现在大家的笔记本怎么也有8G吧？）