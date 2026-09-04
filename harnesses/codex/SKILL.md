---
name: gauntlet-loop
description: >
  Writes a short gauntlet-loop prompt for Codex desktop, CLI, or IDE, then
  can run builder/critic subagents using the session's available tools.
  Supports Astra with Ultra. No /loop or ultracode.
compatibility: Codex with subagent tools enabled
license: CC-BY-4.0
argument-hint: "<goal>"
---

# Gauntlet Loop for Codex

Read `references/loop.md` for the bar, flow, and voice, and `references/run-codex.md` for runtime tool binding and Astra/Ultra setup. Detect tools from the running session; do not assume every Codex client exposes the same signatures.

An explicit request to run authorizes the builder/critic workflow. An explicit request to maintain this skill authorizes editing it directly. User instructions take precedence over skill guidelines.

## Prompt template

Replace the placeholders with the user's concrete goal, fetchable bar, and relevant checks. Omit the checks clause if there is no measurable requirement. Keep the generated prompt near 180 words and use only tool names verified in this session.

```text
Build [GOAL]. Use [FETCHABLE BAR] as the quality reference and [CHECKS] as the measurable requirements. Fetch the actual reference before building.

Act as lead. Use subagents: assign independent pieces to builders and judge each finished piece with a separate, fresh-context critic. Only the lead spawns agents. Use the available Codex tools and schemas; use the supported follow-up tool to send a builder its next gap. Keep the selected model and reasoning effort.

Give critics neutral A/B artifacts without builder explanations or inherited conversation history. Disable history inheritance through the exposed spawn schema. Inspect the actual output at its shipped fidelity. Require a binary winner, the biggest remaining gap, and fetched evidence. Map identities only after judging. A missing comparison is never a win.

Loop until ours wins. For a cross-medium reference, compare champion and challenger against it until the challenger stops winning and no movable gap remains. Park two consecutive losses on the same gap, report evidence, and continue independent pieces. Respect user changes and explicit budgets. Keep gauntlet-progress.md current with verdicts, artifact versions, blockers, and next actions. Never call a parked or blocked piece complete.
```

## Run it here

Follow `references/run-codex.md`. Select Astra and Ultra through the client when requested; prose alone does not change the model configuration.
