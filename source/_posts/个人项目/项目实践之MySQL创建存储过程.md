---
title: 项目实践之MySQL创建存储过程
author: Marlowe
tags:
  - MySQL
  - 存储过程
categories: 个人项目
abbrlink: 48370
date: 2021-06-03 14:59:42
---


<!--more-->

### 问题来源

**歌曲表：**

![20210603150509](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210603150509.png)

**歌手表：**

![20210603150611](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210603150611.png)


起初，我将歌手表和歌曲表分离，并没有在歌曲表中存储歌手的名字，需要利用歌曲表中的`singer_id`在歌曲表中进行连接查询才能获得歌手的姓名。

但是，后面发现连接查询的效率过低，因此选择将歌手的名字`singer_name` 冗余在歌曲表中，提升查询效率。

### 解决方案

#### 方案一

1. 修改歌曲表，添加`singer_name`字段
2. 清空数据库，修改实体类，修改爬虫，直接将歌手名插入到数据库中

**实现方式：**
```java
// 将数据封装，插入数据库
Song song = new Song()
        .setSongId(songId)
        .setSingerId(singerId)
        .setLyric(lyric)
        .setUrl(songRealUrl)
        .setName(title)
        // 设置歌手姓名
        .setSingerName(singerName)
        .setIsDownload(0);
// 将歌曲信息插入数据库
int insert1 = songMapper.insert(song);
```

#### 方案二(推荐)

1. 修改歌曲表，添加`singer_name`字段
2. 在数据库层，通过歌曲表的`singer_id`在歌手表中查询歌手的姓名
3. 将歌手姓名插入到歌曲表的`singer_name`字段中

**实现方式：**

```sql
-- 创建存储过程	
create PROCEDURE test()

BEGIN
	-- 定义变量 
	DECLARE index_id int DEFAULT 1 ;	
	DECLARE singerName VARCHAR(255);
	DECLARE singerID VARCHAR(255);
    -- 遍历歌手表
	while index_id < 1499 do
        -- 提取出歌手id和歌手姓名存储在变量中
		SELECT name,singer_id into singerName,singerID from singer where id = index_id;
        -- 根据歌手id更新歌曲表的歌手姓名
		update song set singer_name = singerName where singer_id=singerID;
		-- 下标自增
        set index_id = index_id + 1;
	end while;
END

-- 调用存储过程
CALL test()
```

结果：
singer表：1498
song表：63304
![20210603152826](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210603152826.png)

数据量大，执行速度有点缓慢

### 总结

在系统开发前，尽量设计好数据库，不然改数据库结构有时候对开发很不友好。