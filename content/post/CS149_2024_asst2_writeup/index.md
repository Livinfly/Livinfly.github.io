---
title: "『学习笔记』CS149 (2024): Assignment 2"
slug: "CS149_2024_asst2_writeup"
authors: ["Livinfly(Mengmm)"]
date: 2025-08-22T16:35:33Z
# 定时发布
# publishDate: 2023-10-01T00:00:00+08:00
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/note/CS149_2024_asst2_writeup"]
categories: ["note"]
tags: ["学习笔记", "CS149", "并行计算"]
description: "Stanford CS149 (2024): Assignment 2 writeup."
image: "cover.jpg" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---

# CS149 (2024): Assignment 2

>   封面来源：[@Ge_DaZuo](https://x.com/Ge_DaZuo/status/1951257475845595443)

> 相关文章：[Stanford-CS149-并行计算-Assignment2-任务执行库 - 知乎](https://zhuanlan.zhihu.com/p/13493010924)、[CS149 Programming Assignment 2 - Scheduling Task Graphs on a Multi-Core CPU | MizukiCry's Blog](https://blog.mizuki.fun/posts/6a4d7d93.html)
>
> C++ 并发帮助的文章：[std::condition_variable.wait()的用法和设计缺陷带来的坑_condition variable wait-CSDN博客](https://blog.csdn.net/TwoTon/article/details/123752423)
>
> 原始实验材料仓库：[stanford-cs149/asst2](https://github.com/stanford-cs149/asst2/tree/842037eb8b544daed6bba37382ab62820f283430)
>
> 我的实现仓库：[Livinfly/15-418u15-618uCS149u](https://github.com/Livinfly/15-418u15-618uCS149u)
>
> 任务推荐资料：
>
> [C++ Interfaces - abstract class 抽象类介绍](https://www.tutorialspoint.com/cplusplus/cpp_interfaces.htm)
>
> [C++ synchronization tutorial 基础的 std::thread, std::mutex, std::condition_variable, std::atomic 使用介绍](https://github.com/stanford-cs149/asst2/blob/842037eb8b544daed6bba37382ab62820f283430/tutorial/README.md)

## 环境

```bash
# 系统版本
uname -a
lsb_release -a
nvidia-smi
cat /proc/cpuinfo
cat /proc/cpuinfo | grep processor | wc -l
# Mac OS
uname -a
sysctl machdep.cpu.brand_string
sysctl hw.physicalcpu
sysctl hw.logicalcpu
```

-   OS: Darwin MacBook-Pro.local 24.1.0 Darwin Kernel Version 24.1.0: Thu Oct 10 21:06:57 PDT 2024; root:xnu-11215.41.3~3/RELEASE_ARM64_T6041 arm64
-   CPU: Apple M4 Pro (14 physicalcpu, 14 logicalcpu)，（10性能和4能效）
-   GPU: 20 Cores
-   Memory: 24 GB
-   Python 3.9.6

（不过不影响，测试同时也在 wsl2 上测试，环境同 asst1）

## Part A: Synchronous Bulk Task Launch

完成类似 ispc task 的功能，任务分成三个类的实现。

因为 pthread 要传递函数参数的话，可能要额外再写个包装函数`void* wrapper_function(void* arg) return NULL;`，再观察到编译 c++ 版本是 c++ 11，决定用 `std::thread` 实现多线程了。

测试和`run_test_harness.py` 统一放到最后。

因为核心数是 10 性能 + 4 能效，所以线程数为 10 时的结果会可能更好。（因为不用等能效核的慢任务）

发现，最大困难是明确要求，初版实现基本都有点偏离要求了，写晕了。（不过也就懒得删，放实现仓库了，以 `.bak` 结尾的 `tasksys` 文件）

参考其他人的实现，重新搞清楚了要求。

### TaskSystemParallelSpawn

固定最大工作线程数，每次在 `run` 的时候创建，只创建最大工作线程数次。

```cpp
// tasksys.h

#include <atomic>
#include <thread>

class TaskSystemParallelSpawn : public ITaskSystem {
   private:
    int _num_threads;
    std::thread* _threads_worker;
};

// tasksys.cpp

TaskSystemParallelSpawn::TaskSystemParallelSpawn(int num_threads)
    : ITaskSystem(num_threads),
      _num_threads(num_threads),
      _threads_worker(new std::thread[num_threads]) {}

TaskSystemParallelSpawn::~TaskSystemParallelSpawn() {
    delete[] _threads_worker;
}

void TaskSystemParallelSpawn::run(IRunnable *runnable, int num_total_tasks) {
    std::atomic<int> task_id(0);

    auto work = [&task_id, &runnable, &num_total_tasks]() {
        // 可以批量处理，减少原子操作
        // const int BATCH_SIZE = 16;
        while (true) {
            int id = task_id.fetch_add(1);
            if (id >= num_total_tasks) break;
            runnable->runTask(id, num_total_tasks);

            // 可以批量处理，减少原子操作
            // int start_id = task_id.fetch_add(BATCH_SIZE);
            // if (start_id >= num_total_tasks) break;
            // int end_id = std::min(start_id + BATCH_SIZE, num_total_tasks);
            // for (int id = start_id; id < end_id; id++) {
            //     runnable->runTask(id, num_total_tasks);
            // }
        }
    };

    for (int i = 0; i < _num_threads; i++) {
        _threads_worker[i] = std::thread(work);
    }
    for (int i = 0; i < _num_threads; i++) {
        _threads_worker[i].join();
    }
}
```

### TaskSystemParallelThreadPoolSpinning

构建类的时候就创建好最大工作线程（线程池），在类析构的时候才停止工作进程，线程等待的时候，选择 spin，即 `while(!condition);`。

```cpp
// tasksys.h

#include <atomic>
#include <mutex>
#include <thread>

class TaskSystemParallelThreadPoolSpinning : public ITaskSystem {
private:
    int _num_threads;
    std::thread* _threads_worker;
    // run_info
    bool _end;
    IRunnable* _runnable;
    int _num_total_tasks;
    int _current_task_id;
    std::mutex* _mtx;
    std::atomic<int> _num_done_tasks;
};

// tasksys.cpp

TaskSystemParallelThreadPoolSpinning::TaskSystemParallelThreadPoolSpinning(
    int num_threads)
    : ITaskSystem(num_threads),
      _num_threads(num_threads),
      _threads_worker(new std::thread[num_threads]),
      _end(false),
      _runnable(nullptr),
      _mtx(new std::mutex) {
    auto work = [&]() {
        while (true) {
            IRunnable *runnable = nullptr;
            int task_id;
            _mtx->lock();
            if (_runnable) {
                runnable = _runnable;
                task_id = _current_task_id++;
                if (_current_task_id >= _num_total_tasks) _runnable = nullptr;
            }
            bool is_end = _end;
            _mtx->unlock();
            if (runnable) {
                runnable->runTask(task_id, _num_total_tasks);
                _num_done_tasks.fetch_add(1);
            } else if (is_end) {
                break;
            }
        }
    };
    for (int i = 0; i < _num_threads; i++) {
        _threads_worker[i] = std::thread(work);
    }
}

TaskSystemParallelThreadPoolSpinning::~TaskSystemParallelThreadPoolSpinning() {
    _mtx->lock();
    _end = true;
    _mtx->unlock();
    for (int i = 0; i < _num_threads; i++) {
        _threads_worker[i].join();
    }
    delete[] _threads_worker;
    delete _mtx;
}

void TaskSystemParallelThreadPoolSpinning::run(IRunnable *runnable,
                                               int num_total_tasks) {

    _mtx->lock();
    _runnable = runnable;
    _num_total_tasks = num_total_tasks;
    _current_task_id = 0;
    _num_done_tasks = 0;
    _mtx->unlock();

    while (_num_done_tasks < _num_total_tasks);
}
```

### TaskSystemParallelThreadPoolSleeping

在 `TaskSystemParallelThreadPoolSpinning` 的基础上，使用 `std::condition_variable` 降低 spin 带来的开销。

提示可以添加在**工作线程没任务做**和**主线程等待工作线程完成任务**这两个阶段。

这里保留了其他实现与调试的注释。

调试过程中，对 `std::mutex`, `std::condition_variable` 逐渐有了些感觉。

（不过像什么 生产者-消费者 模型，只是知道，还没有去实现学习，~~咕咕~~）

这里主要原因是，主线程的等待好像用条件变量，会慢不少，所以保留了（我也不再细究这个情况了）

这种多线程并发的程序调试，感觉很大程度还是需要用输出调试来调，有些时候稍微顺序错位一点点在几次测试中可能并不会出错。

有输出可以更加清楚的知道，运行的情况。

比如我保留的注释，让我发现在 `super_super_light` 测试中，可能在主线程开始等待前，工作线程就做完了等情况。

后面也学着把会被别的线程修改的数据先读到本地，然后在释放锁之后，再做处理。

又可以避免忘记释放锁，也能在后面再使用的时候更加安全。



推荐 [std::condition_variable.wait()的用法和设计缺陷带来的坑_condition variable wait-CSDN博客](https://blog.csdn.net/TwoTon/article/details/123752423) 的同时，

这里再简单说说我对 `std::condition_variable` 粗浅认识：

（如有错误，敬请指正，最好附上代码案例）

主要分为 `wait(unique_lock, [condition])` 和 `notify_one() / notify_all()`。

-   `wait(unique_lock, [condition])`

    需要在 `wait()` 之前，该线程有获得 / 锁上 `unique_lock` 这个锁。

    到 `wait()` 的时候，会检测条件是否符合：

    -   符合，不会堵塞，继续运行；

    -   不符合，会堵塞，等待其他线程唤醒 `notify_*()`。

        唤醒后再判断条件是否符合，以此类推。

    因此，可以等价于 `while(!condition) {wait();}`。

    这里的 `wait()` 就是事实的堵塞，被唤醒后，继续进行循环条件的判断。

    所以，如果恒为真，就不会堵塞，恒为假就永远堵塞。

    因此，对于工作线程的 `std::condition_variale` 只要在最开始执行一次 `notify_all()`，

    然后就会把这一批次执行完了，不需要在内部再反复 `notify_*()` 了。

-   `notify_one() / notify_all()`

    随机唤醒一个等待线程 / 唤醒所有等待线程。

    `notify_*()` 和释放当前锁的先后。

    从结果上来说是都可以，不过先释放锁，在 `notify_*()` 可以减少一步竞争锁这一步（大概？）

```cpp
// tasksys.h

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <thread>

class TaskSystemParallelThreadPoolSleeping : public ITaskSystem {
private:
    int _num_threads;
    std::thread* _threads_worker;
    // run_info
    bool _end;
    IRunnable* _runnable;
    int _num_total_tasks;
    int _current_task_id;
    int _num_done_tasks;
    std::mutex *_mtx, *_mtx_done;
    std::condition_variable *_cv, *_cv_done;
}

// tasksys.cpp

TaskSystemParallelThreadPoolSleeping::TaskSystemParallelThreadPoolSleeping(
    int num_threads)
    : ITaskSystem(num_threads),
      _num_threads(num_threads),
      _threads_worker(new std::thread[num_threads]),
      _end(false),
      _runnable(nullptr),
      _mtx(new std::mutex),
      _mtx_done(new std::mutex),
      _cv(new std::condition_variable),
      _cv_done(new std::condition_variable) {
    auto work = [&]() {
        while (true) {
            IRunnable *runnable = nullptr;
            int task_id;
            std::unique_lock<std::mutex> lk(*_mtx);
            _cv->wait(lk, [&]() { return _runnable || _end; });
            if (_runnable) {
                runnable = _runnable;
                task_id = _current_task_id++;
                if (_current_task_id >= _num_total_tasks) _runnable = nullptr;
            }
            bool is_end = _end;
            lk.unlock();
            if (runnable) {
                runnable->runTask(task_id, _num_total_tasks);
                // 需要 lock，不然可能主线程还没开始 wait
                // 这边的通知就已经发出去了（任务特别轻的时候
                // super_super_light）
                _mtx_done->lock();
                _num_done_tasks++;
                // printf("%d\n", _num_done_tasks);

                // 1
                // bool is_done = _num_done_tasks >= _num_total_tasks;
                _mtx_done->unlock();
                // if (is_done) {
                //     // puts("done 0");
                //     _cv_done->notify_one();
                // }
                // 2
                // _cv_done->notify_one();
            } else if (is_end) {
                break;
            }
        }
    };
    for (int i = 0; i < _num_threads; i++) {
        _threads_worker[i] = std::thread(work);
    }
}

TaskSystemParallelThreadPoolSleeping::~TaskSystemParallelThreadPoolSleeping() {
    _mtx->lock();
    _end = true;
    _mtx->unlock();
    _cv->notify_all();
    for (int i = 0; i < _num_threads; i++) {
        _threads_worker[i].join();
    }
    delete[] _threads_worker;
    delete _mtx;
    delete _mtx_done;
    delete _cv;
    delete _cv_done;
}

void TaskSystemParallelThreadPoolSleeping::run(IRunnable *runnable,
                                               int num_total_tasks) {
    // 要先为 wait 获取锁，堵塞后释放
    
    // 1, 2
    // std::unique_lock<std::mutex> lk_done(*_mtx_done);
    {
        std::unique_lock<std::mutex> lk(*_mtx);
        _runnable = runnable;
        _num_total_tasks = num_total_tasks;
        _current_task_id = 0;
        _num_done_tasks = 0;
    }
    _cv->notify_all();

    // puts("wait");

    // 1
    // _cv_done->wait(lk_done);
    // 2
    // _cv_done->wait(lk_done,
    //                [&]() { return _num_done_tasks >= _num_total_tasks; });
    // 3
    while (true) {
        _mtx_done->lock();
        bool is_done = _num_done_tasks >= _num_total_tasks;
        _mtx_done->unlock();
        if (is_done) break;
    }

    // puts("done 1");
}
```

### 测试

~~加测试还是算了，看看测试得了~~

我调试调出比较多问题的就是 `super_super_light` 了，具体测试的任务，见 `tests/README.md`，找到适合调试的测试，或试着自己创建测试。

```cpp
// tests/main.cpp

// TODO: do this better
if (j + 1 == num_timing_iterations) {
    printf("[%s]:\t\t[%.3f] ms\n", t->name(), minT * 1000);
    // 更多的信息显示
    // 然而 run_test_harness 需要保持输出格式不能出现太多变化
    // printf(
    //     "[%-30s]:  min=%8.3f ms, max=%8.3f ms, avg=%8.3f "
    //     "ms\n",
    //     t->name(), minT * 1000, maxT * 1000,
    //     avgT * 1000 / num_timing_iterations);
}
```

后面就是具体的测试了，展示两个测试结果：

本机 MacOS 的运行结果，我前面发布的 Assignment 1 的 wsl2 的测试结果。

不知道什么缘故，MacOS 跑得很奇怪，不能过的测试的情况，甚至不需要改的串行，打不过参照版本。

**记得把对应的 ref 可执行文件设置执行权限**

MacOS 的测试结果：

```bash
# python3 ../tests/run_test_harness.py

# MacOS
runtasks_ref
Darwin arm64
================================================================================
Running task system grading harness... (11 total tests)
  - Detected CPU with 14 execution contexts
  - Task system configured to use at most 14 threads
================================================================================
================================================================================
Executing test: super_super_light...
Reference binary: ./runtasks_ref_osx_arm
Results for: super_super_light
                                        STUDENT   REFERENCE   PERF?
[Serial]                                3.333     3.388       0.98  (OK)
[Parallel + Always Spawn]               40.791    41.765      0.98  (OK)
[Parallel + Thread Pool + Spin]         30.702    60.015      0.51  (OK)
[Parallel + Thread Pool + Sleep]        23.379    23.475      1.00  (OK)
================================================================================
Executing test: super_light...
Reference binary: ./runtasks_ref_osx_arm
Results for: super_light
                                        STUDENT   REFERENCE   PERF?
[Serial]                                13.892    18.94       0.73  (OK)
[Parallel + Always Spawn]               49.262    50.518      0.98  (OK)
[Parallel + Thread Pool + Spin]         34.876    85.981      0.41  (OK)
[Parallel + Thread Pool + Sleep]        32.64     31.334      1.04  (OK)
================================================================================
Executing test: ping_pong_equal...
Reference binary: ./runtasks_ref_osx_arm
Results for: ping_pong_equal
                                        STUDENT   REFERENCE   PERF?
[Serial]                                233.014   372.162     0.63  (OK)
[Parallel + Always Spawn]               70.801    89.837      0.79  (OK)
[Parallel + Thread Pool + Spin]         55.278    118.816     0.47  (OK)
[Parallel + Thread Pool + Sleep]        49.07     64.635      0.76  (OK)
================================================================================
Executing test: ping_pong_unequal...
Reference binary: ./runtasks_ref_osx_arm
Results for: ping_pong_unequal
                                        STUDENT   REFERENCE   PERF?
[Serial]                                687.359   529.064     1.30  (NOT OK)
[Parallel + Always Spawn]               112.08    96.883      1.16  (OK)
[Parallel + Thread Pool + Spin]         109.983   132.2       0.83  (OK)
[Parallel + Thread Pool + Sleep]        94.275    72.262      1.30  (NOT OK)
================================================================================
Executing test: recursive_fibonacci...
Reference binary: ./runtasks_ref_osx_arm
Results for: recursive_fibonacci
                                        STUDENT   REFERENCE   PERF?
[Serial]                                917.397   908.294     1.01  (OK)
[Parallel + Always Spawn]               88.143    87.136      1.01  (OK)
[Parallel + Thread Pool + Spin]         93.761    91.151      1.03  (OK)
[Parallel + Thread Pool + Sleep]        90.891    87.237      1.04  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop
                                        STUDENT   REFERENCE   PERF?
[Serial]                                206.775   208.574     0.99  (OK)
[Parallel + Always Spawn]               247.204   248.615     0.99  (OK)
[Parallel + Thread Pool + Spin]         142.73    337.597     0.42  (OK)
[Parallel + Thread Pool + Sleep]        115.278   104.963     1.10  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fewer_tasks...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_fewer_tasks
                                        STUDENT   REFERENCE   PERF?
[Serial]                                206.505   208.375     0.99  (OK)
[Parallel + Always Spawn]               236.613   236.781     1.00  (OK)
[Parallel + Thread Pool + Spin]         152.883   317.297     0.48  (OK)
[Parallel + Thread Pool + Sleep]        107.491   93.697      1.15  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fan_in...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_fan_in
                                        STUDENT   REFERENCE   PERF?
[Serial]                                106.303   107.268     0.99  (OK)
[Parallel + Always Spawn]               38.578    39.553      0.98  (OK)
[Parallel + Thread Pool + Spin]         29.772    59.795      0.50  (OK)
[Parallel + Thread Pool + Sleep]        25.858    23.483      1.10  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_reduction_tree...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_reduction_tree
                                        STUDENT   REFERENCE   PERF?
[Serial]                                106.5     107.555     0.99  (OK)
[Parallel + Always Spawn]               17.227    16.92       1.02  (OK)
[Parallel + Thread Pool + Spin]         15.236    18.473      0.82  (OK)
[Parallel + Thread Pool + Sleep]        13.976    12.774      1.09  (OK)
================================================================================
Executing test: spin_between_run_calls...
Reference binary: ./runtasks_ref_osx_arm
Results for: spin_between_run_calls
                                        STUDENT   REFERENCE   PERF?
[Serial]                                325.933   329.414     0.99  (OK)
[Parallel + Always Spawn]               168.387   166.579     1.01  (OK)
[Parallel + Thread Pool + Spin]         172.841   172.559     1.00  (OK)
[Parallel + Thread Pool + Sleep]        170.135   166.414     1.02  (OK)
================================================================================
Executing test: mandelbrot_chunked...
Reference binary: ./runtasks_ref_osx_arm
Results for: mandelbrot_chunked
                                        STUDENT   REFERENCE   PERF?
[Serial]                                234.344   238.415     0.98  (OK)
[Parallel + Always Spawn]               23.441    23.949      0.98  (OK)
[Parallel + Thread Pool + Spin]         24.577    24.065      1.02  (OK)
[Parallel + Thread Pool + Sleep]        23.558    23.893      0.99  (OK)
================================================================================
Overall performance results
[Serial]                                : Perf did not pass all tests
[Parallel + Always Spawn]               : All passed Perf
[Parallel + Thread Pool + Spin]         : All passed Perf
[Parallel + Thread Pool + Sleep]        : Perf did not pass all tests
```

接下来是 wsl2 的测试结果：

```bash
# python3 ../tests/run_test_harness.py

# Linux (wsl2)
runtasks_ref
Linux x86_64
================================================================================
Running task system grading harness... (11 total tests)
  - Detected CPU with 16 execution contexts
  - Task system configured to use at most 16 threads
================================================================================
================================================================================
Executing test: super_super_light...
Reference binary: ./runtasks_ref_linux
Results for: super_super_light
                                        STUDENT   REFERENCE   PERF?
[Serial]                                8.802     13.128      0.67  (OK)
[Parallel + Always Spawn]               605.881   598.953     1.01  (OK)
[Parallel + Thread Pool + Spin]         17.418    29.269      0.60  (OK)
[Parallel + Thread Pool + Sleep]        130.41    128.733     1.01  (OK)
================================================================================
Executing test: super_light...
Reference binary: ./runtasks_ref_linux
Results for: super_light
                                        STUDENT   REFERENCE   PERF?
[Serial]                                77.868    82.437      0.94  (OK)
[Parallel + Always Spawn]               600.781   603.958     0.99  (OK)
[Parallel + Thread Pool + Spin]         23.272    35.303      0.66  (OK)
[Parallel + Thread Pool + Sleep]        121.364   121.066     1.00  (OK)
================================================================================
Executing test: ping_pong_equal...
Reference binary: ./runtasks_ref_linux
Results for: ping_pong_equal
                                        STUDENT   REFERENCE   PERF?
[Serial]                                1258.518  1328.074    0.95  (OK)
[Parallel + Always Spawn]               644.312   653.419     0.99  (OK)
[Parallel + Thread Pool + Spin]         252.352   280.218     0.90  (OK)
[Parallel + Thread Pool + Sleep]        252.865   278.068     0.91  (OK)
================================================================================
Executing test: ping_pong_unequal...
Reference binary: ./runtasks_ref_linux
Results for: ping_pong_unequal
                                        STUDENT   REFERENCE   PERF?
[Serial]                                1835.189  1872.283    0.98  (OK)
[Parallel + Always Spawn]               678.557   682.423     0.99  (OK)
[Parallel + Thread Pool + Spin]         293.994   320.018     0.92  (OK)
[Parallel + Thread Pool + Sleep]        300.234   312.32      0.96  (OK)
================================================================================
Executing test: recursive_fibonacci...
Reference binary: ./runtasks_ref_linux
Results for: recursive_fibonacci
                                        STUDENT   REFERENCE   PERF?
[Serial]                                1053.251  1858.459    0.57  (OK)
[Parallel + Always Spawn]               163.893   227.547     0.72  (OK)
[Parallel + Thread Pool + Spin]         161.371   238.919     0.68  (OK)
[Parallel + Thread Pool + Sleep]        156.074   207.127     0.75  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop
                                        STUDENT   REFERENCE   PERF?
[Serial]                                668.082   666.432     1.00  (OK)
[Parallel + Always Spawn]               3089.146  3064.197    1.01  (OK)
[Parallel + Thread Pool + Spin]         213.058   250.838     0.85  (OK)
[Parallel + Thread Pool + Sleep]        607.31    605.516     1.00  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fewer_tasks...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_fewer_tasks
                                        STUDENT   REFERENCE   PERF?
[Serial]                                668.517   666.362     1.00  (OK)
[Parallel + Always Spawn]               3067.389  3094.792    0.99  (OK)
[Parallel + Thread Pool + Spin]         209.684   243.559     0.86  (OK)
[Parallel + Thread Pool + Sleep]        608.357   611.346     1.00  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fan_in...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_fan_in
                                        STUDENT   REFERENCE   PERF?
[Serial]                                343.895   345.364     1.00  (OK)
[Parallel + Always Spawn]               400.428   400.808     1.00  (OK)
[Parallel + Thread Pool + Spin]         62.778    76.579      0.82  (OK)
[Parallel + Thread Pool + Sleep]        86.475    99.433      0.87  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_reduction_tree...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_reduction_tree
                                        STUDENT   REFERENCE   PERF?
[Serial]                                341.52    341.368     1.00  (OK)
[Parallel + Always Spawn]               114.191   115.154     0.99  (OK)
[Parallel + Thread Pool + Spin]         51.682    56.073      0.92  (OK)
[Parallel + Thread Pool + Sleep]        59.162    59.922      0.99  (OK)
================================================================================
Executing test: spin_between_run_calls...
Reference binary: ./runtasks_ref_linux
Results for: spin_between_run_calls
                                        STUDENT   REFERENCE   PERF?
[Serial]                                370.866   656.866     0.56  (OK)
[Parallel + Always Spawn]               193.432   337.548     0.57  (OK)
[Parallel + Thread Pool + Spin]         327.29    474.147     0.69  (OK)
[Parallel + Thread Pool + Sleep]        187.028   333.137     0.56  (OK)
================================================================================
Executing test: mandelbrot_chunked...
Reference binary: ./runtasks_ref_linux
Results for: mandelbrot_chunked
                                        STUDENT   REFERENCE   PERF?
[Serial]                                431.728   429.047     1.01  (OK)
[Parallel + Always Spawn]               32.047    32.035      1.00  (OK)
[Parallel + Thread Pool + Spin]         33.911    33.334      1.02  (OK)
[Parallel + Thread Pool + Sleep]        33.27     31.475      1.06  (OK)
================================================================================
Overall performance results
[Serial]                                : All passed Perf
[Parallel + Always Spawn]               : All passed Perf
[Parallel + Thread Pool + Spin]         : All passed Perf
[Parallel + Thread Pool + Sleep]        : All passed Perf
```

## Part B: Supporting Execution of Task Graphs

实现异步的**任务图**。

并发这一部分还是挺折磨的，虽然其实就几项东西，但常常写挂，又要调试（我是输出调试了大部分都保留在代码中，有大佬说可以试试 C++ 有的日志库，可能可以节省点精力），特别是在修了一个地方后，发现修假了，只是奇妙正确了，然后继续修；改写法之后，之前改对又变成改错的。

所以，这一部分实现，再确定正确性没有什么问题之后，性能部分可能确实有点犯懒跑路了，~~咕咕~~。



因为有很多类任务，而前面的实现，有一系列参数都是给一类任务完成使用的。

所以，我们能够想到为一类任务，创建一个专属的结构体；对于最后的析构和同步，则是另一部分参数。



前期主要用 `simple_test_async` 在后面大部分时候使用 `super_light_async`  查问题。



说思路感觉有些繁杂，没有理出一条简洁的思考线路来，简单提一下遇到的几个坑吧。

关于测试的，记得最后用异步的测试去测异步啊（x

映射的 `TaskInfo` 和 `_task_executable_list` 的 `TaskInfo` 的信息同步更新。

有些正确性问题，默认的 `run_test_harness.py` 并不能测出来，建议增加一下全都测一遍正确性。

（简单应该就在该文件中的 `LIST_OF_TESTS` 增加些测试字段就好）

```cpp
// tasksys.h

#include <algorithm>
#include <condition_variable>
#include <list>
#include <mutex>
#include <thread>
#include <unordered_map>
#include <vector>

class TaskSystemParallelThreadPoolSleeping : public ITaskSystem {
private:
    struct TaskInfo {  // 具体任务的完成情况
        TaskID _idx;   // 任务编号
        IRunnable* runnable;
        int _num_total_tasks;
        int _current_task_id;  // id 用于同类任务的执行进度标识
        int _num_done_tasks;
        int _num_deps;                     // 依赖的任务数
        std::vector<TaskID> _successores;  // 后继
    };
    int _num_threads;
    std::thread* _threads_worker;
    bool _end;
    // 当前最大的任务类编号, idx 用于不同任务种类
    int _current_task_idx;
    // 任务编号到具体任务完成情况的映射
    // 一开始是指还有依赖的任务的映射，后面改错时变成单纯的映射关系了
    // 这里就懒得改变量名了
    std::unordered_map<TaskID, TaskInfo> _task_waiting_map;
    // 已经可以执行的任务列表
    std::list<TaskInfo*> _task_executable_list;
    std::mutex *_mtx, *_mtx_done;
    std::condition_variable *_cv, *_cv_done;
}

// tasksys.cpp

TaskSystemParallelThreadPoolSleeping::TaskSystemParallelThreadPoolSleeping(
    int num_threads)
    : ITaskSystem(num_threads),
      _num_threads(num_threads),
      _threads_worker(new std::thread[num_threads]),
      _end(false),
      _current_task_idx(0),
      _mtx(new std::mutex),
      _mtx_done(new std::mutex),
      _cv(new std::condition_variable),
      _cv_done(new std::condition_variable) {
    auto work = [&]() {
        while (true) {
            std::unique_lock<std::mutex> lk(*_mtx);
            _cv->wait(lk,
                      [&]() { return !_task_executable_list.empty() || _end; });
            if (_end) return;

            auto iter_iter_task = std::find_if(
                _task_executable_list.begin(), _task_executable_list.end(),
                [](const TaskInfo* t) {
                    return t->_current_task_id < t->_num_total_tasks;
                });
            if (iter_iter_task == _task_executable_list.end()) {
                // cv
                // all_work_dispatched
                continue;
            }

            TaskInfo* iter_task = *iter_iter_task;

            int id_cur = iter_task->_current_task_id++;
            lk.unlock();

            iter_task->runnable->runTask(id_cur, iter_task->_num_total_tasks);

            lk.lock();
            bool is_empty = false;
            iter_task->_num_done_tasks++;
            // printf("task_idx: %d -> num_done_tasks: %d\n", iter_task->_idx,
            //        iter_task->_num_done_tasks);
            if (iter_task->_num_done_tasks == iter_task->_num_total_tasks) {
                for (TaskID successor : iter_task->_successores) {
                    // printf("task_idx: %d -> successor: %d\n",
                    // iter_task->_idx,
                    //        successor);
                    if (--_task_waiting_map[successor]._num_deps == 0) {
                        _task_executable_list.push_back(
                            (TaskInfo*)&_task_waiting_map[successor]);
                        // 原本指还有依赖的任务，所以erase，但是现在不是（x
                        // _task_waiting_map.erase(successor);
                    }
                }
                // printf("done task_idx: %d\n", iter_task->_idx);
                _task_executable_list.erase(iter_iter_task);
                // printf("_task_executable_list size: %d\n",
                //        _task_executable_list.size());
                is_empty = _task_executable_list.empty();
            }
            lk.unlock();
            if (is_empty) {
                _cv_done->notify_one();
            }
        }
    };
    for (int i = 0; i < _num_threads; i++) {
        _threads_worker[i] = std::thread(work);
    }
}

TaskSystemParallelThreadPoolSleeping::~TaskSystemParallelThreadPoolSleeping() {
    // sync(); // 可能没啥必要（？
    _mtx->lock();
    _end = true;
    _mtx->unlock();
    _cv->notify_all();
    for (int i = 0; i < _num_threads; i++) {
        _threads_worker[i].join();
    }
    delete[] _threads_worker;
    delete _mtx;
    delete _mtx_done;
    delete _cv;
    delete _cv_done;
}

void TaskSystemParallelThreadPoolSleeping::run(IRunnable* runnable,
                                               int num_total_tasks) {
    runAsyncWithDeps(runnable, num_total_tasks, {});
    sync();
}

TaskID TaskSystemParallelThreadPoolSleeping::runAsyncWithDeps(
    IRunnable* runnable, int num_total_tasks, const std::vector<TaskID>& deps) {
    std::unique_lock<std::mutex> lk(*_mtx);
    TaskID task_idx = _current_task_idx++;
    // printf("begin run async %d, num_total_tasks: %d\n", task_idx,
    //        num_total_tasks);
    // for (auto dep : deps) {
    //     printf("%d depends on %d\n", task_idx, dep);
    // }
    TaskInfo task{task_idx, runnable, num_total_tasks, 0, 0, 0, {}};
    for (TaskID dep : deps) {
        // auto it = _task_waiting_map.find(dep);
        // if (it != _task_waiting_map.end()) {
        //     // printf("%d depends on %d\n", task_idx, dep);
        //     it->second._successores.push_back(task_idx);
        //     task._num_deps++;
        // }
        // 因为修改了 _task_waiting_map 的含义，需要检测下是否还是需要考虑的依赖
        auto& t = _task_waiting_map[dep];
        if (t._num_done_tasks < t._num_total_tasks) {
            t._successores.push_back(task_idx);
            task._num_deps++;
        }
    }
    // printf("num_deps: %d\n", task._num_deps);
    _task_waiting_map[task_idx] = task;
    if (task._num_deps == 0) {
        _task_executable_list.push_back(
            (TaskInfo*)&_task_waiting_map[task_idx]);
    }
    lk.unlock();
    _cv->notify_all();
    return task_idx;
}

void TaskSystemParallelThreadPoolSleeping::sync() {
    std::unique_lock<std::mutex> lk(*_mtx);
    _cv_done->wait(lk, [&]() { return _task_executable_list.empty(); });
    return;
}
```

最后也是都列一下两次都测试结果

### 测试

原本看 MacOS 上的结果以为性能菜爆了，wsl2 上看起来很正常啊，~~可以安心逃了啊~~

MacOS 的测试结果：

```bash
# python3 ../tests/run_test_harness.py -a

runtasks_ref
Darwin arm64
================================================================================
Running task system grading harness... (22 total tests)
  - Detected CPU with 14 execution contexts
  - Task system configured to use at most 14 threads
================================================================================
================================================================================
Executing test: super_super_light...
Reference binary: ./runtasks_ref_osx_arm
Results for: super_super_light
                                        STUDENT   REFERENCE   PERF?
[Serial]                                3.632     3.658       0.99  (OK)
[Parallel + Always Spawn]               3.655     48.731      0.08  (OK)
[Parallel + Thread Pool + Spin]         3.75      56.003      0.07  (OK)
[Parallel + Thread Pool + Sleep]        53.49     25.094      2.13  (NOT OK)
================================================================================
Executing test: super_super_light_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: super_super_light_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                3.72      3.672       1.01  (OK)
[Parallel + Always Spawn]               3.756     46.866      0.08  (OK)
[Parallel + Thread Pool + Spin]         3.746     44.612      0.08  (OK)
[Parallel + Thread Pool + Sleep]        38.664    20.674      1.87  (NOT OK)
================================================================================
Executing test: super_light...
Reference binary: ./runtasks_ref_osx_arm
Results for: super_light
                                        STUDENT   REFERENCE   PERF?
[Serial]                                14.85     20.105      0.74  (OK)
[Parallel + Always Spawn]               14.651    52.991      0.28  (OK)
[Parallel + Thread Pool + Spin]         14.855    81.532      0.18  (OK)
[Parallel + Thread Pool + Sleep]        74.186    32.391      2.29  (NOT OK)
================================================================================
Executing test: super_light_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: super_light_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                14.814    23.323      0.64  (OK)
[Parallel + Always Spawn]               14.984    47.708      0.31  (OK)
[Parallel + Thread Pool + Spin]         14.843    61.707      0.24  (OK)
[Parallel + Thread Pool + Sleep]        53.509    30.943      1.73  (NOT OK)
================================================================================
Executing test: ping_pong_equal...
Reference binary: ./runtasks_ref_osx_arm
Results for: ping_pong_equal
                                        STUDENT   REFERENCE   PERF?
[Serial]                                238.754   380.542     0.63  (OK)
[Parallel + Always Spawn]               239.122   94.771      2.52  (NOT OK)
[Parallel + Thread Pool + Spin]         241.022   116.505     2.07  (NOT OK)
[Parallel + Thread Pool + Sleep]        85.505    65.267      1.31  (NOT OK)
================================================================================
Executing test: ping_pong_equal_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: ping_pong_equal_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                239.437   403.311     0.59  (OK)
[Parallel + Always Spawn]               239.308   90.367      2.65  (NOT OK)
[Parallel + Thread Pool + Spin]         238.84    88.308      2.70  (NOT OK)
[Parallel + Thread Pool + Sleep]        76.734    63.0        1.22  (NOT OK)
================================================================================
Executing test: ping_pong_unequal...
Reference binary: ./runtasks_ref_osx_arm
Results for: ping_pong_unequal
                                        STUDENT   REFERENCE   PERF?
[Serial]                                709.493   541.609     1.31  (NOT OK)
[Parallel + Always Spawn]               718.295   100.511     7.15  (NOT OK)
[Parallel + Thread Pool + Spin]         703.033   127.53      5.51  (NOT OK)
[Parallel + Thread Pool + Sleep]        125.17    75.149      1.67  (NOT OK)
================================================================================
Executing test: ping_pong_unequal_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: ping_pong_unequal_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                721.091   539.725     1.34  (NOT OK)
[Parallel + Always Spawn]               717.866   99.581      7.21  (NOT OK)
[Parallel + Thread Pool + Spin]         713.579   103.787     6.88  (NOT OK)
[Parallel + Thread Pool + Sleep]        122.256   73.192      1.67  (NOT OK)
================================================================================
Executing test: recursive_fibonacci...
Reference binary: ./runtasks_ref_osx_arm
Results for: recursive_fibonacci
                                        STUDENT   REFERENCE   PERF?
[Serial]                                959.968   959.784     1.00  (OK)
[Parallel + Always Spawn]               954.509   89.347      10.68  (NOT OK)
[Parallel + Thread Pool + Spin]         953.338   93.124      10.24  (NOT OK)
[Parallel + Thread Pool + Sleep]        91.292    87.707      1.04  (OK)
================================================================================
Executing test: recursive_fibonacci_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: recursive_fibonacci_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                948.398   951.048     1.00  (OK)
[Parallel + Always Spawn]               949.616   90.487      10.49  (NOT OK)
[Parallel + Thread Pool + Spin]         951.274   89.336      10.65  (NOT OK)
[Parallel + Thread Pool + Sleep]        86.217    86.383      1.00  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop
                                        STUDENT   REFERENCE   PERF?
[Serial]                                211.938   214.021     0.99  (OK)
[Parallel + Always Spawn]               212.06    261.459     0.81  (OK)
[Parallel + Thread Pool + Spin]         211.18    338.989     0.62  (OK)
[Parallel + Thread Pool + Sleep]        275.752   107.634     2.56  (NOT OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                213.092   213.828     1.00  (OK)
[Parallel + Always Spawn]               211.787   254.468     0.83  (OK)
[Parallel + Thread Pool + Spin]         212.237   211.598     1.00  (OK)
[Parallel + Thread Pool + Sleep]        213.743   94.511      2.26  (NOT OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fewer_tasks...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_fewer_tasks
                                        STUDENT   REFERENCE   PERF?
[Serial]                                211.907   214.769     0.99  (OK)
[Parallel + Always Spawn]               210.929   259.859     0.81  (OK)
[Parallel + Thread Pool + Spin]         211.207   311.943     0.68  (OK)
[Parallel + Thread Pool + Sleep]        240.632   102.62      2.34  (NOT OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fewer_tasks_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_fewer_tasks_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                213.373   213.476     1.00  (OK)
[Parallel + Always Spawn]               211.305   264.555     0.80  (OK)
[Parallel + Thread Pool + Spin]         211.191   24.4        8.66  (NOT OK)
[Parallel + Thread Pool + Sleep]        24.207    22.182      1.09  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fan_in...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_fan_in
                                        STUDENT   REFERENCE   PERF?
[Serial]                                109.248   109.114     1.00  (OK)
[Parallel + Always Spawn]               109.071   41.26       2.64  (NOT OK)
[Parallel + Thread Pool + Spin]         108.701   56.159      1.94  (NOT OK)
[Parallel + Thread Pool + Sleep]        49.214    26.947      1.83  (NOT OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fan_in_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_fan_in_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                109.575   110.209     0.99  (OK)
[Parallel + Always Spawn]               109.705   39.58       2.77  (NOT OK)
[Parallel + Thread Pool + Spin]         109.434   15.786      6.93  (NOT OK)
[Parallel + Thread Pool + Sleep]        15.39     12.864      1.20  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_reduction_tree...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_reduction_tree
                                        STUDENT   REFERENCE   PERF?
[Serial]                                108.948   110.078     0.99  (OK)
[Parallel + Always Spawn]               109.232   17.412      6.27  (NOT OK)
[Parallel + Thread Pool + Spin]         108.214   18.468      5.86  (NOT OK)
[Parallel + Thread Pool + Sleep]        16.801    14.004      1.20  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_reduction_tree_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: math_operations_in_tight_for_loop_reduction_tree_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                108.334   109.013     0.99  (OK)
[Parallel + Always Spawn]               108.57    18.118      5.99  (NOT OK)
[Parallel + Thread Pool + Spin]         108.267   10.62       10.19  (NOT OK)
[Parallel + Thread Pool + Sleep]        10.563    10.466      1.01  (OK)
================================================================================
Executing test: spin_between_run_calls...
Reference binary: ./runtasks_ref_osx_arm
Results for: spin_between_run_calls
                                        STUDENT   REFERENCE   PERF?
[Serial]                                340.303   342.15      0.99  (OK)
[Parallel + Always Spawn]               336.455   170.749     1.97  (NOT OK)
[Parallel + Thread Pool + Spin]         334.875   173.104     1.93  (NOT OK)
[Parallel + Thread Pool + Sleep]        172.416   171.488     1.01  (OK)
================================================================================
Executing test: spin_between_run_calls_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: spin_between_run_calls_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                338.136   341.188     0.99  (OK)
[Parallel + Always Spawn]               338.978   172.345     1.97  (NOT OK)
[Parallel + Thread Pool + Spin]         336.505   173.104     1.94  (NOT OK)
[Parallel + Thread Pool + Sleep]        172.307   169.91      1.01  (OK)
================================================================================
Executing test: mandelbrot_chunked...
Reference binary: ./runtasks_ref_osx_arm
Results for: mandelbrot_chunked
                                        STUDENT   REFERENCE   PERF?
[Serial]                                252.483   262.149     0.96  (OK)
[Parallel + Always Spawn]               251.727   23.925      10.52  (NOT OK)
[Parallel + Thread Pool + Spin]         250.249   24.048      10.41  (NOT OK)
[Parallel + Thread Pool + Sleep]        23.44     23.751      0.99  (OK)
================================================================================
Executing test: mandelbrot_chunked_async...
Reference binary: ./runtasks_ref_osx_arm
Results for: mandelbrot_chunked_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                251.258   261.307     0.96  (OK)
[Parallel + Always Spawn]               248.815   23.821      10.45  (NOT OK)
[Parallel + Thread Pool + Spin]         245.632   23.781      10.33  (NOT OK)
[Parallel + Thread Pool + Sleep]        23.621    23.713      1.00  (OK)
================================================================================
Overall performance results
[Serial]                                : Perf did not pass all tests
[Parallel + Always Spawn]               : Perf did not pass all tests
[Parallel + Thread Pool + Spin]         : Perf did not pass all tests
[Parallel + Thread Pool + Sleep]        : Perf did not pass all tests
```

接下来是 wsl2 的测试结果：

```bash
# python3 ../tests/run_test_harness.py -a

runtasks_ref
Linux x86_64
================================================================================
Running task system grading harness... (22 total tests)
  - Detected CPU with 16 execution contexts
  - Task system configured to use at most 16 threads
================================================================================
================================================================================
Executing test: super_super_light...
Reference binary: ./runtasks_ref_linux
Results for: super_super_light
                                        STUDENT   REFERENCE   PERF?
[Serial]                                8.831     13.11       0.67  (OK)
[Parallel + Always Spawn]               8.804     599.641     0.01  (OK)
[Parallel + Thread Pool + Spin]         8.811     57.77       0.15  (OK)
[Parallel + Thread Pool + Sleep]        130.662   130.013     1.00  (OK)
================================================================================
Executing test: super_super_light_async...
Reference binary: ./runtasks_ref_linux
Results for: super_super_light_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                8.866     13.174      0.67  (OK)
[Parallel + Always Spawn]               8.788     598.207     0.01  (OK)
[Parallel + Thread Pool + Spin]         8.821     43.615      0.20  (OK)
[Parallel + Thread Pool + Sleep]        60.365    129.248     0.47  (OK)
================================================================================
Executing test: super_light...
Reference binary: ./runtasks_ref_linux
Results for: super_light
                                        STUDENT   REFERENCE   PERF?
[Serial]                                60.766    82.207      0.74  (OK)
[Parallel + Always Spawn]               60.947    606.574     0.10  (OK)
[Parallel + Thread Pool + Spin]         60.694    71.464      0.85  (OK)
[Parallel + Thread Pool + Sleep]        120.32    121.31      0.99  (OK)
================================================================================
Executing test: super_light_async...
Reference binary: ./runtasks_ref_linux
Results for: super_light_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                60.707    82.553      0.74  (OK)
[Parallel + Always Spawn]               60.597    610.495     0.10  (OK)
[Parallel + Thread Pool + Spin]         60.862    47.856      1.27  (NOT OK)
[Parallel + Thread Pool + Sleep]        41.968    67.151      0.62  (OK)
================================================================================
Executing test: ping_pong_equal...
Reference binary: ./runtasks_ref_linux
Results for: ping_pong_equal
                                        STUDENT   REFERENCE   PERF?
[Serial]                                974.77    1329.416    0.73  (OK)
[Parallel + Always Spawn]               975.46    657.312     1.48  (NOT OK)
[Parallel + Thread Pool + Spin]         976.396   313.672     3.11  (NOT OK)
[Parallel + Thread Pool + Sleep]        252.91    282.194     0.90  (OK)
================================================================================
Executing test: ping_pong_equal_async...
Reference binary: ./runtasks_ref_linux
Results for: ping_pong_equal_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                972.789   1322.778    0.74  (OK)
[Parallel + Always Spawn]               972.383   643.996     1.51  (NOT OK)
[Parallel + Thread Pool + Spin]         972.607   273.881     3.55  (NOT OK)
[Parallel + Thread Pool + Sleep]        155.528   260.81      0.60  (OK)
================================================================================
Executing test: ping_pong_unequal...
Reference binary: ./runtasks_ref_linux
Results for: ping_pong_unequal
                                        STUDENT   REFERENCE   PERF?
[Serial]                                1882.87   1868.685    1.01  (OK)
[Parallel + Always Spawn]               1898.237  690.707     2.75  (NOT OK)
[Parallel + Thread Pool + Spin]         1880.099  317.811     5.92  (NOT OK)
[Parallel + Thread Pool + Sleep]        325.156   310.165     1.05  (OK)
================================================================================
Executing test: ping_pong_unequal_async...
Reference binary: ./runtasks_ref_linux
Results for: ping_pong_unequal_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                1880.953  1873.262    1.00  (OK)
[Parallel + Always Spawn]               1884.994  692.076     2.72  (NOT OK)
[Parallel + Thread Pool + Spin]         1897.06   305.934     6.20  (NOT OK)
[Parallel + Thread Pool + Sleep]        266.364   294.205     0.91  (OK)
================================================================================
Executing test: recursive_fibonacci...
Reference binary: ./runtasks_ref_linux
Results for: recursive_fibonacci
                                        STUDENT   REFERENCE   PERF?
[Serial]                                1014.363  1864.386    0.54  (OK)
[Parallel + Always Spawn]               1020.526  228.204     4.47  (NOT OK)
[Parallel + Thread Pool + Spin]         1016.456  238.249     4.27  (NOT OK)
[Parallel + Thread Pool + Sleep]        139.825   203.31      0.69  (OK)
================================================================================
Executing test: recursive_fibonacci_async...
Reference binary: ./runtasks_ref_linux
Results for: recursive_fibonacci_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                1014.671  1860.244    0.55  (OK)
[Parallel + Always Spawn]               1014.684  232.264     4.37  (NOT OK)
[Parallel + Thread Pool + Spin]         1016.029  209.449     4.85  (NOT OK)
[Parallel + Thread Pool + Sleep]        133.688   202.183     0.66  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop
                                        STUDENT   REFERENCE   PERF?
[Serial]                                632.822   666.589     0.95  (OK)
[Parallel + Always Spawn]               635.033   3046.272    0.21  (OK)
[Parallel + Thread Pool + Spin]         632.319   353.398     1.79  (NOT OK)
[Parallel + Thread Pool + Sleep]        596.014   610.595     0.98  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_async...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                634.919   665.761     0.95  (OK)
[Parallel + Always Spawn]               633.117   3036.841    0.21  (OK)
[Parallel + Thread Pool + Spin]         634.344   237.828     2.67  (NOT OK)
[Parallel + Thread Pool + Sleep]        145.622   300.302     0.48  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fewer_tasks...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_fewer_tasks
                                        STUDENT   REFERENCE   PERF?
[Serial]                                636.664   665.167     0.96  (OK)
[Parallel + Always Spawn]               637.362   3134.877    0.20  (OK)
[Parallel + Thread Pool + Spin]         635.676   271.59      2.34  (NOT OK)
[Parallel + Thread Pool + Sleep]        627.586   617.228     1.02  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fewer_tasks_async...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_fewer_tasks_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                639.336   666.136     0.96  (OK)
[Parallel + Always Spawn]               640.35    3133.556    0.20  (OK)
[Parallel + Thread Pool + Spin]         639.268   88.845      7.20  (NOT OK)
[Parallel + Thread Pool + Sleep]        80.065    620.919     0.13  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fan_in...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_fan_in
                                        STUDENT   REFERENCE   PERF?
[Serial]                                331.053   342.919     0.97  (OK)
[Parallel + Always Spawn]               327.84    415.618     0.79  (OK)
[Parallel + Thread Pool + Spin]         328.253   128.856     2.55  (NOT OK)
[Parallel + Thread Pool + Sleep]        102.647   104.537     0.98  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_fan_in_async...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_fan_in_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                327.295   345.385     0.95  (OK)
[Parallel + Always Spawn]               327.776   412.113     0.80  (OK)
[Parallel + Thread Pool + Spin]         328.803   51.38       6.40  (NOT OK)
[Parallel + Thread Pool + Sleep]        41.518    47.11       0.88  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_reduction_tree...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_reduction_tree
                                        STUDENT   REFERENCE   PERF?
[Serial]                                325.711   341.696     0.95  (OK)
[Parallel + Always Spawn]               324.627   115.974     2.80  (NOT OK)
[Parallel + Thread Pool + Spin]         323.884   58.146      5.57  (NOT OK)
[Parallel + Thread Pool + Sleep]        59.128    60.844      0.97  (OK)
================================================================================
Executing test: math_operations_in_tight_for_loop_reduction_tree_async...
Reference binary: ./runtasks_ref_linux
Results for: math_operations_in_tight_for_loop_reduction_tree_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                327.136   340.083     0.96  (OK)
[Parallel + Always Spawn]               324.501   116.149     2.79  (NOT OK)
[Parallel + Thread Pool + Spin]         325.255   43.811      7.42  (NOT OK)
[Parallel + Thread Pool + Sleep]        38.818    41.494      0.94  (OK)
================================================================================
Executing test: spin_between_run_calls...
Reference binary: ./runtasks_ref_linux
Results for: spin_between_run_calls
                                        STUDENT   REFERENCE   PERF?
[Serial]                                363.723   663.649     0.55  (OK)
[Parallel + Always Spawn]               363.693   339.764     1.07  (OK)
[Parallel + Thread Pool + Spin]         364.711   460.236     0.79  (OK)
[Parallel + Thread Pool + Sleep]        278.05    332.255     0.84  (OK)
================================================================================
Executing test: spin_between_run_calls_async...
Reference binary: ./runtasks_ref_linux
Results for: spin_between_run_calls_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                362.584   664.393     0.55  (OK)
[Parallel + Always Spawn]               362.411   334.19      1.08  (OK)
[Parallel + Thread Pool + Spin]         363.12    473.104     0.77  (OK)
[Parallel + Thread Pool + Sleep]        255.535   331.168     0.77  (OK)
================================================================================
Executing test: mandelbrot_chunked...
Reference binary: ./runtasks_ref_linux
Results for: mandelbrot_chunked
                                        STUDENT   REFERENCE   PERF?
[Serial]                                432.242   429.148     1.01  (OK)
[Parallel + Always Spawn]               431.654   33.034      13.07  (NOT OK)
[Parallel + Thread Pool + Spin]         431.36    32.959      13.09  (NOT OK)
[Parallel + Thread Pool + Sleep]        31.432    32.407      0.97  (OK)
================================================================================
Executing test: mandelbrot_chunked_async...
Reference binary: ./runtasks_ref_linux
Results for: mandelbrot_chunked_async
                                        STUDENT   REFERENCE   PERF?
[Serial]                                430.727   428.21      1.01  (OK)
[Parallel + Always Spawn]               431.037   31.553      13.66  (NOT OK)
[Parallel + Thread Pool + Spin]         431.366   33.024      13.06  (NOT OK)
[Parallel + Thread Pool + Sleep]        32.403    31.052      1.04  (OK)
================================================================================
Overall performance results
[Serial]                                : All passed Perf
[Parallel + Always Spawn]               : Perf did not pass all tests
[Parallel + Thread Pool + Spin]         : Perf did not pass all tests
[Parallel + Thread Pool + Sleep]        : All passed Perf
```

