---
title: MySQL redo log、binlog、undo log 区别与作用
author: Marlowe
tags:
  - redo log
  - binlog
  - undo log
categories: 数据库
abbrlink: 58289
date: 2021-04-29 22:06:33
---
日志系统主要有redo log(重做日志)和binlog(归档日志)。redo log是InnoDB存储引擎层的日志，binlog是MySQL Server层记录的日志， 两者都是记录了某些操作的日志(不是所有)自然有些重复（但两者记录的格式不同）。
<!--more-->


### MySQL逻辑架构

![20210429220801](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210429220801.png)


### 重做日志（redo log）
#### 作用

确保事务的持久性。防止在发生故障的时间点，尚有脏页未写入磁盘，在重启mysql服务的时候，根据redo log进行重做，从而达到事务的持久性这一特性。

#### 内容

物理格式的日志，记录的是物理数据页面的修改的信息，其redo log是顺序写入redo log file的物理文件中去的。

#### 什么时候产生

事务开始之后就产生redo log，redo log的落盘并不是随着事务的提交才写入的，而是在事务的执行过程中，便开始写入redo log文件中。

#### 什么时候释放

当对应事务的脏页写入到磁盘之后，redo log的使命也就完成了，重做日志占用的空间就可以重用（被覆盖）。

#### 对应的物理文件

默认情况下，对应的物理文件位于数据库的data目录下的ib_logfile1&ib_logfile2

* innodb_log_group_home_dir 指定日志文件组所在的路径，默认./ ，表示在数据库的数据目录下。

* innodb_log_files_in_group 指定重做日志文件组中文件的数量，默认2

#### 关于文件的大小和数量，由以下两个参数配置

* innodb_log_file_size 重做日志文件的大小。

* innodb_mirrored_log_groups 指定了日志镜像文件组的数量，默认1

#### 其他

很重要一点，redo log是什么时候写盘的？前面说了是在事务开始之后逐步写盘的。

之所以说重做日志是在事务开始之后逐步写入重做日志文件，而不一定是事务提交才写入重做日志缓存，原因就是，重做日志有一个缓存区Innodb_log_buffer，Innodb_log_buffer的默认大小为8M(这里设置的16M),Innodb存储引擎先将重做日志写入innodb_log_buffer中。

![20210429221216](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210429221216.png)

**然后会通过以下三种方式将innodb日志缓冲区的日志刷新到磁盘**

1. Master Thread 每秒一次执行刷新Innodb_log_buffer到重做日志文件。
2. 每个事务提交时会将重做日志刷新到重做日志文件。
3. 当重做日志缓存可用空间 少于一半时，重做日志缓存被刷新到重做日志文件

由此可以看出，**重做日志**通过**不止一种方式写入到磁盘**，尤其是对于第一种方式，Innodb_log_buffer到重做日志文件是Master Thread线程的定时任务。

因此重做日志的写盘，并不一定是随着事务的提交才写入重做日志文件的，而是随着事务的开始，逐步开始的。

另外引用《MySQL技术内幕 Innodb 存储引擎》（page37）上的原话：

**即使某个事务还没有提交，Innodb存储引擎仍然每秒会将重做日志缓存刷新到重做日志文件。**

**这一点是必须要知道的，因为这可以很好地解释再大的事务的提交（commit）的时间也是很短暂的。**

--- 

### 回滚日志（undo log）
#### 作用

保存了事务发生之前的数据的一个版本，可以用于回滚，同时可以提供多版本并发控制下的读（MVCC），也即非锁定读。

#### 内容

逻辑格式的日志，在执行undo的时候，仅仅是将数据从逻辑上恢复至事务之前的状态，而不是从物理页面上操作实现的，这一点是不同于redo log的。

#### 什么时候产生

事务开始之前，将当前是的版本生成undo log，undo 也会产生 redo 来保证undo log的可靠性

#### 什么时候释放

当事务提交之后，undo log并不能立马被删除，而是放入待清理的链表，由purge线程判断是否由其他事务在使用undo段中表的上一个事务之前的版本信息，决定是否可以清理undo log的日志空间。

#### 对应的物理文件

MySQL5.6之前，undo表空间位于共享表空间的回滚段中，共享表空间的默认的名称是ibdata，位于数据文件目录中。

MySQL5.6之后，undo表空间可以配置成独立的文件，但是提前需要在配置文件中配置，完成数据库初始化后生效且不可改变undo log文件的个数
如果初始化数据库之前没有进行相关配置，那么就无法配置成独立的表空间了。

#### 关于MySQL5.7之后的独立undo 表空间配置参数如下

* innodb_undo_directory = /data/undospace/ –undo独立表空间的存放目录
* innodb_undo_logs = 128 –回滚段为128KB
* innodb_undo_tablespaces = 4 –指定有4个undo log文件


如果undo使用的共享表空间，这个共享表空间中又不仅仅是存储了undo的信息，共享表空间的默认为与MySQL的数据目录下面，其属性由参数innodb_data_file_path配置。

![20210429221504](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210429221504.png)

#### 其他

undo是在事务开始之前保存的被修改数据的一个版本，产生undo日志的时候，同样会伴随类似于保护事务持久化机制的redolog的产生。

默认情况下undo文件是保持在共享表空间的，也即ibdatafile文件中，当数据库中发生一些大的事务性操作的时候，要生成大量的undo信息，全部保存在共享表空间中的。

因此共享表空间可能会变的很大，默认情况下，也就是undo 日志使用共享表空间的时候，被“撑大”的共享表空间是不会也不能自动收缩的。

因此，mysql5.7之后的“独立undo 表空间”的配置就显得很有必要了。

--- 

### 二进制日志（binlog）

#### 作用

用于复制，在主从复制中，从库利用主库上的binlog进行重播，实现主从同步。
用于数据库的基于时间点的还原。

#### 内容

逻辑格式的日志，可以简单认为就是执行过的事务中的sql语句。

但又不完全是sql语句这么简单，而是包括了执行的sql语句（增删改）反向的信息，也就意味着delete对应着delete本身和其反向的insert；update对应着update执行前后的版本的信息；insert对应着delete和insert本身的信息。

在使用mysqlbinlog解析binlog之后一些都会真相大白。

因此可以基于binlog做到类似于oracle的闪回功能，其实都是依赖于binlog中的日志记录。

#### 什么时候产生

事务提交的时候，一次性将事务中的sql语句（一个事物可能对应多个sql语句）按照一定的格式记录到binlog中。

这里与redo log很明显的差异就是redo log并不一定是在事务提交的时候刷新到磁盘，redo log是在事务开始之后就开始逐步写入磁盘。

因此对于事务的提交，即便是较大的事务，提交（commit）都是很快的，但是在开启了bin_log的情况下，对于较大事务的提交，可能会变得比较慢一些。

这是因为binlog是在事务提交的时候一次性写入的造成的，这些可以通过测试验证。

#### 什么时候释放

binlog的默认是保持时间由参数expire_logs_days配置，也就是说对于非活动的日志文件，在生成时间超过expire_logs_days配置的天数之后，会被自动删除。

![20210429221546](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210429221546.png)

#### 对应的物理文件

配置文件的路径为log_bin_basename，binlog日志文件按照指定大小，当日志文件达到指定的最大的大小之后，进行滚动更新，生成新的日志文件。

对于每个binlog日志文件，通过一个统一的index文件来组织。
![20210429221606](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210429221606.png)

#### 其他

二进制日志的作用之一是还原数据库的，这与redo log很类似，很多人混淆过，但是两者有本质的不同。

**作用不同：** redo log是保证事务的持久性的，是事务层面的，binlog作为还原的功能，是数据库层面的（当然也可以精确到事务层面的），虽然都有还原的意思，但是其保护数据的层次是不一样的。

**内容不同：** redo log是物理日志，是数据页面的修改之后的物理记录，binlog是逻辑日志，可以简单认为记录的就是sql语句

另外，两者日志产生的时间，可以释放的时间，在可释放的情况下清理机制，都是完全不同的。

恢复数据时候的效率，基于物理日志的redo log恢复数据的效率要高于语句逻辑日志的binlog。

**关于事务提交时**，redo log和binlog的写入顺序，为了保证主从复制时候的主从一致（当然也包括使用binlog进行基于时间点还原的情况），是要严格一致的，MySQL通过两阶段提交过程来完成事务的一致性的，也即redo log和binlog的一致性的，理论上是先写redo log，再写binlog，两个日志都提交成功（刷入磁盘），事务才算真正的完成。

### redo log日志模块

redo log是InnoDB存储引擎层的日志，又称重做日志文件，用于记录事务操作的变化，记录的是数据修改之后的值，不管事务是否提交都会记录下来。在实例和介质失败（media failure）时，redo log文件就能派上用场，如数据库掉电，InnoDB存储引擎会使用redo log恢复到掉电前的时刻，以此来保证数据的完整性。

在一条更新语句进行执行的时候，InnoDB引擎会把更新记录写到redo log日志中，然后更新内存，此时算是语句执行完了，然后在空闲的时候或者是按照设定的更新策略将redo log中的内容更新到磁盘中，这里涉及到WAL即Write Ahead logging技术，他的关键点是先写日志，再写磁盘。

有了redo log日志，那么在数据库进行异常重启的时候，可以根据redo log日志进行恢复，也就达到了crash-safe。

redo log日志的大小是固定的，即记录满了以后就从头循环写。

![20210429220838](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210429220838.png)

该图展示了一组4个文件的redo log日志，checkpoint之前表示擦除完了的，即可以进行写的，擦除之前会更新到磁盘中，write pos是指写的位置，当write pos和checkpoint相遇的时候表明redo log已经满了，这个时候数据库停止进行数据库更新语句的执行，转而进行redo log日志同步到磁盘中。

### bin log日志模块

bin log是属于MySQL Server层面的，又称为归档日志，属于逻辑日志，是以二进制的形式记录的是这个语句的原始逻辑，依靠bin log是没有crash-safe能力的

### redo log和binlog区别

* redo log是属于innoDB层面，binlog属于MySQL Server层面的，这样在数据库用别的存储引擎时可以达到一致性的要求。
* redo log是物理日志，记录该数据页更新的内容；binlog是逻辑日志，记录的是这个更新语句的原始逻辑
* redo log是循环写，日志空间大小固定；binlog是追加写，是指一份写到一定大小的时候会更换下一个文件，不会覆盖。
* binlog可以作为恢复数据使用，主从复制搭建，redo log作为异常宕机或者介质故障后的数据恢复使用。


### 参考
[MySQL中的六种日志文件](https://blog.csdn.net/u012834750/article/details/79533866)

[MySQL日志系统：redo log、binlog、undo log 区别与作用](https://blog.csdn.net/u010002184/article/details/88526708)