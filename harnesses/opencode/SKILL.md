---
name: gauntlet-loop
description: >
  Turns any goal into one short, paste-ready gauntlet-loop prompt for OpenCode,
  then can run it with the task tool. Critics are new tasks every time. No
  /loop, no ultracode — those are Claude Code.
  Triggers on "/gauntlet-loop", "gauntlet loop", "gauntlet this".
compatibility: opencode
license: CC-BY-4.0
argument-hint: "<goal>"
---

# Gauntlet Loop (OpenCode)

You are on **OpenCode**. Spawn with `task`. Bar choice can use `question`. Progress can use `todowrite`.

**No `/loop`. No `ultracode`.** Those are Claude Code.

Read `<this-skill-dir>/references/loop.md` for bar tests, flow, and voice. Read `references/run-opencode.md` for spawn details.

## Prompt template

```
Build [GOAL].

The bar is [BAR]. Get the real thing first — fetch it, screenshot it, read it, or run it — and compare against that artifact, not against a memory or a description of it.

You are the lead. Break this into the smallest pieces that can be improved and judged on their own. For each piece, spawn a builder with the task tool and a separate critic with the task tool and fresh context. A critic is a new task every time. After a loss, spawn the builder again with only the gap and the artifact path. Never let a child spawn another child.

The critic inspects the actual output, puts it next to the bar with the labels stripped, says which one is better, and names the single biggest remaining gap. Then you send only that gap back to the builder. The critic should be harsh. Praise is not useful. A score is not useful. If ours does not win, keep going.

Keep looping until the critic picks ours blind — or, for a bar in a different medium than the product, until a challenger version stops beating the champion and no movable gap remains. Park any piece that loses twice on the same gap and report it. Do not stop before that. Do not name a round count.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn builders and critics with the task tool. There is no /loop and no ultracode in this session.
```

## Run it here

Follow `references/run-opencode.md`.

## Example (non-visual)

```
Write a 2000-word explainer on vector databases for readers who are smart but not engineers.

The bar is Julia Evans' writing on hard technical topics. Fetch three of her actual posts and compare against those texts directly, not against a description of her style.

You are the lead. Break this into the smallest pieces that can be judged on their own — the opening, each explanation, the diagrams, the analogies, the ending. For each piece, spawn a writer with the task tool and a separate critic with the task tool. A critic is a new task every time.

The critic reads ours and hers blind with the bylines stripped, says which one a non-engineer would understand faster, and names the single biggest remaining gap. Then you send that gap back to the writer. The critic should be harsh. If ours does not win, it keeps going.

Keep looping until the critic picks ours blind. Do not stop before that.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn writers and critics with the task tool. There is no /loop and no ultracode in this session.
```
