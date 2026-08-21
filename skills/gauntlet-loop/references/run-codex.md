# Run on Codex CLI

This harness has `spawn_agent`, `resume_agent`, `wait_agent`, and `close_agent`. It does **not** have `/loop` or `ultracode`. Never put those Claude Code commands in a Codex prompt.

## Primitives

- **Spawn:** `spawn_agent`. Prefer custom agents `gauntlet-builder` / `gauntlet-critic` when listed; otherwise the default worker. Prefix the prompt with the builder or critic instructions from `builder.md` / `critic.md`.
- **Parallel independent pieces:** multiple `spawn_agent` calls, then `wait_agent` for each.
- **Resume builder:** `resume_agent`. Never resume a critic — spawn a fresh critic every time.
- **Wait:** `wait_agent` after background or parallel spawns.
- Subagents inherit the parent sandbox. Keep the critic off product edits through the prompt (workspace-write is required if it must write a verdict file).

## Prompt last third

```
Keep looping until the critic picks ours blind. Do not stop before that. Do not name a round count.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn builders and critics with spawn_agent. Wait with wait_agent. Resume a builder with resume_agent. A critic is a new spawn every time. There is no /loop and no ultracode in this session.
```

## Run it here

1. Write `gauntlet-progress.md` before the first builder.
2. Prepend `builder.md` / `critic.md` to each spawn prompt.
3. Independent pieces: parallel `spawn_agent` + `wait_agent`. Same-file pieces: one pair at a time.
4. Critic writes `{winner, gap, evidence}` to a named path. Fail closed on missing evidence.
5. After a loss, `resume_agent` on that piece's builder with only the gap.
6. Visual: browser / computer-use tools this Codex session actually has. Fetch live.
7. Stop only when every piece's critic has picked ours, or the user stops you.
