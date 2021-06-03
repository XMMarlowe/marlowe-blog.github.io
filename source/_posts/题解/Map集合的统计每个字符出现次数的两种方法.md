---
title: Map集合的统计每个字符出现次数的两种方法
author: Marlowe
tags: HashMap
categories: 题解
abbrlink: 24114
date: 2020-10-12 21:53:51
---

### Map集合的统计每个字符出现次数的两种方法

#### 一、map.containsKey()方法

Map可以出现在k与v的映射中，v为null的情况。Map集合允许值对象为null，并且没有个数限制，所以当get()方法的返回值为null时，可能有两种情况，一种是在集合中没有该键对象，另一种是该键对象没有映射任何值对象，即值对象为null。因此，在Map集合中不应该利用get()方法来判断是否存在某个键，而应该利用containsKey()方法来判断。

```java
	/**
     * map.containsKey()方法
     *
     * @param nums
     */
    public static void test1(int[] nums) {
        HashMap<Integer, Integer> cnt = new HashMap<>();
        for (int num : nums) {
            if (!cnt.containsKey(num)) {
                cnt.put(num, 1);
            } else {
                cnt.put(num, cnt.get(num) + 1);
            }
        }
        // 遍历HashMap
        pnt(cnt);
    }
```

```
原始数组：int[] nums = new int[]{1, 2, 2, 3, 5, 5, 5, 9, 1, 1};
结果：
    1出现的次数：3
    2出现的次数：2
    3出现的次数：1
    5出现的次数：3
    9出现的次数：1
```

#### 二、map.getOrDefault()方法

 当Map集合中有这个key时，就使用这个key值，如果没有就使用默认值defaultValue 。

```java
	/**
     * map.getOrDefault()方法
     *
     * @param nums
     */
    public static void test2(int[] nums) {
        HashMap<Integer, Integer> cnt = new HashMap<>();
        for (int num : nums) {
            cnt.put(num, cnt.getOrDefault(num, 0) + 1);
        }
        // 遍历HashMap
        pnt(cnt);
    }
```

```java
原始数组：int[] nums = new int[]{1, 2, 2, 3, 5, 5, 5, 9, 1, 1};
结果：
    1出现的次数：3
    2出现的次数：2
    3出现的次数：1
    5出现的次数：3
    9出现的次数：1
```

#### 三、demo源代码

```java
import java.util.HashMap;
import java.util.Map;

/**
 * @program: leecode1
 * @description:
 * @author: Marlowe
 * @create: 2020-09-07 15:28
 **/
public class map集合统计每个字符出现的次数 {
    public static void main(String[] args) {
        int[] nums = new int[]{1, 2, 2, 3, 5, 5, 5, 9, 1, 1};
        test1(nums);
        test2(nums);
    }

    /**
     * map.containsKey()方法
     *
     * @param nums
     */
    public static void test1(int[] nums) {
        HashMap<Integer, Integer> cnt = new HashMap<>();
        for (int num : nums) {
            if (!cnt.containsKey(num)) {
                cnt.put(num, 1);
            } else {
                cnt.put(num, cnt.get(num) + 1);
            }
        }
        pnt(cnt);
    }

    /**
     * map.getOrDefault()方法
     *
     * @param nums
     */
    public static void test2(int[] nums) {
        HashMap<Integer, Integer> cnt = new HashMap<>();
        for (int num : nums) {
            cnt.put(num, cnt.getOrDefault(num, 0) + 1);
        }
        pnt(cnt);
    }

    /**
     * 遍历HashMap
     */
    public static void pnt(HashMap<Integer, Integer> map) {
        for (Map.Entry<Integer, Integer> entry : map.entrySet()) {
            int num = entry.getKey();
            int count = entry.getValue();
            System.out.println(num + "出现的次数：" + count);
        }
    }
}
```


