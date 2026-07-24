# Academic content assets

Keep files owned by the academic homepage in `content/academic/home/assets/`.
Academic posts and their page-specific assets live under
`content/academic/acad-blog/`.

Suggested layout:

```text
content/academic/
├── home/
│   ├── _index.md
│   ├── en/index.md
│   ├── zh-cn/index.md
│   └── assets/
│       ├── cv.pdf
│       ├── profile.png
│       ├── papers/
│       ├── projects/
│       └── slides/
└── acad-blog/
    └── article-slug/
        ├── _index.md
        ├── en/index.md
        ├── zh-cn/index.md
        └── assets/
            ├── cover.webp
            ├── figures/
            └── attachments/
```

The `_index.md` file owns metadata and shared resources. Keep the English and
Chinese Markdown beside one another; either language file may be omitted for a
monolingual article. Reference a shared file from either language with the same
bundle-relative Markdown link, for example:

`profile.png` is the shared Profile image selected by `home/_index.md`. It is
currently a copy of the site icon and can be replaced independently later.

Use the `en/index.md` and `zh-cn/index.md` directories shown above. Native Hugo
language suffixes such as `index.en.md` would enable site-wide language routing
and would change the language ownership of the existing Life Blog URLs.

```markdown
[CV](assets/cv.pdf)
![Project preview](assets/projects/project-slug.webp)
```

The academic Markdown render hooks first check the language page and then its
parent bundle. Hugo publishes one shared asset URL for both versions.

Publication order comes from the article bundle's `date`. Page modification
time comes from the language Markdown file's latest Git author date. Add an
explicit `lastmod` only when that automatic value needs a deliberate override;
before a new file's first commit, local builds fall back to its file-modified
time.
