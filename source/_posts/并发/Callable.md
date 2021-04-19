---
title: Callable
author: Marlowe
tags: Callable
categories: 并发
abbrlink: 36862
date: 2020-12-26 20:29:25
---
<!--more-->
### Callable
简介：
1. 可以有返回值
2. 可以抛出异常
3. 方法不同，Runnable 是 run()， Callable 是call()

```java
public class CallableTest {

    public static void main(String[] args) throws ExecutionException, InterruptedException {
        MyThread thread = new MyThread();
        // 适配类
        FutureTask futureTask = new FutureTask(thread);

        new Thread(futureTask, "A").start();
        new Thread(futureTask, "B").start();

        // get方法可能会产生阻塞
        Integer s = (Integer) futureTask.get();
        System.out.println(s);
    }
}

class MyThread implements Callable<Integer> {

    @Override
    public Integer call() throws Exception {
        System.out.println("call()");
        // 耗时的操作
        return 1024;
    }
}

```

结果：
```java
// 只有一个call(),因为有缓存
call()
```
注意：
1. 有缓存
2. 结果可能需要等待，会阻塞！


