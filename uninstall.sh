#!/bin/bash
#
# whichmodel uninstaller
# Removes the model recommendation hook from Claude Code
#

set -e

TARGET_HOOK="$HOME/.claude/hooks/whichmodel.sh"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "🔧 Uninstalling whichmodel..."

# Remove hook file
if [ -f "$TARGET_HOOK" ]; then
    rm "$TARGET_HOOK"
    echo "📁 Removed ~/.claude/hooks/whichmodel.sh"
fi

# Check if settings file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "No Claude Code settings file found. Nothing to uninstall."
    exit 0
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is required but not installed."
    echo "   Install with: brew install jq"
    exit 1
fi

# Remove whichmodel hooks from settings
UPDATED_SETTINGS=$(jq '
    if .hooks.SessionStart then
        .hooks.SessionStart = [.hooks.SessionStart[] | select(
            .hooks[0].command // "" | contains("whichmodel") | not
        )]
    else
        .
    end
' "$SETTINGS_FILE")

echo "$UPDATED_SETTINGS" > "$SETTINGS_FILE"

echo "✅ whichmodel uninstalled successfully!"
