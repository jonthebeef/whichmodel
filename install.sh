#!/bin/bash
#
# whichmodel installer
# Adds model recommendation hook and reference guide to CLAUDE.md
#

set -e

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"
MARKER="<!-- whichmodel -->"

echo "🔧 Installing whichmodel..."

# Check for jq (needed for settings.json manipulation)
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed."
    echo "   Install with: brew install jq (macOS) or apt install jq (Linux)"
    exit 1
fi

# Create directories if needed
mkdir -p "$HOME/.claude"
mkdir -p "$HOOKS_DIR"

# Check if already installed — upgrade in-place if so
UPGRADING=false
if [ -f "$CLAUDE_MD" ] && grep -q "$MARKER" "$CLAUDE_MD"; then
    UPGRADING=true
    echo "📦 Existing installation detected — upgrading..."
    # Remove old CLAUDE.md section (cross-platform sed)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/<!-- whichmodel -->/,/<!-- \/whichmodel -->/d' "$CLAUDE_MD"
    else
        sed -i '/<!-- whichmodel -->/,/<!-- \/whichmodel -->/d' "$CLAUDE_MD"
    fi
fi

# Backup existing CLAUDE.md if it exists
if [ -f "$CLAUDE_MD" ]; then
    cp "$CLAUDE_MD" "$CLAUDE_MD.backup"
    echo "📦 Backed up existing CLAUDE.md"
fi

# Install the hook script
cat > "$HOOKS_DIR/whichmodel.sh" << 'HOOKEOF'
#!/bin/bash
#
# whichmodel.sh
# Claude Code SessionStart hook for model recommendations
#

set -euo pipefail

cat <<'EOF'
{
  "additionalContext": "MANDATORY: Before starting ANY significant task (feature implementation, bug fix, refactoring, or when receiving tasks from external tools), assess complexity and recommend the appropriate model.\n\nIf no model change is needed, output this block at the TOP before other content:\n\n---\n### ⚡ Model: [Haiku|Sonnet|Opus] (no change needed)\n**Why:** [one sentence reasoning]\n\n---\n\nIf a model SWITCH is recommended, output this block instead:\n\n---\n### ⚡ Model Recommendation: Switch to [recommended]\n**Current:** [current model] → **Suggested:** [recommended model]\n**Why:** [one sentence reasoning]\n\n---\n\nModel guide:\nHAIKU = simple/mechanical (typos, small fixes, docs)\nSONNET = standard features, refactoring, tests\nOPUS = architecture, ambiguous requirements, complex debugging\n\nCRITICAL - IF YOUR RECOMMENDATION DIFFERS FROM THE CURRENT MODEL:\nYou MUST use AskUserQuestion IMMEDIATELY AFTER the banner to pause execution and let the user decide. Use exactly two options:\n- Option 1: label \"Continue with <current model>\", description \"Proceed without changing model\"\n- Option 2: label \"Switch to <recommended model>\", description \"Type /model <recommended> to switch, then re-send your task\"\nIf the user selects option 2, respond ONLY with: \"Type `/model <recommended model>` and then re-send your task.\" Do NOT proceed with the task.\nIf the user selects option 1 or provides any other response, proceed with the task immediately."
}
EOF
HOOKEOF
chmod +x "$HOOKS_DIR/whichmodel.sh"
echo "✓ Hook script installed"

# Append slim reference guide to CLAUDE.md
cat >> "$CLAUDE_MD" << 'EOF'

<!-- whichmodel -->
## Model Recommendation Protocol

Model selection guide (used by whichmodel hook):
- **Haiku**: Simple/mechanical tasks - typos, small fixes, docs, single-file changes, obvious bugs
- **Sonnet**: Standard features, refactoring, tests, multi-file changes with clear patterns, moderate debugging
- **Opus**: Architecture decisions, ambiguous requirements, complex debugging, security-sensitive work, novel problems
<!-- /whichmodel -->
EOF
echo "✓ Model guide added to CLAUDE.md"

# Wire hook into settings.json
HOOK_ENTRY='{"hooks": [{"type": "command", "command": "~/.claude/hooks/whichmodel.sh"}]}'

if [ -f "$SETTINGS" ]; then
    # Backup settings
    cp "$SETTINGS" "$SETTINGS.backup"

    if grep -q "whichmodel.sh" "$SETTINGS"; then
        echo "✓ Hook already wired in settings.json"
    else
        # Add to existing SessionStart array, or create it
        if jq -e '.hooks.SessionStart' "$SETTINGS" > /dev/null 2>&1; then
            # SessionStart exists - append our hook
            jq --argjson entry "$HOOK_ENTRY" '.hooks.SessionStart += [$entry]' "$SETTINGS" > "$SETTINGS.tmp"
        elif jq -e '.hooks' "$SETTINGS" > /dev/null 2>&1; then
            # hooks exists but no SessionStart - add it
            jq --argjson entry "$HOOK_ENTRY" '.hooks.SessionStart = [$entry]' "$SETTINGS" > "$SETTINGS.tmp"
        else
            # no hooks at all - create the structure
            jq --argjson entry "$HOOK_ENTRY" '.hooks = {"SessionStart": [$entry]}' "$SETTINGS" > "$SETTINGS.tmp"
        fi
        mv "$SETTINGS.tmp" "$SETTINGS"
        echo "✓ Hook wired into settings.json"
    fi
else
    # Create settings.json from scratch
    cat > "$SETTINGS" << SETTINGSEOF
{
  "hooks": {
    "SessionStart": [
      $HOOK_ENTRY
    ]
  }
}
SETTINGSEOF
    echo "✓ Created settings.json with hook"
fi

echo ""
if [ "$UPGRADING" = true ]; then
    echo "✅ whichmodel upgraded successfully!"
else
    echo "✅ whichmodel installed successfully!"
fi
echo ""
echo "What's included:"
echo "  - Hook: ~/.claude/hooks/whichmodel.sh (behavioral logic)"
echo "  - Guide: ~/.claude/CLAUDE.md (model selection reference)"
echo "  - Config: ~/.claude/settings.json (hook wiring)"
echo ""
echo "How it works:"
echo "  - Before significant tasks, Claude recommends the right model"
echo "  - If a switch is recommended, Claude pauses and asks you"
echo "  - Select 'Continue' to proceed, or 'Switch' to change model first"
echo ""
echo "To upgrade: git pull && ./install.sh"
echo "To uninstall: ./uninstall.sh"
