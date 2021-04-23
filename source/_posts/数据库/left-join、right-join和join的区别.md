---
title: left join、right join和join的区别
author: Marlowe
tags: join
categories: 数据库
abbrlink: 46265
date: 2021-01-15 17:02:11
---

简要介绍三种连接查询的区别...
<!--more-->

首先，我们先来建两张表，第一张表命名为kemu，第二张表命名为score：
![20210415170429](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210415170429.png)

### left join

顾名思义，就是“左连接”，表1左连接表2，以左为主，表示以表1为主，关联上表2的数据，查出来的结果显示左边的所有数据，然后右边显示的是和左边有交集部分的数据。如下：

```sql
select
   *
from
   kemu
left join score on kemu.id = score.id
```
结果集：
![20210415170405](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210415170405.png)


### right join

“右连接”，表1右连接表2，以右为主，表示以表2为主，关联查询表1的数据，查出表2所有数据以及表1和表2有交集的数据，如下：

```sql
select
   *
from
   kemu
right join score on kemu.id = score.id
```
结果集：
![20210415170521](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210415170521.png)

### join(inner join)

join，其实就是“inner join”，为了简写才写成join，两个是表示一个的，内连接，表示以两个表的交集为主，查出来是两个表有交集的部分，其余没有关联就不额外显示出来，这个用的情况也是挺多的，如下：

```sql
select
   *
from
   kemu
join score on kemu.id = score.id
```
结果集：
![20210415170615](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210415170615.png)


### 参考
[【mySQL】left join、right join和join的区别](https://segmentfault.com/a/1190000017369618)
