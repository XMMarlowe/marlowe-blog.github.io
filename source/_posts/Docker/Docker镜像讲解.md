---
title: Docker镜像讲解
author: Marlowe
tags: Docker
categories: Docker
abbrlink: 23488
date: 2020-11-16 19:46:45
---
如何提交一个自己的镜像
### commit镜像
```shell
docker commit 提交容器成为一个新的副本

# 命令和git原理类似
docker commit -m="提交的描述信息" -a="作者" 容器id 目标镜像名：[TAG] 
```
实战测试
```shell
# 1、启动一个默认的tomcat
[root@hecs-x-large-2-linux-20200425095544 ~]# docker run -it -p 8080:8080 tomcat

# 2、发现这个默认的tomcat是没有webapps应用，镜像的原因，官方的镜像默认webapps下面是没有文件的！

# 3、我自己拷贝进去了基本的文件
root@186285ef065e:/usr/local/tomcat# cp -r webapps.dist/* webapps

# 4、将我们操作过的容器通过commit提交为一个镜像！我们以后就使用我们修改过的镜像即可，这就是我们自己的一个修改的镜像
[root@hecs-x-large-2-linux-20200425095544 ~]# docker commit -a="marlowe" -m="add web app" 186285ef065e tomcat02:1.0

```
```shell
如果你想要保存当前容器的状态，就可以通过commit来提交，获得一个镜像，就好比以前学习VM的时候，快照！
```
到这里才算是入门Docker！
