---
title: "『学习笔记』CS149 (2024): Assignment 5"
slug: "CS149_2024_asst5_writeup"
authors: ["Livinfly(Mengmm)"]
date: 2025-08-27T05:58:15Z
# 定时发布
# publishDate: 2023-10-01T00:00:00+08:00
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/note/CS149_2024_asst5_writeup"]
categories: ["note"]
tags: ["学习笔记", "CS149"]
description: "Stanford CS149 (2024): Assignment 5 writeup."
image: "cover.jpeg" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---

# CS149 (2024): Assignment 5

> 封面来源：[@auhuheben17](https://x.com/auhuheben17/status/1958753861419561292)

> 相关文章：[CS149 Programming Assignment 5 - Big Graph Processing | MizukiCry's Blog](https://blog.mizuki.fun/posts/d5b34e15.html)
>
> 原始实验材料仓库：[stanford-cs149/biggraphs-ec](https://github.com/stanford-cs149/biggraphs-ec/tree/91bb03367178ad644c04efb7430a1f697c50c0b4)
>
> 我的实现仓库：[Livinfly/15-418u15-618uCS149u](https://github.com/Livinfly/15-418u15-618uCS149u)

> 任务推荐资料：
>
> OpenMP：
>
> -   [OpenMP 3.0 规范](http://www.openmp.org/mp-documents/spec30.pdf)
>
> -   [OpenMP 手册](https://www.openmp.org/wp-content/uploads/OpenMP3.1-CCard.pdf)
>
> -   [`omp parallel_for` 自定义](http://www.inf.ufsc.br/~bosco.sobral/ensino/ine5645/OpenMP_Dynamic_Scheduling.pdf) ~~这个长度合适，适合阅读~~
>
> 宽度优先搜索 Breadth-first search (BFS)：
>
> -   [Breadth First Search Tutorials & Notes | Algorithms | HackerEarth](https://www.hackerearth.com/practice/algorithms/graphs/breadth-first-search/tutorial/)
> -   [Breadth First Search Algorithm | Shortest Path | Graph Theory - YouTube](https://www.youtube.com/watch?v=oDqjPvD54Ss)
>
> [OpenMP 入门指南 - 知乎](https://zhuanlan.zhihu.com/p/658770855)

## 环境

又是无法跑在 MacOS-arm64 上，就算安了 `gcc-11`，也会提示 `ref_bfs.o` 无法链接。

```bash
# 系统版本
uname -a
lsb_release -a
nvidia-smi
cat /proc/cpuinfo
cat /proc/cpuinfo | grep processor | wc -l
```

- OS: Windows10 - wsl2 (6.6.87.2-microsoft-standard-WSL2) - Ubuntu 22.04.5 LTS
- CPU: AMD Ryzen 5 3600 6-Core Processor (6 cores, 12 processors)
- GPU: NVIDIA GeForce GTX 1660 super (6 GB, bandwidth 336 GB/s, 192-bit bus), Driver Version: 576.02, CUDA Version: 12.9
- Python 3.10.1

## Part 1: Parallel "Top Down" Breadth-First Search

学习[ `omp parallel for` 自定义]((http://www.inf.ufsc.br/~bosco.sobral/ensino/ine5645/OpenMP_Dynamic_Scheduling.pdf))和按照给的提示，只能初步实现下，最外层循环并行，内层共享参数 `#pragma omp critical`。

后面，学习优化无法并行的更新 `new_frontier`。

具体地，为每个线程创建一个 `buffer`，先写到 `buffer` 中，后续再更新到 `new_frontier`。

由于需要复写的地址不一样，不会有冲突。



因为没有好好看 OpenMP 的文档，写法有问题。

`#pragma omp parallel` 会创建线程，在代码块内部就相当于已经有了这些线程，

此时应该用 `#pragma omp for` 而非 `#pragma omp parallel for`，

否则嵌套并行，创建很多线程，出现线程数越多，运行越慢的情况。

```cpp
// bfs.cpp

void top_down_step(Graph g, vertex_set* frontier, vertex_set* new_frontier,
                   int* distances) {
    const int dist_new = distances[frontier->vertices[0]] + 1;
#pragma omp parallel
    {
        Vertex* buffer = new Vertex[g->num_nodes];
        int buffer_size = 0;

#pragma omp for schedule(dynamic, 64)
        for (int u = 0; u < frontier->count; u++) {
            const int node = frontier->vertices[u];
            for (const Vertex *v = outgoing_begin(g, node),
                              *v_e = outgoing_end(g, node);
                 v < v_e; v++) {
                if (distances[*v] == NOT_VISITED_MARKER &&
                    __sync_bool_compare_and_swap(
                        &distances[*v], NOT_VISITED_MARKER, dist_new)) {
                    buffer[buffer_size++] = *v;
                }
            }
        }
        int idx = __sync_fetch_and_add(&new_frontier->count, buffer_size);
        memcpy(new_frontier->vertices + idx, buffer,
               buffer_size * sizeof(Vertex));

        delete[] buffer;
    }
}
```

## Part 2: "Bottom Up" BFS

尝试去维护未访问的集合，用 `unordered_set` 但是无法支持 openMP 的并行，转成 `vector` 后，重复拷贝太花时间了，反而性能下降。

后面又尝试像是 `frontier` 的滚动，也不行，消耗太大，耗时见测试  `unvisit` 部分。

最后还是维持朴素做法了。（代码中注释掉相关部分了，见代码仓库）

```cpp
// bfs.cpp

void bottom_up_step(Graph g, vertex_set* frontier, vertex_set* new_frontier,
                    int* distances) {
    const int dist_new = distances[frontier->vertices[0]] + 1;
#pragma omp parallel
    {
        Vertex* buffer = new Vertex[g->num_nodes];
        int buffer_size = 0;

#pragma omp for schedule(dynamic, 64)
        for (int v = 0; v < g->num_nodes; v++) {
            if (distances[v] != NOT_VISITED_MARKER) continue;
            for (const Vertex *u = incoming_begin(g, v),
                              *u_e = incoming_end(g, v);
                 u < u_e; u++) {
                if (distances[*u] == dist_new - 1 &&
                    __sync_bool_compare_and_swap(
                        &distances[v], NOT_VISITED_MARKER, dist_new)) {
                    buffer[buffer_size++] = v;
                    break;
                }
            }
        }

        int idx = __sync_fetch_and_add(&new_frontier->count, buffer_size);
        memcpy(new_frontier->vertices + idx, buffer,
               buffer_size * sizeof(Vertex));
        
        delete[] buffer;
    }
}

void bfs_bottom_up(Graph graph, solution* sol) {
    vertex_set list1;
    vertex_set list2;
    vertex_set_init(&list1, graph->num_nodes);
    vertex_set_init(&list2, graph->num_nodes);

    vertex_set* frontier = &list1;
    vertex_set* new_frontier = &list2;

    for (int i = 0; i < graph->num_nodes; i++)
        sol->distances[i] = NOT_VISITED_MARKER;

    frontier->vertices[frontier->count++] = ROOT_NODE_ID;
    sol->distances[ROOT_NODE_ID] = 0;

    while (frontier->count != 0) {
#ifdef VERBOSE
        double start_time = CycleTimer::currentSeconds();
#endif

        vertex_set_clear(new_frontier);
        bottom_up_step(graph, frontier, new_frontier, sol->distances);

#ifdef VERBOSE
        double end_time = CycleTimer::currentSeconds();
        printf("frontier=%-10d %.4f sec\n", frontier->count,
               end_time - start_time);
#endif

        // swap pointers
        vertex_set* tmp = frontier;
        frontier = new_frontier;
        new_frontier = tmp;
    }
}
```

## Part 3: Hybrid BFS

在 `frontier` 点少的时候使用 `top down`。

```cpp
void bfs_hybrid(Graph graph, solution* sol) {
    vertex_set list1;
    vertex_set list2;
    vertex_set_init(&list1, graph->num_nodes);
    vertex_set_init(&list2, graph->num_nodes);

    vertex_set* frontier = &list1;
    vertex_set* new_frontier = &list2;

    for (int i = 0; i < graph->num_nodes; i++)
        sol->distances[i] = NOT_VISITED_MARKER;

    frontier->vertices[frontier->count++] = ROOT_NODE_ID;
    sol->distances[ROOT_NODE_ID] = 0;

    while (frontier->count != 0) {
#ifdef VERBOSE
        double start_time = CycleTimer::currentSeconds();
#endif

        vertex_set_clear(new_frontier);
        if (frontier->count < graph->num_nodes * 0.1) {
            top_down_step(graph, frontier, new_frontier, sol->distances);
        } else {
            bottom_up_step(graph, frontier, new_frontier, sol->distances);
        }

#ifdef VERBOSE
        double end_time = CycleTimer::currentSeconds();
        printf("frontier=%-10d %.4f sec\n", frontier->count,
               end_time - start_time);
#endif

        // swap pointers
        vertex_set* tmp = frontier;
        frontier = new_frontier;
        new_frontier = tmp;
    }
}
```

## 测试

因为共用一个测试，所以是先用串行版本实现所有 Part，然后再初步调优。

```bash
# ./bfs ../all_graphs/rmat_200m.graph
# 串行 6.41

# v1
----------------------------------------------------------
Your Code: Timing Summary
Threads  Top Down          Bottom Up         Hybrid
   1:    6.30 (1.00x)      8.55 (1.00x)      2.74 (1.00x)
   2:    3.28 (1.92x)      4.74 (1.81x)      1.44 (1.91x)
   4:    2.12 (2.96x)      3.30 (2.59x)      0.92 (2.97x)
   8:    1.34 (4.71x)      2.14 (4.00x)      0.59 (4.64x)
  12:    1.12 (5.61x)      1.80 (4.75x)      0.49 (5.58x)
----------------------------------------------------------
Reference: Timing Summary
Threads  Top Down          Bottom Up         Hybrid
   1:    6.58 (1.00x)      5.71 (1.00x)      3.11 (1.00x)
   2:    3.47 (1.90x)      3.10 (1.84x)      1.76 (1.77x)
   4:    2.32 (2.84x)      2.07 (2.75x)      1.14 (2.73x)
   8:    1.59 (4.14x)      1.35 (4.23x)      0.82 (3.79x)
  12:    1.30 (5.08x)      1.18 (4.84x)      0.73 (4.25x)
----------------------------------------------------------
Correctness:

Speedup vs. Reference:
Threads       Top Down          Bottom Up             Hybrid
   1:             1.05               0.67               1.13
   2:             1.06               0.66               1.22
   4:             1.09               0.63               1.23
   8:             1.19               0.63               1.39
  12:             1.15               0.65               1.49
  
# unvisit
----------------------------------------------------------
Your Code: Timing Summary
Threads  Top Down          Bottom Up         Hybrid
   1:    6.13 (1.00x)      9.63 (1.00x)      2.98 (1.00x)
   2:    3.30 (1.86x)      6.63 (1.45x)      1.66 (1.80x)
   4:    1.94 (3.16x)      4.35 (2.21x)      1.05 (2.83x)
   8:    1.30 (4.71x)      3.05 (3.15x)      0.78 (3.82x)
  12:    1.11 (5.52x)      2.70 (3.57x)      0.69 (4.32x)
----------------------------------------------------------
Reference: Timing Summary
Threads  Top Down          Bottom Up         Hybrid
   1:    6.54 (1.00x)      5.80 (1.00x)      3.07 (1.00x)
   2:    3.47 (1.89x)      3.37 (1.72x)      1.74 (1.77x)
   4:    2.34 (2.80x)      1.89 (3.07x)      1.13 (2.70x)
   8:    1.53 (4.27x)      1.36 (4.26x)      0.81 (3.78x)
  12:    1.30 (5.04x)      1.19 (4.89x)      0.72 (4.27x)
----------------------------------------------------------
Correctness:

Speedup vs. Reference:
Threads       Top Down          Bottom Up             Hybrid
   1:             1.07               0.60               1.03
   2:             1.05               0.51               1.04
   4:             1.21               0.44               1.08
   8:             1.18               0.45               1.04
  12:             1.17               0.44               1.04
```

打分：

```bash
# ./bfs_grader ../all_graphs

Max system threads = 12
Running with 12 threads

Graph: grid1000x1000.graph

Top down bfs
ref_time: 0.0222338s
stu_time: 0.0287536s

Bottom up bfs
ref_time: 0.897488s
stu_time: 1.31878s

Hybrid bfs
ref_time: 0.329699s
stu_time: 0.0294195s

Graph: soc-livejournal1_68m.graph

Top down bfs
ref_time: 0.126574s
stu_time: 0.114126s

Bottom up bfs
ref_time: 0.087241s
stu_time: 0.178334s

Hybrid bfs
ref_time: 0.0658287s
stu_time: 0.0361178s

Graph: com-orkut_117m.graph

Top down bfs
ref_time: 0.131646s
stu_time: 0.11027s

Bottom up bfs
ref_time: 0.0830849s
stu_time: 0.12143s

Hybrid bfs
ref_time: 0.0500944s
stu_time: 0.0197173s

Graph: random_500m.graph

Top down bfs
ref_time: 3.45043s
stu_time: 3.17138s

Bottom up bfs
ref_time: 7.58714s
stu_time: 10.1624s

Hybrid bfs
ref_time: 1.57072s
stu_time: 1.35378s

Graph: rmat_200m.graph

Top down bfs
ref_time: 1.29146s
stu_time: 1.17429s

Bottom up bfs
ref_time: 1.15881s
stu_time: 1.75001s

Hybrid bfs
ref_time: 0.718519s
stu_time: 0.504066s


--------------------------------------------------------------------------
SCORES :                    |   Top-Down    |   Bott-Up    |    Hybrid    |
--------------------------------------------------------------------------
grid1000x1000.graph         |      2.00 / 2 |     2.88 / 3 |     3.00 / 3 |
--------------------------------------------------------------------------
soc-livejournal1_68m.graph  |      2.00 / 2 |     1.74 / 3 |     3.00 / 3 |
--------------------------------------------------------------------------
com-orkut_117m.graph        |      2.00 / 2 |     2.91 / 3 |     3.00 / 3 |
--------------------------------------------------------------------------
random_500m.graph           |      7.00 / 7 |     8.00 / 8 |     8.00 / 8 |
--------------------------------------------------------------------------
rmat_200m.graph             |      7.00 / 7 |     7.39 / 8 |     8.00 / 8 |
--------------------------------------------------------------------------
TOTAL                                                      |  67.92 / 70 |
--------------------------------------------------------------------------
```

## 结语

总之是熟悉了一点点 OpenMP。

