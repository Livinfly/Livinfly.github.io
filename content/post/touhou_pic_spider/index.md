---
title: "Python实现东方Project图片爬虫"
slug: "touhou_pic_spider"
authors: ["Livinfly(Mengmm)"]
date: 2022-07-15T00:00:00+08:00
# publishDate: 2023-10-01T00:00:00+08:00 # 定时发布
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/fun/touhou_pic_spider"]
categories: ["fun"]
tags: ["旧文", "爬虫", "东方Project"]
description: "（旧文）东方Project图片的Python爬虫代码，然后发现纯搞耍，哈哈哈哈"
image: "cover.jpg" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: false # 发布设为 false
---

> 本篇文章为旧文

## 视频流程讲解

（咕咕咕中）

## 背景

当时，在~~乱搞~~网站时候，它的默认随机图比较少，心生一念，我自己爬虫爬点下来不就有了？

昨日，爬了ewt后，思绪继续随着时间线向前延伸，想起来要爬图片了！（虽然我现在发现，我大部分文章都会自己发的时候找好配图，随机图好像没大用处？？）

另外，因本人技术力有限，无法标明作者，十分抱歉。

ps.只是爬了30页，懒得爬更多了，同时也为了避免不必要的影响。

## 运行结果预览

贴一下爬下来的图片吧（不能保证质量哦QnQ）

`小咕一手`
upd. 被迫咕，度娘云链接秒挂……

![爬下来的图片文件](TouhouPicSpider.assets/653074884.png)

![经典名图『早苗看鱼』](TouhouPicSpider.assets/702231711.jpg)

## 运行要求

1. 本代码编写在python3.10版本（不确定低版本会不会有问题）
2. requests
3. xpath - lxml库

## 代码

```py
import requests
from lxml import etree

# https://wall.alphacoders.com/by_sub_category.php?id=174892&name=%E4%B8%9C%E6%96%B9+%E5%A3%81%E7%BA%B8&filter=4K+Ultra+HD&lang=Chinese&quickload=880+&page=1

base_url = 'https://wall.alphacoders.com/by_sub_category.php?id=174892&name=%E4%B8%9C%E6%96%B9+%E5%A3%81%E7%BA%B8&filter=4K+Ultra+HD&lang=Chinese&quickload=880+&page='

index = 0

for page in range(1,31):
    print('正在爬取第'+str(page)+'页')
    url = base_url+str(page)
    # //img[@class="img-responsive big-thumb thumb-desktop"]/@src
    response = requests.get(url=url)
    content = response.text
    # print(content)
    tree = etree.HTML(content)
    img_li = tree.xpath('//img[@class="img-responsive big-thumb thumb-desktop"]/@src')
    for img_url in img_li:
        print('正在爬取第'+str(index)+'张')
        img_response = requests.get(url=img_url)
        img_content = img_response.content
        index += 1
        # print(img_url)
        extension = '.'+img_url.split('.')[-1]
        with open('.\\touhou_pic\\'+str(index)+extension,'wb')as fp:
            fp.write(img_content)
```

## 经验教训

爬虫的过程还是要输出的，不知道爬到哪里而不敢轻举妄动的感觉不好受诶。TnT

因为网站随机图加载的速度还是蛮重要的，在合理范围内应当小一点图片大小。