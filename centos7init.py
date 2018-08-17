# coding: utf-8

import sys
import os


def InitSys():
    if os.getuid() == 0:
        pass
    else:
        print("Please use 'root' to excute this script...")
        sys.exit(1)
    dnsconf = "nameserver 172.16.18.245" + "\n" + "nameserver 172.16.18.246"
    with open("/etc/reslov.conf", "a") as f:
        f.write(dnsconf)
    res = os.system(
        "yum -y install ntp make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget crontabs libjpeg libjpeg-devel libpng libpng-devel libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libzip-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils ca-certificates net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel xz expat-devel libaio-devel rpcgen libtirpc-devel perl lrzsz telnet vim")
    if res != 0:
        print("The dependency package install is failed, pelease check your network!")
        sys.exit(1)
    else:
        os.system("/usr/sbin/ntpdate ntp.mofangge.cc")
        print("时间同步成功！")
        os.system("echo '* 4 * * * /usr/sbin/ntpdate ntp.mofangge.cc > /dev/null 2>&1' >> /var/spool/cron/root")
        os.system("systemctl restart crond.service")
        print("时间同步加入到计划任务成功")
        os.system("timedatectl set-timezone Asia/Shanghai")
        print("时区设置为上海！")

    os.system('echo "ulimit -SHn 102400" >> /etc/rc.local')
    limitsconf = "* soft nproc 655350 \n" + "* hard nproc 655350 \n" + "* soft nofile 655350 \n" + "* hard nofile 655350 \n"
    with open("/etc/security/limits.conf", "a") as f:
        f.write(limitsconf)
    print("ulimit 设置成功!")
    os.system("sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config")
    os.system("setenforce 0")
    print("关闭Selinux成功！")

    os.system("systemctl disable firewalld.service && systemctl stop firewalld.service ")
    print("关闭Firewalld 成功!")

    res2 = os.system("""
    cat >> /etc/sysctl.conf << EOF
vm.overcommit_memory = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_abort_on_overflow = 0
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
#net.core.netdev_max_backlog = 262144
#net.core.somaxconn = 262144
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
EOF""")
    if res2 != 0:
        print("sysctl 优化失败！ 请手动执行！")
    else:
        os.system("/sbin/sysctl -p")
        print("sysctl 优化完成！")


class InstallMySQL():
    def __init__(self):
        self.installDir = "/app/local/mysql"
        self.dataDir = "/app/data/mysql"
        self.softDir = "/usr/local/src"
        self.softGzName = "mysql-boost-5.7.23.tar.gz"
        self.softDirName = "mysql-5.7.23"

    def Install(self):
        os.system(
            "yum install -y gcc gcc-c++ ncurses ncurses-devel cmake ncurses-devel openssl-devel bison-devel libaio libaio-devel")
        if os.path.exists(self.installDir):
            pass
        else:
            os.system("mkdir -p " + self.installDir + "/logs")
            os.system("touch " + self.installDir + "/logs/mysqld-safe.log")

        if os.path.exists(self.dataDir):
            pass
        else:
            os.system("mkdir -p " + self.dataDir)
        if os.path.exists(self.softDir + "/" + self.softGzName):
            os.system("tar -zxvf " + self.softDir + "/" + self.softGzName + " -C " + self.softDir)
            # os.system("cd "+ self.softDirName)
            res = os.system("mv " + self.softDir + "/" + self.softDirName + "/boost/boost_1_59_0 /usr/local/")
            if res != 0:
                print("拷贝boost失败，请确认boost名称，然后手动拷贝")
                sys.exit(1)
            else:
                os.chdir(self.softDir + "/" + self.softDirName)
                print(os.getcwd())
                res = os.system("""
cd /usr/local/src/mysql-5.7.23 && cmake \
-DCMAKE_INSTALL_PREFIX=/app/local/mysql \
-DMYSQL_DATADIR=/app/data/mysql  \
-DSYSCONFDIR=/app/local/mysql \
-DMYSQL_USER=mysql \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DENABLE_DOWNLOADS=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_unicode_ci \
-DWITH_DEBUG=0 \
-DMYSQL_MAINTAINER_MODE=0 \
-DDOWNLOAD_BOOST=1 \
-DWITH_BOOST=/usr/local/boost_1_59_0 \
-DWITH_SSL:STRING=bundled \
-DWITH_ZLIB:STRING=bundled
                """)
                if res != 0:
                    print("cmake 失败，请手动执行...")
                else:
                    os.system("make -j `grep processor /proc/cpuinfo | wc -l` && make install ")
                    os.system("groupadd -r mysql && useradd -r -g mysql -s /bin/false -M mysql")
                    os.system("chown -Rf mysql:mysql " + self.installDir + "&& chown -Rf mysql:mysql " + self.dataDir)
            return 1


        else:
            print("请将安装包拷贝到/usr/local/src/ 下！")
            return 0

    def Config(self):
        os.system(
            "cp " + self.softDir + "/" + self.softDirName + "/support-files/mysql.server /etc/init.d/mysql && chmod +x /etc/init.d/mysql && systemctl enable mysql")
        with open("/etc/profile", "a") as f:
            f.write("\nexport PATH=/app/local/mysql/bin:/app/local/mysql/lib:$PATH\n")
        os.system("source /etc/profile")
        os.system()
        mycnf = """
[client]
port = 3306
socket = /tmp/mysql.sock
[mysqld]

character-set-server = utf8mb4    
collation-server = utf8mb4_unicode_ci

skip-external-locking
skip-name-resolve
user = mysql
port = 3306
basedir = /app/local/mysql
datadir = /app/data/mysql

socket = /tmp/mysql.sock
log-error = /app/local/mysql/logs/mysql-error.log
pid-file = /app/local/mysql/mysql.pid

open_files_limit = 10240

back_log = 600
max_connections = 1000
max_connect_errors = 6000
wait_timeout = 28800

#open_tables = 600
#table_cache = 650
#opened_tables = 630

max_allowed_packet = 32M

sort_buffer_size = 4M
join_buffer_size = 4M
thread_cache_size = 300
query_cache_type = 1
query_cache_size = 256M
query_cache_limit = 2M
query_cache_min_res_unit = 16k

tmp_table_size = 256M
max_heap_table_size = 256M

key_buffer_size = 256M
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M

lower_case_table_names=1

default-storage-engine = INNODB

innodb_buffer_pool_size = 1G
innodb_log_buffer_size = 32M
innodb_log_file_size = 128M
innodb_flush_method = O_DIRECT

long_query_time= 2
slow-query-log = on
slow-query-log-file = /app/local/mysql/logs/mysql-slow.log

[mysqldump]
quick
max_allowed_packet = 32M

[mysqld_safe]
log-error=/app/local/mysql/logs/mysqld-safe.log

        """
        with open(self.installDir + "/my.cnf", "a") as f:
            f.write(mycnf)
        res = os.system(
            self.installDir + "/bin/mysqld --defaults-file=" + self.installDir + "/my.cnf" + " --initialize-insecure --user=mysql --basedir=" + self.installDir + " --datadir=" + self.dataDir)
        if res != 0:
            print("MySQL初始化失败！")
        else:
            print("MySQL安装成功！")


if __name__ == "__main__":
    mysql = InstallMySQL()
    res = mysql.Install()
    if res == 0:
        print("安装失败！！ 别配置了！！")
    if res == 1:
        mysql.Config()








