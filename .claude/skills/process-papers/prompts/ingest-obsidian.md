# Obsidian Ingestion Instructions

You are ingesting papers from an Obsidian vault folder. The folder may contain papers directly as PDF, text, or markdown files, and/or markdown notes that reference papers via URLs/DOIs.

## Steps

1. Use the Glob tool to find all supported files in the provided path.
   - If path points to a single file, ingest just that file.
   - If path points to a directory, find all `*.pdf`, `*.txt`, and `*.md` files (non-recursive by default, recursive if no files found at top level).
   - **Exclude** any files matching `_briefing-*.md` — these are previous output briefings from this skill, not papers.

2. Classify and ingest each file by type:

   **PDF files (`.pdf`):**
   - Read using the Read tool with `pages: "1-20"`
   - Check if there are more than 20 pages — biology/medical papers commonly exceed 20 pages
   - If more pages exist, continue reading in 20-page chunks: "21-40", "41-60", etc. until all pages are read
   - Extract the title from the first page or header
   - If the Read tool cannot render the PDF, fall back to `pdftotext` via Bash

   **Text files (`.txt`):**
   - Read using the Read tool
   - Extract the title from the first line or header

   **Markdown files (`.md`):**
   - **Always read the full file** using the Read tool — do not skip any `.md` file.
   - Treat the file as a paper or study material. Extract the title from the first heading (`#`) or the filename.
   - Additionally, scan for embedded references to other papers:
     - URLs: links matching arXiv, DOI, Semantic Scholar, bioRxiv, PubMed, or other academic domains
     - Wikilinks to PDFs: `[[filename.pdf]]` — resolve relative to the vault root
     - Inline links: `[text](url)` format
     - Plain DOIs: patterns like `10.xxxx/xxxxx`
   - For each extracted reference that points to a file or URL **not already in the ingestion list**:
     - If it's a URL: fetch via WebFetch
     - If it's a local PDF wikilink: resolve the path and read as a PDF (see above)
     - If it's a DOI: fetch via `https://doi.org/<DOI>`

3. Normalize each paper into this format:
   - **title**: extracted from the paper content or page title
   - **content**: the full text content
   - **source_type**: "obsidian"
   - **url**: the original URL if applicable
   - **local_path**: the absolute path to the source file

## Error Handling

- If a PDF cannot be read (corrupted, password-protected): print `[WARN] Could not read PDF: <path> — skipping` and continue.
- If a URL fails to fetch (404, timeout, paywall): print `[WARN] Could not fetch: <url> — skipping` and continue.
- If a markdown file contains no paper references and is not itself a paper: print `[INFO] No paper content found in: <filename>` and continue.
- If no papers are found across all files: stop and tell the user "No papers found at the provided Obsidian path."
