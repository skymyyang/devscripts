#!/bin/bash

#----配置时间统一性----
echo "配置时间"
yum install chrony -y
mv /etc/chrony.conf /etc/chrony.conf.bak
cat>/etc/chrony.conf<<EOF
server ntp.aliyun.com iburst
stratumweight 0
driftfile /var/lib/chrony/drift
rtcsync
makestep 10 3
bindcmdaddress 127.0.0.1
bindcmdaddress ::1
keyfile /etc/chrony.keys
commandkey 1
generatecommandkey
logchange 0.5
logdir /var/log/chrony
EOF
/usr/bin/systemctl enable chronyd
/usr/bin/systemctl restart chronyd

#---关闭交换分区---
echo "关闭交换分区"
swapoff -a && sysctl -w vm.swappiness=0
sed -ri '/^[^#]*swap/s@^@#@' /etc/fstab

#---关闭防火墙以及selinux---
echo "关闭防火墙以及selinux"
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -ri '/^[^#]*SELINUX=/s#=.+$#=disabled#' /etc/selinux/config

#---关闭NetworkManager---
echo "关闭NetworkManager"
systemctl disable NetworkManager
systemctl stop NetworkManager

#---安装epel源，并且替换为阿里云的epel源---
yum install epel-release wget -y
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

#---安装依赖组件---
echo "安装依赖组件"
yum install -y \
    curl \
    git \
    conntrack-tools \
    psmisc \
    nfs-utils \
    jq \
    socat \
    bash-completion \
    ipset \
    ipvsadm \
    conntrack \
    libseccomp \
    net-tools \
    crontabs \
    sysstat \
    unzip \
    iftop \
    nload \
    strace \
    bind-utils \
    tcpdump \
    telnet \
    lsof \
    htop
#---ipvs模式需要开机加载下列模块---
echo "ipvs模式需要开机加载下列模块"
cat>/etc/modules-load.d/ipvs.conf<<EOF
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
br_netfilter
EOF
systemctl daemon-reload
systemctl enable --now systemd-modules-load.service

#---设定系统参数---
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.ip_forward = 1
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
# 要求iptables不对bridge的数据进行处理
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.netfilter.nf_conntrack_max = 2310720
fs.inotify.max_user_watches=89100
fs.may_detach_mounts = 1
fs.file-max = 52706963
fs.nr_open = 52706963
vm.overcommit_memory=1
vm.panic_on_oom=0
# https://github.com/moby/moby/issues/31208 
# ipvsadm -l --timout
# 修复ipvs模式下长连接timeout问题 小于900即可
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 10
EOF
sysctl --system

#---优化设置 journal 日志相关---
sed -ri 's/^\$ModLoad imjournal/#&/' /etc/rsyslog.conf
sed -ri 's/^\$IMJournalStateFile/#&/' /etc/rsyslog.conf
sed -ri 's/^#(DefaultLimitCORE)=/\1=100000/' /etc/systemd/system.conf
sed -ri 's/^#(DefaultLimitNOFILE)=/\1=100000/' /etc/systemd/system.conf
sed -ri 's/^#(UseDNS )yes/\1no/' /etc/ssh/sshd_config

#---优化文件最大打开数---
cat>/etc/security/limits.d/kubernetes.conf<<EOF
*       soft    nproc   131072
*       hard    nproc   131072
*       soft    nofile  131072
*       hard    nofile  131072
root    soft    nproc   131072
root    hard    nproc   131072
root    soft    nofile  131072
root    hard    nofile  131072
EOF

#---设置user_namespace.enable=1---
grubby --args="user_namespace.enable=1" --update-kernel="$(grubby --default-kernel)"
