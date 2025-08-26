---
title: "『学习笔记』CS149 (2023): Assignment 4"
slug: "CS149_2023_asst4_writeup"
authors: ["Livinfly(Mengmm)"]
date: 2025-08-26T06:43:05Z
# 定时发布
# publishDate: 2023-10-01T00:00:00+08:00
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/note/CS149_2023_asst4_writeup"]
categories: ["note"]
tags: ["学习笔记", "CS149"]
description: "Stanford CS149 (2023): Assignment 4 writeup."
image: "cover.jpeg" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---

# CS149 (2023): Assignment 4

> 由于 2024 Assignment 4 需要服务器，转做 2023 的了。

> 封面来源：[@hiyualice240](https://x.com/hiyualice240/status/1959637650874458182)

> 相关文章：[CS149 Programming Assignment 4 - Chat149 - A Flash Attention Transformer DNN | MizukiCry&#39;s Blog](https://blog.mizuki.fun/posts/832ed8a6.html)
>
> 原始实验材料仓库：[stanford-cs149/cs149gpt](https://github.com/stanford-cs149/cs149gpt/tree/41e4875b50549f40aa399723dfe12de13e7da637)
>
> 我的实现仓库：[Livinfly/15-418u15-618uCS149u](https://github.com/Livinfly/15-418u15-618uCS149u)

> 任务推荐资料：
>
> 环境问题：
>
> [ImportError: cs149gpt/module_ref.so: undefined symbol · Issue #2 · stanford-cs149/cs149gpt](https://github.com/stanford-cs149/cs149gpt/issues/2)
>
> [我想要请教下此项目环境配置问题是如何解决的呢？ · Issue #1 · BienBoy/cs149gpt](https://github.com/BienBoy/cs149gpt/issues/1)
>
> Transformer 的产生动机：
>
> - [Slide 52 of Lecture 10](https://gfxcourses.stanford.edu/cs149/fall23/lecture/dnneval/slide_52)
> - [What is the intuition behind the attention mechanism?](https://ai.stackexchange.com/questions/21389/what-is-the-intuition-behind-the-attention-mechanism)
> - [Transformer Neural Networks: A Step-by-Step Breakdown](https://builtin.com/artificial-intelligence/transformer-neural-network)
> - [How Transformers Work](https://towardsdatascience.com/transformers-141e32e69591)

## 环境

一开始想在 Mac 上做，但环境存在的不太行，转回 wsl2 了。

- OS: Windows11 - wsl2 (6.6.87.2-microsoft-standard-WSL2) - Ubuntu 22.04.5 LTS
- CPU: AMD Ryzen 7 6800H (8 cores, 16 logical processors, AVX2 256-bit)
- Python 3.10.12

这个任务，**using CPU only**，不需要 GPU。

官方是服务器，没有给环境，需要自己配一下。

参考 [ImportError: cs149gpt/module_ref.so: undefined symbol · Issue #2 · stanford-cs149/cs149gpt](https://github.com/stanford-cs149/cs149gpt/issues/2)

```python
conda create -n gpt149
conda activate gpt149
conda install pytorch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 cpuonly python=3.10 numpy=1.26 ninja tiktoken -c pytorch -c conda-forge
# 上面指定 numpy==1.26 但是如果不降到 numpy 1.x 应该只是警告，如下：
'''
A module that was compiled using NumPy 1.x cannot be run in
NumPy 2.2.6 as it may crash. To support both 1.x and 2.x
versions of NumPy, modules must be compiled with NumPy 2.0.
Some module may need to rebuild instead e.g. with 'pybind11>=2.12'.

If you are a user of the module, the easiest solution will be to
downgrade to 'numpy<2' or try to upgrade the affected module.
We expect that some modules will need time to support NumPy 2
'''

# requirements.txt
torch==2.1.2
ninja
# 如果要跑文字生成
tiktoken
```

## Warm-Up: Accessing Tensors

参照 `2D Accessor`，实现 `4D Accessor`，4D-tensor 转 1D vector 访问。

这里我直接模仿的写法没什么问题，加乘嵌套的写法 `tensor[((x * sizeX + y) * sizeY + z) * sizeZ + b]`，看 MizukiCry 的结果是会影响到编译器的优化。

```cpp
// module.cpp
inline float fourDimRead(std::vector<float> &tensor, int &x, int &y, int &z,
                         int &b, const int &sizeX, const int &sizeY,
                         const int &sizeZ) {
    return tensor[x * (sizeX * sizeY * sizeZ) + y * (sizeY * sizeZ) +
                  z * (sizeZ) + b];
}

inline void fourDimWrite(std::vector<float> &tensor, int &x, int &y, int &z,
                         int &b, const int &sizeX, const int &sizeY,
                         const int &sizeZ, float &val) {
    tensor[x * (sizeX * sizeY * sizeZ) + y * (sizeY * sizeZ) + z * (sizeZ) +
           b] = val;
    return;
}
```

测试结果：

```bash
# python3 gpt149.py 4Daccess

Expected: 0.0008
Result: 0.0008
```

## Part 1: A Simple (But Not So Efficient) Implementation of Attention

简单实现 Attention 模块。

原注释中还给出了写入 0 的例子，难度很友好了。

```cpp
// module.cpp myNaiveAttention()

// -------- YOUR CODE HERE  -------- //
for (int b = 0; b < B; b++) {
    for (int h = 0; h < H; h++) {
        for (int i = 0; i < N; i++) {
            for (int k = 0; k < N; k++) {
                float QK_val = 0.0;
                for (int j = 0; j < d; j++) {
                    float Q_val = fourDimRead(Q, b, h, i, j, H, N, d);
                    float K_val = fourDimRead(K, b, h, k, j, H, N, d);
                    QK_val += Q_val * K_val;
                }
                twoDimWrite(QK_t, i, k, N, QK_val);
            }
        }

        for (int i = 0; i < N; i++) {
            float sum = 0.0;
            for (int j = 0; j < N; j++) {
                float val = twoDimRead(QK_t, i, j, N);
                sum += exp(val);
            }
            for (int j = 0; j < N; j++) {
                float val = twoDimRead(QK_t, i, j, N);
                val = exp(val) / sum;
                twoDimWrite(QK_t, i, j, N, val);
            }
        }

        for (int i = 0; i < N; i++) {
            for (int k = 0; k < d; k++) {
                float O_val = 0.0;
                for (int j = 0; j < N; j++) {
                    float QK_val = twoDimRead(QK_t, i, j, N);
                    float V_val = fourDimRead(V, b, h, j, k, H, N, d);
                    O_val += QK_val * V_val;
                }
                fourDimWrite(O, b, h, i, k, H, N, d, O_val);
            }
        }
    }
}
```

测试结果：

```bash
# python3 gpt149.py part1

Running Part 1 Test: Naive Unfused Attention

-----RUNNING REFERENCE IMPLEMENTATION-----

STAGE:2025-08-26 08:14:12 3895:3895 ActivityProfilerController.cpp:312] Completed Stage: Warm Up
STAGE:2025-08-26 08:14:12 3895:3895 ActivityProfilerController.cpp:318] Completed Stage: Collection
STAGE:2025-08-26 08:14:12 3895:3895 ActivityProfilerController.cpp:322] Completed Stage: Post Processing
manual attention == pytorch attention True
Manual Execution Time:  0.2422347068786621

-------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                           Name    Self CPU %      Self CPU   CPU total %     CPU total  CPU time avg       CPU Mem  Self CPU Mem    # of Calls
-------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                    aten::empty         0.04%     102.000us         0.04%     102.000us      34.000us       5.00 Mb       5.00 Mb  
   3
    REFERENCE - NAIVE ATTENTION        98.58%     238.962ms        99.90%     242.154ms     242.154ms       4.50 Mb      -1.00 Mb  
   1
                    aten::zeros         0.09%     207.000us         0.72%       1.740ms     870.000us       4.50 Mb           0 b  
   2
                    aten::clone         0.12%     290.000us         0.49%       1.187ms     593.500us       1.00 Mb           0 b  
   2
                model_inference         0.10%     247.000us       100.00%     242.401ms     242.401ms     512.00 Kb      -4.00 Mb  
   1
                  aten::flatten         0.10%     231.000us         0.35%     840.000us     168.000us     512.00 Kb           0 b  
   5
               aten::empty_like         0.02%      53.000us         0.03%      70.000us      70.000us     512.00 Kb           0 b  
   1
            aten::empty_strided         0.02%      54.000us         0.02%      54.000us      54.000us     512.00 Kb     512.00 Kb  
   1
                    aten::zero_         0.07%     166.000us         0.60%       1.448ms     724.000us           0 b           0 b  
   2
                    aten::fill_         0.53%       1.282ms         0.53%       1.282ms     641.000us           0 b           0 b  
   2
-------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
Self CPU time total: 242.401ms

REFERENCE - NAIVE ATTENTION statistics
cpu time:  242.154ms
mem usage:  4718592 bytes
-----RUNNING STUDENT IMPLEMENTATION-----

STAGE:2025-08-26 08:14:18 3895:3895 ActivityProfilerController.cpp:312] Completed Stage: Warm Up
STAGE:2025-08-26 08:14:19 3895:3895 ActivityProfilerController.cpp:318] Completed Stage: Collection
STAGE:2025-08-26 08:14:19 3895:3895 ActivityProfilerController.cpp:322] Completed Stage: Post Processing
manual attention == pytorch attention True
Manual Execution Time:  0.23636484146118164

-----------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                         Name    Self CPU %      Self CPU   CPU total %     CPU total  CPU time avg       CPU Mem  Self CPU Mem    # of Calls
-----------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                  aten::empty         0.01%      31.000us         0.01%      31.000us      10.333us       5.00 Mb       5.00 Mb  
 3
    STUDENT - NAIVE ATTENTION        99.39%     234.968ms        99.96%     236.320ms     236.320ms       4.50 Mb      -1.00 Mb  
 1
                  aten::zeros         0.02%      36.000us         0.25%     581.000us     290.500us       4.50 Mb           0 b  
 2
                  aten::clone         0.02%      42.000us         0.30%     707.000us     353.500us       1.00 Mb           0 b  
 2
              model_inference         0.04%      93.000us       100.00%     236.413ms     236.413ms     512.00 Kb      -4.00 Mb  
 1
                aten::flatten         0.02%      37.000us         0.15%     359.000us      71.800us     512.00 Kb           0 b  
 5
             aten::empty_like         0.00%       6.000us         0.00%      11.000us      11.000us     512.00 Kb           0 b  
 1
          aten::empty_strided         0.01%      16.000us         0.01%      16.000us      16.000us     512.00 Kb     512.00 Kb  
 1
                  aten::zero_         0.01%      18.000us         0.22%     519.000us     259.500us           0 b           0 b  
 2
                  aten::fill_         0.21%     501.000us         0.21%     501.000us     250.500us           0 b           0 b  
 2
-----------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
Self CPU time total: 236.413ms

STUDENT - NAIVE ATTENTION statistics
cpu time:  236.32ms
mem usage:  4718592 bytes

# python3 gpt149.py part1 -N <val>
# 随便再测了几个，没有问题
```

## Part 2: Blocked Matrix Multiply and Unfused Softmax

参照 [lecture](https://gfxcourses.stanford.edu/cs149/fall23/lecture/perfopt2/slide_43)，分块优化 cache 的命中率。

先查询本机的 cacheline，为 64

```bash
# Linux
cat /sys/devices/system/cpu/cpu1/cache/index0/coherency_line_size

# MacOS（虽然本次实现不能用它来做）
sysctl hw.cachelinesize
```

- N 固定 1024 时，在本机上的最佳的 tile size 是多少？

- Part 1, 2 的 DRAM 访问差别（缓存命中情况）

    使用 Perf

```cpp
// module.cpp myUnfusedAttentionBlocked()

// -------- YOUR CODE HERE  -------- //
constexpr int BLOCK_SIZE = 16;  // cacheline / sizeof(float)

for (int b = 0; b < B; b++) {
    for (int h = 0; h < H; h++) {
        for (int i_b = 0; i_b < N; i_b += BLOCK_SIZE) {
            for (int j_b = 0; j_b < d; j_b += BLOCK_SIZE) {
                for (int k_b = 0; k_b < N; k_b += BLOCK_SIZE) {
                    int i_e = std::min(i_b + BLOCK_SIZE, N);
                    int j_e = std::min(j_b + BLOCK_SIZE, d);
                    int k_e = std::min(k_b + BLOCK_SIZE, N);

                    for (int i = i_b; i < i_e; i++) {
                        for (int k = k_b; k < k_e; k++) {
                            float QK_val = twoDimRead(QK_t, i, k, N);
                            for (int j = j_b; j < j_e; j++) {
                                float Q_val =
                                    fourDimRead(Q, b, h, i, j, H, N, d);
                                float K_val =
                                    fourDimRead(K, b, h, k, j, H, N, d);
                                QK_val += Q_val * K_val;
                            }
                            twoDimWrite(QK_t, i, k, N, QK_val);
                        }
                    }
                }
            }
        }

        for (int i = 0; i < N; i++) {
            float sum = 0.0;
            for (int j = 0; j < N; j++) {
                float val = twoDimRead(QK_t, i, j, N);
                sum += exp(val);
            }
            for (int j = 0; j < N; j++) {
                float val = twoDimRead(QK_t, i, j, N);
                val = exp(val) / sum;
                twoDimWrite(QK_t, i, j, N, val);
            }
        }

        for (int i_b = 0; i_b < N; i_b += BLOCK_SIZE) {
            for (int j_b = 0; j_b < N; j_b += BLOCK_SIZE) {
                for (int k_b = 0; k_b < d; k_b += BLOCK_SIZE) {
                    int i_e = std::min(i_b + BLOCK_SIZE, N);
                    int j_e = std::min(j_b + BLOCK_SIZE, N);
                    int k_e = std::min(k_b + BLOCK_SIZE, d);

                    for (int i = i_b; i < i_e; i++) {
                        for (int k = k_b; k < k_e; k++) {
                            float O_val =
                                fourDimRead(O, b, h, i, k, H, N, d);
                            for (int j = j_b; j < j_e; j++) {
                                float QK_val = twoDimRead(QK_t, i, j, N);
                                float V_val =
                                    fourDimRead(V, b, h, j, k, H, N, d);
                                O_val += QK_val * V_val;
                            }
                            fourDimWrite(O, b, h, i, k, H, N, d, O_val);
                        }
                    }
                }
            }
        }
    }
}
```

测试结果：

```bash
# python3 gpt149.py part2

Running Part 2 Test: Unfused Attention with Blocked Matmul

-----RUNNING REFERENCE IMPLEMENTATION-----

STAGE:2025-08-26 08:18:17 4350:4350 ActivityProfilerController.cpp:312] Completed Stage: Warm Up
STAGE:2025-08-26 08:18:17 4350:4350 ActivityProfilerController.cpp:318] Completed Stage: Collection
STAGE:2025-08-26 08:18:17 4350:4350 ActivityProfilerController.cpp:322] Completed Stage: Post Processing
manual attention == pytorch attention True
Manual Execution Time:  0.17670416831970215

------------------------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                                            Name    Self CPU %      Self CPU   CPU total %     CPU total  CPU time avg       CPU Mem  Self CPU Mem    # of Calls
------------------------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                                     aten::empty         0.06%     104.000us         0.06%     104.000us      34.667us       5.00 Mb       5.00 Mb             3
    REFERENCE - BLOCKED MATMUL + UNFUSED SOFTMAX        98.49%     174.098ms        99.94%     176.664ms     176.664ms       4.50 Mb      -1.00 Mb             1
                                     aten::zeros         0.05%      85.000us         0.85%       1.501ms     750.500us       4.50 Mb           0 b             2
                                     aten::clone         0.07%     124.000us         0.50%     886.000us     443.000us       1.00 Mb           0 b             2
                                 model_inference         0.06%     107.000us       100.00%     176.771ms     176.771ms     512.00 Kb      -4.00 Mb             1
                                   aten::flatten         0.09%     153.000us         0.33%     585.000us     117.000us     512.00 Kb           0 b             5
                                aten::empty_like         0.02%      31.000us         0.03%      49.000us      49.000us     512.00 Kb           0 b             1
                             aten::empty_strided         0.03%      50.000us         0.03%      50.000us      50.000us     512.00 Kb     512.00 Kb             1
                                     aten::zero_         0.05%      96.000us         0.75%       1.330ms     665.000us           0 b           0 b             2
                                     aten::fill_         0.70%       1.234ms         0.70%       1.234ms     617.000us           0 b           0 b             2
------------------------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
Self CPU time total: 176.771ms

REFERENCE - BLOCKED MATMUL + UNFUSED SOFTMAX statistics
cpu time:  176.664ms
mem usage:  4718592 bytes
-----RUNNING STUDENT IMPLEMENTATION-----

STAGE:2025-08-26 08:18:23 4350:4350 ActivityProfilerController.cpp:312] Completed Stage: Warm Up
STAGE:2025-08-26 08:18:23 4350:4350 ActivityProfilerController.cpp:318] Completed Stage: Collection
STAGE:2025-08-26 08:18:23 4350:4350 ActivityProfilerController.cpp:322] Completed Stage: Post Processing
manual attention == pytorch attention True
Manual Execution Time:  0.16107916831970215

----------------------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                                          Name    Self CPU %      Self CPU   CPU total %     CPU total  CPU time avg       CPU Mem  Self CPU Mem    # of Calls
----------------------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                                   aten::empty         0.03%      54.000us         0.03%      54.000us      18.000us       5.00 Mb       5.00 Mb             3
    STUDENT - BLOCKED MATMUL + UNFUSED SOFTMAX        99.04%     159.579ms        99.94%     161.034ms     161.034ms       4.50 Mb      -1.00 Mb             1
                                   aten::zeros         0.01%      23.000us         0.61%     982.000us     491.000us       4.50 Mb   
  0 b             2
                                   aten::clone         0.02%      36.000us         0.26%     423.000us     211.500us       1.00 Mb   
  0 b             2
                               model_inference         0.06%      91.000us       100.00%     161.125ms     161.125ms     512.00 Kb      -4.00 Mb             1
                                 aten::flatten         0.02%      31.000us         0.12%     195.000us      39.000us     512.00 Kb   
  0 b             5
                              aten::empty_like         0.00%       4.000us         0.00%       6.000us       6.000us     512.00 Kb   
  0 b             1
                           aten::empty_strided         0.01%      15.000us         0.01%      15.000us      15.000us     512.00 Kb     512.00 Kb             1
                                   aten::zero_         0.01%      14.000us         0.56%     907.000us     453.500us           0 b   
  0 b             2
                                   aten::fill_         0.55%     893.000us         0.55%     893.000us     446.500us           0 b   
  0 b             2
----------------------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
Self CPU time total: 161.125ms

STUDENT - BLOCKED MATMUL + UNFUSED SOFTMAX statistics
cpu time:  161.034ms
mem usage:  4718592 bytes

# python3 gpt149.py part2 -N <val>
# 随便再测了几个，没有问题
```

## Part 3: Fused Attention

由于 Q, K 矩阵乘、Softmax、注意力得分，遍历参数类似，但要重复三轮，并且整块占用，对 cache 表现和内存占用都不友好。

观察到 QK矩阵 的每一行之间的计算是独立的，我们考虑把矩阵乘和 Softmax 操作融合 fused 起来。

使用 OpenMP，来简单地实现并行，如 `#pragma omp parallel for collapse(2)`，`omp_get_thread_num()` 来使用必要的子数组。

- 为什么 Part 3 的内存占用和 Part 1 & 2 相比骤降？
- 把 OpenMP 注释掉，比较 cpu 耗时，为什么融合让多线程利用更加轻松且充分了？

```cpp
// module.cpp myFusedAttention()

// -------- YOUR CODE HERE  -------- //
// We give you a template of the first three loops for your convenience
// loop over batch
#pragma omp parallel for collapse(3)
for (int b = 0; b < B; b++) {
    // loop over heads
    for (int h = 0; h < H; h++) {
        for (int i = 0; i < N; i++) {
            // YRow is moved inside so each OpenMP thread gets a local copy.
            at::Tensor ORowTensor = temp.index({torch::indexing::Slice(
                omp_get_thread_num(), torch::indexing::None)});
            std::vector<float> ORow = formatTensor(ORowTensor);
            // YOUR CODE HERE
            float sum = 0.0;
            for (int k = 0; k < N; k++) {
                float QK_val = 0.0;
                for (int j = 0; j < d; j++) {
                    float Q_val = fourDimRead(Q, b, h, i, j, H, N, d);
                    float K_val = fourDimRead(K, b, h, k, j, H, N, d);
                    QK_val += Q_val * K_val;
                }
                ORow[k] = exp(QK_val);
                sum += ORow[k];
            }
            for (int k = 0; k < N; k++) {
                ORow[k] /= sum;
            }
            for (int k = 0; k < d; k++) {
                float O_val = 0.0;
                for (int j = 0; j < N; j++) {
                    float V_val = fourDimRead(V, b, h, j, k, H, N, d);
                    O_val += ORow[j] * V_val;
                }
                fourDimWrite(O, b, h, i, k, H, N, d, O_val);
            }
        }
    }
}
```

测试结果：

```bash
# python3 gpt149.py part3

Running Part 3 Test: Fused Attention

-----RUNNING REFERENCE IMPLEMENTATION-----

STAGE:2025-08-26 08:21:16 4705:4705 ActivityProfilerController.cpp:312] Completed Stage: Warm Up
STAGE:2025-08-26 08:21:16 4705:4705 ActivityProfilerController.cpp:318] Completed Stage: Collection
STAGE:2025-08-26 08:21:16 4705:4705 ActivityProfilerController.cpp:322] Completed Stage: Post Processing
manual attention == pytorch attention True
Manual Execution Time:  0.05468630790710449

-------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                           Name    Self CPU %      Self CPU   CPU total %     CPU total  CPU time avg       CPU Mem  Self CPU Mem    # of Calls
-------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                    aten::empty         0.16%      85.000us         0.16%      85.000us      28.333us       1.03 Mb       1.03 Mb  
   3
                    aten::clone         0.12%      68.000us         1.69%     929.000us     464.500us       1.00 Mb           0 b  
   2
    REFERENCE - FUSED ATTENTION        88.67%      48.607ms        99.63%      54.616ms      54.616ms     544.00 Kb      -1.00 Mb  
   1
                    aten::zeros         0.16%      88.000us         1.04%     569.000us     284.500us     544.00 Kb           0 b  
   2
                model_inference         0.37%     202.000us       100.00%      54.818ms      54.818ms     512.00 Kb     -32.00 Kb  
   1
                  aten::flatten         1.88%       1.028ms         4.27%       2.340ms       4.535us     512.00 Kb           0 b  
 516
               aten::empty_like         0.12%      66.000us         0.17%      93.000us      93.000us     512.00 Kb           0 b  
   1
            aten::empty_strided         0.06%      34.000us         0.06%      34.000us      34.000us     512.00 Kb     512.00 Kb  
   1
                    aten::zero_         0.29%     161.000us         0.77%     423.000us     211.500us           0 b           0 b  
   2
                    aten::fill_         0.48%     262.000us         0.48%     262.000us     262.000us           0 b           0 b  
   1
-------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
Self CPU time total: 54.818ms

REFERENCE - FUSED ATTENTION statistics
cpu time:  54.616ms
mem usage:  557056 bytes
-----RUNNING STUDENT IMPLEMENTATION-----

STAGE:2025-08-26 08:21:22 4705:4705 ActivityProfilerController.cpp:312] Completed Stage: Warm Up
STAGE:2025-08-26 08:21:22 4705:4705 ActivityProfilerController.cpp:318] Completed Stage: Collection
STAGE:2025-08-26 08:21:22 4705:4705 ActivityProfilerController.cpp:322] Completed Stage: Post Processing
manual attention == pytorch attention True
Manual Execution Time:  0.047617435455322266

-----------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                         Name    Self CPU %      Self CPU   CPU total %     CPU total  CPU time avg       CPU Mem  Self CPU Mem    # of Calls
-----------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                  aten::empty         0.06%      30.000us         0.06%      30.000us       7.500us       1.04 Mb       1.04 Mb  
 4
                  aten::clone         0.07%      34.000us         0.82%     391.000us     195.500us       1.00 Mb           0 b  
 2
                  aten::zeros         0.18%      88.000us         0.25%     118.000us      39.333us     548.00 Kb           0 b  
 3
    STUDENT - FUSED ATTENTION        92.52%      44.102ms        99.81%      47.580ms      47.580ms     544.00 Kb      -1.00 Mb  
 1
              model_inference         0.19%      89.000us       100.00%      47.669ms      47.669ms     512.00 Kb     -32.00 Kb  
 1
                aten::flatten         1.44%     688.000us         2.56%       1.221ms       2.362us     512.00 Kb           0 b           517
             aten::empty_like         0.01%       5.000us         0.02%      10.000us      10.000us     512.00 Kb           0 b  
 1
          aten::empty_strided         0.03%      16.000us         0.03%      16.000us      16.000us     512.00 Kb     512.00 Kb  
 1
                  aten::zero_         0.03%      15.000us         0.13%      61.000us      20.333us           0 b           0 b  
 3
                  aten::fill_         0.10%      46.000us         0.10%      46.000us      46.000us           0 b           0 b  
 1
-----------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
Self CPU time total: 47.669ms

STUDENT - FUSED ATTENTION statistics
cpu time:  47.58ms
mem usage:  557056 bytes

# python3 gpt149.py part3 -N <val>
# 随便再测了几个，没有问题
```

## Part 4 : Putting it all Together - Flash Attention

为了更好的融合分块与 Softmax，Flash Attnetion 诞生了。

对着伪代码实现即可，注意变量名不要打错，找了半天 QnQ。

B H 多轮，应该只有 l 是需要重新初始化的。（当然根据写法不同有不同）

实验只要求正确性，不过超过得也比较轻松。挺多可以做融合 fused 的地方，不过为了和伪代码对应，就没去做。

也就不去进一步优化了。

```cpp
// module.cpp myFlashAttention()

// -------- YOUR CODE HERE  -------- //
const int Tr = (N + Br - 1) / Br;
const int Tc = (N + Bc - 1) / Bc;

for (int b = 0; b < B; b++) {
    for (int h = 0; h < H; h++) {
        // 初始化 l
        for (int t = 0; t < N; t++) {
            l[t] = 0.0;
        }

        for (int j = 0; j < Tc; j++) {
            // 读入 Kj, Vj
            int j_e = std::min(Bc, N - j * Bc);
            for (int j_b = 0; j_b < j_e; j_b++) {
                int idx = j * Bc + j_b;
                for (int k = 0; k < d; k++) {
                    float Kj_val = fourDimRead(K, b, h, idx, k, H, N, d);
                    twoDimWrite(Kj, j_b, k, d, Kj_val);
                    float Vj_val = fourDimRead(V, b, h, idx, k, H, N, d);
                    twoDimWrite(Vj, j_b, k, d, Vj_val);
                }
            }

            for (int i = 0; i < Tr; i++) {
                // 读入 Qi, Oi, li
                int i_e = std::min(Br, N - i * Br);
                for (int i_b = 0; i_b < i_e; i_b++) {
                    int idx = i * Br + i_b;
                    for (int k = 0; k < d; k++) {
                        float Qi_val =
                            fourDimRead(Q, b, h, idx, k, H, N, d);
                        float Oi_val =
                            fourDimRead(O, b, h, idx, k, H, N, d);
                        twoDimWrite(Qi, i_b, k, d, Qi_val);
                        twoDimWrite(Oi, i_b, k, d, Oi_val);
                    }
                    li[i_b] = l[idx];
                }

                // 计算 Sij
                for (int i_b = 0; i_b < i_e; i_b++) {
                    for (int j_b = 0; j_b < j_e; j_b++) {
                        float Sij_val = 0.0;
                        for (int k = 0; k < d; k++) {
                            float Qi_val = twoDimRead(Qi, i_b, k, d);
                            float Kj_val = twoDimRead(Kj, j_b, k, d);
                            Sij_val += Qi_val * Kj_val;
                        }
                        twoDimWrite(Sij, i_b, j_b, Bc, Sij_val);
                    }
                }

                // 计算 Pij
                for (int i_b = 0; i_b < i_e; i_b++) {
                    for (int j_b = 0; j_b < j_e; j_b++) {
                        float Sij_val = twoDimRead(Sij, i_b, j_b, Bc);
                        float Pij_val = exp(Sij_val);
                        twoDimWrite(Pij, i_b, j_b, Bc, Pij_val);
                    }
                }

                // 计算 lij
                for (int i_b = 0; i_b < i_e; i_b++) {
                    float sum = 0.0;
                    for (int j_b = 0; j_b < j_e; j_b++) {
                        float Pij_val = twoDimRead(Pij, i_b, j_b, Bc);
                        sum += Pij_val;
                    }
                    lij[i_b] = sum;
                }

                // 计算 lnew
                for (int i_b = 0; i_b < i_e; i_b++) {
                    lnew[i_b] = li[i_b] + lij[i_b];
                }

                // 计算 Oi
                for (int i_b = 0; i_b < i_e; i_b++) {
                    for (int k = 0; k < d; k++) {
                        float PV_val = 0.0;
                        for (int j_b = 0; j_b < j_e; j_b++) {
                            float Pij_val = twoDimRead(Pij, i_b, j_b, Bc);
                            float Vj_val = twoDimRead(Vj, j_b, k, d);
                            PV_val += Pij_val * Vj_val;
                        }
                        float Oi_val = twoDimRead(Oi, i_b, k, d);
                        float Oi_val_new =
                            (li[i_b] * Oi_val + PV_val) / lnew[i_b];
                        twoDimWrite(Oi, i_b, k, d, Oi_val_new);
                    }
                }

                // 写回 Oi, lnew
                for (int i_b = 0; i_b < i_e; i_b++) {
                    int idx = i * Br + i_b;
                    for (int k = 0; k < d; k++) {
                        float Oi_val = twoDimRead(Oi, i_b, k, d);
                        fourDimWrite(O, b, h, idx, k, H, N, d, Oi_val);
                    }
                    l[idx] = lnew[i_b];
                }
            }
        }
    }
}

```

测试结果：

```bash
# python3 gpt149.py part4

Running Part 4 Test: Flash Attention

-----RUNNING REFERENCE IMPLEMENTATION-----

STAGE:2025-08-26 14:10:25 8891:8891 ActivityProfilerController.cpp:312] Completed Stage: Warm Up
STAGE:2025-08-26 14:10:26 8891:8891 ActivityProfilerController.cpp:318] Completed Stage: Collection
STAGE:2025-08-26 14:10:26 8891:8891 ActivityProfilerController.cpp:322] Completed Stage: Post Processing
manual attention == pytorch attention True
Manual Execution Time:  0.7275524139404297

-------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                           Name    Self CPU %      Self CPU   CPU total %     CPU total  CPU time avg       CPU Mem  Self CPU Mem    # of Calls
-------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                    aten::zeros         0.01%     109.000us         0.34%       2.459ms     175.643us       9.16 Mb           0 b        
  14
                    aten::empty         0.02%     110.000us         0.02%     110.000us       7.857us       9.13 Mb       9.13 Mb        
  14
                model_inference         0.04%     274.000us       100.00%     727.590ms     727.590ms     512.00 Kb    -679.00 Kb        
   1
    REFERENCE - FLASH ATTENTION        97.59%     710.021ms        99.89%     726.786ms     726.786ms     512.00 Kb      -8.00 Mb        
   1
                    aten::zero_         0.21%       1.546ms         2.35%      17.065ms      46.122us      32.00 Kb      32.00 Kb        
 370
                    aten::fill_         2.13%      15.530ms         2.13%      15.530ms     116.767us           0 b           0 b        
 133
-------------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
Self CPU time total: 727.590ms

REFERENCE - FLASH ATTENTION statistics
cpu time:  726.786ms
mem usage:  524288 bytes
-----RUNNING STUDENT IMPLEMENTATION-----

STAGE:2025-08-26 14:10:31 8891:8891 ActivityProfilerController.cpp:312] Completed Stage: Warm Up
STAGE:2025-08-26 14:10:32 8891:8891 ActivityProfilerController.cpp:318] Completed Stage: Collection
STAGE:2025-08-26 14:10:32 8891:8891 ActivityProfilerController.cpp:322] Completed Stage: Post Processing
manual attention == pytorch attention True
Manual Execution Time:  0.21417665481567383

-----------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                         Name    Self CPU %      Self CPU   CPU total %     CPU total  CPU time avg       CPU Mem  Self CPU Mem    # of Calls
-----------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
                  aten::empty         0.01%      30.000us         0.01%      30.000us       2.308us       1.63 Mb       1.63 Mb          
13
                  aten::zeros         0.02%      40.000us         0.08%     164.000us      13.667us       1.16 Mb      32.00 Kb          
12
                  aten::clone         0.03%      58.000us         0.27%     585.000us     292.500us       1.00 Mb           0 b          
 2
              model_inference         0.08%     179.000us       100.00%     214.232ms     214.232ms     512.00 Kb    -679.00 Kb          
 1
    STUDENT - FLASH ATTENTION        99.52%     213.207ms        99.85%     213.906ms     213.906ms     512.00 Kb      -1.00 Mb          
 1
                aten::flatten         0.03%      60.000us         0.18%     384.000us      25.600us     512.00 Kb           0 b          
15
             aten::empty_like         0.00%       4.000us         0.00%       6.000us       6.000us     512.00 Kb           0 b          
 1
          aten::empty_strided         0.01%      13.000us         0.01%      13.000us      13.000us     512.00 Kb     512.00 Kb          
 1
                  aten::zero_         0.02%      36.000us         0.04%      96.000us       8.000us           0 b           0 b          
12
                  aten::fill_         0.03%      74.000us         0.03%      74.000us      24.667us           0 b           0 b          
 3
-----------------------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------  ------------
Self CPU time total: 214.232ms

STUDENT - FLASH ATTENTION statistics
cpu time:  213.906ms
mem usage:  524288 bytes

# python3 gpt149.py part4 -N <val> -br <val> -bc <val>
# 随便再测了几个，没有问题（br bc 在合法范围)
```

## Extra Credit: Optimize Further

用 ISPC 进一步优化上面每一个 Part。

感觉意义一般，也跑路了。

## 结语

总的来说，这个是做下来目前根据最简单的。