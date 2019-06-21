#!/bin/sh
yum install -y wget
cd /usr/local/src
wget http://nginx.org/download/nginx-1.14.2.tar.gz
groupadd nginx
useradd -r -g nginx nginx -s /sbin/nologin
yum install -y gcc gcc-c++ automake pcre pcre-devel zlip zlib-devel openssl openssl-devel
if [ -d nginx-1.14.2 ]; then 
echo "nginx folder is exists"
else
tar -xzvf  nginx-1.14.2.tar.gz
fi
cd nginx-1.14.2 && ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-pcre --with-http_stub_status_module --with-http_realip_module --with-http_gzip_static_module --with-stream --with-http_ssl_module && make && make install
cat > /usr/local/nginx/conf/nginx.conf <<EOF
user  nginx;
worker_processes  auto;
worker_rlimit_nofile 655350;

error_log  logs/error.log  notice;

pid        logs/nginx.pid;


events {
    use epoll;
    worker_connections  655350;
    multi_accept on;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"upstream_response_time" "$upstream_response_time"'
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  off;

    server_names_hash_bucket_size 256;
    client_header_buffer_size 256k;
    large_client_header_buffers 8 16k;
    client_max_body_size 100M;
    client_body_buffer_size 128k;

    sendfile        on;
    tcp_nopush     on;

    keepalive_timeout  300;
    keepalive_requests 8192;
    server_tokens       off;
    underscores_in_headers on;
    ignore_invalid_headers off;
    proxy_intercept_errors on;
    #proxy_http_version 1.1;
    #proxy_set_header Connection "";
    fastcgi_intercept_errors on;

    tcp_nodelay on;
    gzip  on;
    gzip_buffers 16 8k;
    gzip_comp_level 6;
    gzip_http_version 1.1;
    gzip_min_length 256;
    gzip_proxied any;
    gzip_vary on;
    gzip_types
        text/xml application/xml application/atom+xml application/rss+xml application/xhtml+xml image/svg+xml
        text/javascript application/javascript application/x-javascript
        text/x-json application/json application/x-web-app-manifest+json
        text/css text/plain text/x-component
        font/opentype application/x-font-ttf application/vnd.ms-fontobject
        image/x-icon;
    gzip_disable  "msie6";

    server {
        listen       80 default;
        return 500;
        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
           root   /usr/local/nginx/html;
        }

    }
    map $http_upgrade $connection_upgrade {
    default upgrade;
      ''      close;
    }
    include /usr/local/nginx/conf/vhost/*.conf;

}
EOF
mkdir /usr/local/nginx/conf/vhosts
cat > /usr/lib/systemd/system/nginx.service <<EOF
Description=nginx
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload && systemctl start nginx && systemctl enable nginx
