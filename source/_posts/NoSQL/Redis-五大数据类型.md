---
title: Redis 五大数据类型
author: Marlowe
tags:
  - Redis
  - 数据类型
categories: NoSQL
abbrlink: 1395
date: 2020-12-19 17:10:33
---
Redis 五大数据类型详述...
<!--more-->

### Redis-key
### String（字符串）

```bash
127.0.0.1:6379> set key1 v1
OK
127.0.0.1:6379> get key1
"v1"
127.0.0.1:6379> keys *
1) "key1"
127.0.0.1:6379> exists key1
(integer) 1
127.0.0.1:6379> append key1 "hello" # 如果当前key不存在，就相当于set key
(integer) 7
127.0.0.1:6379> get key1
"v1hello"
127.0.0.1:6379> strlen key1
(integer) 7

##########################################
# i++
127.0.0.1:6379> set views 0
OK
127.0.0.1:6379> get views
"0"
127.0.0.1:6379> incr views
(integer) 1
127.0.0.1:6379> get views
"1"
127.0.0.1:6379> decr views
(integer) 0
127.0.0.1:6379> decr views
(integer) -1
127.0.0.1:6379> get views
"-1"
127.0.0.1:6379> incr views
(integer) 0
127.0.0.1:6379> get views
"0"
127.0.0.1:6379> incrby views 10
(integer) 10
127.0.0.1:6379> decrby views 5
(integer) 5
##########################################
# 字符串范围  range
127.0.0.1:6379> set key1 "hello,kuangshen"
OK
127.0.0.1:6379> get key1
"hello,kuangshen"
127.0.0.1:6379> getrange key1 0 3
"hell"
127.0.0.1:6379> getrange key1 0 -1
"hello,kuangshen"

# 替换
127.0.0.1:6379> set key2 abcdefg
OK
127.0.0.1:6379> get key2
"abcdefg"
127.0.0.1:6379> setrange key2 1 xx
(integer) 7
127.0.0.1:6379> get key2
"axxdefg"
##########################################
# setex(set with expire) # 设置过期时间
# setnx(set if not exist) # 不存在再设置(在分布式锁中常常使用！)
127.0.0.1:6379> setex key3 30 "hello"
OK
127.0.0.1:6379> ttl key3
(integer) 26
127.0.0.1:6379> get key3
"hello"
127.0.0.1:6379> setnx mykey "redis"
(integer) 1
127.0.0.1:6379> keys *
1) "key2"
2) "key1"
3) "mykey"
4) "key3"
127.0.0.1:6379> keys *
1) "key2"
2) "key1"
3) "mykey"
127.0.0.1:6379> setnx mykey "MongoDB"
(integer) 0
127.0.0.1:6379> get mykey
"redis"

##########################################
127.0.0.1:6379> keys *
(empty list or set)
127.0.0.1:6379> mset k1 v1 k2 v2 k3 v3 # 同时设置多个值
OK
127.0.0.1:6379> keys *
1) "k3"
2) "k2"
3) "k1"
127.0.0.1:6379> get k1 k2 k3
(error) ERR wrong number of arguments for 'get' command
127.0.0.1:6379> mget k1 k2 k3 # 同时获得多个值
1) "v1"
2) "v2"
3) "v3"
127.0.0.1:6379> msetnx k1 v1 k4 v4 # msetnx是一个原子性操作，要么一起成功，要么一起失败！
(integer) 0
127.0.0.1:6379> get k4
(nil)

# 对象
set user:1{name:zhangsan,age:3} # 设置一个user：1对象，值为json字符来保存一个对象

# 这里的key是一个巧妙的设计： user:{id}:{filed}
127.0.0.1:6379> mset user:1:name zhangsan user:1:age 2
OK
127.0.0.1:6379> mget user:1
1) (nil)
127.0.0.1:6379> mget user:1:name user:1:age
1) "zhangsan"
2) "2"
##########################################
getset # 先get再set

127.0.0.1:6379> getset db redis # 如果不存在值，则返回nil
(nil)
127.0.0.1:6379> get db
"redis"
127.0.0.1:6379> getset db mongodb # 如果存在值，则获取原来的值
"redis"
127.0.0.1:6379> get db
"mongodb"
```

String类似的使用场景：value除了是字符串还可以是数字
* 计数器
* 统计多单位的数量
* 粉丝数
* 对象缓存存储！

### List
基本数据类型，列表
所有的list命令都是以l开头
```bash
##########################################
127.0.0.1:6379> keys *
(empty list or set)
127.0.0.1:6379> lpush list one # 将一个值或者多个值，插到列表的头部(左)
(integer) 1
127.0.0.1:6379> lpush list two
(integer) 2
127.0.0.1:6379> lpush list three
(integer) 3
127.0.0.1:6379> lrange list 0 -1
1) "three"
2) "two"
3) "one"
127.0.0.1:6379> rpush list rigth # 将一个值或者多个值，插到列表的尾部(右)
(integer) 4
127.0.0.1:6379> lrange list 0 -1
1) "three"
2) "two"
3) "one"
4) "rigth"
##########################################
lpop
rpop
127.0.0.1:6379> lrange list 0 -1
1) "three"
2) "two"
3) "one"
4) "rigth"
127.0.0.1:6379> lpop list # 移除列表的第一个元素
"three"
127.0.0.1:6379> lrange list 0 -1
1) "two"
2) "one"
3) "rigth"
127.0.0.1:6379> rpop list # 移除列表的最后一个元素
"rigth"
127.0.0.1:6379> lrange list 0 -1
1) "two"
2) "one"
##########################################
lindex
127.0.0.1:6379> lrange list 0 -1
1) "two"
2) "one"
127.0.0.1:6379> lindex list 0 # 通过下标获得list中的某一个值
"two"
127.0.0.1:6379> lindex list 1
"one"
##########################################
llen
127.0.0.1:6379> lpush list one
(integer) 1
127.0.0.1:6379> lpush list two
(integer) 2
127.0.0.1:6379> lpush list three
(integer) 3
127.0.0.1:6379> llen list
(integer) 3
##########################################
移除指定的值！
取关  uid
lrem
127.0.0.1:6379> lrange list 0 -1
1) "three"
2) "three"
3) "two"
4) "one"
127.0.0.1:6379> lrem list 1 one # 移除list集合中指定个数的value，精确匹配
(integer) 1
127.0.0.1:6379> lrange list 0 -1
1) "three"
2) "three"
3) "two"
127.0.0.1:6379> lrem list 1 three
(integer) 1
127.0.0.1:6379> lrange list 0 -1
1) "three"
2) "two"
127.0.0.1:6379> lpush list three
(integer) 3
127.0.0.1:6379> keys *
1) "list"
127.0.0.1:6379> lrange list 0 -1
1) "three"
2) "three"
3) "two"
127.0.0.1:6379> lrem list 2 three
(integer) 2
127.0.0.1:6379> lrange list 0 -1
1) "two"

##########################################
trim：修剪 list：截断
127.0.0.1:6379> rpush list "hello"
(integer) 1
127.0.0.1:6379> rpush list "hello1"
(integer) 2
127.0.0.1:6379> rpush list "hello2"
(integer) 3
127.0.0.1:6379> rpush list "hello3"
(integer) 4
127.0.0.1:6379> rpush list "hello4"
(integer) 5
127.0.0.1:6379> ltrim list 0 1 # 通过下标截取指定的长度，这个list已经被改变了，截断了只剩下截取的元素！
OK
127.0.0.1:6379> lrange list 0 -1
1) "hello"
2) "hello1"

##########################################
rpoplpush # 移除列表的最后一个元素，将他移动到新的列表中
127.0.0.1:6379> rpush list "hello"
(integer) 1
127.0.0.1:6379> rpush list "hello1"
(integer) 2
127.0.0.1:6379> rpush list "hello2"
(integer) 3
127.0.0.1:6379> rpush list "hello3"
(integer) 4
127.0.0.1:6379> rpoplpush list list1 # 移除列表的最后一个元素，将他移动到新的列表中
"hello3"
127.0.0.1:6379> lrange list 0 -1
1) "hello"
2) "hello1"
3) "hello2"
127.0.0.1:6379> lrange list1 0 -1
1) "hello3"

##########################################
lset # 将列表中指定下标的值替换为另外一个值，更新操作
127.0.0.1:6379> lset list 0 item
OK
127.0.0.1:6379> lrange list 0 -1
1) "item"
2) "hello1"
3) "hello2"
127.0.0.1:6379> lset list 1 item1
OK
127.0.0.1:6379> lrange list 0 -1
1) "item"
2) "item1"
3) "hello2"

##########################################
linsert # 将某个具体的value插入到列表中某个元素的前面或者后面！
127.0.0.1:6379> rpush list "hello"
(integer) 1
127.0.0.1:6379> rpush list "world"
(integer) 2
127.0.0.1:6379> linsert list before world other
(integer) 3
127.0.0.1:6379> lrange list 0 -1
1) "hello"
2) "other"
3) "world"
127.0.0.1:6379> linsert list after world other1
(integer) 4
127.0.0.1:6379> lrange list 0 -1
1) "hello"
2) "other"
3) "world"
4) "other1" 
##########################################
```

> 小结
* 实际上是一个链表，before Node after， left right都可以插入值
* 如果key不存在，创建新的链表
* 如果key存在，新增内容
* 如果移除了所有值，空链表，也代表不存在！
* 在两边插入或者改动值，效率最高！中间元素，相对来说效率会低一点~

消息排队！ 消息队列 （lpush rpop），栈（lpush lpop）

### Set(集合)
```bash
##########################################
127.0.0.1:6379> sadd myset hello
(integer) 1
127.0.0.1:6379> sadd myset kuangshen
(integer) 1
127.0.0.1:6379> sadd myset lovekuangshen
(integer) 1
127.0.0.1:6379> smembers myset
1) "lovekuangshen"
2) "hello"
3) "kuangshen"
127.0.0.1:6379> sismember myset hello
(integer) 1
127.0.0.1:6379> sismember myset world
(integer) 0
##########################################
127.0.0.1:6379> scard myset # 获取set集合中的内容元素个数
(integer) 4
##########################################
srem 
127.0.0.1:6379> scard myset
(integer) 4
127.0.0.1:6379> srem myset hello # 移除set集合中指定的元素
(integer) 1
127.0.0.1:6379> scard myset
(integer) 3
127.0.0.1:6379> smembers myset
1) "lovekuangshen2"
2) "lovekuangshen"
3) "kuangshen"
##########################################
set 无序不重复集合，抽随机！
127.0.0.1:6379> smembers myset
1) "lovekuangshen2"
2) "lovekuangshen"
3) "kuangshen"
127.0.0.1:6379> srandmember myset # 随机抽选出一个元素
"lovekuangshen2"
127.0.0.1:6379> srandmember myset # 随机抽选出一个元素
"lovekuangshen2"
127.0.0.1:6379> srandmember myset # 随机抽选出一个元素
"kuangshen"
127.0.0.1:6379> srandmember myset 2 # 随机抽选出指定个数的元素
1) "lovekuangshen"
2) "kuangshen"

##########################################
删除指定的key，随机删除key
127.0.0.1:6379> smembers myset
1) "lovekuangshen2"
2) "lovekuangshen"
3) "kuangshen"
127.0.0.1:6379> spop myset #随机删除一些set中的元素
"kuangshen"
127.0.0.1:6379> spop myset
"lovekuangshen2"
127.0.0.1:6379> smembers myset
1) "lovekuangshen"
##########################################
将一个指定的值，移动到另外一个set集合！
127.0.0.1:6379> sadd myset hello
(integer) 1
127.0.0.1:6379> sadd myset world
(integer) 1
127.0.0.1:6379> sadd myset kuangshen
(integer) 1
127.0.0.1:6379> sadd myset2 set2
(integer) 1
127.0.0.1:6379> smove myset myset2 kuangshen # 将一个指定的值，移动到另外一个set集合
(integer) 1
127.0.0.1:6379> smembers
(error) ERR wrong number of arguments for 'smembers' command
127.0.0.1:6379> smembers myset
1) "hello"
2) "world"
127.0.0.1:6379> smembers myset2
1) "set2"
2) "kuangshen"
##########################################
微博，b站，共同关注(交集)
127.0.0.1:6379> sadd key1 a
(integer) 1
127.0.0.1:6379> sadd key1 b
(integer) 1
127.0.0.1:6379> sadd key1 c
(integer) 1
127.0.0.1:6379> sadd key2 c
(integer) 1
127.0.0.1:6379> sadd key2 d
(integer) 1
127.0.0.1:6379> sadd key2 e
(integer) 1
127.0.0.1:6379> sdiff key1 key2
1) "b"
2) "a"
127.0.0.1:6379> sinter key1 key2
1) "c"
127.0.0.1:6379> sunion key1 key2
1) "c"
2) "a"
3) "b"
4) "d"
5) "e"
##########################################
```
微博，A用户将所有关注的人放在一个set集合中！ 将他的粉丝也放在一个集合中！
共同关注，共同爱好，二度好友，推荐好友！(六度分割理论)
### Hash(哈希)
Map 集合，key-map!

```bash
127.0.0.1:6379> hset myhash field1 kuangshen
(integer) 1
127.0.0.1:6379> hget myhash field1
"kuangshen"
127.0.0.1:6379> hmset myhash field1 hello field2 world
OK
127.0.0.1:6379> hmget myhash field1 field2
1) "hello"
2) "world"
127.0.0.1:6379> hgetall myhash
1) "field"
2) "kuangshen"
3) "field1"
4) "hello"
5) "field2"
6) "world"
127.0.0.1:6379> hdel myhash field1
(integer) 1
127.0.0.1:6379> hgetall myhash
1) "field"
2) "kuangshen"
3) "field2"
4) "world"

##########################################
hlen

127.0.0.1:6379> hgetall myhash
1) "field"
2) "kuangshen"
3) "field2"
4) "world"
127.0.0.1:6379> hlen myhash # 获取hash表的字段数量
(integer) 2

##########################################
127.0.0.1:6379> hexists myhash field1 # 判断hash中指定字段是否存在！
(integer) 0
127.0.0.1:6379> hexists myhash field2
(integer) 1
127.0.0.1:6379> hgetall myhash
1) "field"
2) "kuangshen"
3) "field2"
4) "world"

##########################################
# 只获取所有的field
127.0.0.1:6379> hkeys myhash
1) "field"
2) "field2"
# 只获取所有的value
127.0.0.1:6379> hvals myhash
1) "kuangshen"
2) "world"
##########################################
```
hash变更的数据 user name age，尤其是用户信息之类的，经常变动的数据！hash更适合于对象的存储，String更加适合字符串存储！
### Zset(有序集合)
```bash
zadd
zrange
zrangebyscore xxx -inf +inf withscores # 显示全部的用户并且附带成绩
zrevrange # 从大到小排序
zrem # 移除元素
zcount # 获取指定区间的成员数量
```
其余API，查官方文档
案例思路：set 排序  存储班级成绩表，工资排序表！
普通消息：1    重要消息：2  带权重进行判断！
排行榜应用实现，取TOP 10












