---
title: Redis 如何配置Key的过期时间？他的实现原理是什么？
author: Marlowe
tags: Redis
categories: NoSQL
abbrlink: 9556
date: 2021-05-04 21:11:54
---

<!--more-->

### Redis设置key的过期时间

* EXPIRE
* SETEX


### 实现原理


#### 定期删除

每隔一段时间， 执行一次删除过期key的操作。

#### 懒汉式删除

当使用get、getset等指令 去获取数据时，判断key是否过期。 过期后，就先把key删除，再执行后面的操作。

**Redis是将两种方式结合来使用。**

定期删除：平衡**执行频率**和**执行时长**。

定期删除时会遍历每个datapase(默认16个),检查当前库中指定个数的key(默认是20个)。随机抽查这些key,如果有过期的，就删除。

程序中有一个全局变量记录到扫描到了哪个数据库。|