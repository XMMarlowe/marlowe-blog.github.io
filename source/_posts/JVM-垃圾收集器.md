---
title: JVM 垃圾收集器
author: Marlowe
date: 2021-04-10 22:39:51
tags: 
  - JVM
  - GC
categories: Java
---

<!--more-->

### 七种垃圾收集器:

1. Serial（串行GC）-复制
2. ParNew（并行GC）-复制
3. Parallel Scavenge（并行回收GC）-复制
4. Serial Old（MSC）（串行GC）-标记-整理
5. CMS（并发GC）-标记-清除
6. Parallel Old（并行GC）--标记-整理
7. G1（JDK1.7update14才可以正式商用）

**说明：**
1. 1~3用于年轻代垃圾回收：年轻代的垃圾回收称为minor GC
2. 4~6用于年老代垃圾回收（当然也可以用于方法区的回收）：年老代的垃圾回收称为full GC
3. G1独立完成"分代垃圾回收"

注意：并行与并发

1. 并行：多条垃圾回收线程同时操作
2. 并发：垃圾回收线程与用户线程一起操作



### 参考
[JVM几种垃圾回收器介绍](https://www.cnblogs.com/blythe/p/7488061.html)
