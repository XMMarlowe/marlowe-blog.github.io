---
title: Leetcode全排列1-2题题解
author: Marlowe
tags: Leetcode
categories: 题解
abbrlink: 28414
date: 2020-10-12 21:49:35
---

### Leetcode全排列1-2题题解

对于全排列问题，可能我们很多人从小在数学课上都做过，并且都能由一定的规律将所有排列情况写出来，但如何用编码的方式求解此类问题成了我的问题，或许也成是你们还未解决的问题，其实这类问题的套路都是 dfs + 回溯算法，然后，根据题目要求进行剪枝，我将通过下面两题来讲解这类问题具体做法。

#### [46. 全排列](https://leetcode-cn.com/problems/permutations/)

给定一个 **没有重复** 数字的序列，返回其所有可能的全排列。

**示例:**

```
输入: [1,2,3]
输出:
[
  [1,2,3],
  [1,3,2],
  [2,1,3],
  [2,3,1],
  [3,1,2],
  [3,2,1]
]
```

##### 题解（dfs，回溯算法）

##### 分析：

由于是回溯算法，因此，会用到栈，通常我们所学的栈是这种用法 `Stack<Integer> stack = new Stack<Integer>();`,但在Stack的源码中发现了`Deque<Integer> stack = new ArrayDeque<Integer>();`这种用法，百度之后，知道了[Deque](https://baike.baidu.com/item/deque/849385?fr=aladdin) : （double-ended queue，双端队列）是一种具有[队列](https://baike.baidu.com/item/队列/14580481)和[栈](https://baike.baidu.com/item/栈/12808149)的性质的[数据结构](https://baike.baidu.com/item/数据结构/1450)。双端队列中的元素可以从两端弹出，相比list增加运算符重载。 

##### 具体步骤如下：

```java
class Solution {
    public List<List<Integer>> permute(int[] nums) {
        // 数组长度
        int len = nums.length;
        // 结果集
        List<List<Integer>> res = new ArrayList();
        // 双端队列，保存临时路径
        Deque<Integer> path = new ArrayDeque();
        // 布尔数组，保存改数字是否使用过
        boolean[] used = new boolean[len];
        // 深度优先遍历求所有结果集
        dfs(nums,len,0,used,path,res);
        return res;
    }

    public void dfs(int[] nums,int len,int depth,boolean[] used,Deque<Integer> path,List<List<Integer>> res){
        // 如果到达最深的一层
        if(depth == len){
            // 将当前路径加入结果集
            res.add(new ArrayList(path));
            return;
        }
        for(int i = 0 ; i < len; i++){
            // 判断当前数字是否用过
            if(used[i]){
                continue;
            }
            // 回溯算法经典步骤
            // 先将当前数字加入栈，并将使用过的元素标记为true
            path.addLast(nums[i]);
            used[i] = true;
            dfs(nums,len,depth + 1,used,path,res);
            // 回到之前的状态
            path.removeLast();
            used[i] = false;
        }
    }
}
```

#### [47. 全排列 II](https://leetcode-cn.com/problems/permutations-ii/)

给定一个可包含重复数字的序列，返回所有不重复的全排列。

**示例:**

```
输入: [1,1,2]
输出:
[
  [1,1,2],
  [1,2,1],
  [2,1,1]
]
```

##### 题解（dfs，回溯算法）

##### 分析：

此题和[全排列](https://leetcode-cn.com/problems/permutations/)解法类似，唯一的差别在于可选数组nums中存在重复的数字，可能会产生重复的路径，因此，需要在判断当前数字是否用过后，再次判断上一次使用的数字和当前数字是否相同，如果相同，进行剪枝，具体差别见代码。

##### 具体步骤如下：

```java
class Solution {
    public List<List<Integer>> permuteUnique(int[] nums) {
        // 数组长度
        int len = nums.length;
        // 对数组排序
        Arrays.sort(nums);
        // 结果集
        List<List<Integer>> res = new ArrayList();
        // 双端队列，保存临时路径
        Deque<Integer> path = new ArrayDeque();
        // 布尔数组，保存改数字是否使用过
        boolean[] used = new boolean[len];
        // 深度优先遍历求所有结果集
        dfs(nums,len,0,used,path,res);
        return res;
    }

    public void dfs(int[] nums,int len,int depth,boolean[] used,Deque<Integer> path,List<List<Integer>> res){
        // 如果到达最深的一层
        if(depth == len){
            // 将当前路径加入结果集
            res.add(new ArrayList(path));
            return;
        }
        for(int i = 0 ; i < len; i++){
            // 判断当前数字是否用过
            if(used[i]){
                continue;
            }
            // 因为有重复元素，所以在下一层碰到相同元素会使结果重复，相对于全排列，进一步剪枝
            if (i > 0 && nums[i] == nums[i - 1] && !used[i - 1]) {
                continue;
            }
            // 回溯算法经典步骤
            // 先将当前数字加入栈，并将使用过的元素标记为true
            path.addLast(nums[i]);
            used[i] = true;
            dfs(nums,len,depth + 1,used,path,res);
            // 回到之前的状态
            path.removeLast();
            used[i] = false;
        }
    }
}
```

:smile:以上题解仅限于个人理解，如有更好的方法或者更高效的解法，请移步至评论区，谢谢！


