# foreverglory/docker Dockerfile
FROM ubuntu:14.04

# 签名
MAINTAINER ForeverGlory "foreverglory@qq.com"

# 使用国内阿里云镜像源
RUN mv /etc/apt/sources.list /etc/apt/sources.list.backup
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse' >> /etc/apt/sources.list
RUN echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse' >> /etc/apt/sources.list

# 更新镜像源
RUN apt-get update

# 编译环境
RUN apt-get install -y gcc g++ automake make

# 安装 SSH
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd

# 安装工具
RUN apt-get install -y git

# 安装 mysql
RUN apt-get install -y mysql-client-5.5 mysql-server-5.5

# 编译 nginx
RUN apt-get install -y libpcre3-dev libssl-dev openssl

WORKDIR /usr/local/src
RUN wget http://mirrors.sohu.com/nginx/nginx-1.9.9.tar.gz
RUN tar -zxf nginx-1.9.9.tar.gz

WORKDIR nginx-1.9.9
RUN ./configure --prefix=/usr/local/nginx --user=www-data --group=www-data --with-pcre --with-http_stub_status_module --with-http_gzip_static_module
RUN make && make install

# 编译 php
RUN apt-get install -y libxml2-dev libcurl4-openssl-dev libjpeg-dev libpng12-dev libfreetype6-dev libicu-dev libmcrypt-dev

WORKDIR /usr/local/src
RUN wget http://mirrors.sohu.com/php/php-7.0.5.tar.gz
RUN tar -zxf php-7.0.5.tar.gz

WORKDIR php-7.0.5
RUN ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/etc/conf.d --with-mysql-sock --with-mysqli --with-pdo-mysql --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --enable-mbstring --enable-ftp --enable-sockets --enable-intl --enable-opcache --with-zlib --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-curl --with-openssl --with-mcrypt
RUN make && make install

# 安装 composer
WORKDIR /usr/local/src
RUN wget https://getcomposer.org/composer.phar
RUN mv composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer

# 配置SSH
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN echo 'root:docker' | chpasswd

# 配置 Mysql、Nginx、PHP

ADD conf/nginx/conf/nginx.conf  /usr/local/nginx/conf/
ADD conf/nginx/conf/vhost       /usr/local/nginx/conf/vhost

ADD conf/php/etc/php.ini        /usr/local/php/etc/
ADD conf/php/etc/php-fpm.conf   /usr/local/php/etc/
ADD conf/php/etc/conf.d/*       /usr/local/php/etc/conf.d/
ADD conf/php/etc/php-fpm.d/*    /usr/local/php/etc/php-fpm.d/
RUN ln -s /usr/local/php/bin/php /usr/local/bin/php

RUN mkdir /var/www/web -p && echo '<h1>If you see me. you need run `docker run [OPTIONS] -v youdir:/var/www IMAGE`</h1>' > /var/www/web/index.html
# 开放端口
EXPOSE 22
EXPOSE 80
EXPOSE 3306

# 挂载文件夹
VOLUME /var/www
RUN chown -R www-data:www-data /var/www

WORKDIR /root
# 后台运行
CMD /etc/init.d/mysql start && /usr/local/nginx/sbin/nginx && /usr/local/php/sbin/php-fpm && /usr/sbin/sshd -D
