---
name: gauntlet-loop
description: >
  Turns any goal into one short, paste-ready gauntlet-loop prompt for Grok
  Build, then can run it with spawn_subagent or the gauntlet workflow.
  Depth-1 spawns. No /loop, no ultracode — those are Claude Code.
  Triggers on "/gauntlet-loop", "gauntlet loop", "gauntlet this".
compatibility: grok-build
license: CC-BY-4.0
argument-hint: "<goal>"
when-to-use: "/gauntlet-loop, gauntlet loop, gauntlet this, make a gauntlet prompt, loop until it beats X"
---

# Gauntlet Loop (Grok Build)

You are on **Grok Build**. Spawn with `spawn_subagent`. Prefer the bundled `gauntlet` workflow when running.

**No `/loop`. No `ultracode`.** Those are Claude Code. Putting them in a Grok prompt is a dead instruction.

Read `<this-skill-dir>/references/loop.md` for bar tests, flow, and voice. Read `references/run-grok.md` for spawn and workflow details.

## Prompt template

```
Build [GOAL]. Model is grok-4.6.

The bar is [BAR]. Get the real thing first — fetch it, screenshot it, read it, or run it — and compare against that artifact, not against a memory or a description of it.

You are the lead. Break this into the smallest pieces that can be improved and judged on their own. For each piece, spawn a builder subagent and a separate critic subagent with fresh context. Never let a child spawn another child. Never let a critic resume a builder.

The critic inspects the actual output, puts it next to the bar with the labels stripped, says which one is better, and names the single biggest remaining gap. Then you send only that gap back to the builder. The critic should be harsh. Praise is not useful. A score is not useful. If ours does not win, keep going.

Keep looping until the critic picks ours blind — or, for a bar in a different medium than the product, until a challenger version stops beating the champion and no movable gap remains. Park any piece that loses twice on the same gap and report it. Do not stop before that. Do not name a round count.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn builders and critics from this session. Fetch bars live. For anything visual, open the real page or artifact and compare screenshots Grok can see.
```

## Run it here

Follow `references/run-grok.md`. Prefer `workflow` + `workflows/gauntlet.rhai`.

## Example (visual)

```
Build a landing page for a running brand. Athletic, peak performance, green and dark, energetic, aimed at a young healthy audience. It needs to be interactive and visually unmistakable. Model is grok-4.6.

The bar is Nike's current running campaign page. Open it in the browser, screenshot desktop and mobile, and compare against those images directly, not against a description of them.

You are the lead. Break this into the smallest pieces that can be improved and judged on their own — hero, motion, type, colour, imagery, interaction, mobile. For each piece, spawn a builder subagent and a separate critic subagent with fresh context. Never let a child spawn another child.

The critic opens the real Nike page and our page, puts the screenshots next to each other blind with the labels stripped, says which is better, and names the single biggest remaining gap. Then you send that gap back to the builder. The critic should be harsh. If ours does not win, it keeps going.

Keep looping until the critic picks ours blind. Do not stop before that.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn builders and critics from this session. Fetch the bar live. Compare screenshots Grok can see.
```
