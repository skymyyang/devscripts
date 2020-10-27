#!/bin/sh
groupadd mysql
useradd -r -g mysql mysql
cd /usr/local
if [ -d mysql-5.7.24-linux-glibc2.12-x86_64 ]; then 
echo "mysql folder is exists"
else
tar -xzvf  mysql-5.7.24-linux-glibc2.12-x86_64.tar.gz
fi
ln -s mysql-5.7.24-linux-glibc2.12-x86_64 mysql
cd mysql
echo "export PATH=/usr/local/mysql/bin:$PATH">>/etc/profile
source /etc/profile
if [ -d /data/mysqldata3306 ]; then
echo "mysqldata3306 is exists"
else
mkdir /data/mysqldata3306 -p
fi
chown -R mysql:mysql /data/mysqldata3306
cat > /etc/my.cnf <<EOF
[mysqld]
########basic settings########
server-id = 11 
port = 3306
user = mysql
bind_address = 0.0.0.0
character_set_server=utf8mb4
skip_name_resolve = 1
max_connections = 800
max_connect_errors = 1000
datadir = /data/mysqldata3306
transaction_isolation = READ-COMMITTED
explicit_defaults_for_timestamp = 1
join_buffer_size = 134217728
tmp_table_size = 67108864
tmpdir = /tmp
max_allowed_packet = 16777216
sql_mode = "STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER"
interactive_timeout = 1800
wait_timeout = 1800
read_buffer_size = 16777216
read_rnd_buffer_size = 33554432
sort_buffer_size = 33554432
########log settings########
log_error = error.log
slow_query_log = 1
slow_query_log_file = slow.log
log_queries_not_using_indexes = 1
log_slow_admin_statements = 1
log_slow_slave_statements = 1
log_throttle_queries_not_using_indexes = 10
expire_logs_days = 90
long_query_time = 1
min_examined_row_limit = 100
########replication settings########
master_info_repository = TABLE
relay_log_info_repository = TABLE
log_bin = bin.log
sync_binlog = 1
gtid_mode = on
enforce_gtid_consistency = 1
log_slave_updates
binlog_format = row 
relay_log = relay.log
relay_log_recovery = 1
binlog_gtid_simple_recovery = 1
slave_skip_errors = ddl_exist_errors
########innodb settings########
innodb_page_size = 16384
innodb_buffer_pool_size = 6G
innodb_buffer_pool_instances = 8
innodb_buffer_pool_load_at_startup = 1
innodb_buffer_pool_dump_at_shutdown = 1
innodb_lru_scan_depth = 2000
innodb_lock_wait_timeout = 5
innodb_io_capacity = 4000
innodb_io_capacity_max = 8000
innodb_flush_method = O_DIRECT
innodb_file_format = Barracuda
innodb_file_format_max = Barracuda
innodb_log_group_home_dir = /redolog/
innodb_undo_directory = /undolog/
innodb_undo_logs = 128
innodb_undo_tablespaces = 3
innodb_flush_neighbors = 1
innodb_log_file_size = 4G
innodb_log_buffer_size = 16777216
innodb_purge_threads = 4
innodb_large_prefix = 1
innodb_thread_concurrency = 64
innodb_print_all_deadlocks = 1
innodb_strict_mode = 1
innodb_sort_buffer_size = 67108864 
########semi sync replication settings########
plugin_dir=/usr/local/mysql/lib/plugin
plugin_load = "rpl_semi_sync_master=semisync_master.so;rpl_semi_sync_slave=semisync_slave.so"
loose_rpl_semi_sync_master_enabled = 1
loose_rpl_semi_sync_slave_enabled = 1
loose_rpl_semi_sync_master_timeout = 5000

[mysqld-5.7]
innodb_buffer_pool_dump_pct = 40
innodb_page_cleaners = 4
innodb_undo_log_truncate = 1
innodb_max_undo_log_size = 2G
innodb_purge_rseg_truncate_frequency = 128
binlog_gtid_simple_recovery=1
log_timestamps=system
transaction_write_set_extraction=MURMUR32
show_compatibility_56=on
EOF
cp -rf /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
mkdir /redolog && chown mysql:mysql /redolog/
mkdir /undolog && chown mysql:mysql /undolog/
/usr/local/mysql/bin/mysqld --initialize --user=mysql
/usr/local/mysql/bin/mysql_ssl_rsa_setup
chown -R mysql:mysql /data/mysqldata3306/*.pem
/etc/init.d/mysqld start
chkconfig mysqld on
chkconfig --add mysqld

#启动完成之后密码在error.log日志中可以查看到。如下提示：
#[Note] A temporary password is generated for root@localhost: oSYrVffpB6:D
#安装完mysql 之后，登陆以后，不管运行任何命令，总是提示这个mysql error You must reset your password using ALTER USER statement before executing this statement.

#step 1: SET PASSWORD = PASSWORD('your new password');

#step 2: ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;

#step 3: flush privileges;

#完成以上三步退出再登，使用新设置的密码就行了，以上除了红色的自己修改成新密码外，其他原样输入即可
#之后可以通过/usr/local/mysql/bin/mysql_secure_installation 进行初始化
