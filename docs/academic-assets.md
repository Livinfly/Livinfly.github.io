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

## Create an article bundle

Use the repository script instead of copying an existing article:

```bash
scripts/new-academic-post.sh bilingual my-article
scripts/new-academic-post.sh en-only my-english-note
scripts/new-academic-post.sh zh-only my-chinese-note
```

It creates the parent metadata, language-specific URLs, one shared publication
date, `assets/figures/`, `assets/attachments/`, and a generic shared
`assets/cover.svg`. Replace the placeholder cover before publishing, or pass
`--no-cover` when the article should not have one. Use `--date` to provide a
specific RFC3339 publication time:

```bash
scripts/new-academic-post.sh bilingual my-article \
  --date 2026-07-25T09:00:00+08:00
```

Every generated language page starts with `draft: true`. Preview it with
`hugo server -D`, finish the content and metadata, then remove that field (or
set it to `false`). The script validates the mode, slug, and date, builds the
bundle in a temporary sibling directory, and atomically moves it into place.
It refuses to overwrite an existing bundle.

Run the deterministic scaffold checks with:

```bash
scripts/test-new-academic-post.sh
```

Publication order comes from the article bundle's `date`. If both translations
exist, they must retain the same publication instant—even when one translation
is hidden—because they represent one article in language-specific lists and
feeds. Their modification times may differ.

Academic modification time uses this precedence only:

1. an explicit `lastmod` in that language page;
2. an explicit `modified` when `lastmod` is absent;
3. the latest Git author date for that file;
4. its publication date.

This avoids treating a local filesystem timestamp as a content update and does
not change the Life Blog's Stack date behavior. Add an explicit `lastmod` only
when the Git-derived value needs a deliberate editorial override.

## Typography

The Academic type scale is collected at the top of
`assets/scss/academic/home.scss`. Each semantic level has its own CSS custom
property: body text; sidebar identity, section labels, languages, navigation,
H1/H2 table of contents, and archive levels; profile, list, article, and card
titles; and content H1-H4 headings.

For a longer bilingual name, adjust
`--academic-font-size-sidebar-id` first. If the name still needs more room,
increase `--academic-sidebar-width` or reduce
`--academic-sidebar-summary-inline-padding`. The default identity size keeps a
name such as `Jie Luo | 罗杰` on one line in the 220px sidebar. Profile, list,
article, and card titles have separate responsive values in the mobile media
query.
