# Run on OpenCode

This harness has `task`, `todowrite`, `question`, `skill`, `bash`, `read`, `write`, `edit`. It does **not** have `/loop` or `ultracode`. Never put those Claude Code commands in an OpenCode prompt.

## Primitives

- **Spawn:** `task`. Prefix the prompt with builder or critic instructions. Custom agents in `.opencode/agent/` named `gauntlet-builder` / `gauntlet-critic` when loaded.
- **`task` is typically one-shot.** For a builder fix round, spawn a new `task` and include the artifact path plus the critic's gap so the worker has working memory.
- **Critic:** new `task` every time. Give it `read` / `bash` / `write` (verdict file only), not product `edit`.
- **Bar pick:** `question` if you need the user to choose among candidate bars.
- **Progress todos:** `todowrite` for pieces (optional). The live file is still `gauntlet-progress.md`.

## Prompt last third

```
Keep looping until the critic picks ours blind — or, for a bar in a different medium than the product, until a challenger version stops beating the champion and no movable gap remains. Park any piece that loses twice on the same gap and report it. Do not stop before that. Do not name a round count.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn builders and critics with the task tool. A critic is a new task every time. After a loss, spawn the builder again with only the gap and the artifact path. There is no /loop and no ultracode in this session.
```

## Run it here

1. Write `gauntlet-progress.md` before the first builder.
2. Prepend `builder.md` / `critic.md` to each task prompt.
3. Independent pieces: multiple `task` calls in one turn. Same-file pieces: one pair at a time.
4. Critic writes `{winner, gap, evidence}` with `write`. Fail closed on missing evidence.
5. After a loss, new builder `task` with gap + artifact path.
6. Visual: `webfetch` / browser MCP if connected. Fetch live.
7. Stop only when every piece's critic has picked ours, or the user stops you.
