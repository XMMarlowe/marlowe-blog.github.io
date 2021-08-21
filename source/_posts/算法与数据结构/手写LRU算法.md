---
title: 手写LRU算法
author: Marlowe
tags: LRU
categories: 算法与数据结构
abbrlink: 21383
date: 2021-08-20 23:33:34
---

<!--more-->

### 题目描述

[146. LRU 缓存机制](https://leetcode-cn.com/problems/lru-cache/)
```
运用你所掌握的数据结构，设计和实现一个  LRU (最近最少使用) 缓存机制 。
实现 LRUCache 类：

LRUCache(int capacity) 以正整数作为容量 capacity 初始化 LRU 缓存
int get(int key) 如果关键字 key 存在于缓存中，则返回关键字的值，否则返回 -1 。
void put(int key, int value) 如果关键字已经存在，则变更其数据值；如果关键字不存在，则插入该组「关键字-值」。当缓存容量达到上限时，它应该在写入新数据之前删除最久未使用的数据值，从而为新的数据值留出空间。
 

进阶：你是否可以在 O(1) 时间复杂度内完成这两种操作？

示例：

输入
["LRUCache", "put", "put", "get", "put", "get", "put", "get", "get", "get"]
[[2], [1, 1], [2, 2], [1], [3, 3], [2], [4, 4], [1], [3], [4]]
输出
[null, null, null, 1, null, -1, null, -1, 3, 4]

解释
LRUCache lRUCache = new LRUCache(2);
lRUCache.put(1, 1); // 缓存是 {1=1}
lRUCache.put(2, 2); // 缓存是 {1=1, 2=2}
lRUCache.get(1);    // 返回 1
lRUCache.put(3, 3); // 该操作会使得关键字 2 作废，缓存是 {1=1, 3=3}
lRUCache.get(2);    // 返回 -1 (未找到)
lRUCache.put(4, 4); // 该操作会使得关键字 1 作废，缓存是 {4=4, 3=3}
lRUCache.get(1);    // 返回 -1 (未找到)
lRUCache.get(3);    // 返回 3
lRUCache.get(4);    // 返回 4
 
提示：

1 <= capacity <= 3000
0 <= key <= 10000
0 <= value <= 105
最多调用 2 * 105 次 get 和 put

```

### 解法1：LinkedHashMap

```java
package com.marlowe.demos;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * @program: JavaThreadDemo
 * @description: LinkedHashMap实现LRU算法
 * @author: Marlowe
 * @create: 2021-08-20 14:18
 **/
public class LRUCacheDemo<K, V> extends LinkedHashMap {

    private int capacity;

    /**
     * initialCapacity – the initial capacity
     * loadFactor – the load factor
     * accessOrder – the ordering mode - true for access-order, false for insertion-order
     *
     * @param capacity
     */
    public LRUCacheDemo(int capacity) {
        super(capacity, 0.75F, true);
        this.capacity = capacity;
    }

    @Override
    protected boolean removeEldestEntry(Map.Entry eldest) {
        return super.size() > capacity;
    }

    public static void main(String[] args) {
        LRUCacheDemo lruCacheDemo = new LRUCacheDemo(3);
        lruCacheDemo.put(1, "a");
        lruCacheDemo.put(2, "b");
        lruCacheDemo.put(3, "c");
        System.out.println(lruCacheDemo.keySet());

        lruCacheDemo.put(4, "d");
        System.out.println(lruCacheDemo.keySet());

        lruCacheDemo.put(3, "c");
        System.out.println(lruCacheDemo.keySet());

        lruCacheDemo.put(3, "c");
        System.out.println(lruCacheDemo.keySet());

        lruCacheDemo.put(3, "c");
        System.out.println(lruCacheDemo.keySet());

        lruCacheDemo.put(5, "x");
        System.out.println(lruCacheDemo.keySet());

    }
}
```

### 解法2：map+双向链表

```java
package com.marlowe.demos;

import java.util.HashMap;
import java.util.Map;


/**
 * @program: JavaThreadDemo
 * @description: 链表+hash实现LRU算法
 * @author: Marlowe
 * @create: 2021-08-20 14:18
 **/
public class LRUCacheDemo1 {

    /**
     * map 负责查找，构建一个虚拟的双向链表，它里面装的就是一个个Node节点，作为数据载体
     */

    /**
     * 1.构造一个Node节点，作为数据载体
     *
     * @param <K>
     * @param <V>
     */
    class Node<K, V> {
        K key;
        V value;
        Node<K, V> prev;
        Node<K, V> next;

        /**
         * 无参构造，初始化节点
         */
        public Node() {
            this.prev = this.next = null;
        }

        /**
         * 有参构造，初始化节点
         *
         * @param key
         * @param value
         */
        public Node(K key, V value) {
            this.key = key;
            this.value = value;
            this.prev = this.next = null;
        }
    }

    /**
     * 2.构建一个虚拟的双向链表,里面安放得就是我们的Node
     *
     * @param <K>
     * @param <V>
     */
    class DoubleLinkedList<K, V> {
        Node<K, V> head;
        Node<K, V> tail;

        /**
         * 2.1构造方法，初始化双向链表
         */
        public DoubleLinkedList() {
            head = new Node<>();
            tail = new Node<>();
            head.next = tail;
            tail.next = head;
        }

        /**
         * 2.2添加到头
         *
         * @param node
         */
        public void addHead(Node<K, V> node) {
            node.next = head.next;
            head.next.prev = node;
            node.prev = head;
            head.next = node;
        }

        /**
         * 2.3 删除节点
         *
         * @param node
         */
        public void removeNode(Node<K, V> node) {
            node.next.prev = node.prev;
            node.prev.next = node.next;
            node.prev = null;
            node.next = null;
        }

        /**
         * 2.4 获取最后一个节点
         *
         * @return
         */
        public Node getLast() {
            return tail.prev;
        }
    }

    /**
     * LRU容量
     */
    private int cacheSize;
    Map<Integer, Node<Integer, Integer>> map;
    DoubleLinkedList<Integer, Integer> doubleLinkedList;

    /**
     * 初始化LRU
     * @param cacheSize
     */
    public LRUCacheDemo1(int cacheSize) {
        this.cacheSize = cacheSize;
        map = new HashMap<>();
        doubleLinkedList = new DoubleLinkedList<>();
    }

    /**
     * 获取值
     *
     * @param key
     * @return
     */
    public int get(int key) {
        if (!map.containsKey(key)) {
            return -1;
        }
        Node<Integer, Integer> node = map.get(key);
        doubleLinkedList.removeNode(node);
        doubleLinkedList.addHead(node);
        return node.value;
    }

    /**
     * 向LRU中放值
     * @param key
     * @param value
     */
    public void put(int key, int value) {
        // 如果map里面有key，更新value值，放回map，并移动到队首
        if (map.containsKey(key)) {
            Node<Integer, Integer> node = map.get(key);
            // 更新node的value
            node.value = value;
            // 更新node
            map.put(key, node);

            // 将当前节点移动到队首
            doubleLinkedList.removeNode(node);
            doubleLinkedList.addHead(node);
        } else {
            if (map.size() == cacheSize) {
                // 如果map满了，map和双向链表都移除最后一个元素
                Node lastNode = doubleLinkedList.getLast();
                // map和链表都移除当前最后一个node
                map.remove(lastNode.key);
                doubleLinkedList.removeNode(lastNode);
            }
            // 如果链表没有满，新建节点并从头部加入
            Node<Integer, Integer> newNode = new Node<>(key, value);
            map.put(key, newNode);
            doubleLinkedList.addHead(newNode);
        }
    }

    public static void main(String[] args) {
        LRUCacheDemo1 lruCacheDemo = new LRUCacheDemo1(3);
        System.out.println("缓存容量:" + lruCacheDemo.cacheSize);
        lruCacheDemo.put(1, 1);
        System.out.println("map大小：" + lruCacheDemo.map.size());
        lruCacheDemo.put(2, 2);
        System.out.println("map大小：" + lruCacheDemo.map.size());
        lruCacheDemo.put(3, 3);
        System.out.println("map大小：" + lruCacheDemo.map.size());

        lruCacheDemo.put(4, 4);
        System.out.println(lruCacheDemo.map.keySet());
        System.out.println("map大小：" + lruCacheDemo.map.size());

        lruCacheDemo.put(3, 3);
        System.out.println(lruCacheDemo.map.keySet());
        System.out.println("map大小：" + lruCacheDemo.map.size());

        lruCacheDemo.put(3, 3);
        System.out.println(lruCacheDemo.map.keySet());
        System.out.println("map大小：" + lruCacheDemo.map.size());

        lruCacheDemo.put(3, 3);
        System.out.println(lruCacheDemo.map.keySet());
        System.out.println("map大小：" + lruCacheDemo.map.size());

        lruCacheDemo.put(5, 5);
        System.out.println(lruCacheDemo.map.keySet());
        System.out.println("map大小：" + lruCacheDemo.map.size());
    }
}
```