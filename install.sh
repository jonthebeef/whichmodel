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
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "MANDATORY: Before starting ANY task, determine the CHEAPEST model that can handle it well, then compare to your current model.\n\nStep 1: Match the task to the cheapest sufficient model:\n- HAIKU: docs, READMEs, typos, small fixes, single-file edits, simple creative writing, obvious bugs\n- SONNET: standard features, refactoring, tests, multi-file changes, moderate debugging\n- OPUS: architecture decisions, ambiguous requirements, complex debugging, security-sensitive work, novel problems\n\nStep 2: Compare to your current model. DO NOT bias toward staying on the current model. If the task is simple, recommend the cheaper model even if you are already running.\n\nIf the cheapest sufficient model MATCHES your current model, output:\n\n---\n### ⚡ Model: [current model] (correct for this task)\n**Why:** [one sentence reasoning]\n\n---\n\nThen proceed with the task.\n\nIf the cheapest sufficient model DIFFERS from your current model, output:\n\n---\n### ⚡ Model Recommendation: Switch to [recommended]\n**Current:** [current model] → **Suggested:** [recommended model]\n**Why:** [one sentence reasoning]\n\n---\n\nThen you MUST use AskUserQuestion IMMEDIATELY to pause execution. Use exactly two options:\n- Option 1: label \"Continue with [current model]\", description \"Proceed without changing model\"\n- Option 2: label \"Switch to [recommended model]\", description \"Run /model [recommended] then type 'continue'\"\nIf the user selects option 2, respond ONLY with: \"Run `/model [recommended model]` then type **continue** to pick up where we left off.\" Do NOT proceed with the task.\nIf the user selects option 1 or provides any other response, proceed with the task immediately."
  }
}
EOF
HOOKEOF
chmod +x "$HOOKS_DIR/whichmodel.sh"
echo "✓ Hook script installed"

# Append slim reference guide to CLAUDE.md
cat >> "$CLAUDE_MD" << 'EOF'

<!-- whichmodel -->
## Model Recommendation Protocol

A SessionStart hook (whichmodel) injects model recommendation instructions via additionalContext at the start of every session. You MUST follow those instructions before responding to any task. Do not skip, ignore, or summarize the hook's output — execute its instructions exactly as written, including any AskUserQuestion pauses.
<!-- /whichmodel -->
EOF
echo "✓ Model guide added to CLAUDE.md"

# Wire hook into settings.json
HOOK_ENTRY='{"hooks": [{"type": "command", "command": "$HOME/.claude/hooks/whichmodel.sh"}]}'

if [ -f "$SETTINGS" ]; then
    # Backup settings
    cp "$SETTINGS" "$SETTINGS.backup"

    # Remove any existing whichmodel entries from nested hook groups
    if grep -q "whichmodel.sh" "$SETTINGS"; then
        jq '
          (.hooks.SessionStart // []) |= [
            .[] |
            .hooks = [.hooks[] | select(.command | test("whichmodel") | not)] |
            select(.hooks | length > 0)
          ]
        ' "$SETTINGS" > "$SETTINGS.tmp"
        mv "$SETTINGS.tmp" "$SETTINGS"
    fi

    # Add whichmodel as its own hook group
    if jq -e '.hooks.SessionStart' "$SETTINGS" > /dev/null 2>&1; then
        jq --argjson entry "$HOOK_ENTRY" '.hooks.SessionStart += [$entry]' "$SETTINGS" > "$SETTINGS.tmp"
    elif jq -e '.hooks' "$SETTINGS" > /dev/null 2>&1; then
        jq --argjson entry "$HOOK_ENTRY" '.hooks.SessionStart = [$entry]' "$SETTINGS" > "$SETTINGS.tmp"
    else
        jq --argjson entry "$HOOK_ENTRY" '.hooks = {"SessionStart": [$entry]}' "$SETTINGS" > "$SETTINGS.tmp"
    fi
    mv "$SETTINGS.tmp" "$SETTINGS"
    echo "✓ Hook wired into settings.json"
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
