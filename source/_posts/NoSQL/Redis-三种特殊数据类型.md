---
title: Redis 三种特殊数据类型
author: Marlowe
tags:
  - Redis
  - 数据类型
categories: NoSQL
abbrlink: 28237
date: 2020-12-20 10:58:35
---
Radis 三种特殊数据类型...
<!--more-->

### geospatial
```bash
geoadd # 添加位置
geopos #获得当前定位 一定是一个坐标值
geodist # 两人之间的距离
georadius # 以给定的经纬度为中心，找出某一半径内的元素
可以加参数 withdist 显示距离，  withcoord 显示经纬度， count x 限制个数
georadiusbymember 找出指定元素周围的其他元素
geohash 返回11个字符串的geohash字符串
geo底层的实现原理就是zset！我们可以通过zset命令来操作geo
```
### Hyperloglog
```bash
Redis Hyperloglog 基数统计的算法！
优点:占用的内存固定，2^64不同的元素基数，只需要12KB内存！如果要从内存角度来比较的话Hyperloglog首选！

网页UV（一个人访问一个网站多次，但是还是算作一个人！）
传统的方式，set保存用户的id，然后就可以统计set中的元素数量作为标准判断！
这个方式如果保存大量的用户id，就会比较麻烦！ 我们的目的是为了计数，而不是保存用户id；
0.81误错率！ 统计UV任务，可以忽略不计的！

pfcount 统计元素的基数数量
pfmearge mykey3 mykey mykey2 #合并两组mykey mykey2 => mykey3 并集
如果允许容错，使用Hyperloglog；如果不允许容错，就使用set或者自己的数据类型即可
```
### Bitmap

#### 原理

8bit = 1b = 0.001kb

bitmap就是通过最小的单位bit来进行0或者1的设置，表示某个元素对应的值或者状态。
一个bit的值，或者是0，或者是1；也就是说一个bit能存储的最多信息是2。

#### 优势
1. 基于最小的单位bit进行存储，所以非常省空间。
2. 设置时候时间复杂度O(1)、读取时候时间复杂度O(n)，操作是非常快的。
3. 二进制数据的存储，进行相关计算的时候非常快。
4. 方便扩容

#### 限制

redis中bit映射被限制在512MB之内，所以最大是2^32位。建议每个key的位数都控制下，因为读取时候时间复杂度O(n)，越大的串读的时间花销越多。

#### 案例 

```bash
统计用户信息，活跃 不活跃！ 登录 未登录! 打卡 未打卡！ 两个状态的，都可以使用Bitmaps
Bitmaps 位图，数据结构！ 都是操作二进制来进行记录，就只有0和1两个状态！
365天=365bit  1字节=8比特  46比特左右！

使用bitmap来记录  周一到周日的打卡！
127.0.0.1:6379> setbit sign 0 1
(integer) 0
127.0.0.1:6379> setbit sign 1 0
(integer) 0
127.0.0.1:6379> setbit sign 2 0
(integer) 0
127.0.0.1:6379> setbit sign 3 1
(integer) 0
127.0.0.1:6379> setbit sign 4 1
(integer) 0
127.0.0.1:6379> setbit sign 5 0
(integer) 0
127.0.0.1:6379> setbit sign 6 0
(integer) 0
```
查看某一天是否打卡！
```bash
127.0.0.1:6379> getbit sign 3
(integer) 1
127.0.0.1:6379> getbit sign 6
(integer) 0
```
统计操作，统计打卡的天数！
```bash
127.0.0.1:6379> bitcount sign # 统计这周的打卡记录，可以看到是否全勤
(integer) 3
```