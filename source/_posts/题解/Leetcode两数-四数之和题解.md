---
title: Leetcode两数-四数之和题解
author: Marlowe
tags:
  - Leetcode
categories: 题解
abbrlink: 4115
date: 2020-10-12 21:35:23
---

### Leecode两数-四数之和题解

最近两天做了两数之和，四数之和，并且之前也做过三数之和，感觉这几道题解法都差不多，并且用同样的方法能求解n数之和。

#### [1. 两数之和](https://leetcode-cn.com/problems/two-sum/)

给定一个整数数组 `nums` 和一个目标值 `target`，请你在该数组中找出和为目标值的那 **两个** 整数，并返回他们的数组下标。

你可以假设每种输入只会对应一个答案。但是，数组中同一个元素不能使用两遍。

**示例:**

```
给定 nums = [2, 7, 11, 15], target = 9

因为 nums[0] + nums[1] = 2 + 7 = 9
所以返回 [0, 1]
```

##### 题解（哈希表）

##### 分析：

利用哈希map，key存放数字，value存放索引，遍历数组，依次取一个数，然后计算出另外一个数，如果哈希map中存在，直接取出索引，返回结果，如果不存在，向哈希map中添加当前元素和对应的下标。

##### 具体步骤如下：

```java
class Solution {
    public int[] twoSum(int[] nums, int target) {
        // key存放数字，value存放index
        HashMap<Integer,Integer> map = new HashMap();
        for(int i = 0; i < nums.length;i++){
            int num2 = target - nums[i];
            // 如果哈希map中存在当前数，直接返回i和当前数的下标
            if(map.containsKey(num2)){
               return new int[] { map.get(num2), i };
            }else{
                // 将当前数放入哈希map
                map.put(nums[i],i);
            }
        }
        return null;
    }
}
```

#### [15. 三数之和](https://leetcode-cn.com/problems/3sum/)

给你一个包含 *n* 个整数的数组 `nums`，判断 `nums` 中是否存在三个元素 *a，b，c ，*使得 *a + b + c =* 0 ？请你找出所有满足条件且不重复的三元组。

**注意：**答案中不可以包含重复的三元组。

**示例：**

```
给定数组 nums = [-1, 0, 1, 2, -1, -4]，

满足要求的三元组集合为：
[
  [-1, 0, 1],
  [-1, -1, 2]
]
```

##### 题解（排序，双指针）

##### 分析：

此题要求出三个数的和为0的结果集，则只需对原数组排序，然后从最小的数开始选，接着设置左右指针，如果当前三个数和为0，将这三个数加入结果集，继续寻找，如果当前三个数和大于0，右指针左移，小于0，左指针右移。

##### 具体步骤如下：

```java
class Solution {
    public List<List<Integer>> threeSum(int[] nums) {
        int len = nums.length;
        List<List<Integer>> ans = new ArrayList();
        //如果数组为空 或者长度小于三 直接返回空
        if(nums == null || len <3)
            return ans;
        //对数组排序
        Arrays.sort(nums);
        for(int i = 0 ; i < len;i++){
            //如果当前最小的数大于0，直接结束循环
            if(nums[i] > 0)
                break;
            //去重
            if(i > 0 && nums[i] == nums[i-1])
                continue;
            //设置左右指针
            int left = i + 1;
            int right = len - 1;
            while(left < right){
                int sum = nums[i] + nums[left] + nums[right]; 
                if( sum == 0){
                    ans.add(Arrays.asList(nums[i],nums[left],nums[right]));
                    //左边元素去重
                    while(left < right && nums[left] == nums[left + 1])
                        left++;
                    //右边元素去重
                    while(left < right && nums[right] == nums[right - 1])
                        right--;
                    //移动左右指针
                    left++;
                    right--;
                }
                if(sum > 0)
                    right--;
                if(sum < 0)
                    left++;
            }
        }
        return ans;
    }
}

```

#### [18. 四数之和](https://leetcode-cn.com/problems/4sum/)

给定一个包含 *n* 个整数的数组 `nums` 和一个目标值 `target`，判断 `nums` 中是否存在四个元素 *a，b，c* 和 *d* ，使得 *a* + *b* + *c* + *d* 的值与 `target` 相等？找出所有满足条件且不重复的四元组。

**注意：**

答案中不可以包含重复的四元组。

**示例：**

```
给定数组 nums = [1, 0, -1, 0, -2, 2]，和 target = 0。

满足要求的四元组集合为：
[
  [-1,  0, 0, 1],
  [-2, -1, 1, 2],
  [-2,  0, 0, 2]
]
```

##### 题解（排序，双指针）

##### 分析：

此题要求出四个数的和为target的结果集，则只需对原数组排序，然后将四数之和降为三数之和，接着设置左右指针，如果当前四个数和为target，将这四个数加入结果集，继续寻找，如果当前四个数和大于target，右指针左移，小于0，左指针右移，具体步骤见代码注释。

##### 具体步骤如下：

```java
class Solution {
    public List<List<Integer>> fourSum(int[] nums, int target) {
        List<List<Integer>> res = new ArrayList();
        // 边界条件判断
        if(nums == null || nums.length < 4){
            return res;
        }
        // 对原数组排序
        Arrays.sort(nums);
        // 获取原数组长度
        int l = nums.length;
        for(int i = 0; i < l - 3; i++){
            // 去重
            if( i > 0 && nums[i] == nums[i-1]){
                continue;
            }
            // 如果当前数加上后面最小的三个数都比target大，直接跳出
            if(nums[i] + nums[i + 1] + nums[i + 2] + nums[i + 3] > target){
                break;
            }
            // 如果当前数加上最大的三个数逗比target小，跳过当前数
            if(nums[i] + nums[l - 3] + nums[l - 2] + nums[l - 1] < target){
                continue;
            }
            // 同上（n数之和直接重复此操作即可）
            for(int j = i + 1; j < l - 2; j++){
                if(j > i + 1 && nums[j] == nums[j - 1]){
                    continue;
                }
                if(nums[i] + nums[j] + nums[j + 1] + nums[j + 2] > target){
                    break;
                }
                if(nums[i] + nums[j] + nums[l - 1] + nums[l - 2] < target){
                    continue;
                }
                // 将n树之和转为两数之和
                int left = j + 1;
                int right = l - 1;
                while(left < right){
                    int sum = nums[i] + nums[j] + nums[left] + nums[right];
                    if(sum == target){
                        // 加入结果集
                      res.add(Arrays.asList(nums[i],nums[j],nums[left],nums[right]));
                        // 去重
                        while(left < right && nums[left] == nums[left + 1]){
                            left++;
                        }
                        left++;
                        // 去重
                        while(left < right && nums[right] == nums[right - 1]){
                            right--;
                        }
                        right--;
                    }else if(sum > target){
                        right--;
                    }else{
                        left++;
                    }
                }
            }
        }
        return res;
    }
}
```

**由三数之和和四数之和可以得出n数之和的解法，思想是一样的，都是枚举，去重，再将最后两个数的和转换为双指针，降低时间复杂度**







