---
title: 锁机制与 InnoDB 锁算法
author: Marlowe
tags:
  - 锁
  - InnoDB
categories: 数据库
abbrlink: 28295
date: 2021-01-11 10:19:50
---

Next-Key Locks 是 MySQL 的 InnoDB 存储引擎的一种锁实现。

MVCC 不能解决幻影读问题，Next-Key Locks 就是为了解决这个问题而存在的。在可重复读（REPEATABLE READ）隔离级别下，使用 MVCC + Next-Key Locks 可以解决幻读问题。而Next-Key就是行锁+Gap锁的组合。
<!--more-->

### MyISAM 和 InnoDB 存储引擎使用的锁

* MyISAM 采用表级锁(table-level locking)。
* InnoDB 支持行级锁(row-level locking)和表级锁,默认为行级锁


### 表级锁和行级锁对比

* **表级锁：** MySQL 中锁定 粒度最大 的一种锁，对当前操作的整张表加锁，实现简单，资源消耗也比较少，加锁快，不会出现死锁。其锁定粒度最大，触发锁冲突的概率最高，并发度最低，MyISAM 和 InnoDB 引擎都支持表级锁。
* **行级锁：** MySQL 中锁定 粒度最小 的一种锁，只针对当前操作的行进行加锁。 行级锁能大大减少数据库操作的冲突。其加锁粒度最小，并发度高，但加锁的开销也最大，加锁慢，会出现死锁。


### InnoBD的三种行级锁

#### 1. Record lock：单个行记录上的锁

锁定一个记录上的索引，而不是记录本身。如果表没有设置索引，InnoDB 会自动在主键上创建隐藏的聚簇索引，因此 Record Locks依然可以使用。

#### 2. Gap lock：间隙锁，锁定一个范围，不包括记录本身

间隙锁，锁定一个范围，但不包括记录本身。GAP锁的目的，是为了防止同一事务的两次当前读，出现幻读的情况。

#### 3. Next-key lock：record+gap 锁定一个范围，包含记录本身

1、2组合，锁定一个范围，并且锁定记录本身。对于行的查询，都是采用该方法，主要目的是解决幻读的问题。

### Gap Lock

Gap Lock，又称为间隙锁。存在的主要目的就是为了防止在**可重复读**的事务级别下，出现幻读问题。

在可重复读的事务级别下面，普通的select读的是快照，不存在幻读情况，但是如果加上for update的话，读取是已提交事务数据，gap锁保证for update情况下，不出现幻读。

以下都是在可重读隔离级别情况下。

test表如下：

|id|value|
|:---:|:---:|
|a|1|
|d|3|
|g|6|
|j|8|

其中id是主键，value是非唯一索引

```sql
# T1
select * from test where num=6 for update;
# T2
insert into test (id, value) VALUES ('a', 3);
```
T1这样的操作会锁定（3,6]，(6,8]，但是会发现插入操作依旧可以成功，因为虽然Value的区间是锁住了，但是根据id=‘a’这一条让排序在a前面去了

![20210509110702](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210509110702.png)

总的来说，锁的间隙是根据B+树排序后的叶子节点之间的区间，不但要看非索引，也会看主键。

* 假如是非索引列，那么将会全表间隙加上gap锁。
* 条件是唯一索引等值检索且记录不存在的情况，我们要考虑，gap lock是防止幻读，那么尝试思考，使用唯一索引所谓条件查找数据for update，如果对应的记录不存在的话，是无法使用行锁的。这时候，会使用gap lock来锁住区间，保证记录不会插入，防止出现幻读。
总结

### 总结

Next-Locks就是结合行锁和间隙锁进行的，主要是用于MVCC出现幻读的情况。

### 参考

[MySQL之Gap Locks与Next-key Locks](https://blog.unclezs.com/%E6%95%B0%E6%8D%AE%E5%BA%93/mysql/MySQL%E4%B9%8BGap-Locks%E4%B8%8ENext-key-Locks.html)

[锁机制与 InnoDB 锁算法](https://snailclimb.gitee.io/javaguide/#/docs/database/MySQL?id=%e9%94%81%e6%9c%ba%e5%88%b6%e4%b8%8e-innodb-%e9%94%81%e7%ae%97%e6%b3%95)