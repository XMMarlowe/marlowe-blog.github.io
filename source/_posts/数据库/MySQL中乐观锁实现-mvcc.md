---
title: MySQL中乐观锁实现(mvcc)
author: Marlowe
tags:
  - MySQL
  - mvcc
categories: 数据库
abbrlink: 4476
date: 2021-04-10 10:49:23
---
MVCC即Multi-Version Concurrency Control，中文翻译过来叫多版本并发控制。
<!--more-->

### MVCC是解决了什么问题

众所周知，在MYSQL中，MyISAM使用的是表锁，InnoDB使用的是行锁。而InnoDB的事务分为四个隔离级别，其中默认的隔离级别REPEATABLE READ需要两个不同的事务相互之间不能影响，而且还能支持并发，这点悲观锁是达不到的，所以REPEATABLE READ采用的就是乐观锁，而乐观锁的实现采用的就是MVCC。正是因为有了MVCC，才造就了InnoDB强大的事务处理能力。
