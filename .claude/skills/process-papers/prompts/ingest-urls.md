# URL Ingestion Instructions

You are ingesting papers from a list of URLs.

## Steps

1. Read the provided text file using the Read tool.
2. Parse each line as a URL. Skip empty lines and lines starting with `#` (comments).

3. For each URL:
   - Use WebFetch to retrieve the page content
   - Extract the paper title from the page content or HTML title
   - For arXiv URLs: the abstract page (arxiv.org/abs/...) is preferred over the PDF URL
   - For DOI URLs: follow the redirect to the publisher page

4. Normalize each paper into this format:
   - **title**: extracted from the fetched page
   - **content**: the fetched and cleaned content
   - **source_type**: "url"
   - **url**: the original URL
   - **local_path**: null

## Error Handling

- If a URL fails to fetch: print `[WARN] Could not fetch: <url> — skipping` and continue.
- If the text file is empty or contains no valid URLs: stop and tell the user "No valid URLs found in the provided file."
- If the file does not exist: stop and tell the user "File not found: <path>"
