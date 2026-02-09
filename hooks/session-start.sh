#!/bin/bash
# whichmodel - Session start hook for Claude Code
# Injects model recommendation instructions into every session

cat << 'EOF'
<system-reminder>
## Model Recommendation Protocol

When you enter plan mode, receive a task from a project management tool (Linear, Jira, GitHub Issues, etc.), or are asked to analyze/plan work, you MUST include a model recommendation as part of your response.

### Assessment Criteria

**Haiku** - Recommend for:
- Simple, mechanical tasks (fix typos, rename variables, add logs)
- Single-file changes with clear instructions
- Documentation updates
- Straightforward bug fixes with obvious solutions
- Code formatting or linting fixes

**Sonnet** - Recommend for:
- Standard feature implementation with clear requirements
- Writing tests for existing code
- Refactoring with well-defined scope
- Multi-file changes following established patterns
- Moderate bug fixes requiring some investigation
- Adding validation, error handling, or similar enhancements

**Opus** - Recommend for:
- Complex architectural decisions
- Ambiguous requirements needing interpretation
- System-wide changes affecting multiple components
- Debugging complex issues with unclear root causes
- Performance optimization requiring deep analysis
- Security-sensitive implementations
- Novel problems without established patterns

### Output Format

Include this block in your plan or task analysis:

```
📊 Model Recommendation: [Haiku|Sonnet|Opus]
   Reasoning: [One sentence explaining why]
   Current model: [Your current model]
   Action: [No change needed OR Consider switching via /model <name>]
```

Always place this near the top of your plan, before the detailed implementation steps.
</system-reminder>
EOF
