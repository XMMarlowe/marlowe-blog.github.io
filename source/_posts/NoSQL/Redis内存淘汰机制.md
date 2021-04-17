---
title: Redis内存淘汰机制
author: Marlowe
date: 2021-04-16 20:20:38
tags: Redis
categories: NoSQL
---

<!--more-->

**Redis 提供 6 种数据淘汰策略：**

1. **volatile-lru（least recently used）：** 从已设置过期时间的数据集（server.db[i].expires）中挑选最近最少使用的数据淘汰
2. **volatile-ttl：** 从已设置过期时间的数据集（server.db[i].expires）中挑选将要过期的数据淘汰
3. **volatile-random：** 从已设置过期时间的数据集（server.db[i].expires）中任意选择数据淘汰
4. **allkeys-lru（least recently used）：** 当内存不足以容纳新写入数据时，在键空间中，移除最近最少使用的 key（这个是最常用的）
5. **allkeys-random：** 从数据集（server.db[i].dict）中任意选择数据淘汰
6. **no-eviction：** 禁止驱逐数据，也就是说当内存不足以容纳新写入数据时，新写入操作会报错。这个应该没人使用吧！


**4.0 版本后增加以下两种：**

7. **volatile-lfu（least frequently used）：** 从已设置过期时间的数据集(server.db[i].expires)中挑选最不经常使用的数据淘汰
8. **allkeys-lfu（least frequently used）：** 当内存不足以容纳新写入数据时，在键空间中，移除最不经常使用的 key