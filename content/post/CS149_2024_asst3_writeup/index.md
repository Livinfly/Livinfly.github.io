---
title: "『学习笔记』CS149 (2024): Assignment 3"
slug: "CS149_2024_asst3_writeup"
authors: ["Livinfly(Mengmm)"]
date: 2025-08-16T02:46:17Z
# 定时发布
# publishDate: 2023-10-01T00:00:00+08:00
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/note/CS149_2024_asst3_writeup"]
categories: ["note"]
tags: ["学习笔记", "CS149"]
description: "Stanford CS149 (2024): Assignment 3 writeup."
image: "cover.jpeg" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---

# CS149 (2024): Assignment 3

>   封面来源：[@ch00suke](https://x.com/ch00suke/status/1946495728588661095)

>   因为对着 15418 2016 看，顺序是先讲了写 CUDA，那就先做 Asst3 吧，做到一半感觉难度曲线有些高，滚去看了 CS149 的slides，[dataparallel](https://gfxcourses.stanford.edu/cs149/fall24/lecture/dataparallel/)（于是后面觉得还是对着 CS149 学吧，逃）
>
>   相关文章：[CS149 Programming Assignment 3 - A Simple Renderer in CUDA | MizukiCry's Blog](https://blog.mizuki.fun/posts/1d4a4d05.html)
>
>   原始实验材料仓库：[stanford-cs149/asst3](https://github.com/stanford-cs149/asst3/tree/4fe1eea25f9ec6381d781ba792ac1a23135eec06)
>
>   我的实现仓库：[Livinfly/15-418u15-618uCS149u](https://github.com/Livinfly/15-418u15-618uCS149u)

>   任务推荐资料：
>
>   The CUDA C programmer's guide [PDF 版本](http://docs.nvidia.com/cuda/pdf/CUDA_C_Programming_Guide.pdf) 或 [web 版本](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)
>
>   CUDA 教程和 SDK 例子 Google 或 [NVIDIA developer site](http://docs.nvidia.com/cuda/)
>
>   计算能力文档 [CUDA C Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/#compute-capabilities)
>
>   C++ 的一些特性 [C++ Super-FAQ](https://isocpp.org/faq)
>
>   关于 pinned [Optimizing Host-Device Data Communication I -Pinned Host Memory: DD2360 HT19 (50340) Applied GPU Programming](https://canvas.kth.se/courses/12406/pages/optimizing-host-device-data-communication-i-pinned-host-memory)
>
>   [An Easy Introduction to CUDA C and C++ | NVIDIA Technical Blog](https://developer.nvidia.com/blog/easy-introduction-cuda-c-and-c/)
>
>   [（更新版）An Even Easier Introduction to CUDA (Updated) | NVIDIA Technical Blog](https://developer.nvidia.com/blog/even-easier-introduction-cuda/)（新接触到 [grid-stride loop](https://developer.nvidia.com/blog/cuda-pro-tip-write-flexible-kernels-grid-stride-loops/) 写法，**Where To From Here?**，有不少经典优化方法，还没直接去看）

>   [!TIP]
>
>   建议进入 c++ edit configuration，
>
>   添加 `"C:\\Program Files\\NVIDIA GPU Computing Toolkit\\CUDA\\v12.1\\**"` 的路径类似物到 `includePath`，获取一些补全。

## 环境

因为本机没有 N 卡，在另一台 1660s 的机器上 ssh 做，这里给出这台机器的环境。

```bash
# 系统版本
uname -a
lsb_release -a
nvidia-smi
cat /proc/cpuinfo
cat /proc/cpuinfo | grep processor | wc -l
```

-   OS: Windows10 - wsl2 (6.6.87.2-microsoft-standard-WSL2) - Ubuntu 22.04.5 LTS
-   CPU: AMD Ryzen 5 3600 6-Core Processor (6 cores, 12 processors)
-   GPU: NVIDIA GeForce GTX 1660 super (6 GB, bandwidth 336 GB/s, 192-bit bus), Driver Version: 576.02, CUDA Version: 12.9
-   Python 3.10.1

## Part 1: CUDA Warm-Up 1: SAXPY

自行查看学习`cudaMemcpy`的定义。（应该是在[device-memory](https://docs.nvidia.com/cuda/cuda-c-programming-guide/#device-memory)这一部分）

文档中已说明，默认情况下，GPU 上的 kernel 调用和 CPU 的主线程是异步的，需要用`cudaDeviceSynchronize()`同步（CPU 等待 GPU的同步，`__syncthreads()`是块内同步）。

同时，`cudaMemcpy()`在我们使用的情况下是同步的；CPU 不能访问`cudaMalloc`分配在 CUDA 设备的内存（使用`cudaMallocManaged`分配的可以访问，但按需搬运易有**Page Fault**，使得 Memory-bound，使用`cudaMemPrefetchAsync`预取到 Device 上）



任务：实现`saxpy.cu`。

```cpp
// saxpy.cu
void saxpyCuda(int N, float alpha, float* xarray, float* yarray,
               float* resultarray) {
    // must read both input arrays (xarray and yarray) and write to
    // output array (resultarray)
    int totalBytes = sizeof(float) * 3 * N;

    // compute number of blocks and threads per block.  In this
    // application we've hardcoded thread blocks to contain 512 CUDA
    // threads.
    const int threadsPerBlock = 512;

    // Notice the round up here.  The code needs to compute the number
    // of threads blocks needed such that there is one thread per
    // element of the arrays.  This code is written to work for values
    // of N that are not multiples of threadPerBlock.
    const int blocks = (N + threadsPerBlock - 1) / threadsPerBlock;

    // These are pointers that will be pointers to memory allocated
    // *one the GPU*.  You should allocate these pointers via
    // cudaMalloc.  You can access the resulting buffers from CUDA
    // device kernel code (see the kernel function saxpy_kernel()
    // above) but you cannot access the contents these buffers from
    // this thread. CPU threads cannot issue loads and stores from GPU
    // memory!
    float* device_x = nullptr;
    float* device_y = nullptr;
    float* device_result = nullptr;

    //
    // CS149 TODO: allocate device memory buffers on the GPU using cudaMalloc.
    //
    // We highly recommend taking a look at NVIDIA's
    // tutorial, which clearly walks you through the few lines of code
    // you need to write for this part of the assignment:
    //
    // https://devblogs.nvidia.com/easy-introduction-cuda-c-and-c/
    //

    // start timing after allocation of device memory
    // cudaSetDevice(0);
    cudaMalloc(&device_x, sizeof(float) * N);
    cudaMalloc(&device_y, sizeof(float) * N);
    cudaMalloc(&device_result, sizeof(float) * N);

    double startTime = CycleTimer::currentSeconds();
    //
    // CS149 TODO: copy input arrays to the GPU using cudaMemcpy
    //
    cudaMemcpy(device_x, xarray, sizeof(float) * N, cudaMemcpyHostToDevice);
    cudaMemcpy(device_y, yarray, sizeof(float) * N, cudaMemcpyHostToDevice);
    // run CUDA kernel. (notice the <<< >>> brackets indicating a CUDA
    // kernel launch) Execution on the GPU occurs here.

    double startKernelTime = CycleTimer::currentSeconds();
    saxpy_kernel<<<blocks, threadsPerBlock>>>(N, alpha, device_x, device_y,
                                              device_result);
    cudaDeviceSynchronize();
    double endKernelTime = CycleTimer::currentSeconds();

    //
    // CS149 TODO: copy result from GPU back to CPU using cudaMemcpy
    //
    cudaMemcpy(resultarray, device_result, sizeof(float) * N,
               cudaMemcpyDeviceToHost);
    // end timing after result has been copied back into host memory
    double endTime = CycleTimer::currentSeconds();

    cudaError_t errCode = cudaPeekAtLastError();
    if (errCode != cudaSuccess) {
        fprintf(stderr, "WARNING: A CUDA error occured: code=%d, %s\n", errCode,
                cudaGetErrorString(errCode));
    }

    double overallDuration = endTime - startTime;
    double overallKernelDuration = endKernelTime - startKernelTime;
    printf("Effective BW     by CUDA saxpy: %.3f ms\t\t[%.3f GB/s]\n",
           1000.f * overallDuration, GBPerSec(totalBytes, overallDuration));
    printf("Effective kernel by CUDA saxpy: %.3f ms\n",
           1000.f * overallKernelDuration);
    //
    // CS149 TODO: free memory buffers on the GPU using cudaFree
    //
    cudaFree(device_x);
    cudaFree(device_y);
    cudaFree(device_result);
}
```

运行结果：

```bash
# N 默认 100M
---------------------------------------------------------
Found 1 CUDA devices
Device 0: NVIDIA GeForce GTX 1660 SUPER
   SMs:        22
   Global mem: 6144 MB
   CUDA Cap:   7.5
---------------------------------------------------------
Running 3 timing tests:
Effective BW     by CUDA saxpy: 201.713 ms              [5.540 GB/s]
Effective kernel by CUDA saxpy: 5.995 ms
Effective BW     by CUDA saxpy: 214.931 ms              [5.200 GB/s]
Effective kernel by CUDA saxpy: 4.311 ms
Effective BW     by CUDA saxpy: 185.933 ms              [6.011 GB/s]
Effective kernel by CUDA saxpy: 4.790 ms

# startTime 计时如果放在，分配 cudaMalloc 之前
Running 3 timing tests:
Effective BW     by CUDA saxpy: 447.963 ms              [2.495 GB/s]
Effective kernel by CUDA saxpy: 6.083 ms
Effective BW     by CUDA saxpy: 205.574 ms              [5.436 GB/s]
Effective kernel by CUDA saxpy: 4.299 ms
Effective BW     by CUDA saxpy: 218.466 ms              [5.116 GB/s]
Effective kernel by CUDA saxpy: 4.311 ms
```

为什么第一次会慢 250ms 左右呢？

**CUDA 上下文创建**，在第一次调用需要与 GPU 通信的 CUDA API 时会触发，后续所有的 CUDA API 调用都可以快速执行了。

手动初始化（CUDA 上下文创建），`cudaSetDevice(Device)`，下面这种写法，第一次的测试速度与后两次无异。

```cpp
cudaSetDevice(0);

double startTime = CycleTimer::currentSeconds();

cudaMalloc(&device_x, sizeof(float) * N);
cudaMalloc(&device_y, sizeof(float) * N);
cudaMalloc(&device_result, sizeof(float) * N);
```

对比 Asst1 的`saxpy`的**串行实现与 ISPC 实现**，实验结果如下：

```bash
// 为了实验参数对齐，N 为 100M（默认 20M）
[saxpy serial]:         [60.025] ms     [24.825] GB/s   [3.332] GFLOPS
[saxpy avx2]:           [34.177] ms     [43.600] GB/s   [5.852] GFLOPS
[saxpy ispc]:           [53.822] ms     [27.686] GB/s   [3.716] GFLOPS
[saxpy task ispc]:      [44.228] ms     [33.692] GB/s   [4.522] GFLOPS
                                (1.76x speedup from My AVX2)
                                (1.22x speedup from use of tasks)
                                (1.12x speedup from ISPC)
                                (1.36x speedup from task ISPC)
```

对比串行，能快 10~12 倍，但是内存通信的开销大。

对比峰值内存带宽，显然没有达到预期。

不难发现，**数据移动**占了绝大部分的时间，导致整个运算总时间比串行还长。

根据材料给出的[视频 / 文字稿](https://canvas.kth.se/courses/12406/pages/optimizing-host-device-data-communication-i-pinned-host-memory)学习。

原因是`cudaMemcpy()`的实现使用 DMA 设备，在 Host 端，DMA 操作的是物理地址，会出现超出一页 page 的情况，导致错误。

所以，**DMA 的传输源必须是固定内存 pinned memory（特殊标记的虚拟内存页面）**，所以在传输时，会先复制到 pinned memory 中，产生额外开销。

因此，优化数据移动，我们可以使用以下方法：

1.   使用 pinned memory，具体地，使用`cudaMallocHost()`或`cudaHostAlloc()`而不是`malloc()`或`new`。

     两个函数的区别是，如果要兼容特别老的 CUDA 版本，需要用前者，后者提供了额外的 **flag** 来操控，是前者的超集。

     [cuda-runtime-api cudaHostAlloc](https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__MEMORY.html#group__CUDART__MEMORY_1gb65da58f444e7230d3322b6126bb4902)和[cudaMallocHost and cudaHostAlloc differences and usage](https://forums.developer.nvidia.com/t/cudamallochost-and-cudahostalloc-differences-and-usage/21056)。

2.   使用 pinned memory 时，可以小数据传输批量处理成一次大数据传输。（我的测试试验中好像变化不大，可能是只有两段数据，不明显，便不列出来了）

```cpp
// main.cpp

// pinned memory
float* xarray = nullptr;
float* yarray = nullptr;
float* resultarray = nullptr;
// cudaMallocHost(&xarray, sizeof(float) * N);
// cudaMallocHost(&yarray, sizeof(float) * N);
// cudaMallocHost(&resultarray, sizeof(float) * N);
cudaHostAlloc(&xarray, sizeof(float) * N, cudaHostAllocDefault);
cudaHostAlloc(&xarray, sizeof(float) * N, cudaHostAllocDefault);
cudaHostAlloc(&xarray, sizeof(float) * N, cudaHostAllocDefault);

// pinned memory
cudaFreeHost(xarray);
cudaFreeHost(yarray);
cudaFreeHost(resultarray);
```

运行结果：

```bash
Running 3 timing tests:
Effective BW     by CUDA saxpy: 117.512 ms              [9.510 GB/s]
Effective kernel by CUDA saxpy: 5.163 ms
Effective BW     by CUDA saxpy: 116.699 ms              [9.577 GB/s]
Effective kernel by CUDA saxpy: 4.826 ms
Effective BW     by CUDA saxpy: 110.485 ms              [10.115 GB/s]
Effective kernel by CUDA saxpy: 4.140 ms
```

加速效果明显，数据搬运耗时减少一半，符合预期。

同时，还尝试了`cudaMemcpyAsync()`，不过效果同样不明显，不再列出。

## Part 2: CUDA Warm-Up 2: Parallel Prefix-Sum

实验中给出的`nextPow2()`只使用于大于零的情况，还有`1<<(__lg(n-1)+1)`可能不被某些编译器兼容的求法。

-   `cpu_exclusive_scan()`的`PARALLEL`版本，用来验证，需要数组长度为2的倍数，不然结果有误。

-   修改 Device 中的内存，直接修改直接报**段错误**；需要用`cudaMemset()`等其他 CUDA API 来操作，注意同步。

>   因为写这部分代码的时候，没文档记录，具体的情况与结果标写在注释中了，劳烦翻阅。
>
>   下面就对着代码，然后说明我遇到的一些情况。

### Exclusive Prefix Sum

根据任务要求给出的示例串行代码实现一下就可以。



首先，先说一下 `cpu_exclusive_scan()` 的模拟并行部分的使用问题。

在 upsweep 阶段，`twod <= N / 2`是要带上等号的，虽然对于 exclusive_scan 的结果不影响，但不符合定义上的要求，区别见下。

```bash
# cpu_exclusive_scan
(two_d < N / 2)
    ./cudaScan -i ones -n 7
    Array size: 7
    1 2 1 4 1 2 1 (upsweep phase)
    2 3 4 6 3 4 3 (downsweep phase)

    ./cudaScan -i ones -n 8
    Array size: 8
    1 2 1 4 1 2 1 4 (upsweep phase)
    0 1 2 3 4 5 6 7 (downsweep phase)

(two_d <= N / 2)
    ./cudaScan -i ones -n 7
    Array size: 7
    1 2 1 4 1 2 1 (upsweep phase)
    2 3 4 6 3 4 3 (downsweep phase)

    ./cudaScan -i ones -n 8
    Array size: 8
    1 2 1 4 1 2 1 8 (upsweep phase)
    0 1 2 3 4 5 6 7 (downsweep phase)
```

其次，downsweep 阶段，在非 2 的整幂次时，访问 `output[i + twod1 - 1]` 是溢出的。

若多开空间到 2 的整幂次，根据计算结果的定义，给拓展后的最后一位赋值为 0（或者都初始化为 0）。

总之，修改会同时该比较多的地方，所以，还是就只在 **2 的整幂次**使用吧。



在实现 CUDA 版本的`exclusive_scan()`遇到的坑点，下面给出情况解释与分析。

线程总数可能溢出`int`的问题。

根据分块代码 $\text{idx} = \text{numBlocks} \cross \text{THREADS\_PER\_BLOCK} = \text{numThreads} + [0, 255]$。

如果在外面乘 $\text{stride\_2}$ 变成下标 $\text{idx\_} = (\text{numThreads} + ( < 256)) \cross \text{stride\_2} = \text{N} + [0, 255] \cross \text{stride\_2}$，

 $\text{stride\_2}$ 范围 $[2, \text{N}]$ 所以，$\text{idx\_}$ 范围 $[\text{N}, 256 * \text{N}]$ 这种情况下，$\text{INT\_MAX} = 2^{31} - 1$，

在大约超出 $8388607.996 ( ≈ 2^{23})$ 时，会产生溢出。

```bash
# (idx < N)，内部的话，因为会申请 nextPow2 的内存，所以不会越界
# 实验结果符合预期：
(idx < N)
    8388608 correct, 8388609 error

(idx + stride_2 - 1 < N)
    4194304 correct, 4194305 error
因为 4194305，N 自动变成 8388608，按照上面的分析，idx 刚好在 int 范围，
在加上，就是刚好不在了，所以报错。
```

错误代码示例留存：

```cpp
// scan.cu upsweep
int stride_2 = stride * 2;
idx *= stride_2;
assert(1LL * idx + stride_2 - 1 < 2147483647);
if (idx + stride_2 - 1 < numThreads) {
    output[idx + stride_2 - 1] += output[idx + stride - 1];
}
```

经验就是尽量不要在判断外对 $\text{idx}$ 做其他的运算，找好比较的对象，爆 `int` 也太难查了。

运行结果：

```bash
-------------------------
Scan Score Table:
-------------------------
-------------------------------------------------------------------------
| Element Count   | Ref Time        | Student Time    | Score           |
-------------------------------------------------------------------------
| 1000000         | 1.296           | 2.676           | 0.6053811659192825 |
| 10000000        | 10.398          | 9.67            | 1.25            |
| 20000000        | 20.531          | 16.089          | 1.25            |
| 40000000        | 39.415          | 31.501          | 1.25            |
-------------------------------------------------------------------------
|                                   | Total score:    | 4.355381165919282/5.0 |
-------------------------------------------------------------------------
```

1e6 的没拿满，不太懂，也不是全都开 N 个线程，已经随着遍历改了。

大改写法还是算了。

```cpp
// scan.cu
__global__ void upsweep(int numThreads, int* output, int stride) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    // idx = numBlocks * THREADS_PER_BLOCK = numThreads + [0, 255]
    // 如果在外面乘 stride_2 变成下标
    // idx_ = (numThreads + ( < 256)) * stride_2 = N + [0, 255] * stride_2
    // stride_2 范围 [2, N]
    // 所以，idx_ 范围 [N, 256 * N]
    // 这种情况下，INT_MAX = 2^31 - 1，在大约超出 8388607.996 ( ≈ 2^23)
    // 时，会产生溢出。
    /*
    (idx < N)，内部的话，因为会申请 nextPow2 的内存，所以不会越界
    实验结果符合预期：
    (idx < N)
        8388608 correct, 8388609 error

    (idx + stride_2 - 1 < N)
        4194304 correct, 4194305 error
    因为 4194305，N 自动变成 8388608，按照上面的分析，idx 刚好在 int 范围，
    在加上，就是刚好不在了，所以报错。

    错误代码示例留存：
    int stride_2 = stride * 2;
    idx *= stride_2;
    assert(1LL * idx + stride_2 - 1 < 2147483647);
    if (idx + stride_2 - 1 < numThreads) {
        output[idx + stride_2 - 1] += output[idx + stride - 1];
    }

    经验就是尽量不要在判断外对 idx 做其他的运算，
    找好比较的对象，爆 int 也太难查了。
    */
    if (idx < numThreads) {
        int stride_2 = stride * 2;
        idx *= stride_2;
        output[idx + stride_2 - 1] += output[idx + stride - 1];
    }
}

__global__ void downsweep(int numThreads, int* output, int stride) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < numThreads) {
        int stride_2 = stride * 2;
        idx *= stride_2;
        int t = output[idx + stride - 1];
        output[idx + stride - 1] = output[idx + stride_2 - 1];
        output[idx + stride_2 - 1] += t;
    }
}

void exclusive_scan(int* input, int N, int* result) {
    N = nextPow2(N);

    for (int two_d = 1; two_d <= N / 2; two_d *= 2) {
        int two_dplus1 = 2 * two_d;
        int numThreads = N / two_dplus1;
        int numBlocks =
            (numThreads + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
        upsweep<<<numBlocks, THREADS_PER_BLOCK>>>(numThreads, result, two_d);
        cudaDeviceSynchronize();
    }

    // result[N - 1] = 0;
    cudaMemset(&result[N - 1], 0, sizeof(int));
    cudaDeviceSynchronize();

    for (int two_d = N / 2; two_d >= 1; two_d /= 2) {
        int two_dplus1 = 2 * two_d;
        int numThreads = N / two_dplus1;
        int numBlocks =
            (numThreads + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
        downsweep<<<numBlocks, THREADS_PER_BLOCK>>>(numThreads, result, two_d);
        cudaDeviceSynchronize();
    }
}
```

应该挺好用，但是没怎么用的 `cudaCheckError`

```cpp
#define DEBUG

#ifdef DEBUG
#define cudaCheckError(ans) { cudaAssert((ans), __FILE__, __LINE__); }
inline void cudaAssert(cudaError_t code, const char *file, int line, bool
abort=true)
{
   if (code != cudaSuccess)
   {
      fprintf(stderr, "CUDA Error: %s at %s:%d\n",
        cudaGetErrorString(code), file, line);
      if (abort) exit(code);
   }
}
#else
#define cudaCheckError(ans) ans
#endif

cudaCheckError( cudaMalloc(&a, size*sizeof(int)) );
```

### Find Repeats

还太能直接反映出，并行的实现，有些发懵，先学习了下别人的才反应过来 QnQ。

要利用`exclusive_scan()`。

先标记和相邻的相同的下标，再利用`exclusive_scan()`方便后面映射到结果数组，提取出未相邻重复的数。

运行结果：

```bash
-------------------------
Find_repeats Score Table:
-------------------------
-------------------------------------------------------------------------
| Element Count   | Ref Time        | Student Time    | Score           |
-------------------------------------------------------------------------
| 1000000         | 2.49            | 3.613           | 0.8614724605590922 |
| 10000000        | 15.93           | 15.16           | 1.25            |
| 20000000        | 32.058          | 22.803          | 1.25            |
| 40000000        | 61.725          | 42.734          | 1.25            |
-------------------------------------------------------------------------
|                                   | Total score:    | 4.611472460559092/5.0 |
-------------------------------------------------------------------------``
```

包括这个 `find_repeats`，也是只有 1e6 的没拿满，不太清楚是什么问题，甚至拿别人在他的机器上满分的代码，也有部分没拿满。

```cpp
// scan.cu
__global__ void find_repeats_kernel_1(int length, int* input, int* device_tmp) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx + 1 < length) {
        device_tmp[idx] = (input[idx] == input[idx + 1] ? 1 : 0);
    }
}

__global__ void find_repeats_kernel_2(int length, int* device_tmp,
                                      int* output) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx + 1 < length && device_tmp[idx] != device_tmp[idx + 1]) {
        output[device_tmp[idx]] = idx;
    }
}

int find_repeats(int* device_input, int length, int* device_output) {
    int N = nextPow2(length);

    int numBlocks = (N + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
    int* device_tmp;
    cudaMalloc((void**)&device_tmp, N * sizeof(int));

    find_repeats_kernel_1<<<numBlocks, THREADS_PER_BLOCK>>>(
        length, device_input, device_tmp);
    cudaDeviceSynchronize();

    exclusive_scan(device_tmp, length, device_tmp);

    find_repeats_kernel_2<<<numBlocks, THREADS_PER_BLOCK>>>(length, device_tmp,
                                                            device_output);
    cudaDeviceSynchronize();

    int result;
    cudaMemcpy(&result, &device_tmp[length - 1], sizeof(int),
               cudaMemcpyDeviceToHost);

    cudaFree(device_tmp);
    return result;
}
```

## Part 3: A Simple Circle Renderer

如同任务要求开头所说，"**Now for the real show!**

上来就丢了很多文件和一些说明文档，说原本实现是错的，把他改对。

因为自己在阅读这些资料的过程中，有些迷失了（晕了，看着看着，不知道在看什么，迷茫）。

后参看了下 [MizukiCry](https://blog.mizuki.fun/posts/1d4a4d05.html) 这部分的实现，然后重新又自己理了理，写了写。

所以，这部分再会增加一些对代码结构的一些说明。



首先，尝试按照任务说明的编译运行一下，若提示找不到 `#include <GL/glut.h>`：

```bash
# 安装 GLUT 开发库
sudo apt-get install freeglut3-dev
```

然后，通过任务要求文档， 我们得知，渲染器 renderer 需要按照一定顺序渲染，不然在有图像重叠时，可能会出错。

强调 **Atomicity** 和 **Order**。

这两个点，是我们后面具体修正 CUDA 实现的时候需要注意的。

随后，我们开始阅读代码。

发现文件很多，个人建议先主要看`main.cpp`, `refRenderer.cpp / h`，`cudaRenderer.cu / h`，把握核心逻辑，重点在`kernelRenderCircles()` 和 `shadePixel()`。

看完 `main.cpp` 搞清楚程序运行的逻辑后，后面两个文件的大多数函数，我们只要先知道他做了什么，先不要看他的实现逻辑。（比如每个材质，渲染方式不同，这种逻辑看了对我们没有太大的帮助，当然有兴趣都是可以看的，不过容易直接看晕）

之后按照前面提到的 **Atomicity** 和 **Order** 的实现原则去检查和渲染 render 相关的代码实现，查看是否有错误。

我觉得主要搞清楚一下一些变量的含义，还有它们的范围之后，应该会好看很多。

再要具体写代码的时候，查看 `*.cu_inl` 文件，看看有没有可以重复利用的函数。

如果确定了方向，可以先自己尝试去看，还是比较晕，可以看看我下面的 hint。

```cpp
struct GlobalConstants {
    SceneName sceneName; 	// 场景名字

    int numCircles;      	// 渲染的圆的数量
    float* position;		// 位置
    float* velocity;		// 速度
    float* color;			// 颜色
    float* radius;			// 半径

    int imageWidth;			// 图片宽度
    int imageHeight;		// 图片高度
    float* imageData;		// 图片数据
};
```

具体的存储方式，如 `float3`，范围的话可以在出现的函数中找到，比如很大部分的值时归一化的 `float` 存储的，位置分 `（x, y, 深度）`。

（当然，这些是我理解的，没有仔细查证）

接下来，我介绍我的实现（几种实现的介绍可以参考 data parallel - slide 最后几页）。



我们先思考，CUDA 开的线程是什么信息，圆的编号，还是像素，还是其他？

我这边先给出我第一个实现思路，也是 data parallel - slide 的第一种 solution 1 / 2。（代码统一放在最后）

对每个像素建一个线程，按圆编号顺序以此检查是否在圆内，在圆内才渲染。

满足了两个原则。

```bash
# kernelRenderCircles_1_bf 运行结果
# ./checker.py 

Running scene: rgb...
[rgb] Correctness passed!
[rgb] Student times:  [0.3469, 0.3525, 0.362]
[rgb] Reference times:  [0.4353, 0.4865, 0.4146]

Running scene: rand10k...
[rand10k] Correctness passed!
[rand10k] Student times:  [65.4322, 66.6227, 70.4742]
[rand10k] Reference times:  [5.2589, 5.229, 5.3398]

Running scene: rand100k...
[rand100k] Correctness passed!
[rand100k] Student times:  [642.4314, 638.4485, 639.3848]
[rand100k] Reference times:  [45.3885, 47.9276, 48.3938]

Running scene: pattern...
[pattern] Correctness passed!
[pattern] Student times:  [9.0589, 9.1332, 9.0711]
[pattern] Reference times:  [0.7231, 0.7794, 0.7507]

Running scene: snowsingle...
[snowsingle] Correctness passed!
[snowsingle] Student times:  [595.5139, 593.2695, 597.059]
[snowsingle] Reference times:  [29.8196, 30.8086, 30.8295]

Running scene: biglittle...
[biglittle] Correctness passed!
[biglittle] Student times:  [91.9496, 88.6234, 88.3303]
[biglittle] Reference times:  [27.8894, 27.8606, 28.044]

Running scene: rand1M...
[rand1M] Correctness passed!
[rand1M] Student times:  [6243.6725, 6278.3903, 6286.1439]
[rand1M] Reference times:  [271.1312, 269.9863, 270.0433]

Running scene: micro2M...
[micro2M] Correctness passed!
[micro2M] Student times:  [12637.5187, 12641.5866, 12667.2077]
[micro2M] Reference times:  [500.5195, 501.222, 504.6417]
------------
Score table:
------------
--------------------------------------------------------------------------
| Scene Name      | Ref Time (T_ref) | Your Time (T)   | Score           |
--------------------------------------------------------------------------
| rgb             | 0.4146           | 0.3469          | 9               |
| rand10k         | 5.229            | 65.4322         | 2               |
| rand100k        | 45.3885          | 638.4485        | 2               |
| pattern         | 0.7231           | 9.0589          | 2               |
| snowsingle      | 29.8196          | 593.2695        | 2               |
| biglittle       | 27.8606          | 88.3303         | 5               |
| rand1M          | 269.9863         | 6243.6725       | 2               |
| micro2M         | 500.5195         | 12637.5187      | 2               |
--------------------------------------------------------------------------
|                                    | Total score:    | 26/72           |
--------------------------------------------------------------------------
```

再看到 `shadePixel()`注释中提到的 **specialized template magic**，对 `shadePixel()` 进行模版优化，实现 `shadePixel_template()`。

（然后就发现差别不大，像是正常波动，就不放出来了，不知道是不是实现的其实有问题？后续也继续用原本的`shadePixel()`）



后面写优化感觉自己烂完了，看懂 MizukiCry 的版本跑路了。

优化方式就是增加了像素分块，并行检测块是否在圆内，最后把有交集的整理出来，像素并行，顺序遍历这些圆，去渲染。

具体地实现方面，用`exclusive_scan()`完整并行检测后的排序。

```bash
# MizukiCry 运行结果
# ./checker.py

Running scene: rgb...
[rgb] Correctness passed!
[rgb] Student times:  [0.5717, 0.5957, 0.491]
[rgb] Reference times:  [0.4137, 0.4899, 0.4276]

Running scene: rand10k...
[rand10k] Correctness passed!
[rand10k] Student times:  [6.5862, 6.5918, 6.5984]
[rand10k] Reference times:  [5.3212, 5.232, 5.2773]

Running scene: rand100k...
[rand100k] Correctness passed!
[rand100k] Student times:  [59.2156, 56.0504, 55.9814]
[rand100k] Reference times:  [44.41, 48.7485, 45.5738]

Running scene: pattern...
[pattern] Correctness passed!
[pattern] Student times:  [0.8356, 0.9017, 0.841]
[pattern] Reference times:  [0.7524, 0.7637, 0.7094]

Running scene: snowsingle...
[snowsingle] Correctness passed!
[snowsingle] Student times:  [30.8606, 30.921, 31.0172]
[snowsingle] Reference times:  [30.7988, 30.901, 31.0349]

Running scene: biglittle...
[biglittle] Correctness passed!
[biglittle] Student times:  [50.6408, 51.9845, 47.8579]
[biglittle] Reference times:  [27.885, 28.0244, 27.989]

Running scene: rand1M...
[rand1M] Correctness passed!
[rand1M] Student times:  [277.3871, 271.2555, 278.4894]
[rand1M] Reference times:  [267.8346, 261.9554, 264.5599]

Running scene: micro2M...
[micro2M] Correctness passed!
[micro2M] Student times:  [491.7058, 492.4224, 488.8702]
[micro2M] Reference times:  [492.4264, 497.237, 500.9529]
------------
Score table:
------------
--------------------------------------------------------------------------
| Scene Name      | Ref Time (T_ref) | Your Time (T)   | Score           |
--------------------------------------------------------------------------
| rgb             | 0.4137           | 0.491           | 9               |
| rand10k         | 5.232            | 6.5862          | 8               |
| rand100k        | 44.41            | 55.9814         | 8               |
| pattern         | 0.7094           | 0.8356          | 9               |
| snowsingle      | 30.7988          | 30.8606         | 9               |
| biglittle       | 27.885           | 47.8579         | 7               |
| rand1M          | 261.9554         | 271.2555        | 9               |
| micro2M         | 492.4264         | 488.8702        | 9               |
--------------------------------------------------------------------------
|                                    | Total score:    | 68/72           |
--------------------------------------------------------------------------
```

相关代码：

```cpp
//cudaRenderer.cu
namespace MySolution {

#define DEBUG

#ifdef DEBUG
#define cudaCheckError(ans)                    \
    {                                          \
        cudaAssert((ans), __FILE__, __LINE__); \
    }
inline void cudaAssert(cudaError_t code, const char* file, int line,
                       bool abort = true) {
    if (code != cudaSuccess) {
        fprintf(stderr, "CUDA Error: %s at %s:%d\n", cudaGetErrorString(code),
                file, line);
        if (abort)
            exit(code);
    }
}
#else
#define cudaCheckError(ans) ans
#endif

constexpr int BLOCK_DIM = 16;
constexpr int BLOCK_SIZE = BLOCK_DIM * BLOCK_DIM;

#define SCAN_BLOCK_DIM BLOCK_SIZE
#include "circleBoxTest.cu_inl"
#include "exclusiveScan.cu_inl"

template <bool isSNOWFLAKES>
__device__ __inline__ void shadePixel_template(int circleIndex,
                                               float2 pixelCenter, float3 p,
                                               float4* imagePtr) {
    float diffX = p.x - pixelCenter.x;
    float diffY = p.y - pixelCenter.y;
    float pixelDist = diffX * diffX + diffY * diffY;

    float rad = cuConstRendererParams.radius[circleIndex];
    ;
    float maxDist = rad * rad;

    if (pixelDist > maxDist)
        return;

    float3 rgb;
    float alpha;

    // specialized template magic
    if constexpr (isSNOWFLAKES) {
        const float kCircleMaxAlpha = .5f;
        const float falloffScale = 4.f;

        float normPixelDist = sqrt(pixelDist) / rad;
        rgb = lookupColor(normPixelDist);

        float maxAlpha = .6f + .4f * (1.f - p.z);
        maxAlpha = kCircleMaxAlpha * fmaxf(fminf(maxAlpha, 1.f), 0.f);
        alpha =
            maxAlpha * exp(-1.f * falloffScale * normPixelDist * normPixelDist);

    } else {
        int index3 = 3 * circleIndex;
        rgb = *(float3*)&(cuConstRendererParams.color[index3]);
        alpha = .5f;
    }

    float oneMinusAlpha = 1.f - alpha;

    float4 existingColor = *imagePtr;
    float4 newColor;
    newColor.x = alpha * rgb.x + oneMinusAlpha * existingColor.x;
    newColor.y = alpha * rgb.y + oneMinusAlpha * existingColor.y;
    newColor.z = alpha * rgb.z + oneMinusAlpha * existingColor.z;
    newColor.w = alpha + existingColor.w;

    *imagePtr = newColor;
}

// MizukiCry 的实现（开头提到的博客）
__global__ void kernelRenderCircles_MizukiCry() {
    __shared__ uint circleIsInBox[BLOCK_SIZE];
    __shared__ uint circleIndex[BLOCK_SIZE];
    __shared__ uint scratch[2 * BLOCK_SIZE];
    __shared__ int inBoxCircles[BLOCK_SIZE];

    int boxL = blockIdx.x * BLOCK_DIM;
    int boxB = blockIdx.y * BLOCK_DIM;
    int boxR = min(boxL + BLOCK_DIM, cuConstRendererParams.imageWidth);
    int boxT = min(boxB + BLOCK_DIM, cuConstRendererParams.imageHeight);
    float invWidth = 1.f / cuConstRendererParams.imageWidth;
    float invHeight = 1.f / cuConstRendererParams.imageHeight;
    float boxLNorm = boxL * invWidth;
    float boxRNorm = boxR * invWidth;
    float boxTNorm = boxT * invHeight;
    float boxBNorm = boxB * invHeight;

    int index = threadIdx.y * BLOCK_DIM + threadIdx.x;
    int pixelX = boxL + threadIdx.x;
    int pixelY = boxB + threadIdx.y;
    int pixelId = pixelY * cuConstRendererParams.imageWidth + pixelX;

    for (int i = 0; i < cuConstRendererParams.numCircles; i += BLOCK_SIZE) {
        int circleId = i + index;
        if (circleId < cuConstRendererParams.numCircles) {
            float3 p = *reinterpret_cast<float3*>(
                &cuConstRendererParams.position[3 * circleId]);
            circleIsInBox[index] =
                circleInBox(p.x, p.y, cuConstRendererParams.radius[circleId],
                            boxLNorm, boxRNorm, boxTNorm, boxBNorm);
        } else {
            circleIsInBox[index] = 0;
        }
        __syncthreads();

        sharedMemExclusiveScan(index, circleIsInBox, circleIndex, scratch,
                               BLOCK_SIZE);
        if (circleIsInBox[index]) {
            inBoxCircles[circleIndex[index]] = circleId;
        }
        __syncthreads();

        int numCirclesInBox =
            circleIndex[BLOCK_SIZE - 1] + circleIsInBox[BLOCK_SIZE - 1];
        __syncthreads();

        if (pixelX < boxR && pixelY < boxT) {
            float4* imgPtr = reinterpret_cast<float4*>(
                &cuConstRendererParams.imageData[4 * pixelId]);
            for (int j = 0; j < numCirclesInBox; j++) {
                circleId = inBoxCircles[j];
                shadePixel(circleId,
                           make_float2((pixelX + 0.5) * invWidth,
                                       (pixelY + 0.5) * invHeight),
                           *reinterpret_cast<float3*>(
                               &cuConstRendererParams.position[3 * circleId]),
                           imgPtr);
            }
        }
    }
}

/*
struct GlobalConstants {
    SceneName sceneName;

    int numCircles;
    float* position;
    float* velocity;
    float* color;
    float* radius;

    int imageWidth;
    int imageHeight;
    float* imageData;
} cuConstRendererParams;
*/
__global__ void kernelRenderCircles_1() {
    float invWidth = 1.f / cuConstRendererParams.imageWidth;
    float invHeight = 1.f / cuConstRendererParams.imageHeight;

    int x_idx = blockIdx.x * blockDim.x + threadIdx.x;
    int y_idx = blockIdx.y * blockDim.y + threadIdx.y;
    if (x_idx >= cuConstRendererParams.imageWidth)
        return;
    if (y_idx >= cuConstRendererParams.imageHeight)
        return;

    // 减少原本要访问 圆个数次 全局内存 不知道为什么也没有影响，
    // 可能再重写下 shadePixel?
    // float4 img_local_value = *(imgPtr);
    // float4* imgPtr_local = &img_local_value;

    for (int i = 0; i < cuConstRendererParams.numCircles; i++) {
        int i3 = 3 * i;
        float3 p = *(float3*)(&cuConstRendererParams.position[i3]);
        float rad = cuConstRendererParams.radius[i];
        float2 pixelCenterNorm =
            make_float2(invWidth * (static_cast<float>(x_idx) + 0.5f),
                        invHeight * (static_cast<float>(y_idx) + 0.5f));
        float4* imgPtr =
            (float4*)(&cuConstRendererParams.imageData
                           [4 * (y_idx * cuConstRendererParams.imageWidth +
                                 x_idx)]);

        // 宽松在圆外、严格在圆外
        if (circleInBoxConservative(p.x, p.y, rad, pixelCenterNorm.x,
                                    pixelCenterNorm.x, pixelCenterNorm.y,
                                    pixelCenterNorm.y) == 0 ||
            circleInBox(p.x, p.y, rad, pixelCenterNorm.x, pixelCenterNorm.x,
                        pixelCenterNorm.y, pixelCenterNorm.y) == 0) {
            continue;
        }
        shadePixel(i, pixelCenterNorm, p, imgPtr);
        // shadePixel(i, pixelCenterNorm, p, imgPtr_local);
    }
    // *imgPtr = img_local_value;
}

void renderCircles(int width, int height) {
    // MySolution::
    //     kernelRenderCircles_1<<<dim3((width + BLOCK_DIM - 1) / BLOCK_DIM,
    //                                (height + BLOCK_DIM - 1) / BLOCK_DIM),
    //                           dim3(BLOCK_DIM, BLOCK_DIM)>>>();
    MySolution::kernelRenderCircles_MizukiCry<<<
        dim3((width + BLOCK_DIM - 1) / BLOCK_DIM,
             (height + BLOCK_DIM - 1) / BLOCK_DIM),
        dim3(BLOCK_DIM, BLOCK_DIM)>>>();
    cudaCheckError(cudaDeviceSynchronize());
}
}  // namespace MySolution
```