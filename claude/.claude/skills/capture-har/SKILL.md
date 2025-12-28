---
name: capture-har
description: Capture HTTP Archive (HAR) files from localhost for debugging network traffic and performance analysis. Use when debugging network issues, analyzing performance, or investigating browser behavior.
allowed-tools: Bash(./tools/capture-har.py:*)
---

# HAR Capture Tool

Capture HTTP Archive (HAR) files from localhost:3000 for debugging network traffic and performance analysis.

## Quick Usage

```bash
# Capture root page
./tools/capture-har.py

# Capture specific path
./tools/capture-har.py /tasks

# Custom output filename
./tools/capture-har.py /tasks output.har
```

## What is a HAR File?

HAR (HTTP Archive) is a JSON format for recording HTTP transactions between a browser and server. It captures:
- All network requests (URLs, methods, headers)
- Response data (status codes, timing, content)
- Resource types (HTML, CSS, JavaScript, images)
- Request/response timing (DNS lookup, connection, download)
- Console output from the browser

## Why Use This for Debugging?

### Network Issues
- See all HTTP requests made by your app
- Identify failed requests (4xx, 5xx errors)
- Find missing resources or broken links
- Debug CORS or authentication issues

### Performance Analysis
- Identify slow-loading resources
- See total number of requests
- Find large files impacting load time
- Analyze dependency chains (e.g., date-fns loading 260 modules)

### Browser Behavior
- Capture console.log output
- See execution order of scripts
- Debug module loading issues
- Verify expected resources are loaded

## Analyzing HAR Files

### View in Browser DevTools
1. Open Chrome/Firefox DevTools
2. Go to Network tab
3. Right-click → Import HAR file

### Command-line Analysis
```bash
# Count total requests
cat output.har | python3 -c "import sys, json; print(len(json.load(sys.stdin)['log']['entries']))"

# List all URLs
cat output.har | python3 -c "import sys, json; [print(e['request']['url']) for e in json.load(sys.stdin)['log']['entries']]"

# Find failed requests (non-200)
cat output.har | python3 -c "import sys, json; [print(f\"{e['response']['status']}: {e['request']['url']}\") for e in json.load(sys.stdin)['log']['entries'] if e['response']['status'] != 200]"
```

## Advanced shot-scraper Options

The underlying `shot-scraper har` command supports additional options:

### Wait for Dynamic Content
```bash
# Wait 2 seconds before capturing
shot-scraper har http://localhost:3000 -o output.har --wait 2000

# Wait for specific condition
shot-scraper har http://localhost:3000 -o output.har --wait-for "document.querySelector('.data-loaded')"
```

### Execute JavaScript
```bash
# Run JS before capturing
shot-scraper har http://localhost:3000 -o output.har -j "document.querySelector('#tab-2').click()"
```

### Authentication
```bash
# HTTP Basic Auth
shot-scraper har http://localhost:3000 -o output.har --auth-username user --auth-password pass

# Use saved auth context
shot-scraper har http://localhost:3000 -o output.har --auth auth.json
```

### Error Handling
```bash
# Fail on HTTP errors
shot-scraper har http://localhost:3000 -o output.har --fail

# Skip pages with errors
shot-scraper har http://localhost:3000 -o output.har --skip
```

### Timeout Control
```bash
# Custom timeout (default 10s in our script)
shot-scraper har http://localhost:3000 -o output.har --timeout 30000
```

### Bypass Security
```bash
# Bypass Content-Security-Policy (for local dev)
shot-scraper har http://localhost:3000 -o output.har --bypass-csp
```

## Common Debugging Workflows

### Debug Missing Resources
```bash
./tools/capture-har.py /page output.har
# Then check HAR for 404s or failed requests
```

### Performance Comparison
```bash
# Before optimization
./tools/capture-har.py / before.har

# After optimization
./tools/capture-har.py / after.har

# Compare file sizes and request counts
```

### Debug Module Loading
```bash
# Capture with console output
./tools/capture-har.py /
# Check stderr for console errors and module load order
```

## Output Files

By default, files are named with timestamp:
- `har-root-20251227-111500.har` (root page)
- `har-tasks-20251227-111500.har` (/tasks page)

Files include full request/response data and can be large (1-5 MB typical for this app due to date-fns CDN modules).

## Related Tools

- **shot-scraper screenshot**: Capture visual screenshots
- **shot-scraper html**: Get final HTML after JS execution
- **shot-scraper javascript**: Execute JS and return results
- **shot-scraper pdf**: Generate PDF of page

## Tips

1. Always check console output for JavaScript errors
2. Look for unexpected requests to external domains
3. Check timing data for slow resources
4. Use HAR files to reproduce issues in DevTools
5. Compare HARs before/after changes to verify behavior
