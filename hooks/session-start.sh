#!/bin/bash
#
# session-start.sh (part of whichmodel)
# A Claude Code SessionStart hook that injects model recommendation instructions
#

set -euo pipefail

# Output context that will be injected into the session
cat <<'EOF'
{
  "additionalContext": "MODEL RECOMMENDATION PROTOCOL: When you enter plan mode, receive a task from a project management tool (Linear, Jira, GitHub Issues, etc.), or are asked to analyze/plan work, you MUST include a model recommendation. Assessment: HAIKU for simple/mechanical tasks (typos, single-file changes, docs, obvious fixes); SONNET for standard features, tests, refactoring, multi-file changes following patterns, moderate bugs; OPUS for architecture decisions, ambiguous requirements, system-wide changes, complex debugging, security-sensitive work, novel problems. Format your recommendation as: 📊 Model Recommendation: [Haiku|Sonnet|Opus] | Reasoning: [why] | Current: [your model] | Action: [No change needed OR switch via /model <name>]. Place this near the top of your plan."
}
EOF
