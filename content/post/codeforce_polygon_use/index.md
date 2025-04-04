---
title: "如何用codeforces的polygon平台进行出题"
slug: "codeforce_polygon_use"
authors: ["Livinfly(Mengmm)"]
date: 2023-07-05T00:00:00+08:00
# publishDate: 2023-10-01T00:00:00+08:00 # 定时发布
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/xcpc/codeforce_polygon_use"]
categories: ["xcpc"]
tags: ["codeforces", "polygon", "出题"]
description: "（旧文）介绍了些polygon平台的基础使用"
image: "cover.jpg" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---

> 旧文

## 背景

前几天刚刚完成人生第一次出题~~（其实就是魔改题面，重造数据）~~。

虽然，能略微找到相关博文，但好像还是不太够，所以还是写一下。

本文就按照出题的顺序好了。

ps. 本文指涉及传统题目的过程，不涉及交互题等方式。

同时推一下看到的挺全的文章[codeforces的polygon平台使用指北](https://blog.csdn.net/jokerwyt/article/details/100145318)。

## 注册

找到[polygon](https://polygon.codeforces.com/)的网站，要重新注册一个号，这个和`codeforces`主站不是同一个账号系统。

## 建立题目

点击上方的`New Problem`。

填写题目名字。

自动跳转到`View Problems`界面，找到刚刚创建的文件，点击`Start`。

## General info

由于要出的是传统题，根据要求改`Time limit`和`Memory limit`即可。

方便的话，在`Tags`一栏加上题目涉及的知识点，或是否隐藏评测的提示（由于我没用，就不讨论这个）。

## Statement

题面。

选择好语言，然后填写题面，具体的效果可以用`In HTML`等预览，多语言就`Create New`即可。

具体每一栏要写成什么样子，可以参考`codeforces`官方比赛或已存在的题目的题面。

## Files

可以在直接一次把我们写好的标程`std.cpp`，数据生成的程序`gen.cpp`和生成的数据是否合法的程序`vaild.cpp`，答案检验的程序`checker.cpp`传上来。（`vaild.cpp`和`checker.cpp`不必须）

这里的名称不一定一致，只是代表它的作用。

这些程序怎么写我这里不展开，可以自己去看`codeforces`自己写的关于`testlib.h`库的使用。

## Checker

答案（格式等）的检验器。

上面虽然说`checker.cpp`不必须，但是这里是要选的，不然后面`Tests`生成的时候会出错。

一般选忽略空格`lcmp.cpp`或不忽略空格`fcmp.cpp`，如果要`special judge`就需要自己写`checker.cpp`了。

具体效果可以使用下面的`Checker tests`来看。

自己设置输入、输出、答案和是否合法，然后看实际评判结果。

## Validator

生成数据是否合法的检验器。

感觉一般还是用于后面`hack`阶段的造数据的合法性。

所以，其实也可以没有，但是会在提示有`warning`。

还是建议写一下，写法也是看`codeforces`的官方教程。

同样也可以在下面进行测试是否达到自己预期。

建议在`Files`上传，在那边是可以直接编辑的。

## Tests

数据生成的设置参数的地方。

有两种方式设置数据。

第一种是中间的`Add Test	`，本地生成后，手动输入。

第二种是推荐的写法，需要用到之前上传的`gen.cpp`，在`Script`输入框内输入脚本命令。

具体脚本使用方式，右边比较清楚。

```
[你的数据生成文件名（不带后缀）] 参数1 参数2 ... > [输出到的地方，这里为数字，或者直接 $ 自动识别]
```

写好保存，中间就会出现一条条命令。

点击`Preview Tests`就可以生成数据了，如果已经在`Solution files`中设置好了标程，是可以直接也显示对应答案的。

## Stress

在线对拍。

大概是选择其他上传来的程序，然后和`main correct solution`标程对拍。

我的出题中没有用到。

## Solution files

解决文件。

这里是上传标程、正解等程序的地方，当然还有用来`Stress`对拍的程序。

注意`main correct solution`是标程，且必须要有，别的有没有都无所谓。

## Invocations

用生成的数据来测程序的地方。

相当于`custom test`。

可以帮助知道在OJ上跑大概是什么速度，会不会有什么环境不同导致的不一样等等。

## Issues

团队交流的地方。

我的过程没有用到。

## Packages

打包题目的地方。

根据自己需要选`Standard`或者`Full`，方便搬到本地或者别的OJ。

## Manage access

管理题目权限的地方。

一方面是加出题团队成员。

另一方面是把题目放到`codeforces`上，要点击`Add User`，添加`codeforces`为管理，后面复制右边的`url`填入`codeforces`的`mashup`里，就可以实现题目导入了。

## Verification

在右半边框里。

点击可以查看题目有什么显性的问题。