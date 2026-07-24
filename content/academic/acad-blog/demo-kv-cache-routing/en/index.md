---
title: "Demo: Mapping KV-cache Ownership in Distributed Serving"
description: >-
  A demonstration article for reviewing how a recent post appears with a cover, a compact abstract, and a structured technical discussion.
url: /acad-blog/demo-kv-cache-routing/
academic_lang: en
image_alt: "An abstract diagram of connected cache and compute nodes"
keywords: ["demo", "distributed serving", "KV cache"]
---

> **Demo article.** This page exists to review the Blog layout. Replace or remove it before publishing the site.

# Question {#question}

How should a systems note separate the location of cached state from the workers that execute prefill and decode? This placeholder paragraph shows the normal reading width and paragraph rhythm of a short technical opening.

## Components {#components}

For layout purposes, imagine three independently chosen roles:

- a cache owner that stores reusable state;
- a prefill executor that produces new state;
- a decode worker that consumes the selected context.

### Detail intentionally absent from the sidebar

Third-level headings remain visible in the article, but the sidebar only lists first- and second-level headings.

# Design Sketch {#design-sketch}

| Decision | Placeholder question |
| --- | --- |
| Placement | Where should reusable state live? |
| Transfer | Which tensors cross worker boundaries? |
| Validation | What evidence distinguishes a design claim from an implementation result? |

## Tradeoffs {#tradeoffs}

This section demonstrates a second-level entry and a slightly longer block of prose. A real article would replace it with concrete mechanisms, assumptions, and measured evidence.

# Takeaway {#takeaway}

Use this page only to evaluate navigation, typography, tables, and cover behavior.
