#!/bin/bash
# Copy built plugin files into the Obsidian vault. Bash 3.2 safe.
# Usage: ./deploy.sh   (override target with VAULT_PLUGIN_DIR)
set -u
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${VAULT_PLUGIN_DIR:-/Users/fab/Library/Mobile Documents/iCloud~md~obsidian/Documents/fab/.obsidian/plugins/jw-quote-linker}"

mkdir -p "$DEST" || { echo "cannot create $DEST"; exit 1; }
for f in main.js manifest.json styles.css; do
  if [ ! -f "$SRC/$f" ]; then echo "missing $f"; exit 1; fi
  cp "$SRC/$f" "$DEST/$f" || { echo "copy failed: $f"; exit 1; }
done

# Seed settings from the old store install, only if none exist yet.
OLD="$(dirname "$DEST")/jwl-linker/data.json"
if [ ! -f "$DEST/data.json" ] && [ -f "$OLD" ]; then
  cp "$OLD" "$DEST/data.json" && echo "seeded data.json from old jwl-linker"
fi
echo "deployed to $DEST"
