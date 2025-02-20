---
title: "{{ replace .Name "_" " " | title }}"
slug: "{{ replace .Name " " "_" | title }}"
authors: ["Livinfly(Mengmm)"]
date: {{ .Date }}
# 定时发布
# publishDate: 2023-10-01T00:00:00+08:00
# lastmod: 2023-10-01T00:00:00+08:00
# expiryDate: 2023-12-31T23:59:59+08:00
math: true
# keywords: ["keyword1"] # SEO
# summary: "A short summary of the page content."

aliases: ["/_category/{{ replace .Name " " "_" | title }}"]
categories: ["_category"]
tags: ["_tag1", "_tag2"]
description: "Desc Text."
image: "cover.png" # "https://www.dmoe.cc/random.php"

# weight: 1
# comments: false
draft: true # 发布设为 false
---