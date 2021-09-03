---
title: 消息中间件之Kafka学习
author: Marlowe
tags:
  - MQ
  - Kafka
categories: 中间件
abbrlink: 52848
date: 2021-07-15 22:47:41
---
总结一些Kafka常见问题
<!--more-->

### Kafka架构图

![20210823214922](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210823214922.png)

### Kafka 是什么？主要应用场景有哪些？

Kafka 是一个分布式流式处理平台。这到底是什么意思呢？

流平台具有三个关键功能：

1. **消息队列：** 发布和订阅消息流，这个功能类似于消息队列，这也是 Kafka 也被归类为消息队列的原因。
2. **容错的持久方式存储记录消息流：** Kafka 会把消息持久化到磁盘，有效避免了消息丢失的风险。
3. **流式处理平台：** 在消息发布的时候进行处理，Kafka 提供了一个完整的流式处理类库。

Kafka 主要有**两大应用场景**：

1. **消息队列：** 建立实时流数据管道，以可靠地在系统或应用程序之间获取数据。
2. **数据处理：** 构建实时的流数据处理程序来转换或处理数据流。

### 和其他消息队列相比,Kafka的优势在哪里？

我们现在经常提到 Kafka 的时候就已经默认它是一个非常优秀的消息队列了，我们也会经常拿它给 RocketMQ、RabbitMQ 对比。我觉得 Kafka 相比其他消息队列主要的优势如下：

1. **极致的性能：** 基于 Scala 和 Java 语言开发，设计中大量使用了批量处理和异步的思想，最高可以每秒处理千万级别的消息。
2. **生态系统兼容性无可匹敌：** Kafka 与周边生态系统的兼容性是最好的没有之一，尤其在大数据和流计算领域。

实际上在早期的时候 Kafka 并不是一个合格的消息队列，早期的 Kafka 在消息队列领域就像是一个衣衫褴褛的孩子一样，功能不完备并且有一些小问题比如丢失消息、不保证消息可靠性等等。当然，这也和 LinkedIn 最早开发 Kafka 用于处理海量的日志有很大关系，哈哈哈，人家本来最开始就不是为了作为消息队列滴，谁知道后面误打误撞在消息队列领域占据了一席之地。

随着后续的发展，这些短板都被 Kafka 逐步修复完善。所以，**Kafka 作为消息队列不可靠这个说法已经过时！**

### 队列模型了解吗？Kafka 的消息模型知道吗？

#### 队列模型：早期的消息模型

![20210822234636](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210822234636.png)

**使用队列（Queue）作为消息通信载体，满足生产者与消费者模式，一条消息只能被一个消费者使用，未被消费的消息在队列中保留直到被消费或超时。** 比如：我们生产者发送 100 条消息的话，两个消费者来消费一般情况下两个消费者会按照消息发送的顺序各自消费一半（也就是你一个我一个的消费。）

**队列模型存在的问题：**

假如我们存在这样一种情况：我们需要将生产者产生的消息分发给多个消费者，并且每个消费者都能接收到完成的消息内容。

这种情况，队列模型就不好解决了。很多比较杠精的人就说：我们可以为每个消费者创建一个单独的队列，让生产者发送多份。这是一种非常愚蠢的做法，浪费资源不说，还违背了使用消息队列的目的。

#### 发布-订阅模型:Kafka 消息模型

发布-订阅模型主要是为了解决队列模型存在的问题。

![20210822234918](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210822234918.png)

发布订阅模型（Pub-Sub） 使用**主题（Topic）** 作为消息通信载体，类似于**广播模式**；发布者发布一条消息，该消息通过主题传递给所有的订阅者，**在一条消息广播之后才订阅的用户则是收不到该条消息的。**

**在发布 - 订阅模型中，如果只有一个订阅者，那它和队列模型就基本是一样的了。所以说，发布 - 订阅模型在功能层面上是可以兼容队列模型的。**

**Kafka 采用的就是发布 - 订阅模型。**

> RocketMQ 的消息模型和 Kafka 基本是完全一样的。唯一的区别是 Kafka 中没有队列这个概念，与之对应的是 Partition（分区）。

### 什么是Producer、Consumer、Broker、Topic、Partition？

Kafka 将生产者发布的消息发送到 Topic（**主题**） 中，需要这些消息的消费者可以订阅这些 Topic（**主题**），如下图所示：

![20210822235337](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210822235337.png)

上面这张图也为我们引出了，Kafka 比较重要的几个概念：

1. **Producer（生产者）:** 产生消息的一方。
2. **Consumer（消费者）:** 消费消息的一方。
3. **Broker（代理）:** 可以看作是一个独立的 Kafka 实例。多个 Kafka Broker 组成一个 Kafka Cluster。

同时，你一定也注意到每个 Broker 中又包含了 Topic 以及 Partition 这两个重要的概念：

* **Topic（主题）:** Producer 将消息发送到特定的主题，Consumer 通过订阅特定的 Topic(主题) 来消费消息。
* **Partition（分区）:** Partition 属于 Topic 的一部分。一个 Topic 可以有多个 Partition ，并且同一 Topic 下的 Partition 可以分布在不同的 Broker 上，这也就表明一个 Topic 可以横跨多个 Broker 。这正如我上面所画的图一样。

> 划重点：Kafka 中的 Partition（分区） 实际上可以对应成为消息队列中的队列。这样是不是更好理解一点？

### 生产者分区策略

#### 分区的原因

1. **方便在集群中扩展**，每个 Partition 可以通过调整以适应它所在的机器，而一个 topic又可以有多个 Partition 组成，因此整个集群就可以适应适合的数据了；
2. **可以提高并发**，因为可以以 Partition 为单位读写了。（联想到ConcurrentHashMap在高并发环境下读写效率比HashTable的高效）

#### 分区的原则

我们需要将 producer 发送的数据封装成一个 ProducerRecord 对象。

![20210828121644](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828121644.png)

1. 指明 partition 的情况下，直接将指明的值直接作为 partiton 值；
2. 没有指明 partition 值但有 key 的情况下，将 key 的 hash 值与 topic 的 partition 数进行取余得到 partition 值；
3. 既没有 partition 值又没有 key 值的情况下，第一次调用时随机生成一个整数（后面每次调用在这个整数上自增），将这个值与 topic 可用的 partition 总数取余得到 partition值，也就是常说的 round-robin 算法。

### 消费者分区分配策略

#### 消费方式

**consumer 采用 pull（拉） 模式从 broker 中读取数据。**

**push（推）模式很难适应消费速率不同的消费者，因为消息发送速率是由 broker 决定的。** 它的目标是尽可能以最快速度传递消息，但是这样很容易造成 consumer 来不及处理消息，典型的表现就是拒绝服务以及网络拥塞。而 pull 模式则可以根据 consumer 的消费能力以适当的速率消费消息。

**pull 模式不足之处是**，如果 kafka 没有数据，消费者可能会陷入循环中， 一直返回空数据。 针对这一点， Kafka 的消费者在消费数据时会传入一个时长参数 timeout，如果当前没有数据可供消费， consumer 会等待一段时间之后再返回，这段时长即为 timeout。

#### 分区分配策略

一个 consumer group 中有多个 consumer，一个 topic 有多个 partition，所以必然会涉及到 partition 的分配问题，即确定那个 partition 由哪个 consumer 来消费。

**Kafka 有两种分配策略：**

* round-robin循环
* range

##### Round Robin

关于Roudn Robin重分配策略，其主要采用的是一种轮询的方式分配所有的分区，该策略主要实现的步骤如下。这里我们首先假设有三个topic：t0、t1和t2，这三个topic拥有的分区数分别为1、2和3，那么总共有六个分区，这六个分区分别为：t0-0、t1-0、t1-1、t2-0、t2-1和t2-2。这里假设我们有三个consumer：C0、C1和C2，它们订阅情况为：C0订阅t0，C1订阅t0和t1，C2订阅t0、t1和t2。那么这些分区的分配步骤如下：

* 首先将所有的partition和consumer按照字典序进行排序，所谓的字典序，就是按照其名称的字符串顺序，那么上面的六个分区和三个consumer排序之后分别为：

![20210830080535](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210830080535.png)

* 然后依次以按顺序轮询的方式将这六个分区分配给三个consumer，如果当前consumer没有订阅当前分区所在的topic，则轮询的判断下一个consumer：
* 尝试将t0-0分配给C0，由于C0订阅了t0，因而可以分配成功；
* 尝试将t1-0分配给C1，由于C1订阅了t1，因而可以分配成功；
* 尝试将t1-1分配给C2，由于C2订阅了t1，因而可以分配成功；
* 尝试将t2-0分配给C0，由于C0没有订阅t2，因而会轮询下一个consumer；
* 尝试将t2-0分配给C1，由于C1没有订阅t2，因而会轮询下一个consumer；
* 尝试将t2-0分配给C2，由于C2订阅了t2，因而可以分配成功；
* 同理由于t2-1和t2-2所在的topic都没有被C0和C1所订阅，因而都不会分配成功，最终都会分配给C2。
* 按照上述的步骤将所有的分区都分配完毕之后，最终分区的订阅情况如下：

![20210830080611](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210830080611.png)

从上面的步骤分析可以看出，轮询的策略就是简单的将所有的partition和consumer按照字典序进行排序之后，然后依次将partition分配给各个consumer，如果当前的consumer没有订阅当前的partition，那么就会轮询下一个consumer，直至最终将所有的分区都分配完毕。但是从上面的分配结果可以看出，轮询的方式会导致每个consumer所承载的分区数量不一致，从而导致各个consumer压力不均一。

##### Range

所谓的Range重分配策略，就是首先会计算各个consumer将会承载的分区数量，然后将指定数量的分区分配给该consumer。这里我们假设有两个consumer：C0和C1，两个topic：t0和t1，这两个topic分别都有三个分区，那么总共的分区有六个：t0-0、t0-1、t0-2、t1-0、t1-1和t1-2。那么Range分配策略将会按照如下步骤进行分区的分配：

* 需要注意的是，Range策略是按照topic依次进行分配的，比如我们以t0进行讲解，其首先会获取t0的所有分区：t0-0、t0-1和t0-2，以及所有订阅了该topic的consumer：C0和C1，并且会将这些分区和consumer按照字典序进行排序；
* 然后按照平均分配的方式计算每个consumer会得到多少个分区，如果没有除尽，则会将多出来的分区依次计算到前面几个consumer。比如这里是三个分区和两个consumer，那么每个consumer至少会得到1个分区，而3除以2后还余1，那么就会将多余的部分依次算到前面几个consumer，也就是这里的1会分配给第一个consumer，总结来说，那么C0将会从第0个分区开始，分配2个分区，而C1将会从第2个分区开始，分配1个分区；
* 同理，按照上面的步骤依次进行后面的topic的分配。
* 最终上面六个分区的分配情况如下：

![20210830080704](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210830080704.png)

可以看到，如果按照Range分区方式进行分配，其本质上是依次遍历每个topic，然后将这些topic的分区按照其所订阅的consumer数量进行平均的范围分配。这种方式从计算原理上就会导致排序在前面的consumer分配到更多的分区，从而导致各个consumer的压力不均衡。

TODO:我的问题：topic分多个partition，有些custom根据上述策略，分到topic的部分partition，难道不是要全部partition吗？是不是还要按照相同策略多分配多一次？



### 生产者ISR

为保证 producer 发送的数据，能可靠的发送到指定的 topic， topic 的每个 partition 收到producer 发送的数据后，都需要向 producer 发送 ack（acknowledgement 确认收到），如果producer 收到 ack， 就会进行下一轮的发送，否则重新发送数据。

![20210828121923](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828121923.png)

#### 何时发送ack？

确保有follower与leader同步完成，leader再发送ack，这样才能保证leader挂掉之后，能在follower中选举出新的leader。

#### 多少个follower同步完成之后发送ack？

1. 半数以上的follower同步完成，即可发送ack继续发送重新发送
2. 全部的follower同步完成，才可以发送ack

#### 副本数据同步策略

| 序号	| 方案	| 优点	| 缺点
| :--:|:--: |:--: |:--: |:--: |:--:| 
| 1	| 半数以上完成同步， 就发送 ack	| 延迟低	| 选举新的 leader 时，容忍 n 台节点的故障，需要 2n+1 个副本。（如果集群有2n+1台机器，选举leader的时候至少需要半数以上即n+1台机器投票，那么能容忍的故障，最多就是n台机器发生故障）容错率：1/2
| 2	| 全部完成同步，才发送ack	| 选举新的 leader 时， 容忍 n 台节点的故障，需要 n+1 个副本（如果集群有n+1台机器，选举leader的时候只要有一个副本就可以了）容错率：1	| 延迟高

**Kafka 选择了第二种方案，原因如下：**

1. 同样为了容忍 n 台节点的故障，第一种方案需要 2n+1 个副本，而第二种方案只需要 n+1 个副本，而 Kafka 的每个分区都有大量的数据， 第一种方案会造成大量数据的冗余。
2. 虽然第二种方案的网络延迟会比较高，但网络延迟对 Kafka 的影响较小。

#### ISR

采用第二种方案之后，设想以下情景： leader 收到数据，所有 follower 都开始同步数据，但有一个 follower，因为某种故障，迟迟不能与 leader 进行同步，那 leader 就要一直等下去，直到它完成同步，才能发送 ack。这个问题怎么解决呢？

Leader 维护了一个动态的 in-sync replica set (ISR)，意为和 leader 保持同步的 follower 集合。当 ISR 中的 follower 完成数据的同步之后，就会给 leader 发送 ack。如果 follower长时间未向leader同步数据，则该follower将被踢出ISR，该时间阈值由`replica.lag.time.max.ms`参数设定。 Leader 发生故障之后，就会从 ISR 中选举新的 leader。

> **replica.lag.time.max.ms**
**DESCRIPTION:** If a follower hasn't sent any fetch requests or hasn't consumed up to the leaders log end offset for at least this time, the leader will remove the follower from isr
**TYPE:** long
**DEFAULT:** 10000

### 生产者ACk机制

对于某些不太重要的数据，对数据的可靠性要求不是很高，能够容忍数据的少量丢失，所以没必要等 ISR 中的 follower 全部接收成功。

所以 Kafka 为用户提供了三种可靠性级别，用户根据对可靠性和延迟的要求进行权衡，选择以下的配置。

#### acks 参数配置

* 0： producer 不等待 broker 的 ack，这一操作提供了一个最低的延迟， **broker 一接收到还没有写入磁盘就已经返回**，当 broker 故障时有可能**丢失数据**；
* 1： producer 等待 broker 的 ack， partition 的 leader 落盘成功后返回 ack，如果**在 follower同步成功之前 leader 故障**，那么将会**丢失数据**；

![20210828122550](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828122550.png)

* -1（all） ： producer 等待 broker 的 ack， partition 的 leader 和 ISR 的follower 全部落盘成功后才返回 ack。但是如果在 follower 同步完成后， broker 发送 ack 之前， leader 发生故障，那么会造成**数据重复**。

![20210828122620](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828122620.png)

**问题**

#### ACK设置为-1，为什么导致数据重复？该怎么解决？(幂等性)

**重复的原因：**

1、生产者发送数据到leader。

2、leader写完数据，ISR中的follower也拉取完数据了，但是在返回ack之前，leader宕机了。

3、此时生产者的没拿到ack(这个请求失败了)，就会认为kafka没有拿到数据，就会重发数据。

kafka就又会重新保存这份重发数据，导致数据重复。

**解决办法**

新版的kafka加了个幂等性，用参数enable.idempotence=true就可以开启。

开启之后会使用`poductorId、partition.id、seqNumber`(消息序号，与offset不一样)这三个做缓存，用于判断重发的数据是否已经被leader以及follower保存过了，如果保存过了，就不会再保存，这样就避免重复消息了。


**助记：返ACK前，0无落盘，1一落盘，-1全落盘，（落盘：消息存到本地）**

> **acks**
> 
> **DESCRIPTION:**
> The number of acknowledgments the producer requires the leader to have received before considering a request complete. This controls the durability of records that are sent. The following settings are allowed:
> 
> * acks=0 If set to zero then the producer will not wait for any acknowledgment from the server at all. The record will be immediately added to the socket buffer and considered sent. No guarantee can be made that the server has received the record in this case, and the retries configuration will not take effect (as the client won't generally know of any failures). The offset given back for each record will always be set to -1.
> 
> * acks=1 This will mean the leader will write the record to its local log but will respond without awaiting full acknowledgement from all followers. In this case should the leader fail immediately after acknowledging the record but before the followers have replicated it then the record will be lost.
> 
> * acks=all This means the leader will wait for the full set of in-sync replicas to acknowledge the record. This guarantees that the record will not be lost as long as at least one in-sync replica remains alive. This is the strongest available guarantee. This is equivalent to the acks=-1 setting.
>
> TYPE:string
>
> DEFAULT:1
>
> VALID VALUES:[all, -1, 0, 1]

### 数据一致性问题

![20210828124557](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828124557.png)

* LEO：（Log End Offset）每个副本的最后一个offset
* HW：（High Watermark）高水位，指的是消费者能见到的最大的 offset， ISR 队列中最小的 LEO

#### follower 故障和 leader 故障

* **follower 故障**：follower 发生故障后会被临时踢出 ISR，待该 follower 恢复后， follower 会读取本地磁盘记录的上次的 HW，并将 log 文件高于 HW 的部分截取掉，从 HW 开始向 leader 进行同步。等该 follower 的 LEO 大于等于该 Partition 的 HW，即 follower 追上 leader 之后，就可以重新加入 ISR 了。
* **leader 故障**：leader 发生故障之后，会从 ISR 中选出一个新的 leader，之后，为保证多个副本之间的数据一致性， 其余的 follower 会先将各自的 log 文件高于 HW 的部分截掉，然后从新的 leader同步数据。

注意： 这只能保证副本之间的数据一致性，并不能保证数据不丢失或者不重复。

### ExactlyOnce(幂等性)

将服务器的 ACK 级别设置为-1（all），可以保证 Producer 到 Server 之间不会丢失数据，即 **At Least Once** 语义。

相对的，将服务器 ACK 级别设置为 0，可以保证生产者每条消息只会被发送一次，即 **At Most Once** 语义。

At Least Once 可以保证数据不丢失，但是不能保证数据不重复；相对的， At Most Once可以保证数据不重复，但是不能保证数据不丢失。 但是，对于一些非常重要的信息，比如说**交易数据**，下游数据消费者要求数据既不重复也不丢失，即 **Exactly Once** 语义。

> * At least once—Messages are never lost but may be redelivered.
> * At most once—Messages may be lost but are never redelivered.
> * Exactly once—this is what people actually want, each message is delivered once and only once.

在 0.11 版本以前的 Kafka，对此是无能为力的，只能保证数据不丢失，再在下游消费者对数据做全局去重。对于多个下游应用的情况，每个都需要单独做全局去重，这就对性能造成了很大影响。

0.11 版本的 Kafka，引入了一项重大特性：**幂等性。所谓的幂等性就是指 Producer 不论向 Server 发送多少次重复数据， Server 端都只会持久化一条**。幂等性结合 At Least Once 语义，就构成了 Kafka 的 Exactly Once 语义。即：

```
At Least Once + 幂等性 = Exactly Once
```
**幂等性的具体实现：**
要启用幂等性，只需要将 Producer 的参数中 `enable.idempotence` 设置为 true 即可。**Kafka的幂等性实现其实就是将原来下游需要做的去重放在了数据上游。** **开启幂等性的 Producer 在初始化的时候会被分配一个 PID，发往同一 Partition 的消息会附带 Sequence Number。** 而Broker 端会对`<PID, Partition, SeqNumber>`做缓存，当具有相同主键的消息提交时， **Broker 只会持久化一条。**

但是 PID 重启就会变化，同时不同的 Partition 也具有不同主键，**所以幂等性无法保证跨分区跨会话的 Exactly Once。**

### Kafka事务

Kafka 从 0.11 版本开始引入了事务支持。**事务可以保证 Kafka 在 Exactly Once 语义的基础上，生产和消费可以跨分区和会话，要么全部成功，要么全部失败。**

#### Producer 事务

为了实现跨分区跨会话的事务，需要引入一个全局唯一的 Transaction ID，并将 Producer 获得的PID 和Transaction ID 绑定。这样当Producer 重启后就可以通过正在进行的 TransactionID 获得原来的 PID。

为了管理 Transaction， Kafka 引入了一个新的组件 Transaction Coordinator。 Producer 就是通过和 Transaction Coordinator 交互获得 Transaction ID 对应的任务状态。 Transaction Coordinator 还负责将事务所有写入 Kafka 的一个内部 Topic，这样即使整个服务重启，由于事务状态得到保存，进行中的事务状态可以得到恢复，从而继续进行。

#### Consumer 事务

上述事务机制主要是从 Producer 方面考虑，对于 Consumer 而言，事务的保证就会相对较弱，尤其时无法保证 Commit 的信息被精确消费。这是由于 Consumer 可以通过 offset 访问任意信息，而且不同的 Segment File 生命周期不同，同一事务的消息可能会出现重启后被删除的情况。

### 什么是消费者组？

消费者组是Kafka独有的概念，如果面试官问这个，就说明他对此是有一定了解的。

胡大给的标准答案是：官网上的介绍言简意赅，即**消费者组是Kafka提供的可扩展且具有容错性的消费者机制。**

但实际上，消费者组（Consumer Group）其实包含两个概念，**作为队列**，消费者组允许你分割数据处理到一组进程集合上（**即一个消费者组中可以包含多个消费者进程，他们共同消费该topic的数据**），这有助于你的消费能力的动态调整；**作为发布-订阅模型**（publish-subscribe），Kafka允许你将同一份消息广播到多个消费者组里，以此来丰富多种数据使用场景。

**需要注意的是**：在消费者组中，多个实例共同订阅若干个主题，实现共同消费。同一个组下的每个实例都配置有相同的组ID，被分配不同的订阅分区。当某个实例挂掉的时候，其他实例会自动地承担起它负责消费的分区。 **因此，消费者组在一定程度上也保证了消费者程序的高可用性。**

![20210823215240](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210823215240.png)


注意：消费者组的题目，能够帮你在某种程度上掌控下面的面试方向。

* 如果你擅长位移值原理（Offset），就不妨再提一下消费者组的位移提交机制；
* 如果你擅长Kafka Broker，可以提一下消费者组与Broker之间的交互；
* 如果你擅长与消费者组完全不相关的Producer，那么就可以这么说：“消费者组要消费的数据完全来自于Producer端生产的消息，我对Producer还是比较熟悉的。”

总之，你总得对consumer group相关的方向有一定理解，然后才能像面试官表名你对某一块很理解。

### Kafka中位移（offset）的作用？

标准答案：在Kafka中，每个主题分区下的**每条消息都被赋予了一个唯一的ID数值**，**用于标识它在分区中的位置**。这个ID数值，就被称为位移，或者叫**偏移量**。**一旦消息被写入到分区日志，它的位移值将不能被修改。**

答完这些之后，你还可以把整个面试方向转移到你希望的地方：

* 如果你深谙Broker底层日志写入的逻辑，可以强调下消息在日志中的存放格式
* 如果你明白位移值一旦被确定不能修改，可以强调下“Log Cleaner组件都不能影响位移值”这件事情
* 如果你对消费者的概念还算熟悉，可以再详细说说位移值和消费者位移值之间的区别

### Kafka 的多副本机制了解吗？带来了什么好处？

还有一点我觉得比较重要的是 Kafka 为分区（Partition）引入了多副本（Replica）机制。分区（Partition）中的多个副本之间会有一个叫做 leader 的家伙，其他副本称为 follower。我们发送的消息会被发送到 leader 副本，然后 follower 副本才能从 leader 副本中拉取消息进行同步。

> 生产者和消费者只与 leader 副本交互。你可以理解为**其他副本只是 leader 副本的拷贝，它们的存在只是为了保证消息存储的安全性**。当 leader 副本发生故障时会从 follower 中选举出一个 leader,但是 follower 中如果有和 leader 同步程度达不到要求的参加不了 leader 的竞选。

### 阐述下 Kafka 中的领导者副本（Leader Replica）和追随者副本（Follower Replica）的区别？

**推荐的答案**：Kafka副本当前分为**领导者副本**和**追随者副本**。**只有Leader副本才能对外提供读写服务**，响应Clients端的请求。Follower副本只是采用拉（PULL）的方式，被动地同步Leader副本中的数据，并且在Leader副本所在的Broker宕机后，随时准备应聘Leader副本。

**加分点：**

* 强调Follower副本也能对外提供读服务。**自Kafka 2.4版本开始**，社区通过引入新的Broker端参数，**允许Follower副本有限度地提供读服务**。
* 强调Leader和Follower的消息序列在实际场景中不一致。**通常情况下，很多因素可能造成Leader和Follower之间的不同步，比如程序问题，网络问题，broker问题等，短暂的不同步我们可以关注（秒级别），但长时间的不同步可能就需要深入排查了，因为一旦Leader所在节点异常，可能直接影响可用性。**

**注意**：之前确保一致性的主要手段是高水位机制（HW），**但高水位值无法保证Leader连续变更场景下的数据一致性，因此，社区引入了Leader Epoch机制，来修复高水位值的弊端。**

#### Kafka 的多分区（Partition）以及多副本（Replica）机制有什么好处呢？

1. Kafka 通过给特定 Topic 指定多个 Partition, 而各个 Partition 可以分布在不同的 Broker 上, 这样便能提供比较好的并发能力（负载均衡）。
2. Partition 可以指定对应的 Replica 数, 这也极大地提高了消息存储的安全性, 提高了容灾能力，不过也相应的增加了所需要的存储空间。

### Zookeeper 在 Kafka 中的作用知道吗？

详情见：[Zookeeper 在 Kafka 中的作用](https://www.jianshu.com/p/a036405f989c)

![20210822235906](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210822235906.png)

ZooKeeper 主要为 Kafka 提供元数据的管理的功能。

从图中我们可以看出，Zookeeper 主要为 Kafka 做了下面这些事情：

1. **Broker 注册：** 在 Zookeeper 上会有一个专门用来进行 Broker 服务器列表记录的节点。每个 Broker 在启动时，都会到 Zookeeper 上进行注册，即到/brokers/ids 下创建属于自己的节点。每个 Broker 就会将自己的 IP 地址和端口等信息记录到该节点中去
2. **Topic 注册：** 在 Kafka 中，同一个Topic 的消息会被分成多个分区并将其分布在多个 Broker 上，这些分区信息及与 Broker 的对应关系也都是由 Zookeeper 在维护。比如我创建了一个名字为 my-topic 的主题并且它有两个分区，对应到 zookeeper 中会创建这些文件夹：/brokers/topics/my-topic/Partitions/0、/brokers/topics/my-topic/Partitions/1
3. **负载均衡：** 上面也说过了 Kafka 通过给特定 Topic 指定多个 Partition, 而各个 Partition 可以分布在不同的 Broker 上, 这样便能提供比较好的并发能力。 对于同一个 Topic 的不同 Partition，Kafka 会尽力将这些 Partition 分布到不同的 Broker 服务器上。当生产者产生消息后也会尽量投递到不同 Broker 的 Partition 里面。当 Consumer 消费的时候，Zookeeper 可以根据当前的 Partition 数量以及 Consumer 数量来实现动态负载均衡。
4. ......

### Kafka 如何保证消息的消费顺序？

我们在使用消息队列的过程中经常有业务场景需要严格保证消息的消费顺序，比如我们同时发了 2 个消息，这 2 个消息对应的操作分别对应的数据库操作是：**更改用户会员等级、根据会员等级计算订单价格。假如这两条消息的消费顺序不一样造成的最终结果就会截然不同。**

我们知道 Kafka 中 Partition(分区)是真正保存消息的地方，我们发送的消息都被放在了这里。而我们的 Partition(分区) 又存在于 Topic(主题) 这个概念中，并且我们可以给特定 Topic 指定多个 Partition。

![20210823000011](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210823000011.png)

每次添加消息到 Partition(分区) 的时候都会采用尾加法，如上图所示。Kafka 只能为我们保证 Partition(分区) 中的消息有序，而不能保证 Topic(主题) 中的 Partition(分区) 的有序。

> 消息在被追加到 Partition(分区)的时候都会分配一个特定的偏移量（offset）。Kafka 通过偏移量（offset）来保证消息在分区内的顺序性。

所以，我们就有一种很简单的保证消息消费顺序的方法：**1 个 Topic 只对应一个 Partition**。这样当然可以解决问题，但是破坏了 Kafka 的设计初衷。

Kafka 中发送 1 条消息的时候，可以指定 topic, partition, key,data（数据） 4 个参数。如果你发送消息的时候指定了 Partition 的话，所有消息都会被发送到指定的 Partition。并且，**同一个 key 的消息可以保证只发送到同一个 partition，这个我们可以采用表/对象的 id 来作为 key 。**

总结一下，对于如何保证 Kafka 中消息消费的顺序，有了下面两种方法：

1. 1 个 Topic 只对应一个 Partition。
2. **（推荐）发送消息的时候指定 key/Partition。**

当然不仅仅只有上面两种方法，上面两种方法是我觉得比较好理解的。

### Kafka 如何保证消息不丢失?

#### 生产者丢失消息的情况

生产者(Producer) 调用send方法发送消息之后，**消息可能因为网络问题并没有发送过去。**

所以，我们不能默认在调用send方法发送消息之后消息消息发送成功了。为了确定消息是发送成功，我们要判断消息发送的结果。但是要注意的是 Kafka 生产者(Producer) 使用 send 方法发送消息实际上是异步的操作，我们可以通过 get()方法获取调用结果，但是这样也让它变为了同步操作，示例代码如下：

> 详细代码见我的这篇文章：[Kafka系列第三篇！10 分钟学会如何在 Spring Boot 程序中使用 Kafka 作为消息队列?](https://mp.weixin.qq.com/s?__biz=Mzg2OTA0Njk0OA==&mid=2247486269&idx=2&sn=ec00417ad641dd8c3d145d74cafa09ce&chksm=cea244f6f9d5cde0c8eb233fcc4cf82e11acd06446719a7af55230649863a3ddd95f78d111de&token=1633957262&lang=zh_CN#rd)


```java
SendResult<String, Object> sendResult = kafkaTemplate.send(topic, o).get();
if (sendResult.getRecordMetadata() != null) {
  logger.info("生产者成功发送消息到" + sendResult.getProducerRecord().topic() + "-> " + sendRe
              sult.getProducerRecord().value().toString());
}
```

但是一般不推荐这么做！可以采用为其添加回调函数的形式，示例代码如下：

```java
ListenableFuture<SendResult<String, Object>> future = kafkaTemplate.send(topic, o);
future.addCallback(result -> logger.info("生产者成功发送消息到topic:{} partition:{}的消息", result.getRecordMetadata().topic(), result.getRecordMetadata().partition()),
        ex -> logger.error("生产者发送消失败，原因：{}", ex.getMessage()));
```

如果消息发送失败的话，**我们检查失败的原因之后重新发送即可！**

**另外这里推荐为 Producer 的retries （重试次数）设置一个比较合理的值，一般是 3 ，但是为了保证消息不丢失的话一般会设置比较大一点。设置完成之后，当出现网络问题之后能够自动重试消息发送，避免消息丢失。另外，建议还要设置重试间隔，因为间隔太小的话重试的效果就不明显了，网络波动一次你3次一下子就重试完了**

#### 消费者丢失消息的情况

我们知道消息在被追加到 Partition(分区)的时候都会分配一个特定的偏移量（offset）。偏移量（offset)表示 Consumer 当前消费到的 Partition(分区)的所在的位置。Kafka 通过偏移量（offset）可以保证消息在分区内的顺序性。

![20210823000356](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210823000356.png)

当消费者拉取到了分区的某个消息之后，消费者会自动提交了 offset。自动提交的话会有一个问题，试想一下，**当消费者刚拿到这个消息准备进行真正消费的时候，突然挂掉了，消息实际上并没有被消费，但是 offset 却被自动提交了。**

**解决办法也比较粗暴，我们手动关闭自动提交 offset，每次在真正消费完消息之后之后再自己手动提交 offset 。** 但是，细心的朋友一定会发现，这样会带来消息被重新消费的问题。比如你刚刚消费完消息之后，还没提交 offset，结果自己挂掉了，那么这个消息理论上就会被消费两次。

#### Kafka 弄丢了消息

我们知道 Kafka 为分区（Partition）引入了多副本（Replica）机制。分区（Partition）中的多个副本之间会有一个叫做 leader 的家伙，其他副本称为 follower。我们发送的消息会被发送到 leader 副本，然后 follower 副本才能从 leader 副本中拉取消息进行同步。生产者和消费者只与 leader 副本交互。你可以理解为其他副本只是 leader 副本的拷贝，它们的存在只是为了保证消息存储的安全性。

**试想一种情况：假如 leader 副本所在的 broker 突然挂掉，那么就要从 follower 副本重新选出一个 leader ，但是 leader 的数据还有一些没有被 follower 副本的同步的话，就会造成消息丢失。**

**设置 acks = all**

解决办法就是我们设置 acks = all。acks 是 Kafka 生产者(Producer) 很重要的一个参数。

acks 的默认值即为1，代表我们的消息被leader副本接收之后就算被成功发送。当我们配置 acks = all 代表则所有副本都要接收到该消息之后该消息才算真正成功被发送。

**设置 replication.factor >= 3**

为了保证 leader 副本能有 follower 副本能同步消息，我们一般会为 topic 设置 replication.factor >= 3。这样就可以保证每个 分区(partition) 至少有 3 个副本。虽然造成了数据冗余，但是带来了数据的安全性。

**设置 min.insync.replicas > 1**

一般情况下我们还需要设置 min.insync.replicas> 1 ，这样配置代表消息至少要被写入到 2 个副本才算是被成功发送。min.insync.replicas 的默认值为 1 ，在实际生产中应尽量避免默认值 1。

但是，为了保证整个 Kafka 服务的高可用性，你需要确保 replication.factor > min.insync.replicas 。为什么呢？**设想一下假如两者相等的话，只要是有一个副本挂掉，整个分区就无法正常工作了**。这明显违反高可用性！一般推荐设置成 replication.factor = min.insync.replicas + 1。

**设置 unclean.leader.election.enable = false**

> Kafka 0.11.0.0版本开始 unclean.leader.election.enable 参数的默认值由原来的true 改为false

我们最开始也说了我们发送的消息会被发送到 leader 副本，然后 follower 副本才能从 leader 副本中拉取消息进行同步。多个 follower 副本之间的消息同步情况不一样，**当我们配置了 unclean.leader.election.enable = false 的话，当 leader 副本发生故障时就不会从 follower 副本中和 leader 同步程度达不到要求的副本中选择出 leader ，这样降低了消息丢失的可能性。**

### 监控Kafka的框架都有哪些？

对于SRE来讲，依然是送分题。但基础的我们要知道，Kafka本身是提供了JMX（Java Management Extensions）的，我们可以通过它来获取到Kafka内部的一些基本数据。

* Kafka Manager：更多是Kafka的管理，对于SRE非常友好，也提供了简单的瞬时指标监控
* Kafka Monitor：LinkedIn开源的免费框架，支持对集群进行系统测试，并实时监控测试结果。
* CruiseControl：也是LinkedIn公司开源的监控框架，用于实时监测资源使用率，以及提供常用运维操作等。无UI界面，只提供REST API，可以进行多集群管理。
* JMX监控：由于Kafka提供的监控指标都是基于JMX的，因此，市面上任何能够集成JMX的框架都可以使用，比如Zabbix和Prometheus。
* 已有大数据平台自己的监控体系：像Cloudera提供的CDH这类大数据平台，天然就提供Kafka监控方案。
* JMXTool：社区提供的命令行工具，能够实时监控JMX指标。可以使用kafka-run-class.sh kafka.tools.JmxTool来查看具体的用法。

### LEO、LSO、AR、ISR、HW都表示什么含义？

作为SRE来讲，对于一个开源软件的原理以及概念的理解，是非常重要的。

* **LEO（Log End Offset）：** 日志末端位移值或末端**偏移量**，表示日志下一条待插入消息的位移值。举个例子，如果日志有10条消息，位移值从0开始，那么，第10条消息的位移值就是9。此时，LEO = 10。
* **LSO（Log Stable Offset）：** 这是Kafka事务的概念。如果你没有使用到事务，那么这个值不存在（其实也不是不存在，只是设置成一个无意义的值）。该值控制了事务型消费者能够看到的消息范围。它经常与Log Start Offset，即日志起始位移值相混淆，因为有些人将后者缩写成LSO，这是不对的。在Kafka中，LSO就是指代Log Stable Offset。
* **AR（Assigned Replicas）：** AR是主题被创建后，分区创建时被分配的副本集合，副本个数由副本因子决定。
* **ISR（In-Sync Replicas）：** Kafka中特别重要的概念，指代的是AR中那些与Leader保持同步的副本集合。在AR中的副本可能不在ISR中，但Leader副本天然就包含在ISR中。
* **HW（High watermark）：** 高水位值，这是控制消费者可读取消息范围的重要字段。一个普通消费者只能“看到”Leader副本上介于Log Start Offset和HW（不含）之间的所有消息。水位以上的消息是对消费者不可见的。

需要注意的是，通常在ISR中，可能会有人问到为什么有时候副本不在ISR中，这其实也就是上面说的Leader和Follower不同步的情况，为什么我们前面说，短暂的不同步我们可以关注，但是长时间的不同步，我们需要介入排查了，因为ISR里的副本后面都是通过replica.lag.time.max.ms，即Follower副本的LEO落后Leader LEO的时间是否超过阈值来决定副本是否在ISR内部的。

### Kafka能手动删除消息吗？

Kafka不需要用户手动删除消息。它本身提供了留存策略，能够自动删除过期消息。当然，它是支持手动删除消息的。

* 对于设置了Key且参数cleanup.policy=compact的主题而言，我们可以**构造一条 的消息发送给Broker，依靠Log Cleaner组件提供的功能删除掉该 Key 的消息。**
* 对于普通主题而言，我们可以**使用kafka-delete-records命令**，或编写**程序调用Admin.deleteRecords方法**来删除消息。这两种方法殊途同归，底层都是调用Admin的deleteRecords方法，**通过将分区Log Start Offset值抬高的方式间接删除消息。**

### Kafka为什么不支持读写分离？

这其实是分布式场景下的通用问题，因为我们知道CAP理论下，我们只能保证C（可用性）和A（一致性）取其一，如果支持读写分离，那其实对于一致性的要求可能就会有一定折扣，因为通常的场景下，副本之间都是通过同步来实现副本数据一致的，那同步过程中肯定会有时间的消耗，**如果支持了读写分离，就意味着可能的数据不一致，或数据滞后。**

Leader/Follower模型并没有规定Follower副本不可以对外提供读服务。很多框架都是允许这么做的，**只是 Kafka最初为了避免不一致性的问题，而采用了让Leader统一提供服务的方式。**

不过，**自Kafka 2.4之后，Kafka提供了有限度的读写分离，也就是说，Follower副本能够对外提供读服务。**

### Java Consumer 为什么采用单线程来获取消息？

在回答之前，如果先把这句话说出来，一定会加分：**Java Consumer是双线程的设计。一个线程是用户主线程，负责获取消息；另一个线程是心跳线程，负责向Kafka汇报消费者存活情况。将心跳单独放入专属的线程，能够有效地规避因消息处理速度慢而被视为下线的“假死”情况。**

单线程获取消息的设计能够**避免阻塞式的消息获取方式**。单线程轮询方式容易实现异步非阻塞式，这样便于将消费者扩展成支持实时流处理的操作算子。因为很多实时流处理操作算子都不能是阻塞式的。另外一个可能的好处是，可以简化代码的开发。多线程交互的代码是非常容易出错的。

### 简述Follower副本消息同步的完整流程

首先，Follower发送FETCH请求给Leader。

接着，Leader会读取底层日志文件中的消息数据，再更新它内存中的Follower副本的LEO值，更新为FETCH请求中的fetchOffset值。

最后，尝试更新分区高水位值。Follower接收到FETCH响应之后，会把消息写入到底层日志，接着更新LEO和HW值。

**Leader和Follower的HW值更新时机是不同的，Follower的HW更新永远落后于Leader的HW。这种时间上的错配是造成各种不一致的原因。**

**因此，对于消费者而言，消费到的消息永远是所有副本中最小的那个HW。**

### 参考

[Kafka面试题总结](https://snailclimb.gitee.io/javaguide/#/docs/system-design/distributed-system/message-queue/Kafka%E5%B8%B8%E8%A7%81%E9%9D%A2%E8%AF%95%E9%A2%98%E6%80%BB%E7%BB%93?id=kafka%e9%9d%a2%e8%af%95%e9%a2%98%e6%80%bb%e7%bb%93)

[Kafka经典面试题详解](http://dockone.io/article/10853)

