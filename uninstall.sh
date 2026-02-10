#!/bin/bash
#
# whichmodel uninstaller
# Removes model recommendation instructions from global CLAUDE.md
#

set -e

CLAUDE_MD="$HOME/.claude/CLAUDE.md"

echo "🔧 Uninstalling whichmodel..."

# Check if CLAUDE.md exists
if [ ! -f "$CLAUDE_MD" ]; then
    echo "No ~/.claude/CLAUDE.md found. Nothing to uninstall."
    exit 0
fi

# Check if whichmodel is installed
if ! grep -q "<!-- whichmodel -->" "$CLAUDE_MD"; then
    echo "whichmodel not found in ~/.claude/CLAUDE.md. Nothing to uninstall."
    exit 0
fi

# Remove whichmodel section (between markers)
sed -i '' '/<!-- whichmodel -->/,/<!-- \/whichmodel -->/d' "$CLAUDE_MD"

# Clean up any leftover empty lines at end of file
sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD" 2>/dev/null || true

echo "✅ whichmodel uninstalled successfully!"
echo "   Removed from ~/.claude/CLAUDE.md"
