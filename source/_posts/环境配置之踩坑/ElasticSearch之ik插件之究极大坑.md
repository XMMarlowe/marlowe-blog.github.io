---
title: ElasticSearch之ik插件之究极大坑
author: Marlowe
tags:
  - 踩坑
  - ES
categories: 环境配置之踩坑
abbrlink: 5170
date: 2020-12-08 01:10:24
---
由于最近要做搜索引擎课设，可以用ElasticSearch做，因此，开启了ES的学习之路，也开启了ES踩坑之路，入门一小时，配环境两小时！！~
<!--more-->

在elasticsearch中安装ik中文分词器，使用的elasticsearch版本是7.10.0，elasticsearch-analysis-ik版本是7.10.0。

安装后，重新启动报错，报错信息为：

```log
[2020-11-18T17:14:56,012][WARN ][o.e.c.r.a.AllocationService] [LAPTOP-TLVIFKFC] failing shard [AccessControlException[access denied ("java.io.FilePermission" "D:\Program%20Files\elasticsearch\elasticsearch-7.10.0\plugins\ik\config\IKAnalyzer.cfg.xml" "read")]], markAsStale [true]]
java.security.AccessControlException: access denied ("java.io.FilePermission" "D:\Program%20Files\elasticsearch\elasticsearch-7.10.0\plugins\ik\config\IKAnalyzer.cfg.xml" "read")
```

原因是：elasticsearch安装路径中有空格造成的，如安装路径为D:\Program Files\elasticsearch\elasticsearch-7.10.0，其中"Program Files"两个词中间有空格

**解决方法**：elasticsearch选择没有空格的文件目录下安装


前前后后下载了很多版本的插件，以及找同学烤文件，都没能解决这个问题，在百度重新搜索`elasticsearch ik 7.10.0 下载`的时候，出现了一篇拯救我的文章，重新安装好es所需要的文件后，将整个文件移动到没有空格的文件夹，问题才得以解决！

参考：[elasticsearch-7.10.0使用elasticsearch-analysis-ik-7.10.0分词器插件后启动报错](https://blog.csdn.net/starryzhan2018/article/details/109779035)

ES学习教程:[【狂神说Java】ElasticSearch7.6.x最新完整教程通俗易懂](https://www.bilibili.com/video/BV17a4y1x7zq?p=1)


