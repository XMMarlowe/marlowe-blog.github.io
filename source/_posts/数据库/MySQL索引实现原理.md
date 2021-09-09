---
title: MySQL索引实现原理
author: Marlowe
tags:
  - MySQL
  - InnoDB
  - MyISAM
categories: 数据库
abbrlink: 42977
date: 2021-01-13 09:13:32
---
MySQL索引的实现原理，以及什么时候会走索引...
<!--more-->

目前大部分数据库系统及文件系统都采用B-Tree(B树)或其变种B+Tree(B+树)作为索引结构。B+Tree是数据库系统实现索引的首选数据结构。在MySQL中,索引属于存储引擎级别的概念,不同存储引擎对索引的实现方式是不同的,本文主要讨论MyISAM和InnoDB两个存储引擎的索引实现方式。

在 MySQL 中,索引属于存储引擎级别的概念,不同存储引擎对索引的实现方式是不同的,本文主要讨论 MyISAM 和 InnoDB 两个存储引擎的索引实现方式。

### MyISAM 索引实现 

#### 1. 主键索引

**MyISAM 引擎使用 B+Tree 作为索引结构,叶节点的 data 域存放的是数据记录的地址。** 下图是 MyISAM 索引的原理图:

![MyISAM 索引实现 ](http://aliyunzixunbucket.oss-cn-beijing.aliyuncs.com/jpg/4ab4988a2c158a128c8ec2406d71402a.jpg?x-oss-process=image/resize,p_100/auto-orient,1/quality,q_90/format,jpg/watermark,image_eXVuY2VzaGk=,t_100,g_se,x_0,y_0)

这里设表一共有三列,假设我们以 Col1 为主键,则图 8 是一个 MyISAM 表的主索引(Primary key)示意。可以看出 MyISAM 的索引文件仅仅保存数据记录的地址。

#### 2. 辅助索引

在 MyISAM 中,主索引和辅助索引(Secondary key)在结构上没有任何区别,只是主索引要求 key 是唯一的,而辅助索引的 key 可以重复。如果我们在 Col2 上建立一个辅助索引,则此索引的结构如下图所示：

![辅助索引](http://aliyunzixunbucket.oss-cn-beijing.aliyuncs.com/jpg/8a27a81cde5d0f565d336d8b2501811b.jpg?x-oss-process=image/resize,p_100/auto-orient,1/quality,q_90/format,jpg/watermark,image_eXVuY2VzaGk=,t_100,g_se,x_0,y_0)

同样也是一颗 B+Tree,data 域保存数据记录的地址。因此,MyISAM 中索引检索的算法为首先按照 B+Tree 搜索算法搜索索引,如果指定的 Key 存在,则取出其data 域的值,然后以 data 域的值为地址,读取相应数据记录。

**MyISAM 的索引方式也叫做“非聚集索引”,** 之所以这么称呼是为了与 InnoDB的聚集索引区分。

### InnoDB 索引实现 

虽然 InnoDB 也使用 B+Tree 作为索引结构,但具体实现方式却与 MyISAM 截然不同。

#### 1. 主键索引

1.**第一个重大区别是 InnoDB 的数据文件本身就是索引文件。从上文知道,MyISAM 索引文件和数据文件是分离的,索引文件仅保存数据记录的地址。**

而在InnoDB 中,表数据文件本身就是按 B+Tree 组织的一个索引结构,这棵树的叶点data 域保存了完整的数据记录。这个索引的 key 是数据表的主键,因此 **InnoDB 表数据文件本身就是主索引。**

![主索引](http://aliyunzixunbucket.oss-cn-beijing.aliyuncs.com/jpg/a1f0dd22be4459abf8b984c832ade3c0.jpg?x-oss-process=image/resize,p_100/auto-orient,1/quality,q_90/format,jpg/watermark,image_eXVuY2VzaGk=,t_100,g_se,x_0,y_0)

上图是 InnoDB 主索引(同时也是数据文件)的示意图,可以看到叶节点包含了完整的数据记录。这种索引叫做聚集索引。因为 InnoDB 的数据文件本身要按主键聚集，**InnoDB 要求表必须有主键(MyISAM 可以没有)**,如果**没有显式指定**，则MySQL系统会自动选择一个可以唯一标识数据记录的列作为主键，如果不存在这种列，则MySQL自动为InnoDB表生成一个隐含字段作为主键，这个字段长度为**6个字节**，类型为**长整形**。


同时,**请尽量在 InnoDB 上采用自增字段做表的主键。**因为 InnoDB 数据文件本身是一棵B+Tree,非单调的主键会造成在插入新记录时数据文件为了维持 B+Tree 的特性而**频繁的分裂调整**,十分低效,而使用自增字段作为主键则是一个很好的选择。如果表使用自增主键,那么每次插入新的记录,记录就会顺序添加到当前索引节点的后续位置,当一页写满,就会自动开辟一个新的页。如下图所示:

![分裂](http://aliyunzixunbucket.oss-cn-beijing.aliyuncs.com/jpg/eb34cbdbd601d2b3a6d658cafbe2a08b.jpg?x-oss-process=image/resize,p_100/auto-orient,1/quality,q_90/format,jpg/watermark,image_eXVuY2VzaGk=,t_100,g_se,x_0,y_0)

这样就会形成一个紧凑的索引结构,近似顺序填满。由于每次插入时也不需要移动已有数据,因此效率很高,也不会增加很多开销在维护索引上。

#### 2. 辅助索引

第二个与 MyISAM 索引的不同是 InnoDB 的**辅助索引 data 域存储相应记录主键的值而不是地址。** 换句话说,**InnoDB 的所有辅助索引都引用主键作为 data 域。**

例如,下图为定义在 Col3 上的一个辅助索引:

![辅助索引](http://aliyunzixunbucket.oss-cn-beijing.aliyuncs.com/jpg/78d019a47b6498aa770934ec102521a1.jpg?x-oss-process=image/resize,p_100/auto-orient,1/quality,q_90/format,jpg/watermark,image_eXVuY2VzaGk=,t_100,g_se,x_0,y_0)

**聚集索引这种实现方式使得按主键的搜索十分高效,但是辅助索引搜索需要检索两遍索引:首先检索辅助索引获得主键,然后用主键到主索引中检索获得记录。**

> 拓展点: 这个重新根据主键id去查询行数据的行为被称为回表查询。所以知道为啥叫辅助了,辅助就是先找到大哥(主键),再根据主键去查到最终想要的数据。(不准抢人头)。

**说到这里可以再点一下题**，上面这样分的原因。方便大家记住，innodb下主键索引和非主键索引的主要区别就在于这里，主键索引直接可以拿到行数据,而**非主键索引都需要回表**,所以会增加Io次数,这就说明了为什么主键索引的速度最快。



**引申:为什么不建议使用过长的字段作为主键?**

**因为所有辅助索引都引用主索引，过长的主索引会令辅助索引变得过大。** 再例如，**用非单调的字段作为主键在InnoDB中不是个好主意，因为InnoDB数据文件本身是一颗B+Tree，非单调的主键会造成在插入新记录时数据文件为了维持B+Tree的特性而频繁的分裂调整，十分低效，** 而使用自增字段作为主键则是一个很好的选择。

### InnoDB索引和MyISAM索引的区别

* 主索引的区别，InnoDB的数据文件本身就是索引文件，而MyISAM的索引和数据是分开的。
* 辅助索引的区别，InnoDB的辅助索引data域存储相应记录主键的值而不是地址。而MyISAM的辅助索引和主索引没有多大区别。

### 联合索引及最左原则
联合索引存储数据结构图：
![联合索引](https://img-blog.csdnimg.cn/20190109134515235.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTMzMDg0OTA=,size_16,color_FFFFFF,t_70)

**最左原则：**

例如联合索引有三个索引字段（A,B,C）

查询条件：

（A，，）---会使用索引

（A，B，）---会使用索引

（A，B，C）---会使用索引

（C，B，A    ）---会使用索引

（，B，C）---不会使用索引

（，，C）---不会使用索引

**什么时候会走索引？**
一句话，当查询的数据是有序的时候，比如对一个对象数组进行排序后，他会默认从第一个字段到最后一个字段按照顺序排序，如果在上述例子中查询（，B，C），那么B这个属性不一定是有序的，B有序的前提是A有序的情况下，因此不会走索引。

**注意：**

**但是你说我a、b换下位置可不可以**,比如select * from table where a=xx and b=xx或者select * from table where b=xx and a=xx,这样是可以的,mysql没这么傻这样就认不出来了,**查询优化器会帮你把位置调整过来的**.

### mysql假设一行数据大小为1k，则一颗层高为3的b+树可以存放多少条数据？

mysql页默认大小16k，如果数据行大小1k，叶子节点存放的完整数据，则叶子节点一页可以放16条数据；非叶子节点页面存放的是主键和指针，所以主要看主键是啥类型，假设是integer，则长度8字节，指针大小在innodb是6字节，一共14字节，所以非叶子节点每页可以存16384/14=1170个主键数据（1170个分叉），则三层b+树数据可以存1170*1170*16=21902400条数据。（千万级别）

### 参考

[MySQL索引实现原理分析](https://blog.csdn.net/u013308490/article/details/83001060)

[MyISAM与InnoDB两类存储引擎的索引实现](https://blog.csdn.net/fuzhongmin05/article/details/94396340)
