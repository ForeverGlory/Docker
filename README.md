Docker Build
======

SSH + Nginx1.9 + PHP7 + Mysql
===

1��ʹ�ð����ƾ���

2����װ���뻷��

3����װSSH

4����װMysql

5������Nginx

6������PHP

7����װComposer

8�����Ŷ˿�

------
build
---
docker build -t foreverglory/docker .

run
---
docker run -d -p 2202:22 -p 80:80 foreverglory/docker

docker run -d -p 2202:22 -p 80:80 -v $pwd:/var/www foreverglory/docker
