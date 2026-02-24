# whichmodel

**Automatic model recommendations for Claude Code**

Stop burning Opus tokens on simple tasks. `whichmodel` installs a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) hook that recommends the cheapest sufficient model (Haiku, Sonnet, or Opus) before every task — and pauses to let you switch.

## The Problem

Claude Code remembers your last model. If you were using Opus for a complex task yesterday, you're still on Opus today—even if today's task is "fix a typo in the README."

For Claude Max subscribers, this means hitting rate limits faster than necessary. For API users, it means unnecessary costs.

## The Solution

`whichmodel` installs a SessionStart hook that injects model recommendation logic at the start of every session. Before any task, Claude determines the cheapest model that can handle it and tells you:

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

1. A **SessionStart hook** (`~/.claude/hooks/whichmodel.sh`) injects model recommendation instructions via `hookSpecificOutput.additionalContext`
2. A **CLAUDE.md directive** (`~/.claude/CLAUDE.md`) tells Claude to follow the hook's instructions — no skipping, no summarizing
3. Before any task, Claude determines the **cheapest sufficient model** and compares it to the current one
4. If a switch is recommended, Claude **pauses with AskUserQuestion** before proceeding
5. You switch with `/model <name>` or continue as-is

**No external API calls. No local LLMs. No extra cost.**

The intelligence comes from Claude itself — the hook injects the decision framework, and CLAUDE.md ensures it's followed.

## Model Guidelines

| Model | Best For |
|-------|----------|
| **Haiku** | Simple/mechanical tasks, typos, single-file changes, docs |
| **Sonnet** | Standard features, tests, refactoring, moderate bugs |
| **Opus** | Architecture, ambiguous requirements, complex debugging |

## Token Economics

"But if I'm on Opus, aren't I already using expensive tokens for the recommendation?"

Yes, but the recommendation costs ~1-2k tokens. Implementation costs 50-100k+. If Opus says "this is a Haiku task" before you start coding, you switch and save the bulk of the spend.

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
