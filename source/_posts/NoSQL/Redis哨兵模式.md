---
title: Redis哨兵模式
author: Marlowe
abbrlink: 54932
date: 2021-04-17 15:43:36
tags: Redis
categories: NoSQL
---

主从切换技术的方法是：当主服务器宕机后，需要手动把一台从服务器切换为主服务器，这就需要人工干预，费事费力，还会造成一段时间内服务不可用。这不是一种推荐的方式，更多时候，我们优先考虑哨兵模式...
<!--more-->

### 概述

哨兵模式是一种特殊的模式，首先Redis提供了哨兵的命令，哨兵是一个独立的进程，作为进程，它会独立运行。其原理是**哨兵通过发送命令，等待Redis服务器响应，从而监控运行的多个Redis实例。**

![20210419162113](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210419162113.png)

![20210419162249](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210419162249.png)

这里的哨兵有两个作用

* 通过发送命令，让Redis服务器返回监控其运行状态，包括主服务器和从服务器。

* 当哨兵监测到master宕机，会自动将slave切换成master，然后通过**发布订阅模式**通知其他的从服务器，修改配置文件，让它们切换主机。

然而一个哨兵进程对Redis服务器进行监控，可能会出现问题，为此，我们可以使用多个哨兵进行监控。各个哨兵之间还会进行监控，这样就形成了多哨兵模式。

用文字描述一下**故障切换（failover）** 的过程。假设主服务器宕机，哨兵1先检测到这个结果，系统并不会马上进行failover过程，仅仅是哨兵1主观的认为主服务器不可用，这个现象成为**主观下线。** 当后面的哨兵也检测到主服务器不可用，并且数量达到一定值时，那么哨兵之间就会进行一次投票，投票的结果由一个哨兵发起，进行failover操作。切换成功后，就会通过发布订阅模式，让各个哨兵把自己监控的从服务器实现切换主机，这个过程称为**客观下线。** 这样对于客户端而言，一切都是透明的。


### 工作原理

#### 三个定时任务

一、每10秒每个 sentinel 对master 和 slave 执行**info 命令** :该命令第一个是用来发现slave节点,第二个是确定主从关系。

二、每2秒每个 sentinel 通过 master 节点的 channel(名称为_sentinel_:hello) **交换信息**(pub/sub):用来交互对节点的看法(后面会介绍的节点主观下线和客观下线)以及自身信息。

三、每1秒每个 sentinel 对其他 sentinel 和 redis **执行 ping 命令**,**用于心跳检测**,作为节点存活的判断依据。

#### 主观下线和客观下线

一、主观下线
**SDOWN:subjectively down**,直接翻译的为"主观"失效,即当前sentinel实例认为某个redis服务为”不可用”状态。

二、客观下线

**ODOWN:objectively down**,直接翻译为”客观”失效,即多个sentinel实例都认为master处于”SDOWN”状态,那么此时master将处于ODOWN,ODOWN可以简单理解为master已经被集群确定为”不可用”,将会开启故障转移机制。

主从切换时,kill掉Redis主节点,然后查看 sentinel 日志,如下:

![20210419163036](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210419163036.png)

发现有类似 sdown 和 odown 的日志.在结合我们配置 sentinel 时的配置文件来看:
```bash
#监控的IP 端口号 名称 sentinel通过投票后认为mater宕机的数量，此处为至少2个
sentinel monitor mymaster 192.168.14.101 6379 2
```
最后的 2 表示投票数,也就是说当一台 sentinel 发现一个 Redis 服务无法 ping 通时,就标记为 主观下线 sdown;同时另外的 sentinel 服务也发现该 Redis 服务宕机,也标记为 主观下线,当多台 sentinel (大于等于2,上面配置的最后一个)时,都标记该Redis服务宕机,这时候就变为客观下线了,然后进行故障转移。


#### 故障转移
故障转移是由 sentinel 领导者节点来完成的(**只需要一个sentinel节点**),关于 sentinel 领导者节点的选取也是每个 sentinel 向其他 sentinel 节点发送我要成为领导者的命令,超过半数sentinel 节点同意,并且也大于quorum ,那么他将成为领导者,如果有多个sentinel都成为了领导者,则会过段时间再进行选举。

**sentinel 领导者节点选举出来后,会通过如下几步进行故障转移:**


一、从 slave 节点中选出一个合适的 节点作为新的master节点.这里的合适包括如下几点:

1. 选择 slave-priority(**slave节点优先级,也即priority最小的**)最高的slave节点,如果存在则返回,不存在则继续下一步判断。
2. 选择复制偏移量最大的 slave 节点(**复制的最完整**),如果存在则返回,不存在则继续。
3. 选择runId最小的slave节点(**启动最早的节点**)

二、对上面选出来的 slave 节点执行 slaveof no one 命令让其成为新的 master 节点。

三、向剩余的 slave 节点发送命令,让他们成为新master 节点的 slave 节点,复制规则和前面设置的 parallel-syncs 参数有关。

四、更新原来master 节点配置为 slave 节点,并保持对其进行关注,一旦这个节点重新恢复正常后,会命令它去复制新的master节点信息.(注意:原来的master节点恢复后是作为slave的角色)


**可以从 sentinel 日志中出现的几个消息来进行查看故障转移:**
1. **+switch-master:** 表示切换主节点(从节点晋升为主节点)
2. **+sdown:** 主观下线
3. **+odown:** 客观下线
4. **+convert-to-slave:** 切换从节点(原主节点降为从节点)




