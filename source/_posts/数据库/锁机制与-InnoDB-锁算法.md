---
title: 锁机制与 InnoDB 锁算法
author: Marlowe
tags:
  - 锁
  - InnoDB
categories: 数据库
abbrlink: 28295
date: 2021-04-11 10:19:50
---
<!--more-->

**MyISAM 和 InnoDB 存储引擎使用的锁：**

* MyISAM 采用表级锁(table-level locking)。
* InnoDB 支持行级锁(row-level locking)和表级锁,默认为行级锁


**表级锁和行级锁对比：**

* **表级锁：** MySQL 中锁定 粒度最大 的一种锁，对当前操作的整张表加锁，实现简单，资源消耗也比较少，加锁快，不会出现死锁。其锁定粒度最大，触发锁冲突的概率最高，并发度最低，MyISAM 和 InnoDB 引擎都支持表级锁。
* **行级锁：** MySQL 中锁定 粒度最小 的一种锁，只针对当前操作的行进行加锁。 行级锁能大大减少数据库操作的冲突。其加锁粒度最小，并发度高，但加锁的开销也最大，加锁慢，会出现死锁。


**InnoDB 存储引擎的锁的算法有三种：**

* Record lock：单个行记录上的锁
* Gap lock：间隙锁，锁定一个范围，不包括记录本身
* Next-key lock：record+gap 锁定一个范围，包含记录本身