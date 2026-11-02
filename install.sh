#!/bin/bash
set -euo pipefail

# Links this repo's skills into ~/.claude/skills. Safe to re-run.
# Run by both lukewiwa/dotfiles (macOS host) and lukewiwa/devcontainer-dotfiles (containers).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

echo "Linking Claude config..."
mkdir -p "${CLAUDE_DIR}/skills"

link() {
    local src="$1" dest="$2"
    # Keep a real file or directory that's in the way rather than overwrite it
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mv "$dest" "${dest}.bak"
        echo "  Moved existing ${dest} to ${dest}.bak"
    fi
    ln -sfn "$src" "$dest"
    echo "  Linked ${dest} -> ${src}"
}

for skill in "${SCRIPT_DIR}"/skills/*/; do
    skill="${skill%/}"
    link "$skill" "${CLAUDE_DIR}/skills/$(basename "$skill")"
done
