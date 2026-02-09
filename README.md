# whichmodel

**Automatic model recommendations for Claude Code**

Stop burning Opus tokens on simple tasks. `whichmodel` is a lightweight hook that makes Claude recommend the right model (Haiku, Sonnet, or Opus) based on task complexity—before you start implementation.

## The Problem

Claude Code remembers your last model. If you were using Opus for a complex task yesterday, you're still on Opus today—even if today's task is "fix a typo in the README."

For Claude Max subscribers, this means hitting rate limits faster than necessary. For API users, it means unnecessary costs.

## The Solution

`whichmodel` hooks into Claude Code and injects model recommendation instructions. When you:

- Enter plan mode (`/plan` or via EnterPlanMode)
- Import a ticket from Linear, Jira, or GitHub Issues
- Spawn a task agent

Claude will analyze the task and tell you which model it recommends:

```
📊 Model Recommendation: Sonnet
   Reasoning: Standard feature with clear requirements, no architectural complexity
   Current model: claude-opus-4-5-20251101
   Action: Consider switching via /model sonnet
```

## Installation

```bash
git clone https://github.com/yourusername/whichmodel.git
cd whichmodel
./install.sh
```

Requires `jq` for JSON manipulation:
```bash
brew install jq  # macOS
```

## How It Works

1. A hook fires when you enter plan mode or use task agents
2. The hook injects instructions telling Claude to assess task complexity
3. Claude (using its existing understanding of the task) recommends a model
4. You switch if needed with `/model <name>`

**No external API calls. No local LLMs. No extra cost.**

The intelligence comes from Claude itself—the hook just triggers the recommendation.

## Model Guidelines

| Model | Best For |
|-------|----------|
| **Haiku** | Simple/mechanical tasks, typos, single-file changes, docs |
| **Sonnet** | Standard features, tests, refactoring, moderate bugs |
| **Opus** | Architecture, ambiguous requirements, complex debugging |

## Token Economics

"But if I'm on Opus, aren't I already using expensive tokens for the recommendation?"

Yes, but:
- **Planning is cheap**: ~1-2k tokens to read a task and output a plan
- **Implementation is expensive**: 50-100k+ tokens for coding, iterating, debugging
- **You save on implementation**: If Opus says "this is a Haiku task" before you code, you switch and save the bulk of the spend

## Uninstallation

```bash
./uninstall.sh
```

## License

MIT

## Contributing

PRs welcome! Ideas for improvement:

- [ ] Track recommendation accuracy over time
- [ ] Integration with specific PM tools (Linear, Jira, GitHub)
- [ ] User-configurable complexity thresholds
- [ ] Statistics on estimated savings
