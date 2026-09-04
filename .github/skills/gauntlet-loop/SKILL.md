---
name: gauntlet-loop
description: >
  Turns any goal into one short, paste-ready gauntlet-loop prompt for GitHub
  Copilot CLI, then can run it with the task tool and /fleet for disjoint
  pieces. No /loop, no ultracode — those are Claude Code.
  Triggers on "/gauntlet-loop", "gauntlet loop", "gauntlet this".
compatibility: copilot-cli
license: CC-BY-4.0
argument-hint: "<goal>"
---

# Gauntlet Loop (Copilot CLI)

You are on **GitHub Copilot CLI**. Spawn with `task`. Independent file-disjoint pieces may use `/fleet`. File tools are `view`, `create`, `edit`, `apply_patch`, `bash`.

**No `/loop`. No `ultracode`.** Those are Claude Code.

Read `<this-skill-dir>/references/loop.md` for bar tests, flow, and voice. Read `references/run-copilot.md` for spawn details.

Apply the evidence and completion contract in `references/loop.md`: select references before implementation, isolate blind A/B critic packets, inspect the shipped experience, and require passing checks plus the mode-specific completion condition. Preserve these requirements in the generated prompt.

## Prompt template

```
Build [GOAL].

The bar is [BAR]. Get the real thing first — fetch it, screenshot it, read it, or run it — and compare against that artifact, not against a memory or a description of it.

You are the lead. Break this into the smallest pieces that can be improved and judged on their own. For each piece, spawn a builder with the task tool and a separate critic with the task tool and fresh context. Independent pieces may run in parallel or via /fleet. Same-file pieces stay serial. A critic is a new task every time.

The critic inspects the actual output, puts it next to the bar with the labels stripped, says which one is better, and names the single biggest remaining gap. Then you send only that gap back to the builder. The critic should be harsh. Praise is not useful. A score is not useful. If ours does not win, keep going.

Keep looping until the critic picks ours blind — or, for a bar in a different medium than the product, until a challenger version stops beating the champion and no movable gap remains. Park any piece that loses twice on the same gap and report it. Do not stop before that. Do not name a round count.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn builders and critics with the task tool. There is no /loop and no ultracode in this session.
```

## Run it here

Follow `references/run-copilot.md`.

## Example (visual)

```
Build a landing page for a running brand. Athletic, peak performance, green and dark, energetic, aimed at a young healthy audience. It needs to be interactive and visually unmistakable.

The bar is Nike's current running campaign page. Open it in the browser, screenshot desktop and mobile, and compare against those images directly, not against a description of them.

You are the lead. Break this into the smallest pieces that can be improved and judged on their own — hero, motion, type, colour, imagery, interaction, mobile. For each piece, spawn a builder with the task tool and a separate critic with the task tool. Independent pieces may use /fleet. Never let a critic edit the product.

The critic opens the real Nike page and our page, puts the screenshots next to each other blind with the labels stripped, says which is better, and names the single biggest remaining gap. Then you send that gap back to the builder. The critic should be harsh. If ours does not win, it keeps going.

Keep looping until the critic picks ours blind. Do not stop before that.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn builders and critics with the task tool. There is no /loop and no ultracode in this session.
```
