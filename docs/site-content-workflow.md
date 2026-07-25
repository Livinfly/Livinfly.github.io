# 网站内容维护与发布流程

本文说明如何维护本站的学术主页、Academic Blog 和 Life Blog，以及如何使用
GitHub Pull Request 自动压缩图片、检查构建并发布网站。

## 推荐工作流

每次修改都使用独立内容分支，通过 Pull Request 合并到 `main`：

```text
同步 main
  → 创建内容分支
  → 编辑并本地预览
  → 提交并推送分支
  → 创建 Pull Request
  → 等待构建与图片压缩
  → 合并到 main
  → 自动发布到 gh-pages
```

不要直接编辑 `gh-pages`。该分支保存 GitHub Actions 生成的网站文件，会在每次
部署时被重新生成。

## 开始一次修改

进入仓库，同步 `main`，再创建一个内容分支：

```bash
cd /path/to/Livinfly.github.io

git switch main
git pull --ff-only
git switch -c content/my-new-content
```

分支名可以按照内容类型命名，例如：

```text
content/update-profile
content/acad-research-note
content/life-travel-note
```

## 内容与附件位置

| 内容 | Markdown | 附件 |
| --- | --- | --- |
| 英文学术主页 | `content/academic/home/en/index.md` | `content/academic/home/assets/` |
| 中文学术主页 | `content/academic/home/zh-cn/index.md` | 与英文主页共用 |
| Academic Blog | `content/academic/acad-blog/<slug>/` | 对应文章的 `assets/` |
| Life Blog | `content/post/<slug>/index.md` | 对应文章目录内的 `cover.*`、`assets/` |

学术主页拥有以下共享附件结构：

```text
content/academic/home/assets/
├── profile.png
├── cv.pdf
├── papers/
├── projects/
└── slides/
```

附件应与拥有它的页面放在同一个 page bundle 内。不要把单篇文章的图片集中放入
全局 `static/`，否则后续很难判断附件归属。

更完整的 Academic 附件约定见
[`docs/academic-assets.md`](academic-assets.md)。

## 修改学术主页

编辑对应语言页面：

```text
content/academic/home/en/index.md
content/academic/home/zh-cn/index.md
```

共享文件使用 bundle 相对路径：

```markdown
[CV](assets/cv.pdf)

![Project preview](assets/projects/project-name.webp)
```

侧栏目录按照 Markdown 标题自动生成：

- `# 一级标题`进入侧栏；
- `## 二级标题`进入侧栏；
- `### 三级标题`及以下只显示在正文中；
- 一般让 Hugo 自动生成标题 ID；需要稳定链接时可以写
  `## Section title {#stable-id}`。

通常不需要手动填写 `lastmod`。学术页面会使用对应 Markdown 文件最后一次 Git
提交的时间作为 Updated。需要人工覆盖时，可以在 front matter 中加入：

```yaml
lastmod: 2026-07-25T18:00:00+08:00
```

如果只替换图片或 PDF、没有改动 Markdown，而又希望页面的 Updated 随之变化，
也应显式更新 `lastmod`。

## 新建 Academic Blog

使用仓库脚本创建文章，不要直接复制示例文章：

```bash
# 中英文
scripts/new-academic-post.sh bilingual my-research-note

# 仅英文
scripts/new-academic-post.sh en-only my-research-note

# 仅中文
scripts/new-academic-post.sh zh-only my-research-note
```

`slug` 只允许小写字母、数字和单个连字符。也可以指定 RFC3339 发布时间：

```bash
scripts/new-academic-post.sh bilingual my-research-note \
  --date 2026-07-25T18:00:00+08:00
```

生成后的目录如下：

```text
content/academic/acad-blog/my-research-note/
├── _index.md
├── en/index.md
├── zh-cn/index.md
└── assets/
    ├── cover.svg
    ├── figures/
    └── attachments/
```

发布前需要完成：

1. 修改语言页面中的 `title`、`description`、`keywords`、`image_alt` 和正文。
2. 将 `draft: true` 改为 `draft: false`，或者删除该字段。
3. 替换默认封面，或者创建文章时传入 `--no-cover`。
4. 保留 `_index.md` 中最初的 `date`；它决定列表、归档和 feed 的排序。
5. 只有需要覆盖 Git 自动修改时间时，才在语言页面中填写 `lastmod`。

双语文章的两个语言页面继承同一个发布日期。文章可以只有一种语言；切换语言时
会保留可用内容，不会跳转到 404 页面。

## 新建 Life Blog

使用 Hugo 创建一个 leaf bundle：

```bash
hugo new content/post/my-life-note/index.md
```

然后编辑：

```text
content/post/my-life-note/index.md
```

当前 archetype 会把自动生成的 `slug` 转为标题式大小写，因此需要检查并手动改成
稳定的小写 slug。至少检查这些字段：

```yaml
title: "文章标题"
slug: "my-life-note"
authors: ["Livinfly(Mengmm)"]
date: 2026-07-25T18:00:00+08:00
categories: ["note"]
tags: ["tag1", "tag2"]
description: "文章摘要"
image: "cover.webp"
draft: false
```

推荐目录：

```text
content/post/my-life-note/
├── index.md
├── cover.webp
└── assets/
    ├── figure-1.webp
    └── figure-2.png
```

正文中的图片应提供有意义的替代文字：

```markdown
![图片内容说明](assets/figure-1.webp)
```

Life Blog 列表位于 `/life-blog/`。原有文章 URL 保持为 canonical URL，构建脚本
会额外生成对应的 `/life-blog/.../` 跳转页面，以兼容新的入口结构。

## 本地预览

启动本地服务并包含草稿内容：

```bash
hugo server -D
```

默认访问：

```text
http://localhost:1313/
```

预览时检查：

- 英文和中文页面能否互相切换；
- 标题是否只在 H1、H2 层级进入侧栏；
- 手机宽度下侧栏能否展开、收起；
- 封面、正文图片、CV 和其他附件是否能正常打开；
- 文章标题、摘要、Published 和 Updated 是否正确；
- `draft: true` 的页面是否只在本地草稿模式中出现。

## 提交前检查

执行和 GitHub Actions 对应的主要检查：

```bash
./scripts/test-new-academic-post.sh
hugo --minify --gc
./scripts/generate-route-aliases.sh public
```

`public/`、`resources/` 和 `.hugo_build.lock` 已被 Git 忽略，不需要提交。

本地 Hugo 版本可能比 CI 更新。GitHub Actions 当前固定使用 Hugo Extended
`0.152.2`，因此最终以 Pull Request 中的构建结果为准；不要依赖较新 Hugo 才支持
的语法，除非同时更新 CI 版本。

## 提交并创建 Pull Request

先检查修改范围，只暂存本次内容相关文件：

```bash
git status --short
git add path/to/changed-file path/to/another-file
git diff --cached
git commit -m "content: add my research note"
git push -u origin HEAD
```

然后在 GitHub 网页创建 Pull Request，base 选择 `main`；也可以使用 GitHub CLI：

```bash
gh pr create --base main --fill
gh pr checks --watch
```

Pull Request 阶段：

1. `Deploy to Github Pages` 会执行脚手架测试、Hugo 构建和路由检查，但不会发布。
2. 如果修改了支持的图片，`Compress Images` 会尝试压缩并写回 PR 分支。
3. 等所有检查完成后，再合并 PR。
4. 合并到 `main` 后，部署 workflow 会重新构建并发布到 `gh-pages`。

## 图片自动压缩

图片压缩由
[`calibreapp-image-actions.yml`](../.github/workflows/calibreapp-image-actions.yml)
控制。

### 触发条件

同时满足以下条件时才会运行：

- 修改通过 Pull Request 提交；
- PR 分支属于当前仓库，而不是来自 fork；
- PR 新增或修改了 `.jpg`、`.jpeg`、`.png` 或 `.webp` 文件。

SVG、GIF 和 PDF 当前不会触发这个 workflow。默认 Academic Blog 封面是 SVG；如果
希望它参与压缩，可以替换为：

```text
assets/cover.webp
```

并在文章 `_index.md` 中修改：

```yaml
image: "assets/cover.webp"
```

当前 action 固定到 1.5.0 对应的提交，默认质量参数为：

- JPEG：85；
- PNG：80；
- WebP：85。

它还带有最小字节和百分比变化参数，所以很小、已经优化或压缩收益不足的图片可能
不会产生新 commit，这是正常情况。

### Action 写回后的处理

如果压缩有效，Action 会将优化后的图片作为新 commit 写回 PR 分支。必须等该检查
完成后再合并，否则优化提交可能来不及进入 `main`。

如果 Action 写回后还要继续从本地修改同一分支，先同步远端提交：

```bash
git pull --rebase
```

直接 push 到 `main` 不会触发图片压缩。因此，只要修改包含图片，就应走内容分支和
Pull Request 流程。

## 发布和手动重新部署

部署由 [`deploy.yml`](../.github/workflows/deploy.yml) 控制：

- Pull Request：只构建和检查；
- push 到 `main`：构建并发布；
- 手动运行：从 `main` 重新构建并发布；
- 生成的网站被写入 `gh-pages` 分支。

网站需要重新构建但没有内容修改时，可以在 GitHub Actions 中选择
**Deploy to Github Pages → Run workflow**，或者执行：

```bash
gh workflow run deploy.yml --ref main
```

运行状态：

```bash
gh run list --workflow deploy.yml --limit 5
```

GitHub Actions 页面：

<https://github.com/Livinfly/Livinfly.github.io/actions>

## 常见问题

### 图片压缩没有运行

依次确认：

1. 修改是否通过 PR 提交，而不是直接 push 到 `main`；
2. 图片扩展名是否为 JPG、JPEG、PNG 或 WebP；
3. PR 是否来自当前仓库内的分支；
4. `Compress Images` workflow 是否启用；
5. 图片是否已经足够小，因而没有值得提交的压缩结果。

### 本地分支突然落后于远端

图片 Action 可能向 PR 分支写入了优化 commit。执行：

```bash
git pull --rebase
```

然后再继续修改和 push。不要为了覆盖 Action 的提交而随意 force push。

### 本地可构建，但 Pull Request 构建失败

先查看 Actions 日志。CI 使用 Hugo Extended `0.152.2`，本地较新版本接受的语法
可能不受 CI 版本支持。必要时使用相同 Hugo 版本复现。

### 合并后网站没有更新

1. 查看 `Deploy to Github Pages` 是否成功；
2. 确认合并目标为 `main`；
3. 确认 Pages 仍从 `gh-pages` 根目录发布；
4. 必要时手动重新运行 `deploy.yml`；
5. 不要直接修改 `gh-pages` 或本地 `public/` 来修复源内容。

## 发布前清单

- [ ] 从最新 `main` 创建了内容分支；
- [ ] 标题、slug、摘要、日期和语言正确；
- [ ] `draft` 已删除或设置为 `false`；
- [ ] 图片、附件及替代文字正确；
- [ ] Academic 标题层级符合 H1/H2 侧栏约定；
- [ ] `hugo server -D` 预览正常；
- [ ] 本地构建和路由检查通过；
- [ ] 只暂存并提交了本次修改；
- [ ] PR 构建通过；
- [ ] 图片压缩完成后再合并；
- [ ] 合并后部署成功。
