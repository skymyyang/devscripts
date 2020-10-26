#!/bin/bash

echo "---开始配置时间同步---"

deploy_chronyd(){
    echo "安装chrony"
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
    /etc/init.d/chronyd restart
    /sbin/chkconfig chronyd on
    sed -ri 's/^#(UseDNS )yes/\1no/' /etc/ssh/sshd_config
}

deploy_chronyd


echo "---开始配置阿里云epel源---"

deploy_epel(){
    yum install wget unzip lrzsz -y
    yum install epel-release -y
    wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
}

deploy_epel


echo "---关闭selinux和防火墙---"

close_iptables(){
    setenforce 0
    sed -ri '/^[^#]*SELINUX=/s#=.+$#=disabled#' /etc/selinux/config
    /etc/init.d/iptables stop
    /sbin/chkconfig iptables off
}


close_iptables


echo "---优化文件最大打开数---"

sysctl_limits_deploy(){
    cat>/etc/security/limits.d/99-limits.conf<<EOF
*       soft    nproc   131072
*       hard    nproc   131072
*       soft    nofile  131072
*       hard    nofile  131072
root    soft    nproc   131072
root    hard    nproc   131072
root    soft    nofile  131072
root    hard    nofile  131072
EOF
}

sysctl_limits_deploy



sysctl_system_deploy(){
    mv /etc/sysctl.conf /etc/sysctl.conf.back
    cat <<EOF > /etc/sysctl.conf
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
}

sysctl_system_deploy