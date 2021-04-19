---
title: ForkJoin
author: Marlowe
tags: ForkJoin
categories: 并发
abbrlink: 48829
date: 2021-03-25 13:37:54
---
ForkJoin 在JDK1.7， 并行执行任务！ 在大数据量下提高效率。
<!--more-->

> ForkJoin特点：工作窃取

里面维护的是双端队列。

代码示例：
ForkJoinDemo.java:
```java
public class ForkJoinDemo extends RecursiveTask<Long> {

    private Long start;
    private Long end;
    private Long temp = 10000L;
    public ForkJoinDemo(Long start, Long end) {
        this.start = start;
        this.end = end;
    }


    /**
     * The main computation performed by this task.
     *
     * @return the result of the computation
     */
    @Override
    protected Long compute() {
        if ((end - start) < temp) {
            Long sum = 0L;
            for (Long i = start; i <= end; i++) {
                sum += i;
            }
            return sum;
        } else {
            long mid = (start + end) / 2;
            ForkJoinDemo task1 = new ForkJoinDemo(start, mid);
            task1.fork();
            ForkJoinDemo task2 = new ForkJoinDemo(mid + 1, end);
            task2.fork();
            return task1.join() + task2.join();
        }
    }
}
```

```java
    public static void test1() throws ExecutionException, InterruptedException {
        long start = System.currentTimeMillis();
        ForkJoinPool forkJoinPool = new ForkJoinPool();
        ForkJoinTask<Long> task = new ForkJoinDemo(0L, 10_0000_0000L);
        ForkJoinTask<Long> submit = forkJoinPool.submit(task);
        Long sum = submit.get();
        long end = System.currentTimeMillis();
        System.out.println("sum = " + sum);
        System.out.println("耗时：" + (end - start));
    }
```
结果：
```java
sum = 500000000500000000
耗时：4950
```

> 并行流
```java
    public static void test2() {
        long start = System.currentTimeMillis();
        long sum = LongStream.rangeClosed(0L, 10_0000_0000L).parallel().reduce(0, Long::sum);
        long end = System.currentTimeMillis();
        System.out.println("sum = " + sum);
        System.out.println("耗时：" + (end - start));
    }
```

结果：
```java
sum = 500000000500000000
耗时：271
```





