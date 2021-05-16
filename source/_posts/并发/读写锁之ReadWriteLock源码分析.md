---
title: 读写锁之ReadWriteLock源码分析
author: Marlowe
tags:
  - ReadWriteLock
  - 源码
categories: 并发
abbrlink: 53041
date: 2021-05-10 19:41:51
---


<!--more-->

ReadWriteLock管理一组锁，一个是只读的锁，一个是写锁。读锁可以在没有写锁的时候被多个线程同时持有，写锁是独占的。
所有读写锁的实现必须确保写操作对读操作的内存影响。换句话说，一个获得了读锁的线程必须能看到前一个释放的写锁所更新的内容。
读写锁比互斥锁允许对于共享数据更大程度的并发。每次只能有一个写线程，但是同时可以有多个线程并发地读数据。ReadWriteLock适用于读多写少的并发情况。
Java并发包中ReadWriteLock是一个接口，主要有两个方法，如下：

```java
public interface ReadWriteLock {
    /**
     * 返回读锁
     */
    Lock readLock();

    /**
     * 返回写锁
     */
    Lock writeLock();
}
```

Java并发库中ReetrantReadWriteLock实现了ReadWriteLock接口并添加了可重入的特性。

### 特性

ReentrantReadWriteLock有如下特性：

* 获取顺序
    * 非公平模式（默认）
    当以非公平初始化时，读锁和写锁的获取的顺序是不确定的。非公平锁主张竞争获取，可能会延缓一个或多个读或写线程，但是会比公平锁有更高的吞吐量。
    * 公平模式
    当以公平模式初始化时，线程将会以队列的顺序获取锁。当当前线程释放锁后，等待时间最长的写锁线程就会被分配写锁；或者有一组读线程组等待时间比写线程长，那么这组读线程组将会被分配读锁。
    当有写线程持有写锁或者有等待的写线程时，一个尝试获取公平的读锁（非重入）的线程就会阻塞。这个线程直到等待时间最长的写锁获得锁后并释放掉锁后才能获取到读锁。
* 可重入
允许读锁可写锁可重入。写锁可以获得读锁，读锁不能获得写锁。
* 锁降级
允许写锁降低为读锁
* 中断锁的获取
在读锁和写锁的获取过程中支持中断
* 支持Condition
写锁提供Condition实现
* 监控
提供确定锁是否被持有等辅助方法

### 使用

下面一段代码展示了锁降低的操作：

```java
class CachedData {
   Object data;
   volatile boolean cacheValid;
   final ReentrantReadWriteLock rwl = new ReentrantReadWriteLock();

   void processCachedData() {
     rwl.readLock().lock();
     if (!cacheValid) {
       // Must release read lock before acquiring write lock
       rwl.readLock().unlock();
       rwl.writeLock().lock();
       try {
         // Recheck state because another thread might have
         // acquired write lock and changed state before we did.
         if (!cacheValid) {
           data = ...
           cacheValid = true;
         }
         // Downgrade by acquiring read lock before releasing write lock
         rwl.readLock().lock();
       } finally {
         rwl.writeLock().unlock(); // Unlock write, still hold read
       }
     }

     try {
       use(data);
     } finally {
       rwl.readLock().unlock();
     }
   }
 }
```
ReentrantReadWriteLock可以用来提高某些集合的并发性能。当集合比较大，并且读比写频繁时，可以使用该类。下面是TreeMap使用ReentrantReadWriteLock进行封装成并发性能提高的一个例子：

```java
class RWDictionary {
   private final Map<String, Data> m = new TreeMap<String, Data>();
   private final ReentrantReadWriteLock rwl = new ReentrantReadWriteLock();
   private final Lock r = rwl.readLock();
   private final Lock w = rwl.writeLock();

   public Data get(String key) {
     r.lock();
     try { return m.get(key); }
     finally { r.unlock(); }
   }
   public String[] allKeys() {
     r.lock();
     try { return m.keySet().toArray(); }
     finally { r.unlock(); }
   }
   public Data put(String key, Data value) {
     w.lock();
     try { return m.put(key, value); }
     finally { w.unlock(); }
   }
   public void clear() {
     w.lock();
     try { m.clear(); }
     finally { w.unlock(); }
   }
 }
```

### 源码分析


#### 构造方法

ReentrantReadWriteLock有两个构造方法，如下：

```java

    public ReentrantReadWriteLock() {
        this(false);
    }

    public ReentrantReadWriteLock(boolean fair) {
        sync = fair ? new FairSync() : new NonfairSync();
        readerLock = new ReadLock(this);
        writerLock = new WriteLock(this);
    }
```
可以看到，默认的构造方法使用的是非公平模式，创建的Sync是NonfairSync对象，然后初始化读锁和写锁。一旦初始化后，ReadWriteLock接口中的两个方法就有返回值了，如下：

```java
public ReentrantReadWriteLock.WriteLock writeLock() { return writerLock; }
    public ReentrantReadWriteLock.ReadLock  readLock()  { return readerLock; }
```
从上面可以看到，构造方法决定了Sync是FairSync还是NonfairSync。Sync继承了AbstractQueuedSynchronizer，而Sync是一个抽象类，NonfairSync和FairSync继承了Sync，并重写了其中的抽象方法。

##### Sync分析

Sync中提供了很多方法，但是有两个方法是抽象的，子类必须实现。下面以FairSync为例，分析一下这两个抽象方法：

```java
static final class FairSync extends Sync {
        private static final long serialVersionUID = -2274990926593161451L;
        final boolean writerShouldBlock() {
            return hasQueuedPredecessors();
        }
        final boolean readerShouldBlock() {
            return hasQueuedPredecessors();
        }
    }
```

writerShouldBlock和readerShouldBlock方法都表示当有别的线程也在尝试获取锁时，是否应该阻塞。
对于公平模式，hasQueuedPredecessors()方法表示前面是否有等待线程。一旦前面有等待线程，那么为了遵循公平，当前线程也就应该被挂起。
下面再来看NonfairSync的实现：

```java
 static final class NonfairSync extends Sync {
        private static final long serialVersionUID = -8159625535654395037L;
        final boolean writerShouldBlock() {
            return false; // writers can always barge
        }
        final boolean readerShouldBlock() {
            /* As a heuristic to avoid indefinite writer starvation,
             * block if the thread that momentarily appears to be head
             * of queue, if one exists, is a waiting writer.  This is
             * only a probabilistic effect since a new reader will not
             * block if there is a waiting writer behind other enabled
             * readers that have not yet drained from the queue.
             */
            return apparentlyFirstQueuedIsExclusive();
        }
    }
```
从上面可以看到，非公平模式下，writerShouldBlock直接返回false，说明不需要阻塞；而readShouldBlock调用了apparentFirstQueuedIsExcluisve()方法。该方法在当前线程是写锁占用的线程时，返回true；否则返回false。也就说明，如果当前有一个写线程正在写，那么该读线程应该阻塞。
继承AQS的类都需要使用state变量代表某种资源，ReentrantReadWriteLock中的state代表了读锁的数量和写锁的持有与否，整个结构如下：

![20210510195218](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210510195218.png)

可以看到state的高16位代表读锁的个数；低16位代表写锁的状态。

#### 获取锁

##### 读锁的获取


当需要使用读锁时，首先调用lock方法，如下：

```java
public void lock() {
            sync.acquireShared(1);
        }

```

从代码可以看到，读锁使用的是AQS的共享模式，AQS的acquireShared方法如下：

```java
 if (tryAcquireShared(arg) < 0)
            doAcquireShared(arg);
```

当tryAcquireShared()方法小于0时，那么会执行doAcquireShared方法将该线程加入到等待队列中。
Sync实现了tryAcquireShared方法，如下：

```java
protected final int tryAcquireShared(int unused) {
            /*
             * Walkthrough:
             * 1. If write lock held by another thread, fail.
             * 2. Otherwise, this thread is eligible for
             *    lock wrt state, so ask if it should block
             *    because of queue policy. If not, try
             *    to grant by CASing state and updating count.
             *    Note that step does not check for reentrant
             *    acquires, which is postponed to full version
             *    to avoid having to check hold count in
             *    the more typical non-reentrant case.
             * 3. If step 2 fails either because thread
             *    apparently not eligible or CAS fails or count
             *    saturated, chain to version with full retry loop.
             */
            Thread current = Thread.currentThread();
            int c = getState();
            //如果当前有写线程并且本线程不是写线程，不符合重入，失败
            if (exclusiveCount(c) != 0 &&
                getExclusiveOwnerThread() != current)
                return -1;
            //得到读锁的个数
            int r = sharedCount(c);
            //如果读不应该阻塞并且读锁的个数小于最大值65535，并且可以成功更新状态值,成功
            if (!readerShouldBlock() &&
                r < MAX_COUNT &&
                compareAndSetState(c, c + SHARED_UNIT)) {
                //如果当前读锁为0
                if (r == 0) {
                    //第一个读线程就是当前线程
                    firstReader = current;
                    firstReaderHoldCount = 1;
                }
                //如果当前线程重入了，记录firstReaderHoldCount
                else if (firstReader == current) {
                    firstReaderHoldCount++;
                }
                //当前读线程和第一个读线程不同,记录每一个线程读的次数
                else {
                    HoldCounter rh = cachedHoldCounter;
                    if (rh == null || rh.tid != getThreadId(current))
                        cachedHoldCounter = rh = readHolds.get();
                    else if (rh.count == 0)
                        readHolds.set(rh);
                    rh.count++;
                }
                return 1;
            }
            //否则，循环尝试
            return fullTryAcquireShared(current);
        }
```

从上面的代码以及注释可以看到，分为三步：

1. 如果当前有写线程并且本线程不是写线程，那么失败，返回-1
2. 否则，说明当前没有写线程或者本线程就是写线程（可重入）,接下来判断是否应该读线程阻塞并且读锁的个数是否小于最小值，并且CAS成功使读锁+1，成功，返回1。其余的操作主要是用于计数的
3. 如果2中失败了，失败的原因有三，第一是应该读线程应该阻塞；第二是因为读锁达到了上线；第三是因为CAS失败，有其他线程在并发更新state，那么会调动fullTryAcquireShared方法。

fullTryAcquiredShared方法如下：

```java
  final int fullTryAcquireShared(Thread current) {
           
            HoldCounter rh = null;
            for (;;) {
                int c = getState();
                //一旦有别的线程获得了写锁，返回-1，失败
                if (exclusiveCount(c) != 0) {
                    if (getExclusiveOwnerThread() != current)
                        return -1;
                } 
                //如果读线程需要阻塞
                else if (readerShouldBlock()) {
                    // Make sure we're not acquiring read lock reentrantly
                    if (firstReader == current) {
                        // assert firstReaderHoldCount > 0;
                    }
                    //说明有别的读线程占有了锁
                    else {
                        if (rh == null) {
                            rh = cachedHoldCounter;
                            if (rh == null || rh.tid != getThreadId(current)) {
                                rh = readHolds.get();
                                if (rh.count == 0)
                                    readHolds.remove();
                            }
                        }
                        if (rh.count == 0)
                            return -1;
                    }
                }
                //如果读锁达到了最大值，抛出异常
                if (sharedCount(c) == MAX_COUNT)
                    throw new Error("Maximum lock count exceeded");
                //如果成功更改状态，成功返回
                if (compareAndSetState(c, c + SHARED_UNIT)) {
                    if (sharedCount(c) == 0) {
                        firstReader = current;
                        firstReaderHoldCount = 1;
                    } else if (firstReader == current) {
                        firstReaderHoldCount++;
                    } else {
                        if (rh == null)
                            rh = cachedHoldCounter;
                        if (rh == null || rh.tid != getThreadId(current))
                            rh = readHolds.get();
                        else if (rh.count == 0)
                            readHolds.set(rh);
                        rh.count++;
                        cachedHoldCounter = rh; // cache for release
                    }
                    return 1;
                }
            }
        }
```
从上面可以看到fullTryAcquireShared与tryAcquireShared有很多类似的地方。
在上面可以看到多次调用了readerShouldBlock方法，对于公平锁，只要队列中有线程在等待，那么将会返回true，也就意味着读线程需要阻塞；对于非公平锁，如果当前有线程获取了写锁，则返回true。一旦不阻塞，那么读线程将会有机会获得读锁。

##### 写锁的获取

写锁的lock方法如下：
```java
 public void lock() {
            sync.acquire(1);
        }
```

AQS的acquire方法如下：

```java
public final void acquire(int arg) {
        if (!tryAcquire(arg) &&
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }
```

从上面可以看到，写锁使用的是AQS的独占模式。首先尝试获取锁，如果获取失败，那么将会把该线程加入到等待队列中。
Sync实现了tryAcquire方法用于尝试获取一把锁，如下：
```java
protected final boolean tryAcquire(int acquires) {
            /*
             * Walkthrough:
             * 1. If read count nonzero or write count nonzero
             *    and owner is a different thread, fail.
             * 2. If count would saturate, fail. (This can only
             *    happen if count is already nonzero.)
             * 3. Otherwise, this thread is eligible for lock if
             *    it is either a reentrant acquire or
             *    queue policy allows it. If so, update state
             *    and set owner.
             */
             //得到调用lock方法的当前线程
            Thread current = Thread.currentThread();
            int c = getState();
            //得到写锁的个数
            int w = exclusiveCount(c);
            //如果当前有写锁或者读锁
            if (c != 0) {
                // 如果写锁为0或者当前线程不是独占线程（不符合重入），返回false
                if (w == 0 || current != getExclusiveOwnerThread())
                    return false;
                //如果写锁的个数超过了最大值，抛出异常
                if (w + exclusiveCount(acquires) > MAX_COUNT)
                    throw new Error("Maximum lock count exceeded");
                // 写锁重入，返回true
                setState(c + acquires);
                return true;
            }
            //如果当前没有写锁或者读锁，如果写线程应该阻塞或者CAS失败，返回false
            if (writerShouldBlock() ||
                !compareAndSetState(c, c + acquires))
                return false;
            //否则将当前线程置为获得写锁的线程,返回true
            setExclusiveOwnerThread(current);
            return true;
        }
```

从代码和注释可以看到，获取写锁时有三步：

1. 如果当前有写锁或者读锁。如果只有读锁，返回false，因为这时如果可以写，那么读线程得到的数据就有可能错误；如果有写锁，但是线程不同，即不符合写锁重入规则，返回false
2. 如果写锁的数量将会超过最大值65535，抛出异常；否则，写锁重入
3. 如果没有读锁或写锁的话，如果需要阻塞或者CAS失败，返回false；否则将当前线程置为获得写锁的线程

从上面可以看到调用了writerShouldBlock方法，FairSync的实现是如果等待队列中有等待线程，则返回false，说明公平模式下，只要队列中有线程在等待，那么后来的这个线程也是需要记入队列等待的；NonfairSync中的直接返回的直接是false，说明不需要阻塞。从上面的代码可以得出，当没有锁时，如果使用的非公平模式下的写锁的话，那么返回false，直接通过CAS就可以获得写锁。

##### 总结

从上面分析可以得出结论：

* 如果当前没有写锁或读锁时，第一个获取锁的线程都会成功，无论该锁是写锁还是读锁。
* 如果当前已经有了读锁，那么这时获取写锁将失败，获取读锁有可能成功也有可能失败
* 如果当前已经有了写锁，那么这时获取读锁或写锁，如果线程相同（可重入），那么成功；否则失败


#### 释放锁

获取锁要做的是更改AQS的状态值以及将需要等待的线程放入到队列中；释放锁要做的就是更改AQS的状态值以及唤醒队列中的等待线程来继续获取锁。

##### 读锁的释放
ReadLock的unlock方法如下：
```java
 public void unlock() {
            sync.releaseShared(1);
        }
```
调用了Sync的releaseShared方法，该方法在AQS中提供，如下：

```java
public final boolean releaseShared(int arg) {
        if (tryReleaseShared(arg)) {
            doReleaseShared();
            return true;
        }
        return false;
    }
```

调用tryReleaseShared方法尝试释放锁，如果释放成功，调用doReleaseShared尝试唤醒下一个节点。
AQS的子类需要实现tryReleaseShared方法，Sync中的实现如下：

```java
 protected final boolean tryReleaseShared(int unused) {
            //得到调用unlock的线程
            Thread current = Thread.currentThread();
            //如果是第一个获得读锁的线程
            if (firstReader == current) {
                // assert firstReaderHoldCount > 0;
                if (firstReaderHoldCount == 1)
                    firstReader = null;
                else
                    firstReaderHoldCount--;
            }
            //否则，是HoldCounter中计数-1
            else {
                HoldCounter rh = cachedHoldCounter;
                if (rh == null || rh.tid != getThreadId(current))
                    rh = readHolds.get();
                int count = rh.count;
                if (count <= 1) {
                    readHolds.remove();
                    if (count <= 0)
                        throw unmatchedUnlockException();
                }
                --rh.count;
            }
            //死循环
            for (;;) {
                int c = getState();
                //释放一把读锁
                int nextc = c - SHARED_UNIT;
                //如果CAS更新状态成功，返回读锁是否等于0；失败的话，则重试
                if (compareAndSetState(c, nextc))
                    // Releasing the read lock has no effect on readers,
                    // but it may allow waiting writers to proceed if
                    // both read and write locks are now free.
                    return nextc == 0;
            }
        }
```

从上面可以看到，释放锁的第一步是更新firstReader或HoldCounter的计数，接下来进入死循环，尝试更新AQS的状态，一旦更新成功，则返回；否则，则重试。
释放读锁对读线程没有影响，但是可能会使等待的写线程解除挂起开始运行。所以，一旦没有锁了，就返回true，否则false；返回true后，那么则需要释放等待队列中的线程，这时读线程和写线程都有可能再获得锁。


##### 写锁的释放

WriteLock的unlock方法如下：
```java
  public void unlock() {
            sync.release(1);
        }
```

Sync的release方法使用的AQS中的，如下：

```java
 public final boolean release(int arg) {
        if (tryRelease(arg)) {
            Node h = head;
            if (h != null && h.waitStatus != 0)
                unparkSuccessor(h);
            return true;
        }
        return false;
    }
```
调用tryRelease尝试释放锁，一旦释放成功了，那么如果等待队列中有线程再等待，那么调用unparkSuccessor将下一个线程解除挂起。
Sync需要实现tryRelease方法，如下：

```java
 protected final boolean tryRelease(int releases) {
            //如果没有线程持有写锁，但是仍要释放，抛出异常
            if (!isHeldExclusively())
                throw new IllegalMonitorStateException();
            int nextc = getState() - releases;
            boolean free = exclusiveCount(nextc) == 0;
            //如果没有写锁了，那么将AQS的线程置为null
            if (free)
                setExclusiveOwnerThread(null);
            //更新状态
            setState(nextc);
            return free;
        }
```

从上面可以看到，写锁的释放主要有三步：

1. 如果当前没有线程持有写锁，但是还要释放写锁，抛出异常
2. 得到解除一把写锁后的状态，如果没有写锁了，那么将AQS的线程置为null
3. 不管第二步中是否需要将AQS的线程置为null，AQS的状态总是要更新的

从上面可以看到，返回true当且只当没有写锁的情况下，还有写锁则返回false。

##### 总结

从上面的分析可以得出：

* 如果当前是写锁被占有了，只有当写锁的数据降为0时才认为释放成功；否则失败。因为只要有写锁，那么除了占有写锁的那个线程，其他线程即不可以获得读锁，也不能获得写锁
* 如果当前是读锁被占有了，那么只有在写锁的个数为0时才认为释放成功。因为一旦有写锁，别的任何线程都不应该再获得读锁了，除了获得写锁的那个线程。

#### 其他方法

看完了ReentrantReadWriteLock中的读锁的获取和释放，写锁的获取和释放，再来看一下其余的一些辅助方法来加深我们对读写锁的理解。

##### getOwner()
getOwner方法用于返回当前获得写锁的线程，如果没有线程占有写锁，那么返回null。实现如下：

```java
 protected Thread getOwner() {
        return sync.getOwner();
    }
```

可以看到直接调用了Sync的getOwner方法，下面是Sync的getOwner方法：

```java
final Thread getOwner() {
            // Must read state before owner to ensure memory consistency
            return ((exclusiveCount(getState()) == 0) ?
                    null :
                    getExclusiveOwnerThread());
        }
```
如果独占锁的个数为0，说明没有线程占有写锁，那么返回null；否则返回占有写锁的线程。

##### getReadLockCount()
getReadLockCount()方法用于返回读锁的个数，实现如下：

```java
public int getReadLockCount() {
        return sync.getReadLockCount();
    }
```

Sync的实现如下：
```java
final int getReadLockCount() {
            return sharedCount(getState());
        }

static int sharedCount(int c)    { return c >>> SHARED_SHIFT; }
```

从上面代码可以看出，要想得到读锁的个数，就是看AQS的state的高16位。这和前面讲过的一样，高16位表示读锁的个数，低16位表示写锁的个数。

##### getReadHoldCount()
getReadHoldCount()方法用于返回当前线程所持有的读锁的个数，如果当前线程没有持有读锁，则返回0。直接看Sync的实现即可：

```java
final int getReadHoldCount() {
            //如果没有读锁，自然每个线程都是返回0
            if (getReadLockCount() == 0)
                return 0;
            
            //得到当前线程
            Thread current = Thread.currentThread();
            //如果当前线程是第一个读线程，返回firstReaderHoldCount参数
            if (firstReader == current)
                return firstReaderHoldCount;
            //如果当前线程不是第一个读线程，得到HoldCounter，返回其中的count
            HoldCounter rh = cachedHoldCounter;
            //如果缓存的HoldCounter不为null并且是当前线程的HoldCounter，直接返回count
            if (rh != null && rh.tid == getThreadId(current))
                return rh.count;
            
            //如果缓存的HoldCounter不是当前线程的HoldCounter，那么从ThreadLocal中得到本线程的HoldCounter，返回计数         
            int count = readHolds.get().count;
            //如果本线程持有的读锁为0，从ThreadLocal中移除
            if (count == 0) readHolds.remove();
            return count;
        }
```

从上面的代码中，可以看到两个熟悉的变量，firstReader和HoldCounter类型。这两个变量在读锁的获取中接触过，前面没有细说，这里细说一下。HoldCounter类的实现如下：

```java
  static final class HoldCounter {
            int count = 0;
            // Use id, not reference, to avoid garbage retention
            final long tid = getThreadId(Thread.currentThread());
        }
```

readHolds是ThreadLocalHoldCounter类，定义如下：

```java
 static final class ThreadLocalHoldCounter
            extends ThreadLocal<HoldCounter> {
            public HoldCounter initialValue() {
                return new HoldCounter();
            }
        }
```

可以看到，readHolds存储了每一个线程的HoldCounter，而HoldCounter中的count变量就是用来记录线程获得的写锁的个数。所以可以得出结论：**Sync维持总的读锁的个数，在state的高16位；由于读线程可以同时存在，所以每个线程还保存了获得的读锁的个数，这个是通过HoldCounter来保存的。**
除此之外，对于第一个读线程有特殊的处理，Sync中有如下两个变量：

```java
 private transient Thread firstReader = null;
        private transient int firstReaderHoldCount;
```

看完了HoldCounter和firstReader，再来看一下getReadLockCount的实现，主要有三步：

1. 当前没有读锁，那么自然每一个线程获得的读锁都是0；
2. 如果当前线程是第一个获取到读锁的线程，那么返回firstReadHoldCount；
3. 如果当前线程不是第一个获取到读锁的线程，得到该线程的HoldCounter，然后返回其count字段。如果count字段为0，说明该线程没有占有读锁，那么从readHolds中移除。获取HoldCounter分为两步，第一步是与cachedHoldCounter比较，如果不是，则从readHolds中获取。

##### getWriteLockCount()
getWriteLockCount()方法返回写锁的个数，Sync的实现如下：

```java
 final int getWriteHoldCount() {
            return isHeldExclusively() ? exclusiveCount(getState()) : 0;
        }
```

可以看到如果没有线程持有写锁，那么返回0；否则返回AQS的state的低16位。

#### 总结

当分析ReentranctReadWriteLock时，或者说分析内部使用AQS实现的工具类时，需要明白的就是AQS的state代表的是什么。ReentrantLockReadWriteLock中的state同时表示写锁和读锁的个数。为了实现这种功能，state的高16位表示读锁的个数，低16位表示写锁的个数。AQS有两种模式：共享模式和独占模式，读写锁的实现中，读锁使用共享模式；写锁使用独占模式；另外一点需要记住的即使，当有读锁时，写锁就不能获得；而当有写锁时，除了获得写锁的这个线程可以获得读锁外，其他线程不能获得读锁。



### 参考

[深入理解读写锁—ReadWriteLock源码分析](https://blog.csdn.net/qq_19431333/article/details/70568478)