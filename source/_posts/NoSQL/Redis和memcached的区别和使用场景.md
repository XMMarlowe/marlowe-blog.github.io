---
title: Redis和memcached的区别和使用场景
author: Marlowe
tags:
  - Redis
  - memcached
categories: NoSQL
abbrlink: 16150
date: 2021-05-08 14:58:20
---

<!--more-->

### 共同点

1. 都是基于内存的数据库，一般都用来当做缓存使用。
2. 都有过期策略。
3. 两者的性能都非常高。

### 区别

1. Redis和Memcache都是将数据存放在内存中，**都是内存数据库**。不过memcache还可用于**缓存其他东西，例如图片、视频**等等；

2. Redis不仅仅支持简单的**k/v类型的数据，同时还提供list，set，hash等数据结构**的存储；

3. **虚拟内存**–Redis当物理内存用完时，可以将一些很久没用到的value 交换到磁盘；

4. **过期策略**–memcache**在set时就指定**，例如set key1 0 0 8,即永不过期。Redis可以通过例如**expire 设定**，例如expire name 10；

5. 分布式–设定memcache集群，利用magent做一主多从;redis可以做一主多从。都可以一主一从；

6. **存储数据安全**–memcache挂掉后，数据没了；redis可以定期保存到磁盘（**持久化**）；

7. **灾难恢复**–memcache挂掉后，**数据不可恢复**; redis数据丢失后可以**通过aof恢复**；

8. Redis支持**数据的备份**，即**master-slave模式**的数据备份；

9. **应用场景不一样**：Redis出来作为NoSQL数据库使用外，还能用做消息队列、数据堆栈和数据缓存等；Memcached适合于缓存SQL语句、数据集、用户临时性数据、延迟查询数据和session等。



### 使用场景

1. 如果有**持久方面的需求**或对**数据类型和处理有要求**的应该选择**redis**。
2. 如果 **简单的key/value 存储** 应该选择**memcached**。


### 参考

[redis和memcached的区别和使用场景](https://blog.csdn.net/u010398838/article/details/79995636)

[说一下 Redis 和 Memcached 的区别和共同点](https://snailclimb.gitee.io/javaguide/#/docs/database/Redis/redis-all?id=_3-%e8%af%b4%e4%b8%80%e4%b8%8b-redis-%e5%92%8c-memcached-%e7%9a%84%e5%8c%ba%e5%88%ab%e5%92%8c%e5%85%b1%e5%90%8c%e7%82%b9)