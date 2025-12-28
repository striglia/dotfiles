# /factorio-copy

Sync the Factorio plugin from the current directory to the Factorio Steam mods directory.

## Usage
```
/factorio-copy
```

## Implementation
```bash
#!/bin/bash

# Custom Claude slash command: /factorio-copy
# Syncs the factorio plugin from current directory to Factorio mods directory

set -e

CURRENT_DIR="$(pwd)"
FACTORIO_MODS_DIR="$HOME/Library/Application Support/Factorio/mods"

# Find the plugin directory (should contain info.json)
PLUGIN_DIR=""
for dir in "$CURRENT_DIR"/*/; do
    if [[ -f "$dir/info.json" ]]; then
        PLUGIN_DIR="$dir"
        break
    fi
done

if [[ -z "$PLUGIN_DIR" ]]; then
    echo "Error: No Factorio plugin found (no directory with info.json)"
    exit 1
fi

# Extract plugin name from info.json
PLUGIN_NAME=$(grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$PLUGIN_DIR/info.json" | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

if [[ -z "$PLUGIN_NAME" ]]; then
    echo "Error: Could not extract plugin name from info.json"
    exit 1
fi

echo "Found plugin: $PLUGIN_NAME"
echo "Source: $PLUGIN_DIR"
echo "Target: $FACTORIO_MODS_DIR/$PLUGIN_NAME"

# Create mods directory if it doesn't exist
mkdir -p "$FACTORIO_MODS_DIR"

# Remove existing plugin directory if it exists
if [[ -d "$FACTORIO_MODS_DIR/$PLUGIN_NAME" ]]; then
    echo "Removing existing plugin directory..."
    rm -rf "$FACTORIO_MODS_DIR/$PLUGIN_NAME"
fi

# Copy plugin to mods directory
echo "Copying plugin..."
cp -r "$PLUGIN_DIR" "$FACTORIO_MODS_DIR/$PLUGIN_NAME"

echo "✅ Plugin '$PLUGIN_NAME' successfully synced to Factorio mods directory"
```