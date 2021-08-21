---
title: Spring三级缓存
author: Marlowe
tags:
  - Spring
  - 缓存
categories: Spring
abbrlink: 34881
date: 2021-08-20 08:17:14
---

我们都知道 Spring 是通过三级缓存来解决循环依赖的，但是解决循环依赖真的需要使用到三级缓冲吗？只使用两级缓存是否可以呢？本篇文章就 Spring 是如何使用三级缓存解决循环依赖作为引子，验证两级缓存是否可以解决循环依赖。
<!--more-->

### 循环依赖

既然要解决循环依赖，那么就要知道循环依赖是什么。如下图所示：

![20210820081901](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210820081901.png)

通过上图，我们可以看出：

* A 依赖于 B
* B 依赖于 C
* C 依赖于 A

```java
public class A {
    private B b;
}

public class B {
    private C c;
}

public class C {
    private A a;
}
```

这种依赖关系形成了一种闭环，从而造成了循环依赖的局面。

下面是未解决循环依赖的常规步骤：

1. 实例化 A，此时 A 还未完成属性填充和初始化方法（@PostConstruct）的执行。
2. A 对象发现需要注入 B 对象，但是容器中并没有 B 对象（如果对象创建完成并且属性注入完成和执行完初始化方法就会放入容器中）。
3. 实例化 B，此时 B 还未完成属性填充和初始化方法（@PostConstruct）的执行。
4. B 对象发现需要注入 C 对象，但是容器中并没有 C 对象。
5. 实例化 C，此时 C 还未完成属性填充和初始化方法（@PostConstruct）的执行。
6. C 对象发现需要注入 A 对象，但是容器中并没有 A 对象。
7. 重复步骤 1。

### 三级缓存

Spring 解决循环依赖的核心就是提前暴露对象，而提前暴露的对象就是放置于第二级缓存中。下表是三级缓存的说明：

* singletonObjects: 一级缓存，存放完整的 Bean。
* earlySingletonObjects: 二级缓存，存放提前暴露的Bean，Bean 是不完整的，未完成属性注入和执行 init 方法。
* singletonFactories: 三级缓存，存放的是 Bean 工厂，主要是生产 Bean，存放到二级缓存中。

所有被 Spring 管理的 Bean，最终都会存放在 singletonObjects 中，这里面存放的 Bean 是经历了所有生命周期的（除了销毁的生命周期），完整的，可以给用户使用的。

earlySingletonObjects 存放的是已经被实例化，但是还没有注入属性和执行 init 方法的 Bean。

singletonFactories 存放的是生产 Bean 的工厂。

Bean 都已经实例化了，为什么还需要一个生产 Bean 的工厂呢？这里实际上是跟 AOP 有关，如果项目中不需要为 Bean 进行代理，那么这个 Bean 工厂就会直接返回一开始实例化的对象，如果需要使用 AOP 进行代理，那么这个工厂就会发挥重要的作用了，这也是本文需要重点关注的问题之一。

#### 解决循环依赖

Spring 是如何通过上面介绍的三级缓存来解决循环依赖的呢？这里只用 A，B 形成的循环依赖来举例：

1. 实例化 A，此时 A 还未完成属性填充和初始化方法（@PostConstruct）的执行，A 只是一个半成品。
2. 为 A 创建一个 Bean 工厂，并放入到  singletonFactories 中。
3. 发现 A 需要注入 B 对象，但是一级、二级、三级缓存均为发现对象 B。
4. 实例化 B，此时 B 还未完成属性填充和初始化方法（@PostConstruct）的执行，B 只是一个半成品。
5. 为 B 创建一个 Bean 工厂，并放入到  singletonFactories 中。
6. 发现 B 需要注入 A 对象，此时在一级、二级未发现对象 A，但是在三级缓存中发现了对象 A，从三级缓存中得到对象 A，并将对象 A 放入二级缓存中，同时删除三级缓存中的对象 A。（注意，此时的 A 还是一个半成品，并没有完成属性填充和执行初始化方法）
7. 将对象 A 注入到对象 B 中。
8. 对象 B 完成属性填充，执行初始化方法，并放入到一级缓存中，同时删除二级缓存中的对象 B。（此时对象 B 已经是一个成品）
9. 对象 A 得到对象 B，将对象 B 注入到对象 A 中。（对象 A 得到的是一个完整的对象 B）
10. 对象 A 完成属性填充，执行初始化方法，并放入到一级缓存中，同时删除二级缓存中的对象 A。

我们从源码中来分析整个过程：

创建 Bean 的方法在 AbstractAutowireCapableBeanFactory::doCreateBean()

```java
protected Object doCreateBean(final String beanName, final RootBeanDefinition mbd, Object[] args) throws BeanCreationException {
    BeanWrapper instanceWrapper = null;
	
    if (instanceWrapper == null) {
        // ① 实例化对象
        instanceWrapper = this.createBeanInstance(beanName, mbd, args);
    }

    final Object bean = instanceWrapper != null ? instanceWrapper.getWrappedInstance() : null;
    Class<?> beanType = instanceWrapper != null ? instanceWrapper.getWrappedClass() : null;
   
    // ② 判断是否允许提前暴露对象，如果允许，则直接添加一个 ObjectFactory 到三级缓存
	boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
				isSingletonCurrentlyInCreation(beanName));
    if (earlySingletonExposure) {
        // 添加三级缓存的方法详情在下方
        addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
    }

    // ③ 填充属性
    this.populateBean(beanName, mbd, instanceWrapper);
    // ④ 执行初始化方法，并创建代理
    exposedObject = initializeBean(beanName, exposedObject, mbd);
   
    return exposedObject;
}
```

添加三级缓存的方法如下：

```java
protected void addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) {
    Assert.notNull(singletonFactory, "Singleton factory must not be null");
    synchronized (this.singletonObjects) {
        if (!this.singletonObjects.containsKey(beanName)) { // 判断一级缓存中不存在此对象
            this.singletonFactories.put(beanName, singletonFactory); // 添加至三级缓存
            this.earlySingletonObjects.remove(beanName); // 确保二级缓存没有此对象
            this.registeredSingletons.add(beanName);
        }
    }
}

@FunctionalInterface
public interface ObjectFactory<T> {
	T getObject() throws BeansException;
}
```

通过这段代码，我们可以知道 Spring 在实例化对象的之后，就会为其创建一个 Bean 工厂，并将此工厂加入到三级缓存中。

**因此，Spring 一开始提前暴露的并不是实例化的 Bean，而是将 Bean 包装起来的 ObjectFactory。为什么要这么做呢？**

这实际上涉及到 AOP，如果创建的 Bean 是有代理的，那么注入的就应该是代理 Bean，而不是原始的 Bean。但是 Spring 一开始并不知道 Bean 是否会有循环依赖，通常情况下（没有循环依赖的情况下），Spring 都会在完成填充属性，并且执行完初始化方法之后再为其创建代理。但是，如果出现了循环依赖的话，Spring 就不得不为其提前创建代理对象，否则注入的就是一个原始对象，而不是代理对象。因此，这里就涉及到应该在哪里提前创建代理对象？

Spring 的做法就是在 ObjectFactory 中去提前创建代理对象。它会执行 getObject() 方法来获取到 Bean。实际上，它真正执行的方法如下：

```java
protected Object getEarlyBeanReference(String beanName, RootBeanDefinition mbd, Object bean) {
    Object exposedObject = bean;
    if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
        for (BeanPostProcessor bp : getBeanPostProcessors()) {
            if (bp instanceof SmartInstantiationAwareBeanPostProcessor) {
                SmartInstantiationAwareBeanPostProcessor ibp = (SmartInstantiationAwareBeanPostProcessor) bp;
                // 如果需要代理，这里会返回代理对象；否则返回原始对象
                exposedObject = ibp.getEarlyBeanReference(exposedObject, beanName);
            }
        }
    }
    return exposedObject;
}
```

因为提前进行了代理，避免对后面重复创建代理对象，会在 earlyProxyReferences 中记录已被代理的对象。

```java
public abstract class AbstractAutoProxyCreator extends ProxyProcessorSupport
		implements SmartInstantiationAwareBeanPostProcessor, BeanFactoryAware {
    @Override
    public Object getEarlyBeanReference(Object bean, String beanName) {
        Object cacheKey = getCacheKey(bean.getClass(), beanName);
        // 记录已被代理的对象
        this.earlyProxyReferences.put(cacheKey, bean);
        return wrapIfNecessary(bean, beanName, cacheKey);
    }
}
```

**通过上面的解析，我们可以知道 Spring 需要三级缓存的目的是为了在没有循环依赖的情况下，延迟代理对象的创建，使 Bean 的创建符合 Spring 的设计原则。**

#### 如何获取依赖

我们目前已经知道了 Spring 的三级依赖的作用，但是 Spring 在注入属性的时候是如何去获取依赖的呢？

他是通过一个 getSingleton() 方法去获取所需要的 Bean 的。

```java
protected Object getSingleton(String beanName, boolean allowEarlyReference) {
    // 一级缓存
    Object singletonObject = this.singletonObjects.get(beanName);
    if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
        synchronized (this.singletonObjects) {
            // 二级缓存
            singletonObject = this.earlySingletonObjects.get(beanName);
            if (singletonObject == null && allowEarlyReference) {
                // 三级缓存
                ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
                if (singletonFactory != null) {
                    // Bean 工厂中获取 Bean
                    singletonObject = singletonFactory.getObject();
                    // 放入到二级缓存中
                    this.earlySingletonObjects.put(beanName, singletonObject);
                    this.singletonFactories.remove(beanName);
                }
            }
        }
    }
    return singletonObject;
}
```

当 Spring 为某个 Bean 填充属性的时候，它首先会寻找需要注入对象的名称，然后依次执行 getSingleton() 方法得到所需注入的对象，而获取对象的过程就是先从一级缓存中获取，一级缓存中没有就从二级缓存中获取，二级缓存中没有就从三级缓存中获取，如果三级缓存中也没有，那么就会去执行 doCreateBean() 方法创建这个 Bean。

### 二级缓存

我们现在已经知道，第三级缓存的目的是为了延迟代理对象的创建，因为如果没有依赖循环的话，那么就不需要为其提前创建代理，可以将它延迟到初始化完成之后再创建。

既然目的只是延迟的话，那么我们是不是可以不延迟创建，而是在实例化完成之后，就为其创建代理对象，这样我们就不需要第三级缓存了。因此，我们可以将addSingletonFactory() 方法进行改造。

```java
protected void addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) {
    Assert.notNull(singletonFactory, "Singleton factory must not be null");
    synchronized (this.singletonObjects) {
        if (!this.singletonObjects.containsKey(beanName)) { // 判断一级缓存中不存在此对象
            object o = singletonFactory.getObject(); // 直接从工厂中获取 Bean
            this.earlySingletonObjects.put(beanName, o); // 添加至二级缓存中
            this.registeredSingletons.add(beanName);
        }
    }
}
```

这样的话，每次实例化完 Bean 之后就直接去创建代理对象，并添加到二级缓存中。**测试结果是完全正常的，Spring 的初始化时间应该也是不会有太大的影响，因为如果 Bean 本身不需要代理的话，是直接返回原始 Bean 的，并不需要走复杂的创建代理 Bean 的流程。**


### 问题

#### 一级缓存不行

我们看看一级缓存行不行，如果只留第一级缓存，那么单例的Bean都存在singletonObjects 中，Spring循环依赖主要基于Java引用传递，当获取到对象时，对象的field或者属性可以延后设置，理论上可以，但是如果延后设置出了问题，就会导致完整的Bean和不完整的Bean都在一级缓存中，这个引用时就有空指针的可能，所以一级缓存不行，至少要有singletonObjects 和earlySingletonObjects 两级。

#### 二级缓存不行

那么我们再看看两级缓存行不行

**现在有A的field或者setter依赖B的实例对象，同时B的field或者setter依赖了A的实例，A首先开始创建，并将自己暴露到 earlySingletonObjects 中，开始填充属性，此时发现自己依赖B的属性，尝试去get(B)，发现B还没有被创建，所以开始创建B，在进行属性填充时初始化A，就从earlySingletonObjects 中获取到了实例化但没有任何属性的A，B拿到A后完成了初始化阶段，将自己放到singletonObjects中,此时返回A，A拿到B的对象继续完成初始化，完成后将自己放到singletonObjects中，由A与B中所表示的A的属性地址是一样的，所以A的属性填充完后，B也获取了A的属性，这样就解决了循环的问题。**


似乎完美解决，如果就这么使用的话也没什么问题，但是再加上AOP情况就不同了，被AOP增强的Bean会在初始化后代理成为一个新的对象，也就是说：

**如果有AOP，A依赖于B，B依赖于A，A实例化完成暴露出去，开始注入属性，发现引用B，B开始实例化，使用A暴露的对象，初始化完成后封装成代理对象，A再将代理后的B注入，再做代理，那么代理A中的B就是代理后的B，但是代理后的B中的A是没用代理的A。**

显然这是不对的，所以在Spring中存在第三级缓存，在创建对象时判断是否是单例，允许循环依赖，正在创建中，就将其从earlySingletonObjects中移除掉，并在singletonFactories放入新的对象，这样后续再查询beanName时会走到singletonFactory.getObject()，其中就会去调用各个beanPostProcessor的getEarlyBeanReference方法，返回的对象就是代理后的对象。

```java
public abstract class AbstractAutowireCapableBeanFactory extends AbstractBeanFactory
        implements AutowireCapableBeanFactory {    
    
        // Eagerly cache singletons to be able to resolve circular references
        // even when triggered by lifecycle interfaces like BeanFactoryAware.
        boolean earlySingletonExposure = (mbd.isSingleton() && this.allowCircularReferences &&
                isSingletonCurrentlyInCreation(beanName));
        if (earlySingletonExposure) {
            if (logger.isDebugEnabled()) {
                logger.debug("Eagerly caching bean '" + beanName +
                        "' to allow for resolving potential circular references");
            }
            addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
        }

     /**
     * Add the given singleton factory for building the specified singleton
     * if necessary.
     * <p>To be called for eager registration of singletons, e.g. to be able to
     * resolve circular references.
     * @param beanName the name of the bean
     * @param singletonFactory the factory for the singleton object
     */
    protected void addSingletonFactory(String beanName, ObjectFactory<?> singletonFactory) {
        Assert.notNull(singletonFactory, "Singleton factory must not be null");
        synchronized (this.singletonObjects) {
            if (!this.singletonObjects.containsKey(beanName)) {
                this.singletonFactories.put(beanName, singletonFactory);
                this.earlySingletonObjects.remove(beanName);
                this.registeredSingletons.add(beanName);
            }
        }
    }
```

### 结论

测试证明，二级缓存也是可以解决循环依赖的。为什么 Spring 不选择二级缓存，而要额外多添加一层缓存呢？
如果 Spring 选择二级缓存来解决循环依赖的话，那么就意味着所有 Bean 都需要在实例化完成之后就立马为其创建代理，而 Spring 的设计原则是在 Bean 初始化完成之后才为其创建代理。所以，Spring 选择了三级缓存。但是因为循环依赖的出现，导致了 Spring 不得不提前去创建代理，因为如果不提前创建代理对象，那么注入的就是原始对象，这样就会产生错误。

### 参考

[Spring为什么要使用三级缓存解决循环依赖问题](https://segmentfault.com/a/1190000037589596)

[Spring 解决循环依赖必须要三级缓存吗？](https://juejin.cn/post/6882266649509298189)



