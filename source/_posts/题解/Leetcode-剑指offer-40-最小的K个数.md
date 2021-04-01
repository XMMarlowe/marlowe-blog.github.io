---
title: Leetcode-剑指offer 40.最小的K个数
author: Marlowe
tags: TopK
categories: 题解
abbrlink: 34330
date: 2021-03-27 19:51:16
---

输入整数数组 arr ，找出其中最小的 k 个数。例如，输入4、5、1、6、2、7、3、8这8个数字，则最小的4个数字是1、2、3、4。

**示例 1：**

输入：arr = [3,2,1], k = 2
输出：[1,2] 或者 [2,1]
**示例 2：**

输入：arr = [0,1,2,1], k = 1
输出：[0]
 

**限制：**

0 <= k <= arr.length <= 10000
0 <= arr[i] <= 10000

### 思路
本题是求前 K 小，因此用一个容量为 K 的大根堆，每次 poll 出最大的数，那堆中保留的就是前 K 小。

1. 若目前堆的大小小于K，将当前数字放入堆中。
2. 否则判断当前数字与大根堆堆顶元素的大小关系，如果当前数字比大根堆堆顶还大，这个数就直接跳过；反之如果当前数字比大根堆堆顶小，先poll掉堆顶，再将该数字放入堆中。

### 代码
```java
class Solution {
    public int[] getLeastNumbers(int[] arr, int k) {
        if (k == 0 || arr.length == 0) {
            return new int[0];
        }
        // 默认是小根堆，实现大根堆需要重写一下比较器。
        Queue<Integer> pq = new PriorityQueue<>((v1, v2) -> v2 - v1);
        for (int num: arr) {
            if (pq.size() < k) {
                pq.offer(num);
            } else if (num < pq.peek()) {
                pq.poll();
                pq.offer(num);
            }
        }
        
        // 返回堆中的元素
        int[] res = new int[pq.size()];
        int idx = 0;
        for(int num: pq) {
            res[idx++] = num;
        }
        return res;
    }
}
```


### 参考

[4种解法秒杀TopK（快排/堆/二叉搜索树/计数排序）❤️](https://leetcode-cn.com/problems/zui-xiao-de-kge-shu-lcof/solution/3chong-jie-fa-miao-sha-topkkuai-pai-dui-er-cha-sou/)

