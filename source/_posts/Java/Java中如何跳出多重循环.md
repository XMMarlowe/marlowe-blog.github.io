---
title: Java中如何跳出多重循环
author: Marlowe
tags:
  - Java基础
  - 面经
categories: Java
abbrlink: 4428
date: 2020-12-07 08:20:29
---
Java 基础回顾...
<!--more-->

### 在JAVA中如何跳出当前的多重嵌套循环

在java中，要想跳出多重循环，可以在外面的循环语句前定义一个标号，然后在里层循环体的代码中使用带有标号的的break语句，即可跳出
```java
public static void main(String[] args) {
        ok:
        while (true) {
            for (int i = 0; i < 10000; i++) {
                System.out.println(i);
                if (i == 200) {
                    break ok;
                }
            }
        }
    }
```
### return和 break区别
**break**
break语句虽然可以独立使用，但通常主要用于switch语句中，控制程序的执行流程转移。
在switch语句中，其作用是强制退出switch结构，执行switch结构之后的语句。其本质就是在单层循环结构体系中，其作用是强制退出循环结构。
 
**return** 
return语句用来明确地从一个方法返回。也就是，return 语句使程序控制返回到调用它方法。
因此，将它分类为跳转语句.有两个作用，一个是返回方法指定类型的值（这个值总是确定的）;一个是结束方法的执行（仅仅一个return语句）。return 语句可以使其从当前方法中退出，返回到调用该方法的语句处，继续程序的执行 。

### exit()函数 和 return 区别
exit(0)：正常运行程序并退出程序；
exit(1)：非正常运行导致退出程序；
return()：返回函数，若在主函数中，则会退出函数并返回一值。

具体来说：
1. return返回函数值，是关键字；  exit 是一个函数。
2. return是语言级别的，它表示了调用堆栈的返回；而exit是系统调用级别的，它表示结束一个进程 。
3. return是函数的退出(返回)；exit是进程的退出。
4. return是C语言提供的，exit是操作系统提供的（或者函数库中给出的）。
5. return用于结束一个函数的执行，将函数的执行信息传出个其他调用函数使用；exit函数是退出应用程序，删除进程使用的内存空间，并将应用程序的一个状态返回给OS，这个状态标识了应用程序的一些运行信息，这个信息和机器和操作系统有关，一般是 0 为正常退出， 非0 为非正常退出。
6. 非主函数中调用return和exit效果很明显，但是在main函数中调用return和exit的现象就很模糊，多数情况下现象都是一致的。

### 参考
[在java中如何跳出当前的多重嵌套循环？](https://blog.csdn.net/singit/article/details/47708797)