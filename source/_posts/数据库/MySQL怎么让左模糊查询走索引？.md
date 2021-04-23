---
title: MySQL怎么让左模糊查询走索引？
author: Marlowe
tags: MySQL
categories: 数据库
abbrlink: 32175
date: 2021-01-16 21:37:00
---
<!--more-->

需要做模糊匹配，又要用到索引，索引的最左匹配原则更是不能被打破，这时候可以增加一个字段，这个字段的内容等于USER_NAME字段内容的反转，同时加上这个字段的相关索引，如下：
![20210416213840](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416213840.png)

![20210416213901](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416213901.png)

此时如果是要模糊搜索出用户名后几位有杰这个词的所有用户信息，可以对REVERSE_USER_NAME字段做右模糊查询，效果其实就是和对USER_NAME字段做左模糊查询是一样的，因为二者的内容是相反的，结果如下：

```sql
SELECT * from USER_INFO where REVERSE_USER_NAME like '杰%'
```


**总结**
索引的最左匹配原则不能打破，那么要让左匹配也走索引的话，换个思路，让右匹配的效果和左匹配一样就好了，同时右匹配又能走索引，间接达到了左模糊查询也能走索引的目的。