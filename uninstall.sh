#!/bin/bash
#
# whichmodel uninstaller
# Removes hook, settings entry, and CLAUDE.md guide
#

set -e

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"

echo "🔧 Uninstalling whichmodel..."

# Remove hook script
if [ -f "$HOOKS_DIR/whichmodel.sh" ]; then
    rm "$HOOKS_DIR/whichmodel.sh"
    echo "✓ Removed hook script"
else
    echo "- Hook script not found (skipping)"
fi

# Remove from settings.json
if [ -f "$SETTINGS" ] && command -v jq &> /dev/null; then
    if grep -q "whichmodel.sh" "$SETTINGS"; then
        # Remove any SessionStart entry containing whichmodel.sh
        jq '(.hooks.SessionStart // []) |= [.[] | select(.hooks | any(.command | contains("whichmodel.sh")) | not)]' "$SETTINGS" > "$SETTINGS.tmp"
        # Clean up empty SessionStart array
        jq 'if (.hooks.SessionStart // []) | length == 0 then del(.hooks.SessionStart) else . end' "$SETTINGS.tmp" > "$SETTINGS.tmp2"
        # Clean up empty hooks object
        jq 'if (.hooks // {}) | length == 0 then del(.hooks) else . end' "$SETTINGS.tmp2" > "$SETTINGS"
        rm -f "$SETTINGS.tmp" "$SETTINGS.tmp2"
        echo "✓ Removed hook from settings.json"
    else
        echo "- Hook not found in settings.json (skipping)"
    fi
else
    echo "- settings.json not found or jq not available (skipping)"
fi

# Remove from CLAUDE.md
if [ -f "$CLAUDE_MD" ]; then
    if grep -q "<!-- whichmodel -->" "$CLAUDE_MD"; then
        # Cross-platform sed -i (macOS requires '', Linux does not)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/<!-- whichmodel -->/,/<!-- \/whichmodel -->/d' "$CLAUDE_MD"
            sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD" 2>/dev/null || true
        else
            sed -i '/<!-- whichmodel -->/,/<!-- \/whichmodel -->/d' "$CLAUDE_MD"
            sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CLAUDE_MD" 2>/dev/null || true
        fi
        echo "✓ Removed guide from CLAUDE.md"
    else
        echo "- Guide not found in CLAUDE.md (skipping)"
    fi
else
    echo "- CLAUDE.md not found (skipping)"
fi

echo ""
echo "✅ whichmodel uninstalled successfully!"
