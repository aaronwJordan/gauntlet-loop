# Run on Claude Code

This harness has `/loop` and `ultracode`. Use them. Do not mention Grok `spawn_subagent`, Codex `spawn_agent`, Copilot `/fleet`, or OpenCode `task`.

## Primitives

- **`/effort ultracode`** (or `claude --effort ultracode`, Claude Code v2.1.203+). Session setting: `xhigh` reasoning plus automatic dynamic-workflow orchestration. The paste-ready prompt must tell the lead to fan out with ultracode. If you run it here and ultracode is off, turn it on with `/effort ultracode` before the first spawn.
- **`/loop`**. Repeats a prompt while the session stays open (self-paced if you omit the interval). The paste-ready prompt must include `/loop on each piece until the critic picks ours blind`. That is the keep-going instruction. Do not invent a round count instead.
- **Spawn:** `Agent` (`Task` still aliases). `subagent_type` is `gauntlet-builder` or `gauntlet-critic` when those agents are loaded; otherwise `general-purpose`. Prefix `description` with `[builder]` or `[critic]`. Independent pieces: `run_in_background: true`.
- **Resume builder:** `Agent` with the saved `agentId`, or `SendMessage` to that agent. Never resume a critic — new `Agent` every time.
- **Critic writes a verdict file.** Do not deny Write. The prompt keeps the critic off the product.
- Children must not get the `Agent` tool for further fan-out. Only the lead spawns.

## Prompt last third (paste this shape)

```
/loop on each piece until the critic picks ours blind. Do not stop before that.

Keep a live progress file updating as the work evolves so I can watch it.

Fan out builders and critics with the Agent tool. Use ultracode for this session. A critic is a new Agent every time. Resume a builder; never resume a critic.
```

## Run it here

1. If ultracode is not already on, `/effort ultracode`.
2. Write `gauntlet-progress.md` at the workspace root before the first builder. Update it after every critic.
3. Read `builder.md` and `critic.md` once. Prepend the matching file to each child prompt.
4. Spawn with `Agent` as above. Same workspace. Do not default worktree isolation — pieces of one product share files.
5. Command the critic to fetch the bar and the work, then write `{winner, gap, evidence}` to the path you name. Fail closed: missing file, empty evidence, or a score instead of a pick means ours did not win.
6. After a loss, resume that piece's builder. Send only the critic's gap.
7. Visual work: browser MCP at matching viewports, screenshots for the critic.
8. Independent pieces may run as parallel Agent pairs. Same-file pieces run one at a time.
9. Stop only when every piece's critic has picked ours, or the user stops you.
