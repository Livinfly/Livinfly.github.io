---
title: "Blog"
description: "Research notes, reading reflections, conference reports, and reproducible workflows."
type: acad-blog
url: /acad-blog/
academic_lang: en
outputs:
  - HTML
cascade:
  - type: acad-blog
---

<!--
The example article bundles in this directory are intentionally rendered on the
development branch so the list and single-page layouts can be reviewed. Replace
or remove them before publishing real academic writing. In each post bundle:
- `_index.md` owns shared metadata and resources.
- `en/index.md` and `zh-cn/index.md` are adjacent language versions; either is optional.
- each language file sets `academic_lang` and its final `url`; English uses
  `/acad-blog/<slug>/`, Chinese uses `/zh-cn/acad-blog/<slug>/`.
- the parent cascade supplies one publication `date` to every available
  language version.
- `date` controls publication order. Modification time comes from the latest
  Git revision of each language file unless that file explicitly overrides
  `lastmod` or `modified`.
- `description` is the localized abstract shown on the list and in metadata.
- covers, figures, and attachments belong to the shared `assets/` directory.
-->
