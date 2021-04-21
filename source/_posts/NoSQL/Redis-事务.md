---
title: Redis 事务
author: Marlowe
tags:
  - Redis
  - 事务
categories: NoSQL
abbrlink: 62562
date: 2020-12-20 11:46:30
---
Redis 事务简介...
<!--more-->

Redis 事务本质：一组命令的集合！一个事务中的所有命令都会被序列化，在事务执行过程中，会按照顺序执行！
一次性，顺序性，排他性 执行一系列的命令！
```bash
-----队列  set set set 执行-----
```
**Redis事务没有隔离级别的概念**
所有的命令在事务中，并没有直接被执行！只有发起执行命令的时候才会执行！Exec
**Redis单条命令是保证原子性的，但是事务不保证原子性**
Redis的事务：
* 开启事务()
* 命令入队()
* 执行事务()

**正常执行事务**
```bash
127.0.0.1:6379> multi # 开启事务
OK
127.0.0.1:6379> set k1 v1
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> get k2
QUEUED
127.0.0.1:6379> set k3 v3
QUEUED
127.0.0.1:6379> exec # 执行事务
1) OK
2) OK
3) "v2"
4) OK
```
**放弃事务**
```bash
127.0.0.1:6379> multi # 开启事务
OK
127.0.0.1:6379> set k1 v1
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> set k4 v4
QUEUED
127.0.0.1:6379> discard # 取消事务
OK
127.0.0.1:6379> get k4 # 事务队列中的命令都不会被执行
(nil)
```

**编译型异常，事务中的所有命令都不会被执行！**
```bash
127.0.0.1:6379> multi
OK
127.0.0.1:6379> set k1 v1
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> set k3 v3
QUEUED
127.0.0.1:6379> getset k3 # 错误的命令
(error) ERR wrong number of arguments for 'getset' command
127.0.0.1:6379> set k4 v4
QUEUED
127.0.0.1:6379> set k5 v5
QUEUED
127.0.0.1:6379> exec # 执行命令的时候报错
(error) EXECABORT Transaction discarded because of previous errors.
127.0.0.1:6379> get k5 # 所有的命令都不会执行
(nil)
```

**运行时异常如果事务队列中存在与发行，那么执行命令的时候，其他命令是可以正常执行，错误命令抛出异常！**
```bash
127.0.0.1:6379> multi
OK
127.0.0.1:6379> set k1 "v1"
QUEUED
127.0.0.1:6379> incr k1
QUEUED
127.0.0.1:6379> set k2 v2
QUEUED
127.0.0.1:6379> set k3 v3
QUEUED
127.0.0.1:6379> get k3
QUEUED
127.0.0.1:6379> exec
1) OK
2) (error) ERR value is not an integer or out of range # 第一条命令报错，但是依旧正常执行成功了！
3) OK
4) OK
5) "v3"
127.0.0.1:6379> get k2
"v2"
```
> 监控 Watch

### 悲观锁
* 很悲观，认为什么时候都会出问题，无论做什么都会加锁！

### 乐观锁
* 很乐观，认为什么时候都不会出问题，所以不会上锁！更新数据的时候去判断一下，在此期间是否有人修改过这个数据
* 获取version
* 更新的时候比较version

> Redis 监视测试
正常执行成功！
```bash
127.0.0.1:6379> set money 100
OK
127.0.0.1:6379> set out 0
OK
127.0.0.1:6379> watch money # 监视money对象
OK
127.0.0.1:6379> multi # 事务正常结束，数据期间没有发生变动，这个时候就正常执行成功
OK
127.0.0.1:6379> decrby money 20
QUEUED
127.0.0.1:6379> incrby out 20
QUEUED
127.0.0.1:6379> exec
1) (integer) 80
2) (integer) 20
```
测试多线程修改值，使用watch可以当做redis的乐观锁操作

### 三特性

#### 单独的隔离操作
事务中的所有命令都会序列化、按顺序地执行。事务在执行的过程中,不会被其他客户端发送来的命令请求所打断。

#### 没有隔离级别的概念
队列中的命令没有提交之前都不会实际被执行,因为事务提交前任何指令都不会被实际执行。

#### 不保证原子性
事务中如果有一条命令执行失败 ,后的命令仍然会被执行,没有回滚。
