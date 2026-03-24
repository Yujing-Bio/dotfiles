# PDF Ingestion Instructions

You are ingesting papers from local PDF files.

## Steps

1. Check if the provided path is a single file or a directory.
   - Single file: verify it ends with `.pdf`
   - Directory: use Glob to find all `*.pdf` files in the directory (non-recursive)

2. For each PDF file:
   - First, read pages "1-20" using the Read tool with the `pages` parameter
   - Extract the title from the first page or header of the paper
   - Check if the PDF has more than 20 pages (the Read tool will indicate if there are additional pages)
   - If there are more pages, continue reading in 20-page chunks: "21-40", "41-60", etc. until all pages are read
   - Concatenate all chunks into the full paper content
   - **Important:** Biology and medical papers commonly exceed 20 pages (with supplementary materials). Always check for and read ALL pages — do not stop at the first chunk

3. Normalize each paper into this format:
   - **title**: extracted from the paper's first page/header
   - **content**: the full text content
   - **source_type**: "pdf"
   - **url**: null
   - **local_path**: the absolute path to the PDF file

## Error Handling

- If a PDF cannot be read (corrupted, password-protected): print `[WARN] Could not read PDF: <path> — skipping` and continue.
- If the directory contains no PDF files: stop and tell the user "No PDF files found at the provided path."
- If the path does not exist: stop and tell the user "Path not found: <path>"
