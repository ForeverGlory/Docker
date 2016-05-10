Docker Build
======

SSH + Nginx1.9 + PHP7 + Mysql
===

1、使用阿里云镜像

2、安装编译环境

3、安装SSH

4、安装Mysql

5、编译Nginx

6、编译PHP

7、安装Composer

8、开放端口

------
build
---
docker build -t foreverglory/docker .

run
---
docker run -d -p 2202:22 -p 80:80 foreverglory/docker

docker run -d -p 2202:22 -p 80:80 -v $pwd:/var/www foreverglory/docker
