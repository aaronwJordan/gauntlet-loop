# Run on Claude Code

This harness has `/loop` and `ultracode`. Use them. Do not mention Grok `spawn_subagent`, Codex `spawn_agent`, Copilot `/fleet`, or OpenCode `task`.

## Primitives

- **Effort is a budget decision, not a default.** `/effort ultracode` (or `claude --effort ultracode`, Claude Code v2.1.203+) buys `xhigh` reasoning plus automatic dynamic-workflow orchestration — use it when the user asked for maximum depth and accepted the cost. Otherwise run the lead at normal effort and put the spend where it pays: **builders on a strong model, critics on a cheap one** (`Agent` takes `model`; critics carry two artifacts and a short verdict, no repo context — they are the numerous calls and should be the cheap ones).
- **`/loop`**. Repeats a prompt while the session stays open (self-paced if you omit the interval). The paste-ready prompt must include `/loop on each piece until the critic picks ours blind`. That is the keep-going instruction. Do not invent a round count instead.
- **Spawn:** `Agent` (`Task` still aliases). `subagent_type` is `gauntlet-builder` or `gauntlet-critic` when those agents are loaded; otherwise `general-purpose`. Prefix `description` with `[builder]` or `[critic]`. Independent pieces: `run_in_background: true`.
- **Resume builder:** `Agent` with the saved `agentId`, or `SendMessage` to that agent. Never resume a critic — new `Agent` every time.
- **Critic writes a verdict file.** Do not deny Write. The prompt keeps the critic off the product.
- Children must not get the `Agent` tool for further fan-out. Only the lead spawns.

## Prompt last third (paste this shape)

```
/loop on each piece until the critic picks ours blind — or, for a cross-medium bar, until the challenger stops beating the champion and no movable gap remains. Park any piece that loses twice on the same gap and tell me. Do not stop before that.

Keep a live progress file updating as the work evolves so I can watch it.

Fan out builders and critics with the Agent tool — builders on a strong model, critics on a cheap one. Use ultracode only if I have said the budget allows it. A critic is a new Agent every time. Resume a builder; never resume a critic.
```

## Run it here

1. Turn on `/effort ultracode` only if the user approved the spend; otherwise stay at normal effort and set per-`Agent` models instead.
2. Write the progress file in the project's gitignored scratch (`review/`, `shots/`, or equivalent) — never the repo root of a repo with hygiene rules. Update it after every critic.
3. Read `builder.md` and `critic.md` once. Prepend the matching file to each child prompt.
4. Spawn with `Agent` as above. Same workspace. Do not default worktree isolation — pieces of one product share files.
5. Command the critic to fetch the bar and the work, then write `{winner, gap, evidence}` to the path you name. Fail closed: missing file, empty evidence, or a score instead of a pick means ours did not win.
6. After a loss, resume that piece's builder. Send only the critic's gap.
7. Visual work: browser MCP at matching viewports, screenshots for the critic.
8. Independent pieces may run as parallel Agent pairs. Same-file pieces run one at a time.
9. Stop only when every piece's critic has picked ours, or the user stops you.
