---
title: "『学习笔记』CMU 15-445 (2024 fall) Note"
slug: "CMU_15-445_database_2024fall_note"
authors: ["Livinfly(Mengmm)"]
date: 2025-11-13T06:46:14Z
# 定时发布
# publishDate: 2023-10-01T00:00:00+08:00
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/note/CMU_15-445_database_2024fall_note"]
categories: ["note"]
tags: ["数据库", "CMU_15-445"]
description: "唉，只能算是浅尝辄止了，后半部分更是摸了。"
image: "cover.jpg" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---
> 封面来源：[@wusem0108](https://x.com/wusem0108/status/1988053389478134218)

## #00: Course Overview & Logistics

C++ 17 编写 / 调试 [bootcamp 熟悉 C++ 11 的特性](https://github.com/cmu-db/15445-bootcamp)

C++ 前置要求，见 P12，同时 P0 页面也有进一步给出一些资料。

## Lecture #01: Relational Model & Algebra

数据库 database 是相互关联的**数据**的有组织的**集合**。

数据库管理系统 DBMS (database management systems)，是管理数据库的软件。

### 扁平文件 Flat File Strawman

扁平文件。

逗号分隔值 comma-separated value (csv)

实体文件 entity file (artists.csv, albums.csv)。

不同的**行**分隔不同的**记录**，同一行内用逗号 comma 来分隔不同的属性 attributes。

schema (attribute 1, attribute 2, ...)

**需要考虑的问题**

- 数据完整性 Data Integrity
- 实现 Implementation
- 持续性 Durability

### 数据库管理系统 Database Management System

数据模型 data model 是描述数据库的数据的概念集合。

- Relational (most common)
- NoSQL (key/value, document, graph)
- Array / Matrix / Vector (for machine learning)

### 关系模型 Relational Model

由 Ted Codd (at IBM Research) in the late 1960s 提出，用于解决早期DBMS中逻辑层与物理层紧密耦合。

1. 以简单数据结构（关系）存储数据库
2. 物理存储由DBMS实现决定
3. 通过高级语言访问数据，DBMS 确定最佳执行策略

**关系模型三要素**

- **结构 Structure**：关系定义及其内容，独立于物理表示
- **完整性 Integrity**：确保数据库内容满足特定约束
- **操作 Manipulation**：访问和修改数据库内容的编程接口

一些术语

- **关系 (Relation)**：无序的属性关系集合（等同于表 table）
- **元组 (Tuple)**：关系中属性值的集合（也称为域 domain）
- **n元关系 (n-ary)**：具有n个属性的关系（等同于 n 列的表 table）
- **主键 (Primary Key)**：唯一标识表中单个元组的属性
- **外键 (Foreign Key)**：指定一个关系中的属性映射到另一个关系的元组
- **约束 (Constraint)**：用户定义的必须满足的条件（如唯一键、外键约束）

### 数据操作语言 Data Manipulation Languages (DMLs)

存储和便利数据库的方法。

- 过程式 Procedural

    明确指定数据库管理系统应该如何获取数据，需要写 how，如 for 等逻辑

- 非过程式 Non-procedural （声明式 Declarative）

    只指定需要什么数据，而不指定如何获取，需要写 what，由 DBMS 来选定逻辑。

### 关系代数 Relational Algebra

关系代数 Relational Algebra 是遍历、操作关系元组集合的基础操作集合，可以构建一个链 chain 的 query。

**Selection**

$\sigma_{predicate}(R)$，SQL: SELECT * FROM R WHERE \<predicate\>

输入一个关系 Relation，指定谓词 predicate（充当过滤器 filter 的角色），输出满足谓词的元组 tuple 的集合（关系 Relation）。

**Projection**

$\pi_{A_1,A_2,. . . ,A_n}(R)$，SQL: SELECT b_id-100, a_id FROM R WHERE a_id = 'a2'

输入一个关系 Relation，指定一些属性 attribute，输出一个关系 Relation，元组 tuples 包含指定属性 attribute。

可以改变属性 attribute 顺序与属性的值。

注意：

attribute 通常可以包含字母(a-z, A-Z)、数字(0-9)和下划线(_)，所以 b\_id-100 是取 b\_id 的值再减 100。

**Union**

$(R \cup S)$，SQL: (SELECT * FROM R) UNION ALL (SELECT * FROM S)

输入两个关系 Relation，输出一个关系 Relation 包含所有（至少出现在其中一个关系 Relation 中）的元组 tuple。

注意：

输入的两个关系 Relation 必须有相同的属性 attribute；

SQL 中 UNION 对重复行只保留一份，UNION ALL 都保留。

**Intersection**

$(R \cap S)$，SQL: (SELECT * FROM R) INTERSECT (SELECT * FROM S)

输入两个关系 Relation，输出一个关系 Relation 包含所有（同时出现在两个关系 Relation 中）的元组 tuple。

注意：

输入的两个关系 Relation 必须有相同的属性 attribute。

**Difference**

$(R - S)$，SQL: (SELECT * FROM R) EXCEPT (SELECT * FROM S)

输入两个关系 Relation，输出一个关系 Relation 包含所有（在 R 且不在 S 中）的元组 tuple。

注意：

输入的两个关系 Relation 必须有相同的属性 attribute。

**Product**

$(R \cross S)$，SQL: (SELECT * FROM R) CROSS JOIN (SELECT * FROM S) 或 SELECT * FROM R, S

输入两个关系 Relation，输出一个关系 Relation 包含所有（可能的笛卡尔积组合，产生 |R| * |S| 个）的元组 tuple。

**Join**

$(R \bowtie S)$，SQL: SELECT * FROM R JOIN S USING (ATTRIBUTE1, ATTRIBUTE2...)

输入两个关系 Relation，输出一个关系 Relation 包含所有（连接两个关系 Relation 中相同的 attribute，合并不同的 attribute 到同一个个 tuple，组合复制）的元组 tuple。

注意：

关于不匹配，即相同属性 attribute，属性值没有同时出现的情况。

还有其他的 Join

Theta Join：基于任意条件的连接（如R.a > S.b）；

Outer Join：保留不匹配的行；

Cross Join：等同于Product操作

效率区别：$(R \bowtie (\sigma_{b\_id=102}(S)))$，$\sigma_{b\_id=102}(R \bowtie S)$

给定 SQL (Structured Query Language) 这样的高级的声明式表示，能够让 DBMS 去决定处理逻辑。

### 其他数据模型 Other Data Models

**Document Data Model** 文档数据模型

记录文档的集合，包含 命名字段 / 值对 field / value的层次结构。

value 包括标量 scalar、数组 array、指向其他文档的指针 pointer。

现代实现使用 JSON，之前包括 XML 等对象 object 表示。

通过耦合对象 object 和数据库，避免"关系-对象阻抗不匹配"。

有优点，但也有前面 flat file 提到的一些缺点。

**Vector Data Model** 向量数据模型

表示用于最近邻搜索 nearest-neighbor search （准确 / 估计）的一维数组

用于基于 ML 模型生成的嵌入 embedding 的语义搜索 semantic search

许多关系型DBMS已添加向量索引功能（如 pgvector）

**Databases are ubiquitous.**

## Lecture #02: Modern SQL

声明式的 query，起源于 IBM **System R** in the 1970s。

SQL 是在关系型数据库管理系统上，与关系型数据库交互的标准语言。

### 关系语言 Relational Languages

- **数据操作语言(DML)**：SELECT, INSERT, UPDATE, DELETE
- **数据定义语言(DDL)**：定义表 tables、索引 indexes、视图 views 等对象的结构
- **数据控制语言(DCL)**：管理安全性 Security 和访问控制
- **其他**：视图定义、完整性约束、事务管理

**关键区别**：关系代数基于**集合** set (无序，无重复)，而SQL基于**包** bag (无序，允许重复)

后面都是些语法说明，就散记写查的。

GROUP BY，聚合默认是整个结果集为一个组，如果要按某一字段划分，组内分别聚合，则需要 GROUP BY。

WHERE 在 GROUP BY 前，原始数据行；HAVING 在 GROUP BY 后，过滤分组结果。

ON用于连接条件，WHERE用于过滤。

SQL 查询的执行顺序是：

1. FROM/JOIN（确定数据源）
2. WHERE（过滤原始行）
3. GROUP BY（分组）
4. HAVING（过滤分组结果）
5. SELECT（选择输出列）
6. ORDER BY（排序结果）

HAVING 阶段 SELECT 还不存在。

字符串大小写敏感 case sensitive，只允许单引号。

- `%` 匹配任意子串，`_` 匹配任一字母。
- 函数 SUBSTRING(S, B, E) and UPPER(S)...
- 连接符 `||`

INTO 输出重定向

输出控制。

## Lecture #03: Database Storage (Part I)

### 存储 Storage

易失性设备 Volatile Device，byte-addressable，memory 内存

非易失性设备 Non-Volatile Device，block/page addressable，better at sequential access，disk 磁盘，SSD HDD

persistent memory

NVMe (non-volatile memory express)

缓存池 buffer pool 来控制 disk 和 memory 之间的数据移动。

### DBMS vs. OS

**顶层设计目标**

支持超过可用内存的数据库。

像是虚拟内存 virtual memory 的顶层设计目标，

其中的一个实现方式是把文件内容 mmap 到进程中，但如果 mmap 发生 page fault，进程会堵塞。

所以永远不在 DBMS 中使用 mmap。

**The operating system is not your friend.**

使用以下的指令来使用 OS。

- `madvise` 告诉 OS 什么时候想读某 page
- `mlock` 不要换出某范围的内存
- `msync` 刷新某范围的内存

虽然 OS 有不少可以提供的函数功能，但为了**可控**和**性能**，DBMS 自己实现。

### 文件存储 File Storage

文件层级 file hierarchy

单文件 single file (e.g. SQLite)

DBMS 的存储管理器，管理 database 的文件（page 的集合）

DBMS 的 page 的三个概念

1. 硬件页 hardware page (usually 4 KB)
2. 系统页 OS page (4 KB)
3. database page (1-16 KB)

存储设备保证了原子写入 atomic write，在 HW page 下。

超出的时候，DBMS 需要为安全写出产生额外开销，所以，一般只读的工作负载，开大点的 page size。

### 数据库堆 Database Heap

有许多方式找到页 page 的位置，如堆文件 heap file（页 page 的无序集合）。

1. 链表 Linked List，页头有指针指向 free page 和 data page，查找只能串型查找
2. 页面目录 Page Directory

### 页布局 Page Layout

每格页 page 包含 header

- Page size
- Checksum
- DBMS version
- Transaction visibility
- Self-containment (Oracle...)

1. **Slotted-pages 开槽页**

    维护槽 slot 的个数，最后使用的槽 slot 的偏移 offset，槽 slot 的阵列。

    槽 slot 头到尾增长，data tuple 尾到头增长

2. **Log-Structured 日志结构**

### 元组布局 Tuple Layout

1. 元组头 Tuple Header，元数据

2. 元组数据 Tuple Data

3. 唯一标识符 Unique Identifier，常见 page_id + (offset / slot)

4. 非规范化的元组数据 Denormalized Tuple Data

    两个有关联的表，DBMS 可以预连接 pre-join，这样，就只需要从一个表读，而不是两个不同的表，更高效。

    但更新会更贵，因为每个 tuple 需要的空间更大。

## Lecture #04: Database Storage II

### 日志结构存储 Log-Structured Storage

开槽页 Slotted-Page 面向元组 tuple-oriented 的问题

- 碎片化 Fragmentation
- 无效磁盘 I/O，面向块的非易失性存储，每次都要读整块取更新一个元组 tuple
- 随机磁盘 I/O 效率低

如果只能创建新页 page 且不能复写 overwrite，可以解决上面的问题。

基于 LSFS (log-structured file systems) 和 LSM Tree (log-structured merge tree)。

DBMS 存储元组的改变的日志记录，在内存中的数据结构中应用改变 MemTable，再依次把改变写到磁盘中 SSTable。

PUT / DELETE，原地更新在内存中。

读一条记录的时候，先检查 MemTable，不存在的话找 SSTables，从新到旧，使用二分。

为了优化，在内存中维护 SummaryTable，跟踪其他的元数据 min/max key..., key filter。

**压缩 Compaction**

在写负载重的任务中，SSTable 会很多， 周期性使用合并排序，压缩最近的跨页 page 的元组修改。

**权衡 Treadeoff**

- 顺序写快，对只附加的存储好
- 写可能慢
- 压缩开销大
- 对写入放大影响，每个逻辑写，会产生多个物理写。

### 索引组织的存储 Index-Organized Storage

数据直接存在索引结构里，索引即数据，天然有序。

### 数据表示 Data Representation

**填充 Padding** 和 **重排 Reordering** 实现 word-aligned，提高访存效率。

## Lecture #05: Storage Models & Compression

### 数据库工作负载 Database Workloads

**OLTP (Online Transaction Processing)**

对单个实体 entity 的快速、简单、重复的查询，写多读少。Write Heavy

**OLAP (Online Analytical Processing)**

时间久、复杂的查询，读多写少，分析数据。 Read Heavy

**HTAP (Hybrid Transaction + Analytical Processing)**

混合。

### 存储模型 Storage Models

元组 tuple 的存储

**N-Ary Storage Model (NSM)**

N 元组存储模型、行存储 row store，在 OLTP write-heavy 的任务中表现好，因为一次就能拿到所有的属性。

但不好压缩。

**Decomposition Storage Model (DSM)**

分解存储模型、行存储 column store，在 OLAP read-heavy 的任务表现好，因为常分析属性的子集。

在行存储的情况下，把 tuple 放一起有**固定长度偏移 fixed-length offsets** 或 **嵌入元组编号 embedded tuple ids**。

**Partition Attributes Across (PAX)**

跨属性分割。

综合前两种方式的列的访问，和行的局部性。

### 数据库压缩 Database Compression

在只读分析的工作负责中的常用优化。

块、元组（NSM）、属性、列（DSM）。

**压缩率**和**压缩速度**。

### 列压缩 Columnar Compression

**run-length encoding (RLE)**

游程编码、运行长度编码。

值 + 起始偏移 + 连续长度。

DBMS 需要预先排序。

**Bit-Packing Encoding**

根据数据范围，只存有效位。

**Mostly Encoding**

Bit-Packing 基础上，加上特殊标记，表示在什么时候会超过最大值，维持 look-up table 来存储。

**Bitmap Encoding**

表示第 i 个值在不在。

常常把位图分成小段，避免占用大块连续内存。

适用于种类少的时候。

Roaring Bitmaps 可以用来压缩稀疏数据。

**Delta Encoding**

存储和相邻数值的差值。

**Incremental Encoding**

记录常见的前后缀，对排序后的数据好。

**Dictionary Compression**

需要支持保序编码 order-preserving encodings，使得能直接在编码后的数据上操作。

## Lecture #06: Buffer Pools

buffer pool manager 控制 page 在内存和存储的移动。

优化目标是时 Temporal 空 Spatial 的控制，

**page directory** = page_id => page_address

**page table** = frame_id => page_id

**lock**，能够回滚 roll back 修改。

**latch**，不需要回滚，锁操作过程。

Least Recently Used (LRU)

CLOCK

在 sequential flooding 顺序扫描中表现不佳。

LRU-K

localization优化局部性、减少对剩余的污染。

priority hints

 Direct I/O (via the O DIRECT flag) 来绕过操作系统的 cache

### 缓冲池的优化 Buffer Pool Optimizations

**Multiple Buffer Pools**

多个缓冲池，不同的用途用不同的缓冲池。

采用 Object ID 或 Hash 来找到 page_id 应该找哪个缓存池。

**Pre-fetching**

预取，特别是在顺序扫描的时候。

**Scan Sharing (Synchronized Scans)**

同步扫描，共享一个扫描。

**Buffer Pool Bypass**

缓冲池旁路，如顺序扫描等操作，不通过缓冲池，而通过开辟内存的另外的地方。

防止污染缓冲池。

由于 DBMS 能有更多的信息做判断，所以总是比 OS 的操作好，Evictions, Allocations, Pre-fetching。

## Lecture #07: Hash Tables

DBMS 的 hash table 在内部使用，不需要加密，指关心**速度**和**冲突率**，哈希函数目前的 sota 是 facebook **xxhash3**。

### 静态哈希策略 Static Hashing Schemes

**Linear Probe Hashing**

线性探测哈希，没找到就向后找，删除用 tombstones 来替换。

短的字符串直接存，长的才哈希。

为了维护不同大小的哈希表，维护版本，复用原本的哈希表。

Google’s **absl::flat_hash_map** 是 sota

**Cuckoo Hashing**

布谷鸟哈希，多个哈希函数 / 种子，都被占了的时候，踢出原本在的，让它重新哈希。

### 动态哈希策略 Dynamic Hashing Schemes

能够空间不足的时候，重建哈希表。

**Chained Hashing**

链哈希。拉链法，hash 到链表的桶，然后遍历链表。

**Extendible Hashing**

可扩展哈希。拉链法没有限制链表的长度，可扩展哈希，使用必要时分裂当前桶的操作来缓解这一点。

全局深度、局部深度，具体逻辑暂时没有去了解。

**Linear Hashing**

线性哈希。不在超出的时候立刻分裂，按照指针，一个一个分裂，避免一次性处理过多。

## Lecture #08: Indexes & Filters I

table index 表索引，常不用 hash table，因为不支持范围扫描、部分键查找。

B- Tree 在所有节点存值，B+ Tree 只在叶子节点存值。

B+ Tree 的设计选择：

节点大小 Node size、合并阈值 Merge Threshold、变长键 Variable Length Keys（指针、变长节点（内存效率不好）、填充、键映射）

内部节点，M/2 − 1 <= num of keys <= M − 1。

节点内搜索：

线性、二分、插值。

优化方法：

前缀压缩、去重、后缀截断、指针变换、大量插入（自底向上的构建）、写优化（Bϵ-Tree，懒写入）

## Lecture #09: Indexes II

过滤器 filter，回答元素是否在集合中。

快速回答，加速查询。（可能假阳性 false positive）

### 布隆过滤器 Bloom filter

位图 bitmap 实现的概率过滤器，假阳性率可以计算出来，需要定义**位图的大小**、**哈希函数的数量大小**。

Insert，算出每个 hash value，对位图大小取模 modular，bitmap 的对应位置 1。

lookup，找有无这样的位图。

**变体**

计数布隆过滤器 Counting Bloom filter，用整数序列代替位图，支持删除操作。

布谷鸟过滤器 Cuckoo filter，Cuckoo Hash 的思路，存储元素的内存占用，支持删除操作。

精简范围过滤器 Succinct range filter，不可变的过滤器，支持范围查询。

### 跳表 Skip List

多级链表，没有重平衡的需要。

**操作**

find，顶层链表开始，逐级下移直到找到目标或确定不存在。

insert，通过抛硬币随机决定新节点的层数，从底层向上逐层插入。

delete，先标记节点为删除状态（避免并发读取问题），后续清理时从顶层向下移除节点。

实现简单，反向扫描复杂，缓存不友好。

### 字典树 Trie

按字符/位存储键值的前缀信息，每个节点代表一个字符/位，指针指向子节点，操作时间复杂度取决于键的长度。

**压缩优化**

水平压缩，用数组替代映射表（如256字节数组），减少指针开销。

垂直压缩（Radix Tree），合并单子节点路径，减少树深度，提升查询效率。（假阳性）

### 倒排索引 Inverted Index

关键词搜索，不同于前面提到的点检索、范围检索，将术语映射到包含该术语的记录列表（posting list）。

从关键词查找文档。

**实现方案**

**Lucene**，有限状态转换器（FST, finite state transducer），每条边存储权重，通过权重和计算精确位置。

**PostgreSQL**，B+树存储词典，小posting list直接存ID，大列表用嵌套B+树。

### 向量索引 Vector Index

语义搜索，处理嵌入向量（embedding）的相似性查询。

**倒排文件分区** Inverted File ，通过聚类将向量分组，查询时定位到相关组，如 IVFFlat。

**可导航小世界**，Navigable Small Worlds，构建向量邻居图，通过贪婪搜索逼近目标，如 FAISS, HNSWlib。

## Lecture #10: Index Concurrency Control

物理正确性：确保数据结构内部指针有效，不访问无效内存

逻辑正确性：保证事务读取到预期值

**锁(Locks)**：高层逻辑原语，保护数据库内容（如表、元组），事务期间持有，系统自动处理死锁检测

**闩锁(Latches)**：底层原语，保护内部数据结构，短期持有（如单次操作），需开发者手动避免死锁

### 闩锁的实现方式 Latch Implementations

compare-and-swap (CAS)

**Test-and-Set Spin Latch (TAS)**

使用CAS指令自旋等待，std::atomic

单指令加锁/解锁（x86），DBMS完全控制，高竞争时效率低，缓存一致性问题（多线程轮询）。

**Blocking OS Mutex**

用户空间自旋+内核级互斥量，std::mutex

实现简单，开销大（~25ns/次），需OS调度，不推荐DBMS内部使用。

**Reader-Writer Latches**

支持读写模式，多读并发，std::shared mutex

允许多个读同时进行，提高读密集型场景性能，需管理读写队列避免饥饿，存储开销大（需额外元数据）。

### 哈希表闩锁 Hash Table Latching

**Page Latches**

每页一个读写闩锁，**读多**写少场景，单页内操作频繁。

**Slot Latches**

每个槽独立闩锁，高并发**写入**场景，槽间访问分散。

**无闩锁**，CAS指令实现的 Linear Probe Hash。

### B+Tree Latching

**Basic Latch Crabbing Protocol**

find，从根节点出发，获取子节点闩锁，再释放父节点闩锁。

insert / delete，自顶向下获取所有需要的闩锁，子节点安全（插入：节点未满；删除：节点半满以上），则释放祖先节点。

**Improved Latch Crabbing Protocol**

insert / delete，先用 read latch 像 find 到叶子节点，叶子安全直接操作，不安全释放，重新执行上面的协议。

**Leaf Node Scans**

如扫描和删除，不同遍历方向导致的死锁。（因为分裂 / 合并，需要同时访问两个相邻的节点）

解决方法：

无等待模式 No-wait mode，获取失败则重试；

根据进度来安排有限度。

## Lecture #11: Sorting & Aggregation Algorithms

### Query plan

数据库把 SQL 编译成操作树——Query plan。

### 排序 Sorting

Top-N Heap Sort，External merge sort

Two-way Merge Sort

General (K-way) Merge Sort

Double Buffering Optimization，双倍缓冲区，可用缓冲区减半，但取数据和计算同步进行。

Comparison Optimizations，如 **Code specialization**，例如 template specialization；字符串的后缀截断 suffix truncation。

Using B+Trees，利用 B+Tree index，无需计算，顺序访问。

### 聚合 Aggregation

**Sorting**

先过滤再排序，减少排序的数据。

**Hashing**

不追求顺序的时候。

1. 分区
2. 再哈希

## Lecture #12: Joins Algorithms

数据库设计的目标是减少重复信息，因此常通过**规范化** normalization theory 将数据拆分到多个表中，再使用 **join** 重组数据。

通常将较小的表作为**外表（outer table）**。

### Join Operators

实际一般混合使用。

**Early Materialization**

将匹配的所有列值复制到中间结果中，后续操作无需回基表，但占用更多内存。

**Late Materialization**

仅复制连接键和记录ID。适合列存储，减少内存占用。

### Cost Analysis

主要成本指标：**磁盘 I/O 次数**。

不考虑输出结果的 I/O，因为所有算法的输出相同。

注意选择合理的连接类型。

### Nested Loop Join

外部 for 循环中的表称为外表，而内部 for 循环中的表称为内表。

希望“较小”的表作为外表。

**简单嵌套循环连接**

将外表中的每个元组与内表中的每个元组进行比较。

成本： M+(m×N)

**块嵌套循环连接**

对于外表中的每个块，获取内表中的每个块，并比较这两个块中的所有元组。

成本： M+((R中的块数)×N)

块大小：如果 DBMS 有 BB 个可用缓冲区来计算连接，它可以使用 B−2B−2 个缓冲区来扫描外表。页数较少的表将作为外表。它将使用一个缓冲区来扫描内表，一个缓冲区来存储连接的输出。  

成本： M+(MB−2)×N

**索引嵌套循环连接**

先前的嵌套循环连接算法性能不佳，因为 DBMS 必须进行顺序扫描来检查内表中的匹配项。

外表将是没有索引的那个表。内表将是有索引的那个表。

成本：M+(m×C)

### Sort-Merge Join

该算法的最坏情况是如果两个表中所有元组的连接属性都包含相同的值，这在实际数据库中极不可能发生。在这种情况下，合并的成本将是 M⋅NM⋅N，因为对于每个外部页，我们将不得不匹配整个内部表。但大多数时候，键几乎是唯一的，因此可以假设合并成本大约为 M+NM+N。

假设 DBMS 有 BB 个缓冲区可用于该算法：

_表 RR 的排序成本：_ 2M×(1+⌈logB−1⌈MB⌉⌉)
_表 SS 的排序成本：_ 2N×(1+⌈logB−1⌈NB⌉⌉)

_合并成本：_ (M+N)

### Hash Join

**基本哈希连接**

Build Phase：扫描外表，根据哈希函数 h1 构建内存中的 Hash Table。

Probe Phase：扫描内表，对每条元组使用 h1 在 Hash Table 中查找匹配。


一个优化是使用布隆过滤器

布隆过滤器是一种概率数据结构，**可以放入 CPU 缓存**中，并回答“键 x 在哈希表中吗？”的问题，回答要么是“绝对不在”，要么是“可能在”。提供了额外元数据，**横向信息传递**。

**Grace 哈希连接 / 分区哈希连接**

优化原理：当哈希表太大无法放入内存时，将两个表都使用同一个哈希函数 h1 分区并写入磁盘。然后，逐对加载对应的分区到内存中进行连接。

递归分区：如果单个分区仍然过大，使用另一个哈希函数 h2 进行递归分区，直到每个子分区都能放入内存。

代价：3(M + N)，源于对两个表的两次读写（分区+探测）。

**Hybrid Hash Join**：一种自适应优化，用于处理**数据倾斜**。它将**热分区**（频繁出现的键）保留在内存中，并在 **Build Phase** 时立即进行连接，而不是将其溢出到磁盘。

>下面将是用 AI 对 Note 进行进一步提炼，复制（略加修改得来的）

## Lecture #13: Query Processing I

### 查询计划与执行概览

**查询计划 (Query Plan)** 是一个由**算子 (Operators)** 组成的**有向无环图 (DAG)**。

**流水线 (Pipeline)**：一系列算子，数据在其中连续流动，无需中间存储。

**流水线破坏者 (Pipeline Breaker)**：必须等待其子算子**产出所有元组 (Emit All Their Tuples)** 后才能开始工作的算子，例如 **Join (构建端)**、**子查询 (Subqueries)**、**排序 (Order By)**。

### 处理模型 (Processing Models)

处理模型定义了系统如何执行一个**查询计划 (Query Plan)**。

**A. Iterator Model / Volcano Model / Pipeline Model**

- **原理**：每个算子实现一个 `Next()` 函数。调用时返回**单条元组 (Single Tuple)** 或 `null`。通过递归调用子算子的 `Next()` 来**拉取 (Pull)** 数据。
    
- **控制流 (Control Flow)**：自顶向下**拉取 (Pull)**。
    
- **优点**：
    
    - 输出控制简单，适合**流水线 (Pipelining)**。
        
    - 几乎所有的**基于行 (Row-Based)** 的系统都使用它。
        
- **缺点**：每个元组都调用 `Next()`，导致高频函数调用，可能成为性能瓶颈。
    

**B. Materialization Model**

**原理**：每个算子一次处理**所有输入 (All Input)**，并一次性**物化 (Materialize)** **所有输出 (All Output)**。

**控制流 (Control Flow)**：自顶向下拉取，但每次处理一批。

**优点**：

函数调用次数少，适合**OLTP (Online Transaction Processing)** 负载，因为这类查询通常只涉及少量元组。

可结合**Late Materialization (延迟物化)** 优化。

**缺点**：不适合中间结果集大的查询，可能导致内存爆炸。


**C. Vectorized / Batch Model**

**原理**：每个算子一次处理并返回**一批数据 (a Batch of Tuples)**。Batch 是一组元组的集合（如 100-1000 个）。

**控制流 (Control Flow)**：自顶向下拉取，但每次处理一个 **Batch**。

**优点**：

显著减少函数调用次数。

更适合利用 **SIMD (Single Instruction Multiple Data)** 指令进行向量化计算，优化 CPU 利用率。

非常适合 **OLAP (Online Analytical Processing)** 负载。

**现代趋势**：许多现代系统（如 Snowflake, Amazon Redshift）采用此模型。

### 访问方法 (Access Methods)

定义了如何访问表中存储的数据，是查询计划中的叶节点。

**A. 顺序扫描 (Sequential Scan)**

**原理**：迭代表中的每一页，评估**谓词 (Predicate)** 并决定是否发出元组。

**优化方法**：

**预取 (Prefetching)**

**缓冲池旁路 (Buffer Pool Bypass)**：避免**顺序淹没 (Sequential Flooding)**。

**区域映射 (Zone Map)**：**无损数据跳过 (Lossless Data Skipping)**，通过预计算聚合值判断是否需要访问该页。

**延迟物化 (Late Materialization)**：列存数据库中，延迟组合元组直至查询计划上层。

**近似查询 (Approximate Queries)**：**有损数据跳过 (Lossy Data Skipping)**，对数据子集进行采样以快速得到近似结果。


 **B. 索引扫描 (Index Scan)**

**原理**：DBMS 选择一个**索引 (Index)** 来查找查询所需的元组。

**索引选择因素**：索引包含的属性、查询引用的属性、**值域 (Value Domains)**、**谓词组合 (Predicate Composition)**、键是否唯一等。

**C. 多索引扫描 (Multi-Index Scan)**

**原理**：使用多个索引，分别计算满足条件的**记录ID集合 (Sets of Record IDs)**，然后根据谓词（如 AND）合并这些集合（使用**位图/Bitmaps**、**哈希表/Hash Tables** 或 **布隆过滤器/Bloom Filters**），最后获取记录并应用剩余谓词。

### 修改查询 (Modification Queries)

**INSERT, UPDATE, DELETE** 算子负责检查**约束 (Constraints)** 和更新索引。

**万圣节问题 (Halloween Problem)**：一个**更新 (Update)** 操作改变了元组的物理位置，导致**扫描算子 (Scan Operator)** 多次访问该元组。

**解决方案**：跟踪每个查询已修改的**记录ID (Record IDs)**。

例子 

“给所有工资小于25000的员工加薪百分之十”

“所有工资小于25000的哪些记录被无限次数得加薪了百分之十，直到工资大于等于25000为止。”

重复扫描了修改后的元组。

### 表达式求值 (Expression Evaluation)

**WHERE 子句**被表示为一棵**表达式树 (Expression Tree)**。

**传统方式**：遍历树并逐个求值，速度慢。

**优化方式**：
- **代码生成 (Code Generation) / JIT编译 (JIT Compilation)**：直接编译表达式为高效代码。
- **常量折叠 (Constant Folding)**：预先计算常量表达式。
- **公共子表达式消除 (Sub Expression Elimination)**：识别并消除重复子表达式。
- **向量化求值 (Vectorized Evaluation)**：对批次元组同时求值。

## Lecture #14: Query Execution II

### 并行执行背景

并行执行通过多个**工作线程 Worker** 处理查询，带来关键优势：  

**提升性能**：更高的吞吐量与更低的延迟  

**提升响应与可用性**

**降低总拥有成本 Total Cost of Ownership**

### 并行与分布式数据库

**并行数据库 Parallel DBMS**  
资源物理位置相近，通过高速互联通信，通信快速、廉价、可靠。

**分布式数据库 Distributed DBMS**  
资源可能分布在全球，通过较慢的公网互联，通信成本高且必须考虑故障。

两者对应用程序均呈现为单一逻辑数据库。

### 进程模型 Process Models

定义了系统如何处理多用户并发请求。

**进程每工作线程 Process per Worker**  
每个工作线程是独立的操作系统进程。  
依赖操作系统调度，可使用共享内存或消息传递。  
一个进程崩溃不会导致整个系统崩溃。  
例如 IBM DB2, Postgres, Oracle。

**线程每工作线程 Thread per Worker**  
单一进程内包含多个工作线程。  
DBMS 拥有完全的调度控制权，上下文切换开销更小。  
一个线程崩溃可能杀死整个数据库进程。  
近 20 年的现代 DBMS 普遍采用，如 Microsoft SQL Server, MySQL。

**嵌入式数据库 Embedded DBMS**  
数据库系统运行在应用程序的地址空间内，由应用程序负责调度。  
例如 DuckDB, SQLite, RocksDB。

**调度 Scheduling**  
DBMS 需要为每个查询计划决定在何处、何时以及如何执行，它比操作系统掌握更多信息，应优先由其决策。

### 查询间并行 Inter Query Parallelism

同时执行多个不同的查询。  
对于只读查询，协调简单；对于更新操作，会产生复杂冲突。

### 查询内并行 Intra Query Parallelism

并行执行单个查询中的操作，降低长查询的延迟。  
遵循**生产者/消费者 Producer/Consumer**范式。

**intra-operator 并行（水平）**  
将算子分解为独立的**片段 Fragment**，在不同数据子集上执行相同功能。  
使用**交换算子 Exchange Operator** 合并子算子结果：  
**收集 Gather**：将多个工作线程的结果合并为单一输出流。  
**分发 Distribute**：将单一输入流拆分为多个输出流。  
**重分区 Repartition**：在多个输入流和输出流之间重新组织数据。

**inter-operator 并行（垂直）**  
也称为**流水线并行 Pipelined Parallelism**，重叠算子执行，无需物化中间结果，数据直接从一阶段流入下一阶段。广泛用于流处理系统。

**Bushy 并行**  
**intra-operator** 和 **inter-operator** 并行的混合模式，工作线程同时执行查询计划不同段的多个算子。同样使用交换算子合并中间结果。

### I/O 并行

为避免磁盘成为瓶颈，将数据库拆分到多个存储设备。

**多磁盘并行 Multi Disk Parallelism**  
通过存储设备或 RAID 配置，由操作系统/硬件将数据库文件分布到多个存储设备。对 DBMS 透明。

**数据库分区 Database Partitioning**  
将数据库拆分为不相交的子集，分配到不同的磁盘。  
可以在文件系统级别实现，对应用程序理想情况下是透明的。

## Lecture #15: Query Planning & Optimization

SQL是**声明式语言 Declarative Language**，仅说明要计算什么，而非如何计算。  

**查询优化器 Query Optimizer** 负责将SQL语句转换为最优的**可执行查询计划 Executable Query Plan**。  

查询优化是DBMS中最难构建的部分。

### 逻辑 vs. 物理计划

**逻辑计划 Logical Plan** 大致对应于关系代数表达式。  
**物理计划 Physical Plan** 定义了使用特定**访问路径 Access Path** 的具体执行策略。  
逻辑计划与物理计划之间并非总是一一对应。

### 查询优化类型

**基于规则的优化 Rule Based Optimization**  
使用静态**启发式规则 Heuristics** 来匹配查询模式并转换计划，无需检查数据本身。  
例如**谓词下推 Predicate Pushdown**、**投影下推 Projection Pushdown**。

**基于成本的优化 Cost Based Optimization**  
读取数据并估算等效计划的执行**成本 Cost**，选择成本最低的计划。

### 成本估算 Cost Estimations

成本模型评估的指标包括：CPU、磁盘I/O、内存、网络。  
为避免穷举所有可能计划（对于n路连接有 $4^n$ 种顺序），优化器必须限制搜索空间。

**统计信息 Statistics**  
DBMS在**内部目录 Internal Catalog** 中维护关于表、属性和索引的统计信息。  
关键统计信息：  
$N_R$​：关系R中的元组数量  
$V(A,R)$：属性A的不同取值数量 

**选择基数 Selection Cardinality**

$SC(A,R)$：属性A的平均记录数，计算公式为 $\frac{N_R}{V(A,R)​​}$

**选择性 Selectivity** 

谓词P的**选择性 Selectivity** 是满足条件的元组比例，等效于该谓词为真的概率。  
复杂选择性计算依赖于三个关键假设：  

**均匀数据 Uniform Data**：取值分布是均匀的。  
**独立谓词 Independent Predicates**：不同属性上的谓词相互独立。  
**包含原则 Inclusion Principle**：连接键的域相互重叠，内表中的每个键在外表中都存在。  
这些假设在真实数据中常常不成立。

### 直方图与采样

**直方图 Histograms** 用于处理倾斜 skewed 数据，减少存储开销。  
**等宽直方图 Equi-Width Histogram**：每个桶的取值区间宽度相同。  
**等深直方图 Equi-Depth Histogram**：每个桶的总出现次数大致相同。

**采样 Sampling** 
对具有相似分布的表的较小副本应用谓词，以估算选择性。

### 单关系查询计划

主要挑战是选择最佳**访问方法 Access Method**（顺序扫描、索引扫描等）。  
OLTP查询通常是**可优化查询 Sargable**，存在一个可通过简单启发式规则选择的最佳索引。

### 多关系查询计划

随着连接数增加，可选计划数量急剧增长，必须限制搜索空间。

**生成式 / 自底向上优化 Generative / Bottom up Optimization**  
从无到有构建计划。例如 IBM System R, Postgres。  
使用动态编程确定最佳连接顺序，构建**左深树 Left Deep Tree**。

**转换式 / 自顶向下优化 Transformation / Top down Optimization**  
从期望的结果开始，向下寻找最优计划。例如 Microsoft SQL Server, CockroachDB。
执行**分支限界搜索 Branch and Bound Search**，将逻辑算子转换为物理算子。

### 嵌套子查询 Nested Sub Queries

DBMS将WHERE子句中的嵌套子查询视为接受参数并返回单个值或值集合的函数。

**重写 Rewriting**  
通过**解相关 De correlating** 或**扁平化 Flattening** 将嵌套子查询重写为JOIN。

**分解 Decomposition**  
将嵌套查询分解，将结果存储到临时表中。

### 表达式重写 Expression Rewriting

将查询表达式转换为最小的表达式集合。

**不可能谓词 Impossible Predicates**  
在优化时评估表达式，消除不可能条件。

**合并谓词 Merging Predicates**  
合并冗余的谓词范围。

## Lecture #16: Concurrency Control Theory

### 动机

并发控制需解决两个核心问题：  
**丢失更新问题 Lost Update Problem (并发控制 Concurrency Control)**：如何避免同时更新记录时的竞态条件。  
**持久性问题 Durability Problem (恢复 Recovery)**：如何在发生断电等故障时确保数据库处于正确状态。

### 事务 Transactions

**事务 Transaction** 是在共享数据库上执行一个或多个操作（如SQL查询）的序列，以完成某个高级功能。它是数据库变更的基本单位，必须是**原子性 Atomic**的。

**简易系统 Strawman System**  
一次只执行一个事务，通过复制整个数据库文件来实现。该方法性能低下，无法并发。

### 定义

数据库可表示为一组固定的命名**数据对象 Data Objects**。  
**事务 Transaction** 是对这些对象的**读 Read**和**写 Write**操作序列。  
事务边界由客户端定义，以**BEGIN**开始，以**COMMIT**或**ABORT**结束。  
正确性标准由**ACID**准则保证。

### ACID：原子性 Atomicity

保证事务中的所有操作要么全部发生，要么全部不发生。

**方法一：日志记录 Logging**  
记录所有操作以便在事务中止时**撤销 Undo**。被现代系统广泛使用。

**方法二：影子分页 Shadow Paging**  
事务修改页的副本，仅在提交时才使页面可见。运行时性能通常较差，恢复简单，实践中较少使用。

### ACID：一致性 Consistency

确保数据库所代表的“世界”在逻辑上是正确的。

**数据库一致性 Database Consistency**：数据库准确建模现实世界并遵循完整性约束。  
**事务一致性 Transaction Consistency**：确保事务一致性是应用程序的责任。

### ACID：隔离性 Isolation

为事务提供一种**幻觉 Illusion**，使其感觉在系统中是单独运行的。并发执行事务的结果应与某种串行执行的结果相同。

**并发控制 Concurrency Control**  
**并发控制协议 Concurrency Control Protocol** 决定如何在运行时正确交错执行多个事务的操作。

**悲观并发控制 Pessimistic**：假定事务会冲突，从而预先防止问题发生。之前加锁。
**乐观并发控制 Optimistic**：假定冲突很少发生，在提交时再处理冲突。之后修正。

**执行调度 Execution Schedule**  
DBMS执行操作的顺序称为**执行调度 Execution Schedule**。目标是最大化并发的同时确保输出“正确”。

**可串行化调度 Serializable Schedule**：一个与某种串行执行等效的调度。

**冲突 Conflict**  
两个操作在不同事务中，针对同一对象，且至少有一个是写操作时，发生冲突。
**读-写冲突 Read Write Conflicts ("不可重复读 Unrepeatable Reads")**  
**写-读冲突 Write Read Conflicts ("脏读 Dirty Reads")**  
**写-写冲突 Write Write conflict ("丢失更新 Lost Updates")**

**冲突可串行化 Conflict Serializability**  
两个调度是**冲突等效 Conflict Equivalent**的，当且仅当它们包含相同事务的相同操作，并且每对冲突操作的顺序相同。  
一个调度是**冲突可串行化 Conflict Serializable**的，当且仅当其**依赖图 Dependency Graph (优先图 Precedence Graph)** 是无环的。

**视图可串行化 View Serializability**  
一种更弱的可串行化定义，允许**冲突可串行化 Conflict Serializable**和**盲写 Blind Writes**（不先读值就直接写）。允许更多调度，但难以有效执行，实践中不常用。

**调度宇宙 Universe of Schedules**  
串行调度 ⊂ 冲突可串行化调度 ⊂ 视图可串行化调度 ⊂ 所有调度

### ACID：持久性 Durability

已提交事务的所有更改在崩溃或重启后必须是**持久的 Durable**。通常使用**日志记录 Logging**或**影子分页 Shadow Paging**来确保，要求更改存储在**非易失性存储器 Non Volatile Memory**中。

## Lecture #17: Two-Phase Locking

### 事务锁 Transaction Locks

DBMS使用**锁 Locks**来动态生成**可串行化 Serializable**的执行调度，以保护数据库对象在并发访问时的安全。

**锁 Locks** 与 **闩 Latches** 的区别：  
**锁 Locks** 保护数据库中的值免受并发事务影响。  
**闩 Latches** 保护DBMS内部数据结构免受并发线程影响。

**基本锁类型**：  
**共享锁 Shared Lock (S LOCK)**：允许多个事务同时读取同一对象。  
**排他锁 Exclusive Lock (X LOCK)**：允许事务修改对象，阻止其他事务获取任何其他锁。

事务必须向**锁管理器 Lock Manager**请求锁，锁管理器根据当前锁的持有情况授予或阻塞请求。事务在不再需要锁时必须释放它们。

### 两阶段锁 Two Phase Locking

**两阶段锁 2PL** 是一种**悲观并发控制 Pessimistic Concurrency Control**协议，用于动态判断是否允许事务访问数据库中的对象。

**阶段一：增长阶段 Growing Phase**  
事务从锁管理器请求它所需的所有锁。

**阶段二：收缩阶段 Shrinking Phase**  
事务在释放第一个锁后进入此阶段，此阶段只允许释放锁，不允许获取新锁。

2PL本身足以保证**冲突可串行化 Conflict Serializability**，但它容易导致**级联中止 Cascading Aborts**（一个事务中止导致另一个事务必须回滚），并且仍然可能存在**脏读 Dirty Reads**和**死锁 Deadlocks**。

### 强严格两阶段锁 Strong Strict Two Phase Locking

也称为**严谨两阶段锁 Rigorous 2PL**，是2PL的一种变体，事务仅在提交时才释放所有锁。

优点：避免了级联中止，并且可以通过恢复修改元组的原始值来回滚已中止事务的更改。  
缺点：生成更保守/悲观的调度，限制了并发性。

**调度宇宙 Universe of Schedules**  
串行调度 ⊂ 强严格2PL调度 ⊂ 冲突可串行化调度 ⊂ 视图可串行化调度 ⊂ 所有调度

### 死锁处理 Deadlock Handling

**死锁 Deadlock** 是事务之间相互等待释放锁的循环。2PL中处理死锁有两种方法：检测和预防。

**方法一：死锁检测 Deadlock Detection**  
DBMS创建一个**等待图 Waits For Graph**，其中节点是事务，如果事务 Ti 正在等待事务 Tj 释放锁，则存在一条从 Ti 到 Tj 的有向边。  
系统定期检查等待图中是否存在环，并选择**牺牲者事务 Victim Transaction**来中止以打破死锁。选择牺牲者时可以考虑的属性包括：**时间戳 Timestamp**（新旧）、进度、已锁定的项目数量、需要随之回滚的事务数量、过去已重启的次数（避免**饥饿 Starvation**）。

**方法二：死锁预防 Deadlock Prevention**  
在死锁发生之前阻止事务引起死锁。事务被分配优先级（通常基于时间戳，旧事务优先级更高）。

**等待-死亡 Wait Die**（"老等少"）：如果请求事务的优先级高于持有事务，则等待；否则，请求事务中止（死亡）。  
**伤害-等待 Wound Wait**（"少等老"）：如果请求事务的优先级高于持有事务，则持有事务中止（被伤害）并释放锁；否则，请求事务等待。

### 锁粒度 Lock Granularities

为了在锁开销和并发度之间取得平衡，DBMS使用**锁层次结构 Lock Hierarchy**来处理不同粒度级别的锁。

**数据库锁层次结构 Database Lock Hierarchy**  
数据库级 Database level（较罕见）  
表级 Table level（非常常见）  
页级 Page level（常见）  
元组级 Tuple level（非常常见）  
属性级 Attribute level（罕见）

当事务获取层次结构中某个对象的锁时，它隐式获取了其所有子对象的锁。

**意向锁 Intention Locks**  
意向锁是隐式锁，用于表明在较低级别持有显式锁，从而避免较粗粒度的锁与较细粒度的锁冲突。

**意向共享锁 Intention Shared (IS)**：表示在较低级别使用共享锁进行显式锁定。  
**意向排他锁 Intention Exclusive (IX)**：表示在较低级别使用排他锁或共享锁进行显式锁定。  
**共享意向排他锁 Shared Intention Exclusive (SIX)**：该节点为根的子树以共享模式显式锁定，并且在较低级别正以排他模式锁进行显式锁定。

通过层次锁，当事务获取大量低级别锁时，DBMS可以自动切换到更粗粒度的锁，这减少了锁管理器必须处理的请求数量。

## Lecture #18: Timestamp Ordering Concurrency Control

### 时间戳排序并发控制 Timestamp Ordering Concurrency Control

**时间戳排序 T/O** 是一类**乐观并发控制 Optimistic Concurrency Control**协议，它假设事务冲突很少，不使用锁，而是使用**时间戳 Timestamps**来确定事务的**可串行化顺序 Serializable Order**。

每个事务 Ti 被分配一个唯一的、单调递增的固定时间戳 TS(Ti)。如果 TS(Ti) < TS(Tj)，则DBMS必须确保执行调度等效于 Ti 在 Tj 之前出现的串行调度。

**时间戳分配策略 Timestamp Allocation**：可以使用**系统时钟 System Clock**或**逻辑计数器 Logical Counter**，也可使用混合方法。

### 乐观并发控制 Optimistic Concurrency Control

**乐观并发控制 OCC** 是另一种使用时间戳验证事务的乐观协议，在冲突较少时（如只读事务或访问不相交数据子集）效果最好。

OCC为每个事务创建一个**私有工作空间 Private Workspace**。所有修改都在此空间中进行，其他事务无法读取该空间中的更改。

**OCC包含三个阶段**：  
**读阶段 Read Phase**：跟踪事务的**读集 Read Set**和**写集 Write Set**，将所有访问的元组复制到私有工作空间以确保**可重复读 Repeatable Reads**。
**验证阶段 Validation Phase**：当事务提交时，检查其是否与其他事务冲突。  
**写阶段 Write Phase**：若验证成功，则将私有工作空间的更改应用到数据库；否则中止并重启事务。

**验证阶段 Validation Phase**  
DBMS在事务进入验证阶段时为其分配时间戳。为确保只允许可串行化调度，DBMS检查 Ti 与其他事务的 RW 和 WW 冲突，并确保所有冲突单向发生。

**前向验证 Forward Validation**：检查正在提交的事务与所有其他正在运行的事务的时间戳顺序。  
**后向验证 Backward Validation**：检查正在提交的事务与已提交事务的读/写集。

**潜在问题 Potential Issues**：  
将数据复制到私有工作空间的开销高。  
验证/写阶段可能成为瓶颈。  
中止比在其他协议中更浪费，因为事务已执行完毕。  
时间戳分配可能成为瓶颈。

### 动态数据库与幻读问题 Dynamic Databases and The Phantom Problem

当事务执行插入、更新和删除时，会出现新的复杂情况。

**幻读问题 Phantom Problem**：当事务只锁定现有记录，而忽略了正在创建中的记录时，会导致不可串行化的执行。

**解决幻读问题的方法**：  
**重新执行扫描 Re Execute Scans**：在提交时重新运行查询以检查结果是否一致，确保没有因新记录或删除记录而遗漏更改。  
**谓词锁 Predicate Locking**：基于查询的谓词获取锁，确保任何满足谓词的数据都不能被其他事务修改。类似**精度锁 Precision Locking**。  
**索引锁 Index Locking**：利用索引键来保护数据范围，确保没有新数据可以落入锁定的范围内。  
**键值锁 Key Value Locks**：对索引中的单个键值加锁，包括不存在值的虚拟键。  
**间隙锁 Gap Locks**：对键值后的间隙加锁，防止在间隙中插入。  
**键范围锁 Key Range Locks**：对从一个现有键到下一个键的范围加锁。  
**层次锁 Hierarchical Locking**：允许事务以不同模式持有更广泛的键范围锁，减少锁管理器开销。

如果没有合适的索引，事务必须锁定表中的每一页或整个表本身以防止幻读。

### 隔离级别 Isolation Levels

**可串行化 Serializability** 允许程序员忽略并发问题，但强制执行它可能允许的并行性太少并限制性能。可以使用较弱的一致性级别来提高可扩展性。

**隔离级别 Isolation Levels** 控制一个事务在多大程度上暴露于其他并发事务的操作。

**异常现象 Anomalies**：  
**脏读 Dirty Read**：读取未提交的数据。  
**不可重复读 Unrepeatable Reads**：再次读取得到不同结果。  
**丢失更新 Lost Updates**：事务覆盖另一个并发事务的数据。  
**幻读 Phantom Reads**：插入或删除导致相同的范围扫描查询得到不同结果。

**隔离级别 Isolation Levels**（从强到弱）：  
**可串行化 SERIALIZABLE**：无幻读、所有读可重复、无脏读。可能实现方式：严格两阶段锁 + 幻读保护（如索引锁）。  
**可重复读 REPEATABLE READS**：可能出现幻读。可能实现方式：严格两阶段锁。  
**读已提交 READ COMMITTED**：可能出现幻读、不可重复读和丢失更新。可能实现方式：排他锁使用严格两阶段锁，读后立即释放共享锁。  
**读未提交 READ UNCOMMITTED**：所有异常都可能发生。可能实现方式：排他锁使用严格两阶段锁，读操作不加共享锁。

SQL-92标准定义的隔离级别只关注基于两阶段锁的DBMS中可能出现的异常。应用程序在开始执行查询之前设置每个事务的隔离级别。

## Lecture #19: Multi-Version Concurrency Control

### 多版本并发控制 Multi Version Concurrency Control

**多版本并发控制 MVCC** 是一个比并发控制协议更广泛的概念，涉及DBMS设计和实现的各个方面，是过去十年间几乎所有新DBMS最广泛使用的方案。

MVCC为单个逻辑对象维护多个物理版本。事务写入对象时，DBMS创建该对象的新版本；事务读取对象时，读取该事务开始时存在的最新版本。

**核心优势**：**写者不阻塞读者 Writers Do Not Block Readers**，**读者不阻塞写者 Readers Do Not Block Writers**。

**其他优势**：  
只读事务无需任何锁即可读取数据库的一致性**快照 Snapshot**。  
天然支持**快照隔离 Snapshot Isolation**。  
支持**时间旅行查询 Time Travel Queries**（若无垃圾回收）。

### 快照隔离 Snapshot Isolation

为事务提供其开始时数据库的一致性快照。快照中的数据值仅来自已提交事务，事务在完成前完全与其他事务隔离。

**写冲突 Write Conflicts**：若两个事务更新同一对象，**先写者获胜 First Writer Wins**。

**写偏斜异常 Write Skew Anomaly**：在快照隔离中，两个并发事务修改不同对象可能导致不可串行化的调度。

### MVCC设计考量

**1. 并发控制协议 Concurrency Control Protocol**  
在之前讨论的方法（两阶段锁、时间戳排序、乐观并发控制）之间选择。

**2. 版本存储 Version Storage**  
DBMS如何存储逻辑对象的不同物理版本，以及事务如何找到对其可见的最新版本。

通过元组的指针字段为每个逻辑元组创建**版本链 Version Chain**（一个按时间戳排序的链表）。索引始终指向链的"头"（最新或最旧版本，取决于实现）。

**仅追加存储 Append Only Storage**  
同一表空间内存储所有物理版本，更新时将新版本追加到表中并更新版本链。  
**旧到新 Oldest to Newest**：查找需要遍历链。  
**新到旧 Newest to Oldest**：每次新版本都需要更新索引指针（无需遍历链，通常是更好的方法）。

**时间旅行存储 Time Travel Storage**  
维护一个单独的**时间旅行表 Time Travel Table**存储旧版本。每次更新时，将元组的旧版本复制到时间旅行表，并在主表中用新数据覆盖该元组。

**增量存储 Delta Storage**  
不存储完整的旧元组，只存储**增量 Deltas**（元组间的更改）。事务可以通过反向遍历增量并应用它们来重建旧版本。写操作比时间旅行存储快，但读操作更慢。

**3. 垃圾回收 Garbage Collection**  
需要移除**可回收的 Reclaimable**物理版本。如果一个版本没有活跃事务可以"看到"，或者它是由已中止事务创建的，则该版本可回收。

**元组级垃圾回收 Tuple Level GC**  
**后台清理 Background Vacuuming**：单独的线程定期扫描表并查找可回收版本。可使用**脏页位图 Dirty Page Bitmap**优化。  
**协同清理 Cooperative Cleaning**：工作线程在遍历版本链时识别可回收版本。仅适用于旧到新链。

**事务级垃圾回收 Transaction Level GC**  
每个事务负责跟踪自己的旧版本。DBMS无需扫描元组。每个事务维护自己的读/写集。

**4. 索引管理 Index Management**  
**主键索引 Primary Key Indexes** 始终指向版本链头。更新主键属性被视为**删除 DELETE** 后接**插入 INSERT**。

**二级索引 Secondary Indexes** 管理更复杂：  
**逻辑指针 Logical Pointers**：使用每个元组的固定标识符，需要一个额外的**间接层 Indirection Layer**将逻辑ID映射到元组的物理位置。  
**物理指针 Physical Pointers**：使用指向版本链头的物理地址。更新版本链头时需要更新每个索引，开销很大。

**MVCC重复键问题 MVCC Duplicate Key Problem**  
MVCC DBMS索引（通常）不存储带有其键的元组的版本信息。因此，每个索引必须支持来自不同快照的重复键，因为相同的键在不同快照中可能指向不同的逻辑元组。

**5. 删除操作 Deletes**  
只有当逻辑删除的元组的所有版本都不可见时，DBMS才会从数据库中物理删除该元组。

**删除标志 Deleted Flag**：维护一个标志（在元组头或单独的列中）来指示逻辑元组已被删除。  
**墓碑元组 Tombstone Tuple**：创建一个空的物理版本来指示逻辑元组已被删除。使用单独的池存储墓碑元组以减少存储开销。

## Lecture #20: Database Logging

### 崩溃恢复 Crash Recovery

**恢复算法 Recovery Algorithms** 用于在发生故障后确保数据库一致性、事务原子性和持久性。

**关键原语 Key Primitives**  
**撤销 UNDO**：移除未完成或已中止事务的影响的过程。  
**重做 REDO**：重新应用已提交事务的影响以实现持久性的过程。

### 缓冲池管理策略 Buffer Pool Management Policies

**偷取策略 Steal Policy**  
**允许偷取 STEAL**：允许未提交事务覆盖非易失性存储中对象的最新已提交值。  
**禁止偷取 NO STEAL**：不允许。

**强制策略 Force Policy**  
**强制 Force**：要求事务的所有更新在事务被允许提交前（即向客户端返回提交消息前）反映到非易失性存储上。  
**非强制 NO FORCE**：不要求。

**策略组合**  
**禁止偷取 + 强制 NO STEAL + FORCE**：最容易实现的策略。无需撤销中止事务的更改（因为更改未写入磁盘），也无需重做已提交事务的更改（因为所有更改在提交时保证已写入磁盘）。但所有待修改数据必须能放入内存，且频繁写入可能导致存储设备磨损。

### 影子分页 Shadow Paging

DBMS在写入时复制页面，维护数据库的两个独立版本：  
**主版本 master**：仅包含已提交事务的更改。  
**影子版本 shadow**：包含未提交事务更改的临时数据库。

更新仅在影子副本中进行。当事务提交时，影子副本被原子性地切换为新的主版本。

**恢复 Recovery**  
**撤销 UNDO**：移除影子页面。保留主版本和数据库根指针不变。  
**重做 REDO**：完全不需要。

**缺点 Disadvantages**  
复制整个页表开销大。提交开销高，需要刷新页表、根页和每个更新页，导致大量对随机非连续页的写入。导致数据碎片化。需要垃圾回收。仅支持一次一个写入事务或批处理事务。

### 日志文件 Journal File

事务修改页面之前，DBMS将原始页面复制到单独的日志文件中。重启后，如果存在日志文件，DBMS收集原始页面并无视性地用这些原始页面覆盖当前页面，将数据恢复到未提交事务之前的状态。

### 预写日志 Write Ahead Logging

DBMS在更改磁盘页面之前，将所有对数据库的更改记录到**日志文件 Log File**（在稳定存储上）。日志包含必要信息以在崩溃后执行撤销和重做操作来恢复数据库。

DBMS必须在将数据库对象刷新到磁盘之前，将对应于该对象更改的日志文件记录写入磁盘。

**实现 Implementation**  
DBMS首先在易失性存储中暂存事务的所有日志记录。所有与更新页面相关的日志记录必须在页面本身被允许在非易失性存储中被覆盖之前写入非易失性存储。直到所有日志记录写入稳定存储，事务才被视为已提交。

**缓冲池策略 Buffer Pool Policies**  
大多数DBMS采用**非强制 + 偷取 NO FORCE + STEAL**策略，因为它具有更优的运行时性能。但在恢复阶段，非强制要求数据库重做，偷取要求数据库撤销，因此恢复时间比强制+禁止偷取慢。

**变更数据捕获 Change Data Capture**  
预写日志也可用于将更改传播到其他数据源。

### 日志方案 Logging Schemes

**物理日志 Physical Logging**：记录对数据库中特定位置所做的字节级更改。例如 git diff。  
**逻辑日志 Logical Logging**：记录事务执行的高级操作。不一定局限于单个页面。每个日志记录写入的数据比物理日志少，但在非确定性并发控制方案中，存在并发事务时难以实现恢复，且恢复时间更长，因为必须重新执行每个事务。  
**生理日志 Physiological Logging**：混合方法，日志记录针对单个页面，但不指定页面的数据组织。即，根据页面中的槽号识别元组，而不指定更改在页面中的确切位置。因此DBMS可以在日志记录写入磁盘后重新组织页面。是DBMS中最常用的方法。

### 检查点 Checkpoints

基于预写日志的DBMS的主要问题是日志文件会无限增长。崩溃后，DBMS必须重放整个日志，如果日志文件很大，这将花费很长时间。

DBMS可以定期**设置检查点 Checkpoint**，将所有缓冲区刷新到磁盘。

**设置检查点的频率**取决于应用程序的性能和停机时间要求。设置检查点太频繁会导致DBMS运行时性能下降。但两次检查点之间等待时间过长同样不利，因为系统重启后的恢复时间会增加。

**阻塞式检查点实现 Blocking Checkpoint Implementation**  
DBMS停止接受新事务并等待所有活跃事务完成。  
将所有当前驻留在主内存中的日志记录和脏块刷新到稳定存储。  
将**检查点 CHECKPOINT**条目写入日志并刷新到稳定存储。  
这种实现方式在设置检查点时必须停止一切以确保一致性快照，对运行时性能不利，但使恢复变得容易。

## Lecture #21: Database Crash Recovery

### 崩溃恢复 Crash Recovery

**恢复算法 Recovery Algorithms** 确保在发生故障时数据库的一致性、事务的原子性和持久性。每个恢复算法包含两部分：  
正常事务处理期间采取的行动，确保DBMS能够从故障中恢复。  
故障发生后采取的行动，将数据库恢复到确保事务原子性、一致性和持久性的状态。

### ARIES 恢复算法

**利用语义进行恢复和隔离的算法 Algorithms for Recovery and Isolation Exploiting Semantics (ARIES)** 是1990年代早期IBM为DB2系统开发的恢复算法。

**三个核心概念 Three Key Concepts**  
**预写日志 Write Ahead Logging**：任何更改在数据库更改写入磁盘之前，都记录在稳定存储的日志中（对应 STEAL + NO-FORCE 策略）。  
**重做期间重演历史 Repeating History During Redo**：重启时，回溯操作并将数据库恢复到崩溃前的确切状态。  
**撤销期间记录更改 Logging Changes During Undo**：将撤销操作记录到日志，确保在发生重复故障时操作不会重复执行。

### 预写日志记录 WAL Records

扩展DBMS的日志记录格式，包含全局唯一的**日志序列号 Log Sequence Number (LSN)**。所有日志记录都有一个LSN。

**关键 LSN**  
**flushedLSN**：内存中，磁盘上日志的最后一条LSN。  
**pageLSN**：页面中，对该页面最近更新的LSN。  
**recLSN**：脏页表 Dirty Page Table 中，自上次刷新后页面最旧更新的LSN。  
**lastLSN**：活跃事务表 Active Transaction Table 中，事务 Ti 的最新记录（由事务管理）。  
**MasterRecord**：磁盘上，最新检查点的LSN。

DBMS将页面 i 写入磁盘之前，必须至少将日志刷新到 pageLSNi ≤ flushedLSN 的位置。

### 正常执行 Normal Execution

**事务提交 Transaction Commit**  
DBMS首先将 COMMIT 记录写入内存中的日志缓冲区。  
然后将包括该事务 COMMIT 记录在内的所有日志记录刷新到磁盘。  
这些日志刷新是顺序的、同步的磁盘写入。  
COMMIT 记录安全存储在磁盘上后，DBMS向应用程序返回确认。  
稍后，DBMS会向日志写入特殊的 TXN END 记录，表明该事务在系统中完全结束。

**事务中止 Transaction Abort**  
中止事务是ARIES撤销操作仅应用于单个事务的特殊情况。

**prevLSN** 字段：对应事务的前一个LSN。DBMS使用这些值维护每个事务的链表，便于遍历日志查找其记录。

**补偿日志记录 Compensation Log Record (CLR)**：描述为撤销先前更新记录操作而采取的行动。包含更新日志记录的所有字段，外加 **undoNextLSN** 指针（即下一个要撤销的LSN）。CLR像任何其他记录一样被添加到日志中，但它们永远不需要被撤销。DBMS在通知应用程序事务已中止之前，无需等待CLR刷新到磁盘。

中止事务时，DBMS首先将 ABORT 记录附加到内存中的日志缓冲区。然后以相反顺序撤销事务的更新，从数据库中移除其影响。对于每个被撤销的更新，DBMS在日志中创建CLR条目并恢复旧值。在所有被中止事务的更新被反转后，DBMS写入 TXN END 日志记录。

### 检查点 Checkpointing

DBMS定期设置**检查点 Checkpoint**，将其缓冲池中的脏页写入磁盘。用于最小化恢复时必须重放的日志量。

**非模糊检查点 Non Fuzzy Checkpoints**  
DBMS在设置检查点时停止事务和查询的执行，以确保它将数据库的一致性快照写入磁盘。  
停止任何新事务的开始。  
等待所有活跃事务执行完成。  
将脏页刷新到磁盘。  
影响运行时性能，但显著简化了恢复。

**稍好的阻塞检查点 Slightly Better Blocking Checkpoints**  
DBMS在设置检查点时记录其开始时的内部系统状态。  
停止任何新事务的开始。  
在DBMS设置检查点时暂停事务。  
记录两个关键组件：**活跃事务表 Active Transaction Table (ATT)** 和**脏页表 Dirty Page Table (DPT)**。

**活跃事务表 Active Transaction Table (ATT)**  
跟踪DBMS中正在运行的事务。包含：  
**transactionId**：唯一事务标识符  
**status**：事务当前"模式"（运行中、提交中、撤销候选）  
**lastLSN**：事务写入的最远LSN  
ATT包含每个没有 TXN END 日志记录的事务。

**脏页表 Dirty Page Table (DPT)**  
包含缓冲池中被未提交事务修改的页面的信息。每个脏页有一个条目，包含 **recLSN**（即首次导致页面变脏的日志记录的LSN）。  
DPT包含缓冲池中所有脏页。

**模糊检查点 Fuzzy Checkpoints**  
DBMS允许其他事务继续运行。这是ARIES在其协议中使用的。  
DBMS使用额外的日志记录来跟踪检查点边界：  
**检查点开始 CHECKPOINT BEGIN**：指示检查点的开始。此时DBMS获取当前ATT和DPT的快照。  
**检查点结束 CHECKPOINT END**：当检查点完成时。包含在写入 CHECKPOINT BEGIN 日志记录时捕获的ATT + DPT。  
检查点完成后，CHECKPOINT BEGIN 记录的LSN被记录在 MasterRecord 中。

### ARIES 恢复 ARIES Recovery

崩溃后启动时，DBMS将执行以下三个阶段：

**分析阶段 Analysis Phase**  
从通过数据库 MasterRecord LSN 找到的最后一个检查点开始。  
向前扫描日志从检查点开始。  
如果DBMS找到 TXN END 记录，则从事务表ATT中移除其事务。  
所有其他记录，将事务添加到ATT，状态为 UNDO，提交时，将事务状态更改为 COMMIT。  
对于 UPDATE 日志记录，如果页面 P 不在 DPT 中，则将 P 添加到 DPT 并将 P 的 recLSN 设置为该日志记录的LSN。

**重做阶段 Redo Phase**  
目标是DBMS**重演历史 Repeating History**，以重建其到崩溃时刻的状态。它将重新应用所有更新（甚至是已中止的事务）并重做CLR。  
DBMS从包含 DPT 中最小 recLSN 的日志记录开始向前扫描。  
对于每个具有给定LSN的更新日志记录或CLR，DBMS重新应用更新，除非：  
受影响页面不在 DPT 中，或  
受影响页面在 DPT 中，但该日志记录的LSN小于页面的 recLSN（更新已传播到磁盘），或  
受影响页面的 pageLSN（在磁盘上）≥ LSN。  
重做操作时，DBMS重新应用日志记录中的更改，然后将受影响页面的 pageLSN 设置为该日志记录的LSN。没有额外的日志记录或强制刷新。  
在重做阶段结束时，为所有状态为 COMMIT 的事务写入 TXN END 日志记录，并将它们从ATT中移除。

**撤销阶段 Undo Phase**  
DBMS反转所有在崩溃时处于活跃状态的事务。这些是在分析阶段后ATT中状态为 UNDO 的所有事务。  
DBMS使用 lastLSN 以反向LSN顺序处理事务，以加速遍历。在每个步骤中，选择ATT中所有事务中最大的 lastLSN。当它反转事务的更新时，DBMS为每个修改写入一个CLR条目到日志中。  
一旦最后一个事务被成功中止，DBMS将日志刷新出去，然后准备开始处理新事务。

**崩溃问题 Crash Issues**  
如果在恢复的分析阶段数据库崩溃，则再次运行恢复。  
如果在恢复的重做阶段数据库崩溃，则再次重做所有操作。  
为了提高在重做阶段恢复期间的性能，假设它不会再次崩溃，并在后台异步刷新所有更改到磁盘。  
为了提高在撤销阶段恢复期间的性能，在新事务访问页面之前延迟回滚更改，并重写应用程序以避免长时间运行的事务。

## Lecture #22: Introduction to Distributed Databases

### 分布式数据库系统 Distributed DBMSs

分布式DBMS将单个逻辑数据库划分到多个物理资源上。应用程序（通常）不知道数据在分离的硬件上被拆分。系统依赖单节点DBMS的技术和算法来支持分布式环境中的事务处理和查询执行。一个重要设计目标是**容错性 Fault Tolerance**。

**并行数据库 Parallel Database** 与 **分布式数据库 Distributed Database** 的区别：  
**并行数据库**：节点物理位置相近，通过高速LAN互联，通信成本低且可靠，设计协议时无需过多考虑节点崩溃或丢包。  
**分布式数据库**：节点可能相距甚远，通过可能缓慢且不可靠的公网互联，通信成本和连接问题不可忽略（节点会崩溃，数据包会丢失）。

### 系统架构 System Architectures

**无共享 Shared Nothing**  
每个节点拥有自己的CPU、内存和磁盘。节点仅通过网络进行通信。  
增加容量更困难，因为DBMS必须将数据物理移动到新节点。确保所有节点一致性也更困难。  
优势是潜在性能更好、效率更高。

**共享磁盘 Shared Disk**  
所有CPU可以通过互联直接读写单个逻辑磁盘，但各自拥有私有内存。每个计算节点的本地存储可作为缓存。在基于云的DBMS中更常见。  
执行层可以与存储层独立扩展。添加新存储节点或执行节点不会影响另一层中数据的布局或位置。  
节点必须相互发送消息以了解其他节点的当前状态。节点拥有自己的缓冲池，被认为是无状态的。

**共享内存 Shared Memory**  
CPU通过高速互联访问公共内存地址空间。CPU也共享同一个磁盘。  
每个处理器对所有内存中的数据结构具有全局视图。每个处理器上的DBMS实例必须“知道”其他实例。  
实践中大多数DBMS不使用此架构，因为它是在操作系统/内核级别提供的，并且会导致问题。

### 设计问题 Design Issues

分布式DBMS旨在维护**数据透明性 Data Transparency**，意味着用户不应需要知道数据的物理位置，或表是如何分区或复制的。数据存储的细节对应用程序是隐藏的。一个在单节点DBMS上工作的SQL查询在分布式DBMS上应该同样工作。

关键设计问题：  
应用程序如何找到数据？  
查询应如何在分布式数据上执行？应将查询推送到数据所在位置，还是应将数据汇集到公共位置执行查询？  
数据库应如何跨资源划分？  
DBMS如何确保正确性？

### 分区方案 Partitioning Schemes

分布式系统必须将数据库跨多个资源（包括磁盘、节点、处理器）进行**分区 Partitioning**。在NoSQL系统中此过程有时称为**分片 Sharding**。

分区方案的目标是最大化**单节点事务 Single Node Transactions**（仅访问一个分区内数据的事务），这使得DBMS无需协调在其他节点上运行的并发事务的行为。而**分布式事务 Distributed Transaction** 访问一个或多个分区中的数据，这需要昂贵且困难的协调。

**实现方式 Implementation**  
**简单数据分区 Naive Data Partitioning**：每个节点存储一个表。易于实现，但不可扩展，在跨表连接查询或存在非均匀访问模式时效果不佳。  
**垂直分区 Vertical Partitioning**：将表的属性拆分到不同的分区中。每个分区还必须存储用于重建原始记录的元组信息。  
**水平分区 Horizontal Partitioning**：将表的元组拆分为不相交的子集。选择能在大小、负载或使用情况上平均划分数据库的列，这些键称为**分区键 Partitioning Key**。

DBMS可以基于**哈希 Hashing**、**数据范围 Data Ranges** 或**谓词 Predicates** 进行物理分区（无共享）或逻辑分区（共享磁盘）。

**一致性哈希 Consistent Hashing**  
将每个节点分配到某个逻辑环上的一个位置。然后每个分区键的哈希值映射到环上的一个位置。顺时针方向上最接近该键的节点负责该键。  
当添加或移除节点时，键仅在相邻节点之间移动，因此只有 1/n 的键被移动。  
**复制因子 Replication Factor** 为 k 意味着每个键在顺时针方向的 k 个最近节点处被复制。

**逻辑分区 Logical Partitioning**：节点负责一组键，但并不实际存储这些键。常用于共享磁盘架构。  
**物理分区 Physical Partitioning**：节点负责一组键，并物理存储这些键。常用于无共享架构。

### 分布式并发控制 Distributed Concurrency Control

分布式事务访问一个或多个分区中的数据，这需要昂贵的协调。

**集中式协调器 Centralized Coordinator**  
充当全局“交通警察”，协调所有行为。客户端与协调器通信以获取其想要访问的分区上的锁。收到确认后，客户端将其查询发送到这些分区。给定事务的所有查询完成后，客户端向协调器发送提交请求。然后协调器与事务涉及的分区通信以确定是否允许事务提交。  
集中式协调器可用作**中间件 Middleware**，接受查询请求并将查询路由到正确的分区。  
集中式方法在多个客户端尝试获取相同分区上的锁时会产生瓶颈，但对于分布式两阶段锁，它拥有锁的中央视图，可以更快地处理死锁。

**去中心化协调器 Decentralized Coordinator**  
节点自行组织。客户端直接将查询发送到其中一个分区。这个**主分区 Home Partition** 将结果返回给客户端，并负责与其他分区通信并相应提交。

### 联邦数据库 Federated Databases

这是一种将多个DBMS连接成单个逻辑系统的分布式架构。在大型公司中更流行。  
查询可以访问任何位置的数据。这很困难，因为存在不同的数据模型、查询语言以及每个独立DBMS的限制。此外，没有简单的方法来优化查询，并且涉及大量数据复制。  
通常通过一个**中间件 Middleware** 层来实现，该层将查询转换为系统中使用的特定DBMS可读的格式，并通过连接器与多个后端DBMS交互，然后处理从DBMS返回的结果。

## Lecture #23: Distributed OLTP Databases

### OLTP 与 OLAP

**联机事务处理 On line Transaction Processing (OLTP)**  
短生存期的读写事务  
小数据足迹  
重复性操作

**联机分析处理 On line Analytical Processing (OLAP)**  
长时间运行的只读查询  
复杂连接  
探索性查询

### 去中心化协调器设置 Decentralized Coordinator Setup

基本场景包含一个应用服务器和多个数据分区。其中一个分区被选为**主节点 Primary Node**。  
事务的开始请求从应用服务器发送到主节点，查询则直接发送到各个节点。  
提交请求从应用服务器发送到主节点，主节点负责在所有参与节点间协调是否允许提交。  
使用**两阶段锁 2PL**、**多版本并发控制 MVCC**、**乐观并发控制 OCC** 等策略来判断事务是否能在每个节点上安全提交。

### 复制 Replication

DBMS跨冗余节点复制数据以提高可用性。

**设计决策 Design Decisions**  
**副本配置 Replica Configuration**  
**传播方案 Propagation Scheme**  
**传播时序 Propagation Timing**  
**更新方法 Update Method**

**副本配置 Replica Configurations**  
**主从复制 Primary Replica**：所有更新都发送到每个对象的指定主节点。主节点将更新传播到其副本，无需原子提交协议。如果不需要最新信息，只读事务可以访问副本。如果主节点宕机，则举行选举选出新的主节点。  
**多主复制 Multi Primary**：事务可以在任何副本更新数据对象。副本必须使用原子提交协议相互同步。

**K安全 K safety**：确定复制数据库容错能力的阈值。K值表示每个数据对象必须始终可用的副本数量。如果副本数量低于此阈值，则DBMS停止执行并自行脱机。较高的K值可降低数据丢失风险。

**传播方案 Propagation Scheme**  
**同步 Synchronous**（强一致性）：主节点将更新发送到副本，然后等待它们确认已完全应用更改。然后主节点可以通知客户端更新已成功。确保DBMS不会因强一致性而丢失任何数据。在传统DBMS中更常见。  
**异步 Asynchronous**（最终一致性）：主节点立即向客户端返回确认，而无需等待副本应用更改。此方法中可能发生**陈旧读取 Stale Reads**。如果可以容忍某些数据丢失，此选项是一种可行的优化。常用于NoSQL系统。

**传播时序 Propagation Timing**  
**连续传播 Continuous Propagation**：DBMS在生成日志消息时立即发送。注意提交和中止消息也需要发送。大多数系统使用此方法。  
**提交时传播 On Commit Propagation**：DBMS仅在事务提交后才将事务的日志消息发送到副本。这不会浪费时间为中止的事务发送日志记录。它假设事务的日志记录完全适合内存。

**主动 vs 被动 Active vs Passive**  
**主动-主动 Active Active**：事务在每个副本上独立执行。最后，DBMS需要检查事务在每个副本上是否以相同结果结束，以查看副本是否正确提交。这很困难，因为现在事务的排序必须在所有节点之间同步，因此不太常见。  
**主动-被动 Active Passive**：每个事务在单个位置执行，并将整体更改传播到副本。DBMS可以发送更改的物理字节（更常见）或逻辑SQL查询。大多数系统是主动-被动。

### 原子提交协议 Atomic Commit Protocols

当多节点事务完成时，DBMS需要询问所有涉及的节点是否可以安全提交。根据协议，可能需要多数节点或所有节点同意才能提交。

所有原子提交协议都有一个共同结构。它们通常有**资源管理器 Resource Managers (RMs)** 的概念，这些RMs在不同节点上管理资源数据库。RMs需要共同协调以决定每个事务的命运：提交或中止。

原子提交协议需要保证以下属性：  
**稳定性 Stability**：一旦事务的命运被决定，就不能改变。  
**一致性 Consistency**：所有RMs最终处于相同状态，即使在故障之后。  
**活跃性 Liveness**：协议总有某种方式向前推进。

**两阶段提交 Two Phase Commit**  
客户端向协调器发送提交请求。  
第一阶段：协调器发送**准备 Prepare**消息，询问参与者节点当前事务是否允许提交。如果参与者验证事务有效，则向协调器发送**同意 OK**。如果协调器从所有参与者收到同意，系统进入第二阶段。如果有人向协调器发送**中止 Abort**，协调器则向客户端发送中止。  
第二阶段：如果所有参与者都发送了同意，协调器向所有参与者发送**提交 Commit**，告诉这些节点提交事务。一旦参与者响应同意，协调器可以告诉客户端事务已提交。  
如果事务在第一阶段被中止，参与者会从协调器收到中止，并应响应同意。  
要么所有人都提交，要么没有人提交。协调器也可以是系统中的参与者。  
在崩溃情况下，所有节点都会跟踪每个阶段结果的非易失性日志。节点会阻塞，直到能确定下一步行动。

**优化 Optimizations**  
**早期准备投票 Early Prepare Voting**：如果DBMS向一个远程节点发送查询，并且知道这将是该节点执行的最后一个查询，那么该节点将在查询结果中同时返回其对准备阶段的投票。  
**准备后早期确认 Early Acknowledgement after Prepare**：如果所有节点都投票提交事务，协调器可以在提交阶段完成之前向客户端发送事务成功的确认。

**Paxos**  
Paxos（以及Raft）在现代系统中比2PC更普遍。2PC是Paxos的一种退化情况；Paxos使用 `2F + 1` 个协调器，只要至少 `F + 1` 个协调器正常工作就能取得进展，而2PC设置 `F = 0`。

Paxos是一种共识协议，协调器提出一个结果，然后参与者对该结果是否应该成功进行投票。如果大多数参与者可用，该协议不会阻塞，并且在最佳情况下具有可证明的最小消息延迟。

对于Paxos，协调器称为**提议者 Proposer**，参与者称为**接受者 Acceptors**。

**Multi Paxos**：如果系统选举一个单一领导者在一段时间内监督提议更改，那么它可以跳过提议阶段。系统使用另一轮Paxos定期更新领导者是谁。当发生故障时，DBMS可以回退到完整的Paxos。

### CAP 定理

CAP定理指出，分布式系统不可能同时始终保证**一致性 Consistency**、**可用性 Availability** 和**分区容错性 Partition Tolerance**。只能选择这三者中的两个。

**一致性 Consistency** 等同于所有节点上操作的**线性一致性 Linearizability**。  
**可用性 Availability** 是所有处于运行状态的节点都能满足所有请求的概念。  
**分区容错性 Partition Tolerance** 意味着系统在节点之间就值达成共识时出现某些消息丢失的情况下仍能正确运行。

如果为系统选择了一致性和分区容错性，则在大多数节点重新连接之前不允许更新，通常在传统或NewSQL DBMS中完成。

**PACELC 定理** 是现代版本，考虑了**一致性 vs 延迟 Consistency vs Latency** 的权衡：在分布式系统中出现网络分区的情况下，必须在可用性和一致性之间做出选择，否则，即使系统在没有网络分区的情况下正常运行，也必须在延迟和一致性之间做出选择。
## Lecture #24: Distributed OLAP Databases

### 决策支持系统 Decision Support Systems

**数据仓库 Data Warehouse** 是一种后端OLAP数据库，用于存储和分析历史数据。  
**ETL** 是一个中间步骤，代表**提取、转换、加载 Extract, Transform, and Load**，将OLTP数据库组合成数据仓库的通用模式。  
**ELT** 是一种现代趋势，代表**提取、加载、转换 Extract, Load, and Transform**，原始数据加载到OLAP数据库后，转换工作在OLAP数据库本身上完成。

**决策支持系统 Decision Support Systems** 通过分析数据仓库中存储的历史数据，帮助人们对未来的问题和事务做出决策。

**星型模式 Star Schema**  
包含两种类型的表：**事实表 Fact Tables** 和**维度表 Dimension Tables**。  
事实表包含应用程序中发生的多个"事件"，包含每个事件的最小唯一信息，其余属性是对外部维度表的外键引用。  
维度表包含在多个事件中重复使用的冗余信息。  
星型模式中只能有一层维度表，查询通常更快，因为连接更少。

**雪花模式 Snowflake Schema**  
与星型模式类似，但允许从事实表引出多个维度，有时包含多个事实表。  
冗余较少，占用存储空间更小，但查询需要更多连接，因此查询通常比星型模式慢。

### 执行模型 Execution Models

分布式DBMS的执行模型指定了在查询执行期间节点之间如何通信。

**将查询推送到数据 Pushing a Query to Data**  
DBMS将查询（或其中一部分）发送到包含数据的节点。它在数据驻留的位置执行尽可能多的过滤和处理，以最小化昂贵的数据传输。然后将结果发送回执行查询的位置。在**无共享 Shared Nothing** 系统中更常见。

**将数据拉取到查询 Pulling Data to Query**  
DBMS将数据带到执行查询所需的节点。换句话说，节点检测它们可以对哪些数据分区进行计算，并相应地从存储中拉取数据。然后，本地操作传播到一个节点，该节点对所有中间结果执行操作。通常是**共享磁盘 Shared Disk** 系统会这样做。

**查询容错 Query Fault Tolerance**  
大多数无共享分布式OLAP DBMS设计为假设节点在查询执行期间不会发生故障。如果一个节点在查询执行期间发生故障，则整个查询失败，迫使整个查询从头开始重新执行。  
DBMS可以在执行期间对查询的中间结果进行**快照 Snapshot**，以便在节点发生故障时恢复，但此操作开销很大。

### 查询计划 Query Planning

分布式查询优化更加困难，因为它必须考虑集群中数据的物理位置和**数据移动成本 Data Movement Costs**。

**查询计划片段 Query Plan Fragments**  
生成单个全局查询计划，然后将物理算子分发到节点，将其分解为特定于分区的片段。大多数系统实现此方法。  
另一种方法是将SQL查询重写为特定于分区的查询。这允许在每个节点进行本地优化。

### 分布式连接算法 Distributed Join Algorithms

对于分析工作负载，大部分时间花在连接和从磁盘读取上。

**场景1**：一个表在每个节点复制，另一个表跨节点分区。每个节点并行连接其本地数据，然后将结果发送到协调节点。

**场景2**：两个表都在连接属性上分区，ID在每个节点上匹配。每个节点对本地数据执行连接，然后发送到一个节点进行合并。

**场景3**：两个表在不同键上分区。如果其中一个表很小，则DBMS将该表**广播 Broadcast** 到所有节点。这回到场景1。本地连接被计算，然后这些连接被发送到一个公共节点以执行最终连接。这称为**广播连接 Broadcast Join**。

**场景4**：最坏情况。两个表都没有在连接键上分区。DBMS通过跨节点**重新洗牌 Reshuffling** 来复制表。本地连接被计算，然后结果被发送到一个公共节点进行最终连接。这称为**洗牌连接 Shuffle Join**。

**半连接 Semi Join**  
一种连接算子，结果仅包含左表的列。分布式DBMS使用半连接来最小化连接期间发送的数据量。

### 云系统 Cloud Systems

供应商提供**数据库即服务 Database as a Service** 产品，即托管的DBMS环境。

**托管式DBMS Managed DBMS**  
没有对DBMS进行重大修改以使其"感知"它在云环境中运行。它为客户端提供了一种抽象所有备份和恢复的方法。大多数供应商部署此方法。

**云原生DBMS Cloud Native DBMS**  
明确设计用于在云环境中运行的系统。通常基于共享磁盘架构。例如 Snowflake, Google BigQuery, Amazon Redshift, Microsoft SQL Azure。

**无服务器数据库 Serverless Databases**  
当客户变得空闲时，**无服务器DBMS Serverless DBMS** 会驱逐租户，将系统中的当前进度**设置检查点 Checkpointing** 到磁盘。当不主动查询时，用户只需为存储付费。

**数据湖 Data Lakes**  
一个集中式存储库，用于存储大量结构化、半结构化和非结构化数据，而无需定义模式或将数据摄取到专有内部格式中。数据湖通常在摄取数据时更快，因为它们不需要立即进行转换。但它们需要用户编写自己的转换管道。

### OLAP 商品化 OLAP Commoditization

近十年的一个趋势是将OLAP引擎子系统拆分为独立的开源组件。

**系统目录 System Catalogs**  
DBMS在其目录中跟踪数据库的模式和数据文件。 Notable examples: HCatalog, Google Data Catalog, Amazon Glue Data Catalog。

**查询优化器 Query Optimizers**  
用于基于启发式和成本的查询优化的可扩展搜索引擎框架。 Notable examples: Greenplum Orca, Apache Calcite。

**数据文件格式 Data File Formats**  
新的开源二进制文件格式，使跨系统访问数据更容易。 Notable examples: Apache Parquet, Apache ORC, Apache CarbonData, Apache Iceberg, HDF5, Apache Arrow。

**执行引擎 Execution Engines**  
用于在列式数据上执行向量化查询算子的独立库。 Notable examples: Velox, DataFusion, Intel OAP。