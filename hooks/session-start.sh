#!/bin/bash
#
# whichmodel.sh
# Claude Code SessionStart hook for model recommendations
#

set -euo pipefail

cat <<'EOF'
{
  "additionalContext": "MANDATORY: When creating ANY plan, include this block at the TOP before other content:\n\n📊 Model Recommendation: [Haiku|Sonnet|Opus]\n   Reasoning: [one sentence why]\n   Current model: [state your model]\n   Action: [No change needed OR switch via /model <name>]\n\nHAIKU = simple/mechanical (typos, small fixes, docs)\nSONNET = standard features, refactoring, tests\nOPUS = architecture, ambiguous requirements, complex debugging\n\nThis block is REQUIRED at the start of every plan."
}
EOF
