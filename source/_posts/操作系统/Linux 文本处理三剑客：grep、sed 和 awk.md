---
title: Linux 文本处理三剑客：grep、sed 和 awk
author: Marlowe
tags: Linux
categories: 操作系统
abbrlink: 35403
date: 2021-07-21 21:27:24
---

awk、grep、sed是linux操作文本的三大利器，合称文本三剑客，也是必须掌握的linux命令之一。三者的功能都是处理文本，但侧重点各不相同，其中属awk功能最强大，但也最复杂。grep更适合单纯的查找或匹配文本，sed更适合编辑匹配到的文本，awk更适合格式化文本，对文本进行较复杂格式处理。

<!--more-->

### grep

Linux 系统中 grep 命令是一种强大的文本搜索工具，它能使用正则表达式搜索文本，并把匹配的行打印出来。grep全称是 Global Regular Expression Print，表示全局正则表达式版本，它的使用权限是所有用户。

grep可用于shell脚本，因为grep通过返回一个状态值来说明搜索的状态，如果模板搜索成功，则返回0，如果搜索不成功，则返回1，如果搜索的文件不存在，则返回2。我们利用这些返回值就可进行一些自动化的文本处理工作。

命令的基本格式：

```bash
grep [option] pattern file
```

即便不熟悉这个命令，应该大多数同学也用过查询进程的命令：

```bash
ps -ef|grep xxxx
```

这就是 grep 的一个基本用法，从所有进程中搜索某个进程。

grep 常用的参数如下：

* -A<行数 x>：除了显示符合范本样式的那一列之外，并显示该行之后的 x 行内容。
* -B<行数 x>：除了显示符合样式的那一行之外，并显示该行之前的 x 行内容。
* -C<行数 x>：除了显示符合样式的那一行之外，并显示该行之前后的 x 行内容。
* -c：统计匹配的行数
* **-e ：实现多个选项间的逻辑or 关系**
* **-E：扩展的正则表达式**
* -f 文件名：从文件获取 PATTERN 匹配
* -F ：相当于fgrep
* -i --ignore-case #忽略字符大小写的差别。
* -n：显示匹配的行号
* -o：仅显示匹配到的字符串
* -q： 静默模式，不输出任何信息
* -s：不显示错误信息。
* **-v：显示不被 pattern 匹配到的行，相当于[^] 反向匹配**
* -w ：匹配 整个单词

前三个 A、B、C 参数很容易理解，举个栗子，假设我们有一个文件，文件名是 test，内容是从 1 到 9，每个数字一行：

```bash
➜ grep -A2 7 test
7
8
9
```
`-A2 7` 的效果就是找到 7 ，然后输出 7 后面两行。

同理，`-B2 7`和`-C2 7`就是找到 7 ，然后分别输出 7 前面两行和前后两行：
```bash
➜ grep -B2 7 test
5
6
7

➜ grep -C2 7 test
5
6
7
8
9
```

继续，假设我们有个名叫 test 的文件内容如下：

```bash
➜ cat test
aaaa
bbbbbb
AAAaaa
BBBBASDABBDA
```

`grep -c`命令的作用就是输出匹配到的行数，比如我们想找包含`aaa`的有几行，一眼就能看出来有两行，第一行和第三行都包含：

```bash
➜ grep -c aaa test
2
```

`grep -e`命令是实现多个匹配之间的或关系，比如我们想找包含`aaaa`或者`bbbb`的，显然应该返回第一行和第二行：

```bash
➜ grep -e aaaa -e bbbb test
aaaa
bbbbbb
```

grep -F相当于fgrep命令，就是将pattern视为固定字符串。比如搜索'aa*'不带-F和带上，区别如下：

```bash
➜ grep 'aa*' test
aaaa
AAAaaa

➜ grep -F 'aa*' test
```


可以看到第二次就找不到了，因为搜索的是 aa*这个字符串，而不是正则表达式。

`grep -f 文件名`的使用方法是把后面这个文件里的内容当做`pattern`。比如我们有个文件，名字是 grep.txt，然后内容是`aa*`，使用方法如下：

```bash
➜ grep -f grep.txt test
aaaa
AAAaaa
```

实际上等同于`grep 'aa*' test`

`grep -i --ignore-case`作用是忽略大小写。

`grep -n`显示匹配的行号，就是多显示了个行号，不用细说。

`grep -o`仅显示匹配到的字符串，还是用刚才的`aa*`距离，之前显示的都是匹配到的字符所在的整行，这个命令是只显示匹配到的字符：

```bash
➜ grep -o 'aa*' test
aaaa
aaa
```

`grep -q`不打印匹配结果。刚看到这个我疑惑了半天，让你搜索字符串，你不给我结果那有啥用？然后发现还有一条很多教程没说：如果有匹配的内容则立即返回状态值 0。所以一般用在`shell`脚本中，在 `if` 判断里面。

`grep -s`不显示错误信息，不解释。

`grep -v`显示不被匹配到的行，相当于[^]反向匹配，最常见的还是用在查找线程的命令里，有时候会打印`grep`线程，可以再加上这么一个去除自己：

```bash
➜ ps -ef|grep Typora
  501 91616     1   0 五11上午 ??        13:39.32 /Applications/Typora.app/Contents/MacOS/Typora
  501 14814 93748   0  5:33下午 ttys002    0:00.00 grep --color=auto --exclude-dir=.bzr --exclude-dir=CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn Typora

➜ ps -ef|grep Typora|grep -v grep
  501 91616     1   0 五11上午 ??        13:39.32 /Applications/Typora.app/Contents/MacOS/Typora
```

可以看到第二次就没有打印grep线程自身

`grep -w`匹配整个单词，只有完全符合pattern的单次才会匹配到：

```bash
➜ grep aaa test
aaaa
AAAaaa

➜ grep -w aaa test
```

可以看到第二次结果为空，因为没有aaa这个单词。

关于正则的高级用法就不再深入研究了，改日再统一整理。

### sed

`sed` 命令的作用是利用脚本来处理文本文件。使用方法：

`sed [-hnV][-e<script>][-f<script文件>][文本文件]`

**参数说明：**

* `-e<script>`或`--expression=<script>` 以选项中指定的 `script` 来处理输入的文本文件，这个`-e`可以省略，直接写表达式。
* `-f<script文件>`或`--file=<script文件>`以选项中指定的 `script` 文件来处理输入的文本文件。
* `-h`或`--help`显示帮助。
* `-n` 或 `--quiet` 或 `--silent` 仅显示 `script` 处理后的结果。
* `-V` 或 `--version` 显示版本信息。

**动作说明：**

* a：新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行)～
* c：取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行！
* d：删除，因为是删除啊，所以 d 后面通常不接任何咚咚；
* i：插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行)；
* p：打印，亦即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运行～
* s：取代，通常这个 s 的动作可以搭配正规表示法，例如 1,20s/old/new/g 。

我们先准备一个文件，名为test做测试，内容如下：

```bash
➜ cat test 
HELLO LINUX!  
Linux is a free unix-type opterating system.  
This is a linux testfile!  
Linux test
```

#### 增加内容

使用命令sed -e 3a\newLine testfile这个命令的意思就是，在第三行后面追加newLine这么一行字符，字符前面要用反斜线作区分。执行完毕之后可以看到结果：

```bash
➜ sed -e 3a\newline test  
HELLO LINUX!  
Linux is a free unix-type opterating system.  
This is a linux testfile!  
newline
Linux test
```

但是注意，这个只是将文字处理了，没有写入到文件里，文件里还是之前的内容。

其实 a 前面是可以匹配字符串，比如我们只想在出现 Linux 的行后面追加，就可以：`sed -e /Linux/a\newline test` 两个斜线之间的内容是需要匹配的内容。可以看出，只有第二、第四行有`Linux`，所以结果如下：

```bash
➜ sed -e /Linux/a\newline test 
HELLO LINUX!  
Linux is a free unix-type opterating system.  
newline
This is a linux testfile!  
Linux test 
newline
```
这里用双引号把整个表达式括起来也可以，还方便处理带空格的字符。

`sed -e /Linux/a\newline test`等效于`sed "/Linux/a newline" test`

#### 插入内容

跟 `a` 类似，`sed 3i\newline test`是在第三行前面插入`newline`:

```bash
➜ sed 3i\newline test
HELLO LINUX!  
Linux is a free unix-type opterating system.  
newline
This is a linux testfile!  
Linux test
```

`sed /Linux/i\newline test`是在所有匹配到`Linux`的行前面插入：

```bash
➜ sed /Linux/i\newline test
HELLO LINUX!  
newline
Linux is a free unix-type opterating system.  
This is a linux testfile!  
newline
Linux test
```

可以看出插入的用法和增加很相似。

#### 删除

删除的字符是`d`，用法跟前面也很相似，就不赘述，例子如下：

```bash
➜ sed '/Linux/d' test      
HELLO LINUX!  
This is a linux testfile!
```

可以看到删除了匹配到的两行。

#### 替换

替换也是一样，字符是`c`。举个栗子：

```bash
➜ sed '/Linux/c\Windows' test                   
HELLO LINUX!  
Windows
This is a linux testfile!  
Windows
```

替换还有个字符是 s，但是用法由不太一样了，最常见的用法：sed 's/old/new/g'其中old代表想要匹配的字符，new是想要替换的字符，比如：

```bash
➜ sed 's/Linux/Windows/g' test
HELLO LINUX!  
Windows is a free unix-type opterating system.  
This is a linux testfile!  
Windows test
```

这里的`/g`的意思是一行中的每一次匹配，因为一行中可能匹配到很多次。我们拿一个新的文本文件做例子：

```bash
➜ cat test2
aaaaaaaaaaa
bbbbbabbbbb
cccccaacccc
```

假设我们想把一行中的第三次及以后出现的`a`变成大写`A`，那应该这么写：

```bash
➜ sed 's/a/A/3g' test2
aaAAAAAAAAA
bbbbbabbbbb
cccccaacccc
```

可以看出只有第一行的有的改了，因为第二第三行没有这么多`a`出现。

关于`s`还有很多用法，还是回到第一个文件，比如可以用`/^/`和`/$/`分别代表行首和行尾：

```bash
➜ sed 's/^/###/g' test
###HELLO LINUX!  
###Linux is a free unix-type opterating system.  
###This is a linux testfile!  
###Linux test 

➜ sed 's/$/---/g' test
HELLO LINUX!  ---
Linux is a free unix-type opterating system.  ---
This is a linux testfile!  ---
Linux test ---
```

这个其实就是正则表达式的语法，其他类似语法还有：

* `^` 表示一行的开头。如：`/^#/` 以#开头的匹配。
* `$` 表示一行的结尾。如：`/}$/` 以}结尾的匹配。
* `\>` 表示词尾。 如：`abc\>` 表示以 abc 結尾的詞。
* `.` 表示任何单个字符。
* `*` 表示某个字符出现了0次或多次。
* `[ ]` 字符集合。 如：`[abc]` 表示匹配a或b或c，还有 `[a-zA-Z]` 表示匹配所有的26个字符。如果其中有^表示反，如 `[^a]` 表示非a的字符

以上的所有用法，还可以在字符前面增加行号或者匹配。什么意思呐？比如你想在第一和第二行后面增加一行内容newline，就是：

```bash
➜ sed '1,2a\newline' test
HELLO LINUX!  
newline
Linux is a free unix-type opterating system.  
newline
This is a linux testfile!  
Linux test
```

其他操作同理。不止可以用数字来限定范围，还可以用匹配来限定，只需要用//括起来：

```bash
➜ sed '/LINUX/,/linux/i\test' test
test
HELLO LINUX!  
test
Linux is a free unix-type opterating system.  
test
This is a linux testfile!  
Linux test
```
这里的意思是，从匹配到`LINUX`的那一行，到匹配到`linux`的那一行，也就是 123 这三行

，都做插入操作。

#### 多个匹配

用`-e`命令可以执行多次匹配，相当于顺序依次执行两个sed命令：

```bash
➜ sed -e 's/Linux/Windows/g' -e 's/Windows/Mac OS/g' test
HELLO LINUX!  
Mac OS is a free unix-type opterating system.  
This is a linux testfile!  
Mac OS test
```

这个命令其实就是先把`Linux`替换成`Windows`，再把`Windows`替换成`Mac OS`。

#### 写入文件

上面介绍的所有文件操作都支持在缓存中处理然后打印到控制台，实际上没有对文件修改。想要保存到原文件的话可以用`> file`或者`-i`来保存到文件。

### awk

awk是一个强大的文本分析工具，相对于grep的查找，sed的编辑，awk在其对数据分析并生成报告时，显得尤为强大。简单来说awk就是把文件逐行的读入，以空格为默认分隔符将每行切片，切开的部分再进行各种分析处理。

#### 语法

```bash
awk [选项参数] 'script' var=value file(s)
或
awk [选项参数] -f scriptfile var=value file(s)
```

**参数说明：**

* -F fs or --field-separator fs 指定输入文件折分隔符，fs是一个字符串或者是一个正则表达式，如-F:。
* -v var=value or --asign var=value 赋值一个用户定义变量。
* -f scripfile or --file scriptfile 从脚本文件中读取awk命令。

#### 基本用法

最基本的用法是`awk 动作 文件名`。我们先准备一个文件`test`：

```bash
➜ cat test 
2 this is a test
3 Are you like awk
This's a test
10 There are orange,apple,mongo
```

然后输入`awk '{print $1,$4}' test`就可以看到：

```bash
2 a
3 like
This's 
10 orange,apple,mongo
```

对比可以很清楚的发现，这行语句的作用是打印每行的第一个和第四个单词。这里如果是$0的话就是把整行都输出出来。

`awk -F`命令可以指定使用哪个分隔符，默认是空格或者 tab 键：

```bash
➜ awk -F, '{print $2}' test



apple
```

可以看出只有最后一行有输出，因为用逗号做分割，之后最后一行被分成了`10 There are orange、apple和mongo`三项，然后我们要的是第二项。

还可以同时使用多个分隔符：

```bash
➜ awk -F '[ ,]'  '{print $1,$2,$5}' test 
2 this test
3 Are awk
This's a 
10 There apple
```

这个例子便是使用空格和逗号两个分隔符。

匹配项中可以用正则表达式，比如：

```bash
➜ awk '/^This/' test
This's a test
```

匹配的就是严格以`This`开头的内容。

还可以取反：

```bash
➜ awk '$0 !~ /is/' test 
3 Are you like awk
10 There are orange,apple,mongo
```

这一个的结果就是去掉带有is的行，只显示其余部分。

从文件中读取：`awk -f {awk脚本} {文件名}`，这个很好理解，就不再做解释。

#### 变量

`awk`中有不少内置的变量，比如`$NF`代表的是分割后的字段数量，相当于取最后一个。

```bash
➜ awk '{print $NF}' test            
test
awk
test
orange,apple,mongo
```

可以看出都是每行的最后一项。

其他的内置变量还有：

* `FILENAME`：当前文件名
* `FS`：字段分隔符，默认是空格和制表符。
* `RS`：行分隔符，用于分割每一行，默认是换行符。
* `OFS`：输出字段的分隔符，用于打印时分隔字段，默认为空格。
* `ORS`：输出记录的分隔符，用于打印时分隔记录，默认为换行符。
* `OFMT`：数字输出的格式，默认为％.6g。

#### 函数

awk还提供了一些内置函数，方便对原始数据的处理。主要如下：

* `toupper()`：字符转为大写。
* `tolower()`：字符转为小写。
* `length()`：返回字符串长度。
* `substr()`：返回子字符串。
* `sin()`：正弦。
* `cos()`：余弦。
* `sqrt()`：平方根。
* `rand()`：随机数。

#### 条件

`awk`允许指定输出条件，只输出符合条件的行。输出条件要写在动作的前面：
```bash
awk '条件 动作' 文件名
```

还是刚才的例子，用逗号分隔之后有好几个空白行，我们加上限制条件，匹配后为空的不显示：

```bash
➜ awk -F, '$2!="" {print $2}' test
apple
```

可以看到就只剩下`apple`了。

#### if 语句

`awk`提供了`if`结构，用于编写复杂的条件。比如：

```bash
➜ awk '{if ($2 > "t") print $1}' test
2
```

这一句的完整含义应该是：把每一行按照空格分割之后，如果第二个单词大于`t`，就输出第一个单词。这里对字符的大小判断应该是基于字符长度和 unicode 编码。

以上这些只是三剑客的基础用法，包括正则表达式也有很多技巧，更多扩展内容网上也很多了，可以自行搜索，或者翻阅下面的参考文章。

### 参考

[Linux 文本处理三剑客：grep、sed 和 awk](https://zhuanlan.zhihu.com/p/110983126)
[SED 简明教程](https://coolshell.cn/articles/9104.html)
[Linux sed 命令](https://www.runoob.com/linux/linux-comm-sed.html)
[Linux awk 命令](https://www.runoob.com/linux/linux-comm-awk.html)
[awk 入门教程](http://www.ruanyifeng.com/blog/2018/11/awk.html)
