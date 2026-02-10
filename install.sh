#!/bin/bash
#
# whichmodel installer
# Adds model recommendation instructions to global CLAUDE.md
#

set -e

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER="<!-- whichmodel -->"

echo "🔧 Installing whichmodel..."

# Create .claude directory if needed
mkdir -p "$HOME/.claude"

# Check if already installed
if [ -f "$CLAUDE_MD" ] && grep -q "$MARKER" "$CLAUDE_MD"; then
    echo "⚠️  whichmodel is already installed in ~/.claude/CLAUDE.md"
    echo "   Run ./uninstall.sh first if you want to reinstall."
    exit 0
fi

# Backup existing CLAUDE.md if it exists
if [ -f "$CLAUDE_MD" ]; then
    cp "$CLAUDE_MD" "$CLAUDE_MD.backup"
    echo "📦 Backed up existing CLAUDE.md"
fi

# Append whichmodel instructions
cat >> "$CLAUDE_MD" << 'EOF'

<!-- whichmodel -->
## Model Recommendation Protocol

Before starting ANY significant task (feature implementation, bug fix, refactoring, or when receiving tasks from Linear/Jira/GitHub), assess the complexity and recommend the appropriate model.

**Include this block before you begin work:**

```
📊 Model Recommendation: [Haiku|Sonnet|Opus]
   Reasoning: [one sentence why]
   Current model: [your current model]
   Action: [No change needed OR switch via /model <name>]
```

**Model selection guide:**
- **Haiku**: Simple/mechanical tasks - typos, small fixes, docs, single-file changes, obvious bugs
- **Sonnet**: Standard features, refactoring, tests, multi-file changes with clear patterns, moderate debugging
- **Opus**: Architecture decisions, ambiguous requirements, complex debugging, security-sensitive work, novel problems

**When to show this:**
- When entering plan mode
- When the user describes a task they want done
- When importing/analyzing tickets from external tools
- At the start of any multi-step implementation

This helps users optimize their Claude Max subscription by using the right model for each task.
<!-- /whichmodel -->
EOF

echo "✅ whichmodel installed successfully!"
echo ""
echo "Added to: ~/.claude/CLAUDE.md"
echo ""
echo "How it works:"
echo "  - Before starting significant tasks, Claude recommends the right model"
echo "  - Switch models with /model <name> if recommended"
echo ""
echo "To uninstall: ./uninstall.sh"
