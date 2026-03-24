---
name: process-papers
description: Use when the user wants to read, summarize, and analyze academic papers from Obsidian, local PDFs, or URLs. Produces per-paper summaries, crosschecks claims, generates a deep-research synthesis, and supports interactive Q&A study sessions.
---

# Process Papers

Read and analyze a collection of academic papers, producing research briefing notes.

## Arguments

Parse the following from ARGUMENTS:

- `<path>` — **Default: Obsidian folder.** A folder path (or single file) to read papers from. Treated as `--obsidian` unless another source flag is given. The folder may contain PDFs, .txt, and .md files.
- `--pdfs <path>` — Explicit: treat path as local PDF directory or single file
- `--urls <path>` — Explicit: treat path as a text file with URLs, one per line
- `--depth brief|detailed` — Summary depth (default: `detailed`)
- `--topic <name>` — Topic/field name for output title/filename
- `--output <path>` — Local output directory (default: `./output/`)

A path is required. If `--topic` is omitted, ask the user.

**Output location:** The research briefing is always saved back into the source folder (alongside the papers) with the filename `_briefing-{topic-slug}-{YYYY-MM-DD}.md`. A copy is also written to `--output` if provided. This means you can rerun `/process-papers` on the same folder and each run produces a timestamped briefing.

## Batch Limits

- Warn if paper count exceeds 15
- Hard-stop if paper count exceeds 30 with message: "Too many papers for a single run. Please split into batches of 15 or fewer."

## Incremental Mode

Before ingesting papers, check if the source folder already contains a previous briefing file (matching `_briefing-*.md`).

If a previous briefing exists:
1. Read the most recent briefing file (by date in filename).
2. Extract the list of paper titles from the `## Per-Paper Summaries` section.
3. Extract any Q&A from the `## Study Session Q&A` section — these are **carried forward** into the new briefing.
4. During ingestion, compare each paper's title against the already-processed list.
   - **Papers already summarized:** Skip ingestion and summarization. Carry forward their existing summary, crosscheck, and replication plan sections verbatim from the previous briefing.
   - **New papers:** Ingest and process normally through all stages.
5. If the previous briefing's `.md` file itself has been **edited by the user** (e.g., new Q&A added manually, annotations, or notes appended), detect the additions:
   - New `**Q:**` / `**A:**` pairs added to the Study Session section → carry them forward.
   - Any text added under a new `## User Notes` section → include it in the new briefing and use it as context during synthesis.
6. Re-run **Synthesis** (Stage 4) and **Cross-Paper Analysis** using all papers (old + new) to produce an updated executive synthesis.
7. Print: `[Incremental] Found previous briefing with N papers. Processing M new papers. Carrying forward K Q&A pairs.`

If no previous briefing exists, run the full pipeline from scratch.

## Pipeline

Execute these stages in order:

1. **Ingest** — Check for incremental mode (see above). Then read the instructions in `prompts/ingest-obsidian.md`, `prompts/ingest-pdfs.md`, or `prompts/ingest-urls.md` depending on the source flag. Normalize each paper into: title, content, source type, URL (if applicable), local path (if applicable). Print progress: `[N/total] Ingested: "Paper Title"`. Track any failed ingestions in a `failed_papers` list with reason. If no papers are found or ALL papers fail to ingest, display an error summary and stop.

2. **Summarize** — For each paper, read the instructions in `prompts/summarize-brief.md` or `prompts/summarize-detailed.md` based on `--depth`. Generate the summary. Flag each paper as AI/ML or non-AI/ML. For batches of 3+ papers, use `superpowers:dispatching-parallel-agents` to summarize papers in parallel. If the paper is not in English, summarize in English (best-effort translation).

3. **Crosscheck** — Read the instructions in `prompts/crosscheck.md`. For each paper, verify top 3-5 claims against cited sources using WebSearch/WebFetch. Fact-check key claims via web search. If multiple papers: also compare findings across papers (Type 2 cross-paper comparison). If single paper: skip Type 2, run only Type 1 (cited sources) and Type 3 (web fact-check).

4. **Synthesize** — If multiple papers: read `prompts/synthesize-brief.md` or `prompts/synthesize-detailed.md` based on `--depth`. Operate on the per-paper summaries from Stage 2, NOT the raw paper content (to manage context window). If single paper: read `prompts/single-paper-analysis.md` instead.

5. **AI Replication Plan** — For papers flagged as AI/ML in Step 2, read `prompts/replication-plan.md` and generate a high-level architecture plan.

6. **Interactive Study Session** — Present the synthesis to the user. Enter Q&A mode. Tell the user: "Ask me anything about these papers and the field. Type `done` when you're ready to finalize." Answer questions grounded in the paper content. When the user types `done`, proceed to Step 7.

7. **Finalize** — Read `prompts/output-template.md`. Compile all outputs into the template. For incremental runs: merge carried-forward sections (old summaries, old Q&A, user notes) with new content. Include any failed/skipped papers in a "Skipped Papers" section at the end. Write the briefing to the source folder as `_briefing-{topic-slug}-{date}.md` (never overwrite previous briefings). Also write to `--output` if provided.
