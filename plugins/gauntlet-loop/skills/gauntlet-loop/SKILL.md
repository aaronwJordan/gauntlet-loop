---
name: gauntlet-loop
description: >
  Turns any goal into one short, paste-ready gauntlet-loop prompt, then can run
  it. The prompt makes the lead set a concrete fetchable quality bar, split the
  work, spawn a builder and a separate harsh critic on each piece, compare blind
  against the real bar, and loop until the critic picks ours. Tailored per
  harness: Claude Code uses /loop and ultracode; Grok uses spawn_subagent and a
  workflow; Codex uses spawn_agent; Copilot uses task and /fleet; OpenCode uses
  task. Triggers on "/gauntlet-loop", "gauntlet loop", "gauntlet this",
  "make a gauntlet prompt", "loop until it beats X".
when-to-use: "/gauntlet-loop, gauntlet loop, gauntlet this, make a gauntlet prompt, loop until it beats X"
argument-hint: "<goal>"
license: CC-BY-4.0
metadata:
  author: Aaron Jordan
  short-description: Harness-tailored gauntlet loop
---

# Gauntlet Loop

The user gives a goal. You give back ONE short prompt they can paste into a fresh session of **this** harness.

You are not doing the work. You are writing the prompt that makes another session grind until it beats a real reference.

If they then say to run it, you become the lead and follow the matching run file.

## Bind the harness first

Detect from tools **actually present**. Never invent a tool. Never mix primitives.

1. `spawn_subagent` → **Grok.** Read `references/run-grok.md`. No `/loop`, no `ultracode`.
2. `Agent` or `Task` together with `Bash` / `Read` / `Write` → **Claude Code.** Read `references/run-claude.md`. Use `/loop` and `ultracode`.
3. `spawn_agent` → **Codex CLI.** Read `references/run-codex.md`. No `/loop`, no `ultracode`.
4. `task` together with `view` / `apply_patch` → **Copilot CLI.** Read `references/run-copilot.md`. `/fleet` for disjoint pieces. No `/loop`, no `ultracode`.
5. `task` together with `todowrite` / `question` / `skill` → **OpenCode.** Read `references/run-opencode.md`. No `/loop`, no `ultracode`.

Then read `references/loop.md` (bar, flow, voice) and, when running, `references/builder.md` and `references/critic.md`.

Write the prompt using **that** run file's last third. A Claude prompt that omits `/loop` and ultracode is wrong. A Grok/Codex/Copilot/OpenCode prompt that includes them is wrong.

## After the prompt

One flat line: "I can run this here." Not a question.

If they say run it, follow that run file's **Run it here**. Resolve this skill's directory from the path of this SKILL.md.
