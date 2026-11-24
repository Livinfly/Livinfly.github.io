
大概一些小文章，或者没有什么要记录的，就略过了。

## 2026

### [谈谈 XPU 的 Virtual ISA](https://mp.weixin.qq.com/s?__biz=MzUxNzQ5MTExNw==&mid=2247499877&idx=1&sn=8e67ef99821db3296935b7db2b9cdb23&chksm=f995d0a7cee259b189b05c5ab1d233d7e986420dd10a8ce0f924a458f0a07eeb038e5b8717ec#rd)

[【直播回放+文字实录】华为Fellow廖恒博士在顶会MICRO 2026 专题 Workshop报告分享](https://www.chaspark.com/#/hotspots/1335109403879198720)

数据布局：Nested Tensor Descriptor
依赖：Nested Mbarrier

ISA 契约错配导致适配成本高、语义丢失、正确性难验证、生态被锁定、多样化硬件难协同。

加一层 Virtual ISA 可以变得简洁干净，具体实现交给 ISA。

### [置身 AI 内 : 读懂 AI 竞赛, 必须读懂 AI 组织](https://mp.weixin.qq.com/s?__biz=MzUxNzQ5MTExNw==&mid=2247499854&idx=1&sn=478c9757b5a10098af19b13d9023e527&chksm=abc123&scene=21#wechat_redirect)

半书半 AI，有机会可能再去读读原书；更像是一种理解、解读现有框架与问题的方式，但具体怎么走，还是要慢慢磨合以及领导人的 taste，对个人的指导意义可能是知道哪里的环境是好的可能性会更大吧。

### [AI时代 “雕花”的艺术](https://mp.weixin.qq.com/s?__biz=MzUxNzQ5MTExNw==&mid=2247499846&idx=1&sn=ab94cfbce352a8f07422bff72d7bc7ce&chksm=abc123&scene=21#wechat_redirect)

后训练培养是模型 taste 的过程。里面提到 microbenchmark driven，我觉得不仅是人和人的团队，对于后训练的数据来说也是这样，当你不选择这么做，而 reward 只看这部分的时候，是很难跳出 microbenchmark driven 的方式的，所以，我觉得当数据充足的时候， reward 决定了上限。

scope 和 taste 决定了很多。

更广泛的视野和更好的提问。

### [谈谈10T参数模型的AI Infra 要什么](https://mp.weixin.qq.com/s?__biz=MzUxNzQ5MTExNw==&mid=2247499842&idx=1&sn=388b5d3567ae6c3105c5718de17ad526&chksm=f995d080cee25996134902437d16896ee483b3ad8a0e431ee82ae89a08b897116fcf8cc8afbc#rd)

超大模型，**算力约束**和**内存约束**，需要考虑到高速推理，MoE、更长上下文，kvcache。

互联的稳定性，目前无脑堆超节点规模不太合理。

Agent 执行环境应当被当作“不可信代码 + 短生命周期 + 任务级租户”来设计；网络策略是外围防线，不是安全边界本身。NV 的安全还不够。

超标量的讨论，[辩经系列之六：超标量或者静态排流水 - 知乎](https://zhuanlan.zhihu.com/p/2085077594198824273?share_code=1f6g3IYpUSCiJ&utm_psn=2089396614821631138)


### [谈谈未来的Transformer: Loops Are Not What You Need](https://mp.weixin.qq.com/s?__biz=MzUxNzQ5MTExNw==&mid=2247499685&idx=1&sn=98c0a98e003ff99e54649b7351f98ab4&chksm=f995ef67cee266715eba48534273bf8ce42d3ce0f9c6f64a916cd61182e69001b2199ed0b864#rd)

> 一个 transformer block 上可注入的面就清楚了: 残差 , 归一化的增益偏置, 度量 G, 偏置 b, 求和范围 j, head 集合 h, 输出门, 以及后续 FFN。

里面对 Attn 计算方式的改写，从 attn 的记忆注入点的分析角度出发，说明了 Loop Transformer 存在的问题。

从这个角度来分析，以往的改进与未来改进方向很有意思。

剩余的部分，其实在畅想下一代的智能涌现情况了，核心是模型内化这些 harness 的能力，比如自己调整 context，自己反复思考等。

我觉得这很有趣，但是对于推理框架 / 训练框架或者流程来说，是不是还需要做些适配才好做到？

或者会比如，让模型产生一个容量认知，然后，会有一些 \<label\> token，让这些文中提到的 block 等，可以根据模型的意思，重新推理或者什么。。

但是好像也还是 harness 的样子。。。

或者说，一个回过头来看思考的过程和一个反复纠正掉，不留下错误过程的模型，emmm。

从人的角度来说，我觉得，人的思考是有 trace 的，潜意识的话，或许有潜 trace，但是应该还是能感知到的？而不是直接压掉了？


### [[随笔]谈谈 Loop Transformer](https://mp.weixin.qq.com/s?__biz=MzUxNzQ5MTExNw==&mid=2247499660&idx=1&sn=23a6d175be300a1214a969db6da7a30f&chksm=f995ef4ecee266587a62eca367ed2965656060f6734b3b15c9eafd8d902d29998bdf1018376e#rd)

会从 model scaling 的角度去提这个事情。

对于 model 来说，主要的模块就是 Attn 和 FFN，FFN 已经可以通过 MoE 实现存储和计算的稀疏，而 Attn 也需要类似的机制，来稀疏参数本身与 KV cache 的存储。

我觉得 loop transformer / recirculation 这种形式是有合理性的，不过也像里面提到的，这样情况下 KV cache，不同 loop 之间的 prefix-caching hit 会是什么样的情况？

其实对 YOCO 这种 KV cache 复用的工作还没有建立对应的直觉，还需要多多看看。

另外就是 dynamic loop 的结果，模型自己选择跳层，high level 来看，应该也是 make sense 的，不过同样，这样的 kv cache 该怎么理解，如果前后不同 loop step，prefix cache 怎么理解呢？

