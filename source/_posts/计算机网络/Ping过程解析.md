---
title: Ping过程解析
author: Marlowe
date: 2021-04-16 20:03:07
tags: Ping
categories: 计算机网络
---

<!--more-->

### Ping过程解析

1. A电脑（192.168.2.135）发起ping请求，ping 192.168.2.179

2. A电脑广播发起ARP请求，查询 192.168.2.179的MAC地址。

3. B电脑应答ARP请求，向A电脑发起单向应答，告诉A电脑自己的MAC地址为90:A4:DE:C2:DF:FE

4. 知道了MAC地址后，开始进行真正的ping请求，由于B电脑可以根据A电脑发送的请求知道源MAC地址，所有就可以根据源MAC地址进行响应了。


### 总结

我们分析了一次完整的ping请求过程，ping命令是依托于ICMP协议的，ICMP协议的存在就是为了更高效的转发IP数据报和提高交付成功的机会。ping命令除了依托于ICMP，在局域网下还要借助于ARP协议，ARP协议能根据IP地址查出计算机MAC地址。ARP是有缓存的，为了保证ARP的准确性，计算机会更新ARP缓存。