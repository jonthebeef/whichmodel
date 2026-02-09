#!/bin/bash
# whichmodel installer
# Adds the model recommendation hook to Claude Code settings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_PATH="$SCRIPT_DIR/hooks/session-start.sh"
SETTINGS_FILE="$HOME/.claude/settings.json"

echo "🔧 Installing whichmodel..."

# Make hook executable
chmod +x "$HOOK_PATH"

# Check if settings file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "Creating Claude Code settings file..."
    mkdir -p "$HOME/.claude"
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
echo "📦 Backed up settings to $SETTINGS_FILE.backup"

# Add the hook to settings using the correct Claude Code hook structure
UPDATED_SETTINGS=$(jq --arg hook "$HOOK_PATH" '
    # Ensure hooks object exists
    .hooks //= {} |
    # Ensure PreToolUse array exists
    .hooks.PreToolUse //= [] |
    # Remove any existing whichmodel hooks to avoid duplicates
    .hooks.PreToolUse = [.hooks.PreToolUse[] | select(
        .hooks[0].command // "" | contains("whichmodel") | not
    )] |
    # Add our hook for EnterPlanMode and Task tools
    .hooks.PreToolUse += [{
        "matcher": "EnterPlanMode|Task",
        "hooks": [{
            "type": "command",
            "command": $hook
        }]
    }]
' "$SETTINGS_FILE")

echo "$UPDATED_SETTINGS" > "$SETTINGS_FILE"

echo "✅ whichmodel installed successfully!"
echo ""
echo "How it works:"
echo "  - When you enter plan mode or spawn a task agent,"
echo "    Claude will now recommend which model to use."
echo ""
echo "To uninstall: ./uninstall.sh"
