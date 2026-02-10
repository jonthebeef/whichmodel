#!/bin/bash
#
# whichmodel installer
# Adds the model recommendation hook to Claude Code
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HOOK="$SCRIPT_DIR/hooks/session-start.sh"
TARGET_DIR="$HOME/.claude/hooks"
TARGET_HOOK="$TARGET_DIR/whichmodel.sh"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "🔧 Installing whichmodel..."

# Create hooks directory if needed
mkdir -p "$TARGET_DIR"

# Copy hook to .claude/hooks
cp "$SOURCE_HOOK" "$TARGET_HOOK"
chmod +x "$TARGET_HOOK"
echo "📁 Copied hook to ~/.claude/hooks/whichmodel.sh"

# Check if settings file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Creating Claude Code settings file..."
    echo '{}' > "$SETTINGS_FILE"
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is required but not installed."
    echo "   Install with: brew install jq"
    exit 1
fi

# Backup existing settings
cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"
echo "📦 Backed up settings to ~/.claude/settings.json.backup"

# Add the hook to SessionStart
UPDATED_SETTINGS=$(jq '
    # Ensure hooks object exists
    .hooks //= {} |
    # Ensure SessionStart array exists
    .hooks.SessionStart //= [] |
    # Remove any existing whichmodel hooks to avoid duplicates
    .hooks.SessionStart = [.hooks.SessionStart[] | select(
        .hooks[0].command // "" | contains("whichmodel") | not
    )] |
    # Add our hook
    .hooks.SessionStart += [{
        "hooks": [{
            "type": "command",
            "command": "~/.claude/hooks/whichmodel.sh"
        }]
    }]
' "$SETTINGS_FILE")

echo "$UPDATED_SETTINGS" > "$SETTINGS_FILE"

echo "✅ whichmodel installed successfully!"
echo ""
echo "How it works:"
echo "  - At the start of each session, Claude receives instructions"
echo "    to recommend the right model when planning tasks."
echo ""
echo "To test: Start a new session and use /plan with any task."
echo "To uninstall: ./uninstall.sh"
