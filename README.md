# whichmodel

**Automatic model recommendations for Claude Code**

Stop burning Opus tokens on simple tasks. `whichmodel` adds instructions to your global CLAUDE.md that make Claude recommend the right model (Haiku, Sonnet, or Opus) based on task complexity—before you start implementation.

## The Problem

Claude Code remembers your last model. If you were using Opus for a complex task yesterday, you're still on Opus today—even if today's task is "fix a typo in the README."

For Claude Max subscribers, this means hitting rate limits faster than necessary. For API users, it means unnecessary costs.

## The Solution

`whichmodel` installs a SessionStart hook and reference guide into your Claude Code config. Before any significant task, Claude analyses complexity and recommends which model to use:

```
⚡ Model Recommendation: Switch to Sonnet
Current: claude-opus-4-6 → Suggested: claude-sonnet-4-6
Why: Standard feature with clear requirements, no architectural complexity
```

If a switch is recommended, Claude pauses and asks before continuing — so you never waste tokens on the wrong model.

## Installation

Requires `jq` (`brew install jq` on macOS, `apt install jq` on Linux).

```bash
git clone https://github.com/jonthebeef/whichmodel.git
cd whichmodel
./install.sh
```

That's it. One dependency, one command.

## How It Works

1. The installer adds a **SessionStart hook** to `~/.claude/settings.json`
2. It also appends a **model selection guide** to `~/.claude/CLAUDE.md`
3. Before any significant task, Claude recommends the right model
4. If a switch is recommended, Claude **pauses and asks you** before proceeding
5. You switch with `/model <name>` or continue as-is

**No external API calls. No local LLMs. No extra cost.**

The intelligence comes from Claude itself — the hook just tells it to include a recommendation.

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

## Upgrading

```bash
cd whichmodel
git pull
./install.sh
```

The installer detects existing installations and upgrades in-place. No need to uninstall first.

## Uninstallation

```bash
./uninstall.sh
```

Cleanly removes the hook, settings entry, and CLAUDE.md guide while preserving all your other config.

## License

MIT

## Contributing

PRs welcome! Ideas for improvement:

- [ ] Track recommendation accuracy over time
- [ ] Integration with specific PM tools (Linear, Jira, GitHub)
- [ ] User-configurable complexity thresholds
- [ ] Statistics on estimated savings
