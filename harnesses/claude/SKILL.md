---
name: gauntlet-loop
description: >
  Turns any goal into one short, paste-ready gauntlet-loop prompt for Claude
  Code, then can run it with /loop and the Agent tool (ultracode when the budget
  allows). Builder and critic are separate subagents. Loop until the critic
  picks ours blind; cross-medium bars run champion-challenger until no
  movable gap remains.
  Triggers on "/gauntlet-loop", "gauntlet loop", "gauntlet this".
compatibility: claude-code
license: CC-BY-4.0
argument-hint: "<goal>"
---

# Gauntlet Loop (Claude Code)

You are on **Claude Code**. `/loop` is native here — use it in every written prompt. `/effort ultracode` is a budget decision, not a default (see `references/run-claude.md`).

Do not mention Grok `spawn_subagent`, Codex `spawn_agent`, Copilot `/fleet`, or OpenCode `task`.

Read `<this-skill-dir>/references/loop.md` for bar tests, flow, and voice. Read `references/run-claude.md` for spawn details. Prepend `references/builder.md` and `references/critic.md` when spawning.

## Prompt template

```
Build [GOAL].

The bar is [BAR]. Get the real thing first — fetch it, screenshot it, read it, or run it — and compare against that artifact, not against a memory or a description of it.

You are the lead. Break this into the smallest pieces that can be improved and judged on their own. For each piece, fan out a builder and a separate critic with fresh context using the Agent tool. Never let a child spawn another child. Never let a critic resume a builder.

The critic inspects the actual output, puts it next to the bar with the labels stripped, says which one is better, and names the single biggest remaining gap. Then you send only that gap back to the builder. The critic should be harsh. Praise is not useful. A score is not useful. If ours does not win, keep going.

/loop on each piece until the critic picks ours blind — or, for a cross-medium bar, until the challenger stops beating the champion and no movable gap remains. Park any piece that loses twice on the same gap and tell me. Do not stop before that.

Keep a live progress file updating as the work evolves so I can watch it.

Fan out subagents — builders on a strong model, critics on a cheap one. Use ultracode only if I have approved the spend.
```

## Run it here

Follow `references/run-claude.md`, including its effort-budget and progress-file rules.

## Example (visual)

Bars offered, user picks Nike's current running campaign page.

```
Build a landing page for a running brand. Athletic, peak performance, green and dark, energetic, aimed at a young healthy audience. It needs to be interactive and visually unmistakable.

The bar is Nike's current running campaign page. Open it in the browser, screenshot desktop and mobile, and compare against those images directly, not against a description of them.

You are the lead. Break this into the smallest pieces that can be improved and judged on their own — hero, motion, type, colour, imagery, interaction, mobile. For each piece, fan out a builder and a separate critic with the Agent tool. Never let a child spawn another child.

The critic opens the real Nike page and our page, puts the screenshots next to each other blind with the labels stripped, says which is better, and names the single biggest remaining gap. Then you send that gap back to the builder. The critic should be harsh. If ours does not win, it keeps going.

/loop on each piece until the critic picks ours blind. Do not stop before that.

Keep a live progress file updating as the work evolves so I can watch it.

Fan out subagents and ultracode.
```
