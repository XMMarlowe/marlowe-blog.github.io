---
title: Leetcode组合总和1-4题题解
author: Marlowe
tags: Leetcode
categories: 题解
abbrlink: 24553
date: 2020-10-12 21:52:22
---

### Leetcode组合总和1-4题题解

Leecode最近几天的每日一题都是组合总和问题，预测明天是组合总和Ⅳ，因此，提前将组合总和的所有题目刷了，前三题的思路都差不多，最后一题做法有所不同：

组合总和：`candidates` 中的数字可以无限制重复被选取。 

组合总和Ⅱ： `candidates` 中的每个数字在每个组合中只能使用一次。 

组合总和Ⅲ：组合中只允许有1-9的数字，并且每种组合中不存在重复的数字。 

组合总和Ⅳ：找出符合要求组合的个数。

#### [39. 组合总和](https://leetcode-cn.com/problems/combination-sum/)

给定一个**无重复元素**的数组 `candidates` 和一个目标数 `target` ，找出 `candidates` 中所有可以使数字和为 `target` 的组合。

`candidates` 中的数字可以无限制重复被选取。

**说明：**

- 所有数字（包括 `target`）都是正整数。
- 解集不能包含重复的组合。 

**示例 1：**

```
输入：candidates = [2,3,6,7], target = 7,
所求解集为：
[
  [7],
  [2,2,3]
]
```

**示例 2：**

```
输入：candidates = [2,3,5], target = 8,
所求解集为：
[
  [2,2,2,2],
  [2,3,3],
  [3,5]
]
```

**提示：**

- `1 <= candidates.length <= 30`
- `1 <= candidates[i] <= 200`
- `candidate` 中的每个元素都是独一无二的。
- `1 <= target <= 500`

##### 题解（dfs，回溯算法）

##### 分析：

此类问题可以画出树形图，然后就会发现此题可以用dfs+回溯算法解决，用到的数据结构为双端队列，具有栈和队列的性质，其定义方式为：Deque<Integer> stack = new ArrayDeque<Integer>();具体步骤见代码。

##### 具体步骤如下：

```java
class Solution {
    public List<List<Integer>> combinationSum(int[] candidates, int target) {
        // 保存结果集
        List<List<Integer>> res = new ArrayList();
        // 获取数组的长度
        int len = candidates.length;
        //如果数组为空，直接返回空集合
         if(len == 0){
             return res;
         }
		 // 双端队列，保存临时路径
         Deque<Integer> path = new ArrayDeque();
         // 深度优先遍历求所有结果集
         dfs(candidates,0,len,target,path,res);
         return res;
    }

    public void dfs(int[] candidates,int start,int len,int target,Deque<Integer> path,List<List<Integer>> res){
        // 如果选多了，也即target < 0,直接return
        if(target < 0){
            return;
        }
        // 找到一条路径
        if(target == 0){
            // 将路径加入结果集
            res.add(new ArrayList(path));
        }
		// 从下标为start的数开始寻找
        for(int i = start; i < len; i++){
            // 将当前元素入栈
            path.addLast(candidates[i]);
            // 由于可以选择重复的元素，因此i不变，但是选择了东西，target对应减少
            dfs(candidates,i,len,target - candidates[i],path,res);
            // 回到之前的状态
            path.removeLast();
        }
    }
}
```

#### [40. 组合总和 II](https://leetcode-cn.com/problems/combination-sum-ii/)

给定一个数组 `candidates` 和一个目标数 `target` ，找出 `candidates` 中所有可以使数字和为 `target` 的组合。

`candidates` 中的每个数字在每个组合中只能使用一次。

**说明：**

- 所有数字（包括目标数）都是正整数。
- 解集不能包含重复的组合。 

**示例 1:**

```
输入: candidates = [10,1,2,7,6,1,5], target = 8,
所求解集为:
[
  [1, 7],
  [1, 2, 5],
  [2, 6],
  [1, 1, 6]
]
```

**示例 2:**

```
输入: candidates = [2,5,2,1,2], target = 5,
所求解集为:
[
  [1,2,2],
  [5]
]
```

##### 题解（dfs，回溯算法，哈希表）

##### 分析：

此题和[组合总和](https://leetcode-cn.com/problems/combination-sum/)的区别在于 `candidates` 中的每个数字在每个组合中只能使用一次，并且解集不能包含重复的元素，因此可用哈希表对重复解集去重，具体步骤看下方代码注释。

##### 具体步骤如下：

```java
class Solution {
    public List<List<Integer>> combinationSum2(int[] candidates, int target) {
        // 将原始数组排序
        Arrays.sort(candidates);
        // 获取数组长度
        int len = candidates.length;
        // 结果集列表
        List<List<Integer>> res = new ArrayList();
        // 双端队列
        Deque<Integer> path = new ArrayDeque();
        // 深度优先遍历 + 回溯
        dfs(candidates,0,len,target,path,res);
        // 去重，因为解集不能有重复元素
        HashSet<List<Integer>> set = new HashSet();
        for(List<Integer> list : res){
            set.add(list);
        }
        // 将HashSet转换为List集合
        return new ArrayList(set);
    }

    public void dfs(int[] candidates,int start,int len,int target,Deque<Integer> path,List<List<Integer>> res){
        // 如果选多了，也即target < 0,直接return
        if(target < 0){
            return;
        }
        // 找到一条路径
        if(target == 0){
            // 将路径加入结果集
            res.add(new ArrayList(path));
        }
        for(int i = start; i < len; i++){
            // 将当前元素入栈
            path.addLast(candidates[i]);
            // 由于数组中的元素只能用一次，因此i + 1,并且target减少
            dfs(candidates,i+1,len,target - candidates[i],path,res);
            // 回到之前的状态
            path.removeLast();
        }
    }
}
```

#### [216. 组合总和 III](https://leetcode-cn.com/problems/combination-sum-iii/)

 找出所有相加之和为 ***n*** 的 ***k*** 个数的组合**。**组合中只允许含有 1 - 9 的正整数，并且每种组合中不存在重复的数字。 

**说明：**

- 所有数字都是正整数。
- 解集不能包含重复的组合。 

**示例 1:**

```
输入: k = 3, n = 7
输出: [[1,2,4]]
```

**示例 2:**

```
输入: k = 3, n = 9
输出: [[1,2,6], [1,3,5], [2,3,4]]
```

##### 题解（dfs，回溯算法）

##### 分析：

此题和[组合总和Ⅱ](https://leetcode-cn.com/problems/combination-sum-ii/)的区别在于在1-9中选择数据,并且每个数据只能选一次，且只需返回长度为k的路径,因此需对结果集进行筛选，具体步骤看下方代码注释。

##### 具体步骤如下：

```java
class Solution {
    public List<List<Integer>> combinationSum3(int k, int n) {
        // 手动将1-9加入数组arr中
        int[] arr = new int[]{1,2,3,4,5,6,7,8,9};
        // 初始结果集
        List<List<Integer>> res = new ArrayList();
        // 最终结果集
        List<List<Integer>> res1 = new ArrayList();
        // 临时路径
        Deque<Integer> path = new ArrayDeque();
        // 深度优先遍历求出所有解集
        dfs(arr,0,n,path,res);
        // 选出符合长度为k的解集
        for(List<Integer> list : res){
            if(list.size() == k){
                res1.add(list);
            }
        }
        return res1;
    }

    public void dfs(int[] arr,int start,int n ,Deque<Integer> path,List<List<Integer>> res){
        // 如果选多了，也即n < 0,直接return
        if(n < 0){
            return;
        }
        // 找到一条路径
        if(n == 0){
            // 将路径加入结果集
            res.add(new ArrayList(path));
        }
		
        for(int i = start; i < 9; i++){
            // 将当前元素入栈
            path.addLast(arr[i]);
            // 由于数组中的元素只能用一次，因此i + 1,并且n减少
            dfs(arr,i + 1,n - arr[i],path,res);
            // 回到之前的状态
            path.removeLast();
        }
    }
}

```

#### [377. 组合总和 Ⅳ](https://leetcode-cn.com/problems/combination-sum-iv/)

给定一个由正整数组成且不存在重复数字的数组，找出和为给定目标正整数的组合的个数。

**示例:**

```
nums = [1, 2, 3]
target = 4

所有可能的组合为：
(1, 1, 1, 1)
(1, 1, 2)
(1, 2, 1)
(1, 3)
(2, 1, 1)
(2, 2)
(3, 1)

请注意，顺序不同的序列被视作不同的组合。

因此输出为 7。

```

**进阶：**
如果给定的数组中含有负数会怎么样？
问题会产生什么变化？
我们需要在题目中添加什么限制来允许负数的出现？

##### 题解（1.dfs,回溯算法 2.动态规划）

##### 分析：

此题和[组合总和](https://leetcode-cn.com/problems/combination-sum/)类似，区别在于求出所有解集后，还需求出解集的全排列，并返回全排列的个数。

组合总数前三题都是同样的套路，只是在结果处理以及中间过程有略微差别，但是这题不同的是要求结果集的全排列，因此，我就想用第一题的算法 + 全排列算法求出此题，代码如`demo1`，结果超时，代码逻辑是没有问题的，但题目所给数据过大，导致算全排列的时候使用过多时间，因此未通过。

查看题解，发现正确的解法为动态规划，根据分析可以得到状态转移方程：

`dp[i] = dp[i - nums[0]] + dp[i - nums[1]] + dp[i - nums[2]]......`

`例如nums = [1,3,4],target = 7;`

`dp[7] = dp[6] + dp[4] + dp[3];`

具体代码见`demo2`

##### 具体步骤如下：

`demo1`

```java
class Solution {
    public int combinationSum4(int[] nums, int target) {
        Arrays.sort(nums);
        int sum = 0;
        // 保存结果集
        List<List<Integer>> res = new ArrayList();
        // 获取数组的长度
        int len = nums.length;
		// 双端队列，保存临时路径
        Deque<Integer> path = new ArrayDeque();
        // 深度优先遍历求所有结果集
        dfs(nums,0,len,target,path,res);
         
        // 求出解集中的所有情况
        for(List<Integer> list : res){
            sum += isok(list);
        }
        return sum; 
    }

    // 求出所有解集
    public void dfs(int[] nums,int start,int len,int target,Deque<Integer> path,List<List<Integer>> res){
        if(target < 0){
            return;
        }
        if(target == 0){
            res.add(new ArrayList(path));
        }
        for(int i = start; i < len; i++){
            path.addLast(nums[i]);
            // 可以重复使用，因此i不用+1
            dfs(nums,i,len,target - nums[i],path,res);
            path.removeLast();
        }
    }
    // 求出列表的所有组合情况
    public int isok(List<Integer> list){
        int[] nums = new int[list.size()];
        for(int i = 0 ; i < nums.length; i++){
            nums[i] = list.get(i);
        }
        int len = nums.length;
        Deque<Integer> path = new ArrayDeque();
        List<List<Integer>> res = new ArrayList();
        // 布尔数组，用于标记改数是否使用过
        boolean[] used = new boolean[len];
        dfs2(nums,len,0,used,path,res);
        return res.size();
    }
	// 求全排列
    public void dfs2(int[] nums,int len,int depth,boolean[] used,Deque<Integer> path,List<List<Integer>> res){
        if(depth == len){
            res.add(new ArrayList(path));
            return;
        }
        for(int i = 0 ; i < len; i++){
            if(used[i]){
                continue;
            }
            // 因为有重复元素，所以在下一层碰到相同元素会使结果重复，相对于全排列，进一步剪枝
            if(i > 0 && nums[i] == nums[i - 1] && !used[i - 1]){
                continue;
            }
            // 回溯算法经典步骤
            // 先将当前数字加入栈，并将使用过的元素标记为true
            path.addLast(nums[i]);
            used[i] = true;
            dfs2(nums,len,depth + 1,used,path,res);
            // 回到之前的状态
            path.removeLast();
            used[i] = false;
        }
    }
}   

```

`demo2`

```java
class Solution {
    public int combinationSum4(int[] nums, int target) {
        int[] dp = new int[target + 1];
        dp[0] = 1;
        for(int i  = 0; i <= target; i++){
            for(int num : nums){
                if(num <= i){
                    dp[i] += dp[i - num];
                }
            }
        }
        return dp[target];
    }
}

```

:smile:以上题解仅限于个人理解，如有更好的方法或者更高效的解法，请移步至评论区，谢谢！