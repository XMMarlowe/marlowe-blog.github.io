---
title: Redis跳跃表
author: Marlowe
tags: Redis
categories: NoSQL
abbrlink: 12505
date: 2021-04-16 20:39:08
---
Redis跳跃表相关问题...
<!--more-->

### 什么是跳跃表
跳跃表是一种有序的数据结构，它通过在每个节点中维持多个指向其他的几点指针，从而达到快速访问队尾目的。跳跃表的效率可以和平衡树想媲美了，最关键是它的实现相对于平衡树来说，代码的实现上简单很多。

### 跳跃表用在哪里

说真的，跳跃表在 Redis 中使用不是特别广泛，只用在了两个地方：
一、是实现有序集合键。
二、是集群节点中用作内部数据结构。
### 跳跃表原理
我们先来看一下一张完整的跳跃表的图。
![跳跃表](https://img-blog.csdnimg.cn/20190608163948471.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MTYyMjE4Mw==,size_16,color_FFFFFF,t_70)

### 跳跃表的 level 是如何定义的？
跳跃表 level 层级完全是随机的。一般来说，层级越多，访问节点的速度越快。


### 跳跃表的插入
首先我们需要插入几个数据。链表开始时是空的。
![20210416205626](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205626.png)
**插入 level = 3，key = 1**
当我们插入 level = 3，key = 1 时，结果如下：
![20210416205639](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205639.png)
**插入 level = 1，key = 2**
当继续插入 level = 1，key = 2 时，结果如下
![20210416205649](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205649.png)
**插入 level = 2，key = 3**
当继续插入 level = 2，key = 3 时，结果如下
![20210416205658](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205658.png)
**插入 level = 3，key = 5**
当继续插入 level = 3，key = 5 时，结果如下
![20210416205705](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205705.png)
**插入 level = 1，key = 66**
当继续插入 level = 1，key = 66 时，结果如下
![20210416205713](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205713.png)
**插入 level = 2，key = 100**
当继续插入 level = 2，key = 100 时，结果如下
![20210416205725](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205725.png)
上述便是跳跃表插入原理，关键点就是层级–使用抛硬币的方式，感觉还真是挺随机的。每个层级最末端节点指向都是为 null，表示该层级到达末尾，可以往下一级跳。


### 跳跃表的查询
现在我们要找键为 **66** 的节点的值。那跳跃表是如何进行查询的呢？

跳跃表的查询是从顶层往下找，那么会先从第顶层开始找，方式就是循环比较，如过顶层节点的下一个节点为空说明到达末尾，会跳到第二层，继续遍历，直到找到对应节点。

如下图所示红色框内，我们带着键 66 和 1 比较，发现 66 大于 1。继续找顶层的下一个节点，发现 66 也是大于五的，继续遍历。由于下一节点为空，则会跳到 level 2。
![20210416205837](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205837.png)

上层没有找到 66，这时跳到 level 2 进行遍历，但是这里有一个点需要注意，遍历链表不是又重新遍历。而是从 5 这个节点继续往下找下一个节点。如下，我们遍历了 level 3 后，记录下当前处在 5 这个节点，那接下来遍历是 5 往后走，发现 100 大于目标 66，所以还是继续下沉。

![20210416205855](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205855.png)

当到 level 1 时，发现 5 的下一个节点恰恰好是 66 ，就将结果直接返回。
![20210416205912](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205912.png)

### 跳跃表删除
跳跃表的删除和查找类似，都是一级一级找到相对应的节点，然后将 next 对象指向下下个节点，完全和链表类似。

现在我们来删除 66 这个节点，查找 66 节点和上述类似。
![20210416205947](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205947.png)

接下来是断掉 5 节点 next 的 66 节点，然后将它指向 100 节点。
![20210416205955](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210416205955.png)
如上就是跳跃表的删除操作了，和我们平时接触的链表是一致的。当然，跳跃表的修改，也是和删除查找类似，只不过是将值修改罢了，就不继续介绍了。

### 参考
[面试准备 -- Redis 跳跃表](https://blog.csdn.net/weixin_41622183/article/details/91126155)

