---
title: Docker常用命令
author: Marlowe
tags: Docker
categories: Docker
abbrlink: 7569
date: 2020-11-11 16:16:31
---
### 帮助命令
```shell
docker version      # 显示docker的版本信息
docker info         # 显示docker的系统信息，包括镜像和容器的数量
docker 命令 --help  # 帮助命令
```
帮助文档地址：https://docs.docker.com/reference/
### 镜像命令
**docker images** 查看所有本地的主机上的镜像
```shell
[root@hecs-x-large-2-linux-20200425095544 home]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
mysql               8.0                 db2b37ec6181        2 weeks ago         545MB
mysql               latest              db2b37ec6181        2 weeks ago         545MB
hello-world         latest              bf756fb1ae65        10 months ago       13.3kB

# 可选项
    -a，--all      # 列出所有的镜像
    -q，--quiet    # 只显示镜像的id
```
**docker search** 搜索镜像
```shell
[root@hecs-x-large-2-linux-20200425095544 home]# docker search mysql
NAME                              DESCRIPTION                                     STARS               OFFICIAL          
mysql                             MySQL is a widely used, open-source relation…   10148               [OK] 

# 可选项，通过收藏来过滤
--filter=STARS=3000   # 搜索出来的镜像就是STARS大于3000的
[root@hecs-x-large-2-linux-20200425095544 home]# docker search mysql --filter=stars=3000
NAME                DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
mysql               MySQL is a widely used, open-source relation…   10148               [OK]                
mariadb             MariaDB is a community-developed fork of MyS…   3737                [OK]   
```
**docker pull** 下载镜像
```shell
# 下载镜像 docker pull 镜像名[:tag]
[root@hecs-x-large-2-linux-20200425095544 ~]# docker pull mysql:8.0
8.0: Pulling from library/mysql # 如果不写tag，默认就是latest
bb79b6b2107f: Pull complete 
49e22f6fb9f7: Pull complete 
842b1255668c: Pull complete 
9f48d1f43000: Pull complete 
c693f0615bce: Pull complete 
8a621b9dbed2: Pull complete 
0807d32aef13: Pull complete 
a56aca0feb17: Pull complete 
de9d45fd0f07: Pull complete 
1d68a49161cc: Pull complete 
d16d318b774e: Pull complete 
49e112c55976: Pull complete 
Digest: sha256:8c17271df53ee3b843d6e16d46cff13f22c9c04d6982eb15a9a47bd5c9ac7e2d # 签名
Status: Downloaded newer image for mysql:8.0
docker.io/library/mysql:8.0 # 真实地址

# 等价于它
docker pull mysql
docker pull docker.io/library/mysql:8.0 
```
**docker rmi** 删除镜像
```shell
[root@hecs-x-large-2-linux-20200425095544 ~]# docker rmi -f 镜像id  # 删除指定的镜像
[root@hecs-x-large-2-linux-20200425095544 ~]# docker rmi -f 镜像id 镜像id # 删除多个镜像
[root@hecs-x-large-2-linux-20200425095544 ~]# docker rmi -f $(docker images -aq) # 删除全部的镜像
```
### 容器命令
**说明：我们有了镜像才可以创建容器，linux，下载一个centos镜像来测试学习**
```shell
docker pull centos
```
**新建容器并启动**
```shell
docker run[可选参数] image

# 参数说明
--name="Name"     容器名字  tomcat01   tomcat02  用来区分容器
-d                后台方式运行
-it               使用交互方式运行，进入容器查看内容
-p                指定容器的端口  -p  8080:8080
   -p ip:主机端口：容器端口
   -p 主机端口：容器端口（常用）
   -p 容器端口
   容器端口
-P                随机指定端口

# 测试，启动并进入容器
[root@hecs-x-large-2-linux-20200425095544 ~]# docker run -it centos /bin/bash
[root@9b4676b718b5 /]# ls  # 查看容器内的centos，基础版本，很多命令都是不完善的！
bin  etc   lib	  lost+found  mnt  proc  run   srv  tmp  var
dev  home  lib64  media       opt  root  sbin  sys  usr

# 从容器中退回主机
[root@9b4676b718b5 /]# exit
exit
[root@hecs-x-large-2-linux-20200425095544 ~]# ls
install.sh
```

**列出所有运行的容器**
```shell
# docker ps 命令
      # 列出当前正在运行的容器
-a    # 列出当前正在运行的容器 + 带出历史运行过的容器
-n=? # 显示最近创建的容器
-q    # 只显示容器的编号

[root@hecs-x-large-2-linux-20200425095544 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
[root@hecs-x-large-2-linux-20200425095544 ~]# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
9b4676b718b5        centos              "/bin/bash"         26 minutes ago      Exited (0) 16 minutes ago                       festive_feistel
c8c1137aaa4e        bf756fb1ae65        "/hello"            5 hours ago         Exited (0) 5 hours ago                          confident_cannon
```
**退出容器**
```shell
exit  # 容器停止并退出
Ctrl + P + Q # 容器不停止退出

[root@hecs-x-large-2-linux-20200425095544 ~]# docker run -it centos /bin/bash
[root@9d6ac1f17089 /]# [root@hecs-x-large-2-linux-20200425095544 ~]#
```

**删除容器**
```shell
docker rm 容器id                    # 删除指定的容器，不能删除正在运行的容器，如果要强制删除 rm -f 
docker rm -f $(docker ps -aq)      # 删除所有的容器
docker ps -a -q|xargs docker rm    # 删除所有的容器，使用管道
```

**启动和容器的操作**
```shell
docker start 容器id     # 启动容器
docker restart 容器id   # 重启容器
docker stop 容器id      # 停止当前正在运行的容器
docker kill 容器id      # 强制停止当前容器
```

### 常用其他命令
 **后台启动容器**
 ```shell
 # 命令 docker run -d 镜像名：
 [root@hecs-x-large-2-linux-20200425095544 ~]# docker run -d centos

 # 问题docker ps，发现 centos停止了

 # 常见的坑！！ docker容器使用后台运行，就唏嘘有一个前台进程，docker发现没有应用，就自动停止
 # nginx，容器启动后，发现自己没有提供服务，就会立刻停止，就是没有程序了
 ```
 **查看日志**
 ```shell
 docker logs -f -t --tail 容器id ,没有日志

 # 自己编写一段shell脚本
 [root@hecs-x-large-2-linux-20200425095544 ~]# docker run -d centos /bin/bash -c "while true;do echo kuangshen; sleep 1;done"

[root@hecs-x-large-2-linux-20200425095544 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
aadc743a101c        centos              "/bin/bash -c 'while…"   4 seconds ago       Up 3 seconds                            tender_moser

 # 显示日志
 -tf                         # 显示日志
 -tail number                # 要显示日志条数
 [root@hecs-x-large-2-linux-20200425095544 ~]# docker logs -tf --tail 10 284eaba4616b
 ```

 **查看容器中进程信息 ps**
```shell
# 命令 docker top 容器id 
[root@hecs-x-large-2-linux-20200425095544 ~]# docker top 284eaba4616b
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                15211               15194               0                   18:31               ?                   00:00:00            /bin/bash -c while true;do echo kuangshen; sleep 1;done
root                15918               15211               0                   18:37               ?                   00:00:00            /usr/bin/coreutils --coreutils-prog-shebang=sleep /usr/bin/sleep 1
```

**查看镜像的元数据**
```shell
# 命令
docker inspect 容器id
# 测试
[root@hecs-x-large-2-linux-20200425095544 ~]# docker inspect 284eaba4616b
[
    {
        "Id": "284eaba4616b4e748dc87a6aedf14d3b7bb508ef28d77cf215f01677a9149ae6",
        "Created": "2020-11-12T10:31:46.264703694Z",
        "Path": "/bin/bash",
        "Args": [
            "-c",
            "while true;do echo kuangshen; sleep 1;done"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 15211,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2020-11-12T10:31:46.559658378Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:0d120b6ccaa8c5e149176798b3501d4dd1885f961922497cd0abef155c869566",
        "ResolvConfPath": "/var/lib/docker/containers/284eaba4616b4e748dc87a6aedf14d3b7bb508ef28d77cf215f01677a9149ae6/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/284eaba4616b4e748dc87a6aedf14d3b7bb508ef28d77cf215f01677a9149ae6/hostname",
        "HostsPath": "/var/lib/docker/containers/284eaba4616b4e748dc87a6aedf14d3b7bb508ef28d77cf215f01677a9149ae6/hosts",
        "LogPath": "/var/lib/docker/containers/284eaba4616b4e748dc87a6aedf14d3b7bb508ef28d77cf215f01677a9149ae6/284eaba4616b4e748dc87a6aedf14d3b7bb508ef28d77cf215f01677a9149ae6-json.log",
        "Name": "/dazzling_roentgen",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "Capabilities": null,
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": [],
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "KernelMemory": 0,
            "KernelMemoryTCP": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": false,
            "PidsLimit": null,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": [
                "/proc/asound",
                "/proc/acpi",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/proc/sched_debug",
                "/proc/scsi",
                "/sys/firmware"
            ],
            "ReadonlyPaths": [
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        },
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/9f2dc5029ecc2e3355d547bc678a613bc9fcaf84e23692e9ae8d36b010c2392a-init/diff:/var/lib/docker/overlay2/ab2394ffb62a3a589a4794ed317cdec52ff1b73d6c0025a32b56cfa266fe4d97/diff",
                "MergedDir": "/var/lib/docker/overlay2/9f2dc5029ecc2e3355d547bc678a613bc9fcaf84e23692e9ae8d36b010c2392a/merged",
                "UpperDir": "/var/lib/docker/overlay2/9f2dc5029ecc2e3355d547bc678a613bc9fcaf84e23692e9ae8d36b010c2392a/diff",
                "WorkDir": "/var/lib/docker/overlay2/9f2dc5029ecc2e3355d547bc678a613bc9fcaf84e23692e9ae8d36b010c2392a/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [],
        "Config": {
            "Hostname": "284eaba4616b",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
            ],
            "Cmd": [
                "/bin/bash",
                "-c",
                "while true;do echo kuangshen; sleep 1;done"
            ],
            "Image": "centos",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {
                "org.label-schema.build-date": "20200809",
                "org.label-schema.license": "GPLv2",
                "org.label-schema.name": "CentOS Base Image",
                "org.label-schema.schema-version": "1.0",
                "org.label-schema.vendor": "CentOS"
            }
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "da70a9e57940a409d3f4827907ee892aa3a9a20aa2575fbeffd380cedfc6b03a",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {},
            "SandboxKey": "/var/run/docker/netns/da70a9e57940",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "9e9c2139cd06d068313f00e7e7ec3bf9411a3344792d962fffecd4324d1ff87a",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "7a8c920abbd19ce06b9315879005e6d73adea85afc13f16ca1bd88c49bf5694b",
                    "EndpointID": "9e9c2139cd06d068313f00e7e7ec3bf9411a3344792d962fffecd4324d1ff87a",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02",
                    "DriverOpts": null
                }
            }
        }
    }
]
```
**进入当前正在运行的容器**
```shell
# 我们通常容器都是使用后台方式运行的，需要进入容器，修改一些配置

# 命令 
docker exec -it 容器id bashShell

# 测试
[root@hecs-x-large-2-linux-20200425095544 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
e60fd257e7cf        mysql:8.0           "docker-entrypoint.s…"   6 hours ago         Up 6 hours          33060/tcp, 0.0.0.0:3307->3306/tcp   mysql
[root@hecs-x-large-2-linux-20200425095544 ~]# docker exec -it e60fd257e7cf /bin/bash
root@e60fd257e7cf:/# ls
bin   docker-entrypoint-initdb.d  home	 media	proc  sbin  tmp
boot  entrypoint.sh		  lib	 mnt	root  srv   usr
dev   etc			  lib64  opt	run   sys   var
root@e60fd257e7cf:/# ps -ef

# 方式2 
docker attach 容器id


# docker exec          # 进入容器后开启一个新的终端，可以在里面操作（常用）
# docker attach        # 进入容器正在执行的终端，不会启动新的进程
```
**从容器内拷贝文件到主机上**
```shell
docker cp 容器id：容器内路径 目的的主机路径

# 查看当前主机目录下
[root@hecs-x-large-2-linux-20200425095544 home]# ls
chn  hello.java  hh  leo  Marlowe  www
[root@hecs-x-large-2-linux-20200425095544 home]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                               NAMES
37b64bd24047        centos              "/bin/bash"              About a minute ago   Up About a minute                                       funny_williams
e60fd257e7cf        mysql:8.0           "docker-entrypoint.s…"   7 hours ago          Up 7 hours          33060/tcp, 0.0.0.0:3307->3306/tcp   mysql

# 进入docker容器内部
[root@hecs-x-large-2-linux-20200425095544 home]# docker attach 37b64bd24047
[root@37b64bd24047 /]# cd /home
[root@37b64bd24047 home]# ls

# 在容器内新建一个文件
[root@37b64bd24047 home]# touch test.java
[root@37b64bd24047 home]# ls
test.java
[root@37b64bd24047 home]# exit
exit
[root@hecs-x-large-2-linux-20200425095544 home]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
e60fd257e7cf        mysql:8.0           "docker-entrypoint.s…"   7 hours ago         Up 7 hours          33060/tcp, 0.0.0.0:3307->3306/tcp   mysql

# 将这文件拷贝出来到主机上
[root@hecs-x-large-2-linux-20200425095544 home]# docker cp 37b64bd24047:/home/test.java /home 
[root@hecs-x-large-2-linux-20200425095544 home]# ls
chn  hello.java  hh  leo  Marlowe  test.java  www

# 拷贝是一个手动过程，未来我们使用 -v 卷的技术，可以实现，自动同步 /home  /home
```

>Docker 安装nginx
```shell
# 1.搜索镜像 search 建议大家去docker搜素，可以看帮助文档
# 2.下载镜像 pull
# 3.运行测试
[root@hecs-x-large-2-linux-20200425095544 home]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               latest              c39a868aad02        7 days ago          133MB
mysql               8.0                 db2b37ec6181        2 weeks ago         545MB
mysql               latest              db2b37ec6181        2 weeks ago         545MB
centos              latest              0d120b6ccaa8        3 months ago        215MB


# -d后台运行
# --name 给容器命名
# -p 宿主机端口，容器内部端口
[root@hecs-x-large-2-linux-20200425095544 home]# docker run -d --name nginx01 -p 3344:80 nginx
100d4c411f6d16c5ff4e630f521f59448d065cb2b201bd0b3a1ea6840045e955
[root@hecs-x-large-2-linux-20200425095544 home]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
100d4c411f6d        nginx               "/docker-entrypoint.…"   8 seconds ago       Up 7 seconds        0.0.0.0:3344->80/tcp                nginx01
e60fd257e7cf        mysql:8.0           "docker-entrypoint.s…"   7 hours ago         Up 7 hours          33060/tcp, 0.0.0.0:3307->3306/tcp   mysql
[root@hecs-x-large-2-linux-20200425095544 home]# curl localhost:3344 
```

### 作业练习
>Docker 安装 Nginx
```shell
# 1.搜索镜像 search 建议去docker搜索，可以看到帮助文档
# 2.下载镜像 pull
# 3.运行测试
[root@hecs-x-large-2-linux-20200425095544 ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               latest              c39a868aad02        9 days ago          133MB
mysql               8.0                 db2b37ec6181        3 weeks ago         545MB
mysql               latest              db2b37ec6181        3 weeks ago         545MB
centos              latest              0d120b6ccaa8        3 months ago        215MB

# -d 后台运行
# --name 容器命名
# -p 宿主机端口：容器内端口
[root@hecs-x-large-2-linux-20200425095544 ~]# docker run -d --name nginx01 -p 3344:80 nginx


[root@hecs-x-large-2-linux-20200425095544 ~]# curl localhost:3344
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>


# 进入容器
[root@hecs-x-large-2-linux-20200425095544 ~]# docker exec -it nginx01 /bin/bash
root@100d4c411f6d:/# whereis nginx
nginx: /usr/sbin/nginx /usr/lib/nginx /etc/nginx /usr/share/nginx
```

思考问题：我们每次改动nginx配置文件，都需要进入容器内部？十分麻烦，我要是可以在容器外部提供一个映射路径，达到在容器修改文件名，容器内部就可以自动修改？ -v 数据卷！

>作业2：docker装tomcat
```shell
# 官方安装
docker run -it --rm tomcat:9.0

# 我们之前的启动都是后台，停止了容器之后，容器还是可以查到， docker run -it --rm  一般用来测试，用完就删除

# 下载再启用
docker pull tomcat
# 启动运行
docker run -d -p 3355:8080 --name tomcat01 tomcat


# 测试访问没有问题

# 进入容器
[root@hecs-x-large-2-linux-20200425095544 ~]# docker exec -it tomcat01 /bin/bash

# 发现问题：1.linux命令少了，2.没有webapps，阿里云镜像的原因，默认是最小的镜像，左右不必要的都删除掉。
# 保证最小可运行的环境！
```

思考问题：我们以后要部署项目，如果每次都要进入容器是不是十分麻烦？我要是可以在容器外提供一个映射路径，webapps，我们在外部放置项目，就自动同步到内部就好了！

>作业：部署es+kibana
```shell
# es 暴露的端口很多
# es 十分的耗内存
# es的数据一般需要放置到安全目录！ 挂载
# --net somenetwork ？ 网络配置

# 下载启动
docker run -d --name elasticsearch  -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.6.2

# 启动后非常卡 linux卡住了，docker status 查看cpu状态

# es十分耗内存；

# 查看 docker stats

# 测试es是否成功了
[root@hecs-x-large-2-linux-20200425095544 ~]# curl localhost:9200
{
  "name" : "6e4e7e14f10d",
  "cluster_name" : "docker-cluster",
  "cluster_uuid" : "C4GbFU9pQ7m0WT6ko_pkJA",
  "version" : {
    "number" : "7.6.2",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "ef48eb35cf30adf4db14086e8aabd07ef6fb113f",
    "build_date" : "2020-03-26T06:34:37.794943Z",
    "build_snapshot" : false,
    "lucene_version" : "8.4.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```
```shell
# 增加内存限制，修改配置文件 -e 环境配置修改
docker run -d --name elasticsearch02  -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms64m -Xmx512m" elasticsearch:7.6.2
```
作业：使用kibana连接es？思考网络如何才能连接过去！

### 可视化
* portainer(先用这个)
```shell
docker run -d -p 8088:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```
* Rancher(CI/CD再用)

**什么是portainer？**
Docker图形化界面管理工具！提供一个后台面板供我们操作！
```shell
docker run -d -p 8088:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```
 