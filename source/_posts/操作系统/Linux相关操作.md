---
title: Linux相关操作
author: Marlowe
tags: Linux
categories: 操作系统
abbrlink: 57149
date: 2021-07-20 21:27:24
---

### 一、Linux 基本操作

> a. 将 系统 hostname 改为 个人名称，如：zhang.san；

`hostnamectl set-hostname Marlowe.chen` # 设置新的hostname

![20210719153432](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719153432.png)

> b. 创建用户，用户名为：个人名称，如： zhang.san，将该用户加入root组并更改账户密码；

`useradd Marlowe.chen` # 添加新用户
`passwd Marlowe.chen` # 修改账户密码
`usermod -g root Marlowe.chen` # 将用户加入root组

> c. 查看是否安装了 xfsprogs 包，如果已安装，则移除对应 xfsprogs 包；

`yum search xfsprogs` # 查找指定软件包
`yum remove xfsprogs` # 移除软件包

![20210719154802](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719154802.png)

> d. 找到 xfsprogs rpm 包文件并删除；

`rpm -qi xfsprogs` # 找到xfsprogs的rpm包


> e. 使用 yum 下载 xfsprogs rpm 包到本地然后使用 rpm 工具安装；

``

> f. 将终端的最近100条历史执行命令记录以文本文件形式保存到个人用户目录（如：/home/ zhang.san）下；

`history 100 > /home/Marlowe.chen/history.txt` # 将最近的100条历史记录输出到文件

![20210719170914](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719170914.png)


### 二、文件系统创建及挂载

> a. 查找系统上的一块空间为30GB的空闲块设备；

`df -h` # 查看文件系统空间使用

![20210719172126](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719172126.png)

`fdisk -l`

![20210719182210](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719182210.png)

> b. 将空闲块设备格式化成两个15GB大小的xfs文件系统；

![clip_image003](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/clip_image003.png)

![20210719182248](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719182248.png)

![20210719182256](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719182256.png)

![20210719182302](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719182302.png)

![clip_image010](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/clip_image010.png)

![20210719182351](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719182351.png)

![clip_image012](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/clip_image012.png)



> c. 创建/data_01和/data_02目录；

![20210719182410](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719182410.png)


> d. 将格式化好的两个xfs文件系统分别挂载到/data_01和/data_02目录；

![clip_image015](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/clip_image015.jpg)

### 三、文本文件处理

> a 从远程服务器 192.168.184.242 （root/eisoo.com123）复制 /data_01/
> File_CDP_Driver_writeData.tar.gz 文件到本地 /data_01目录下；

`scp -r root@192.168.184.242:/data_01/File_CDP_Driver_writeData.tar.gz /root/data_01`

![20210719183520](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719183520.png)

> b. 将 File_CDP_Driver_writeData.tar.gz 文件解压缩，找到里面的 File_CDP_Driver_writeData.LOG 文件；

`tar -zxvf File_CDP_Driver_writeData.tar.gz`

> c. 统计 File_CDP_Driver_writeData.LOG 文件中包含 错误码 “C0000034”的行数；

`iconv -f utf16 -t utf8 File_CDP_Driver_writeData.LOG -o File_CDP_Driver_writeData.log` # 转换文件编码

`grep -c "C0000034" File_CDP_Driver_writeData.log` # 统计包含的行数

![20210719191953](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719191953.png)

> d. 统计 File_CDP_Driver_writeData.LOG 文件中不包含 错误码 “C0000034”的行数；

`grep -cv "C0000034" File_CDP_Driver_writeData.log` # 统计不包含的行数

> e. 对 File_CDP_Driver_writeData.LOG 文件按照 10MB/个 进行切割，切割后文件按[个人邮箱名称]_自然数序号方式命名；

`split -b 10m File_CDP_Driver_writeData.LOG -d -a 2 Marlowe.chen@aishu.cn_`

![20210719192631](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719192631.png)

> f. 将切割后文件进行整体打包，以个人邮箱名称命名，复制到服务器  192.168.184.242 /data_01目录下；

`tar -cvf Marlowe.chen@aishu.cn.tar.gz Marlowe.chen@aishu.cn*` # 打包命令

`scp Marlowe.chen@aishu.cn.tar.gz 192.168.184.242:/data_01` # 复制到服务器

![20210719193717](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719193717.png)

![20210719193648](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719193648.png)

### 四、Shell 脚本编程

> a. 将 考题3 的整个处理流程写成Shell 脚本

bash:
![20210719202800](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719202800.png)

![20210719202636](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719202636.png)

### 五、Linux系统分析工具操作实践

![20210719203930](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210719203930.png)
