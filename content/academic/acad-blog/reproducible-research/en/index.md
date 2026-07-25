---
title: "Example: Building a Reproducible Research Workflow"
description: >-
  A bilingual sample showing how to turn a research question into a traceable workflow through documented inputs, versioned analysis, validation, and reusable outputs.
url: /acad-blog/reproducible-research/
academic_lang: en
image_alt: "An abstract diagram connecting the stages of a reproducible research workflow"
keywords: ["example", "reproducible research", "research workflow"]
---

> **Example article.** Replace the prompts and illustrative details below with the methods, evidence, and artifacts from your own project.

# Research Question {#research-question}

Begin with a question that is narrow enough to test and clear enough for another researcher to interpret. State the population, material, corpus, or phenomenon being studied, together with the scope of the claim.

## Define the Scope {#define-the-scope}

Record the decisions that shape the study before collecting or analysing evidence:

- inclusion and exclusion criteria;
- units of observation and sampling decisions;
- variables, categories, or interpretive framework;
- criteria for deciding whether the question has been answered.

### Detail intentionally omitted from the sidebar

Third-level headings remain available in the article, while the sidebar lists only first- and second-level headings.

# Record the Workflow {#record-the-workflow}

| Component | What to record |
| --- | --- |
| Inputs | Sources, identifiers, versions, and access dates |
| Procedure | Ordered steps, instruments, parameters, and decision rules |
| Environment | Software, equipment, and relevant configuration |
| Outputs | File names, schemas, figures, and links to supporting material |

## Preserve Inputs and Provenance {#preserve-inputs-and-provenance}

Keep original inputs separate from derived files. For every transformation, document its source and the procedure that produced it. When inputs cannot be shared, describe how an authorised researcher could obtain or reconstruct an equivalent dataset.

## Version the Analysis {#version-the-analysis}

Store analysis code, notebooks, protocols, or coding guides with explicit versions. A short command or workflow diagram should be sufficient to show how the published outputs are regenerated.

# Validate the Result {#validate-the-result}

## Add Independent Checks {#add-independent-checks}

Choose checks that match the discipline: rerun an analysis from a clean environment, review a sample with a second coder, calibrate an instrument, compare alternative specifications, or trace a quotation back to its source.

# Share Reusable Artifacts {#share-reusable-artifacts}

Publish only material that can be shared ethically and legally. A concise README should explain the directory structure, prerequisites, reproduction steps, expected outputs, licence, and any access restrictions.

# Reflection {#reflection}

Reproducibility is not a claim that every study will yield an identical result. It is a way to make the path from question to evidence visible enough for others to inspect, repeat, and extend.
