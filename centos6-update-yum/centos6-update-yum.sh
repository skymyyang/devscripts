#!/bin/bash

BACKUP_DIR=/etc/yum.repos.d/backup

[ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR} || echo "yum BACKUP_DIR is existing!"

mv /etc/yum.repos.d/*.repo ${BACKUP_DIR}

cat <<EOF > /etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-\$releasever
failovermethod=priority
baseurl=https://vault.centos.org/6.10/os/x86_64/
gpgcheck=1
gpgkey=https://vault.centos.org/6.10/os/x86_64/RPM-GPG-KEY-CentOS-6


[updates]
name=CentOS-\$releasever
enabled=1
failovermethod=priority
baseurl=https://vault.centos.org/6.10/updates/\$basearch/
gpgcheck=1
gpgkey=https://vault.centos.org/6.10/os/x86_64/RPM-GPG-KEY-CentOS-6


[extras]
name=CentOS-\$releasever
enabled=1
failovermethod=priority
baseurl=https://vault.centos.org/6.10/extras/\$basearch/
gpgcheck=1
gpgkey=https://vault.centos.org/6.10/os/x86_64/RPM-GPG-KEY-CentOS-6
EOF

cat <<EOF > /etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
baseurl=https://archives.fedoraproject.org/pub/archive/epel/6/\$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 6 - \$basearch - Debug
baseurl=https://archives.fedoraproject.org/pub/archive/epel/6/\$basearch/debug
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux 6 - \$basearch - Source
baseurl=https://archives.fedoraproject.org/pub/archive/epel/6/SRPMS
failovermethod=priority
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
gpgcheck=1
EOF

yum clean all
yum makecache

