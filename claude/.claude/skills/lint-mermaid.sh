#!/usr/bin/env bash
# lint-mermaid.sh — Extract and validate all Mermaid blocks from an HTML file.
# Usage: lint-mermaid.sh <file.html>
# Exit code: 0 if all blocks valid, 1 if any failed.
# Requires: @mermaid-js/mermaid-cli (npm install -g @mermaid-js/mermaid-cli)

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: lint-mermaid.sh <file.html>"
  exit 1
fi

HTML_FILE="$1"
if [[ ! -f "$HTML_FILE" ]]; then
  echo "File not found: $HTML_FILE"
  exit 1
fi

if ! command -v mmdc &>/dev/null; then
  echo "Error: mmdc not found. Install with: npm install -g @mermaid-js/mermaid-cli"
  exit 1
fi

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# Extract Mermaid blocks using Python (portable across macOS/Linux)
python3 -c "
import re, sys, os
html = open(sys.argv[1]).read()
blocks = re.findall(r'<pre class=\"mermaid\">(.*?)</pre>', html, re.DOTALL)
for i, block in enumerate(blocks):
    with open(os.path.join(sys.argv[2], f'block_{i+1}.mmd'), 'w') as f:
        f.write(block.strip() + '\n')
print(len(blocks))
" "$HTML_FILE" "$WORK_DIR" > "$WORK_DIR/count"

TOTAL=$(cat "$WORK_DIR/count")
FAILURES=0

if [[ "$TOTAL" -eq 0 ]]; then
  echo "No Mermaid blocks found in $HTML_FILE"
  exit 0
fi

for i in $(seq 1 "$TOTAL"); do
  mmd_file="$WORK_DIR/block_${i}.mmd"
  output_file="$WORK_DIR/block_${i}.svg"

  if mmdc -i "$mmd_file" -o "$output_file" -q 2>"$WORK_DIR/err.log"; then
    echo "  ✓ Block $i — OK"
  else
    FAILURES=$((FAILURES + 1))
    echo "  ✗ Block $i — FAILED"
    echo "    Content:"
    sed 's/^/      /' "$mmd_file"
    echo "    Error:"
    sed 's/^/      /' "$WORK_DIR/err.log"
  fi
done

echo ""
if [[ $FAILURES -gt 0 ]]; then
  echo "$FAILURES of $TOTAL Mermaid block(s) failed validation."
  exit 1
else
  echo "All $TOTAL Mermaid block(s) valid."
  exit 0
fi
