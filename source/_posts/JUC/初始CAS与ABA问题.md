---
title: 初始CAS与ABA问题
author: Marlowe
tags:
  - CAS
  - ABA
categories: JUC
abbrlink: 33465
date: 2021-03-25 20:34:19
---

<!--more-->
### 什么是CAS？
CAS是英文单词CompareAndSwap的缩写，中文意思是：比较并替换。CAS需要有3个操作数：内存地址V，旧的预期值A，即将要更新的目标值B。 CAS指令执行时，当且仅当内存地址V的值与预期值A相等时，将内存地址V的值修改为B，否则就什么都不做。整个比较并替换的操作是一个原子操作。它体现的一种乐观锁的思想，比如多个线程要对一个共享的整型变量执行 +1 操作

获取共享变量时，为了保证该变量的可见性，需要使用 volatile 修饰。结合 CAS 和 volatile 可以实现无锁并发，适用于竞争不激烈、多核 CPU 的场景下。

* 因为没有使用 synchronized，所以线程不会陷入阻塞，这是效率提升的因素之一
* 但如果竞争激烈，可以想到重试必然频繁发生，反而效率会受影响

CAS 底层依赖于一个 Unsafe 类来直接调用操作系统底层的 CAS 指令

伪代码：
```java
// 需要不断尝试
while(true) { 
  int 旧值 = 共享变量;//比如拿到了当前值 0 
  int 结果 = 旧值 + 1;//在旧值 0 的基础上增加 1 ，正确结果是 1 

  //这时候如果别的线程把共享变量改成了 5，本线程的正确结果 1 就作
  //废了，这时候 compareAndSwap 返回 false，重新尝试，直到： compareAndSwap 返回 
  //true，表示我本线程做修改的同时，别的线程没有干扰 */
  if( compareAndSwap ( 旧值, 结果 )) { 
    // 成功，退出循环 
  }
}
```

代码示例：
```java
public class CASDemo {

    public static void main(String[] args) {

        AtomicInteger atomicInteger = new AtomicInteger(2020);
        // public final boolean compareAndSet(int expect, int update)
        // 如果我的期望值达到了，就更新，否则不更新  CAS是CPU的并发原语！
        System.out.println(atomicInteger.compareAndSet(2020, 2021));
        System.out.println(atomicInteger.get());

        System.out.println(atomicInteger.compareAndSet(2020, 2021));
        System.out.println(atomicInteger.get());
    }
}
```
结果：
```java
true
2021
false
2021
```

### CAS 缺点
CAS虽然很高效的解决了原子操作问题，但是CAS仍然存在三大问题。
1. 循环会耗时
2. 一次性只能保证一个共享变量的原子性
3. ABA问题



### CAS:ABA问题(狸猫换太子)





### 参考
[认识CAS与ABA问题](https://blog.unclezs.com/Java/%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B/%E8%AE%A4%E8%AF%86CAS%E4%B8%8EABA%E9%97%AE%E9%A2%98.html)


