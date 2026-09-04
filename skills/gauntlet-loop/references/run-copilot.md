# Run on GitHub Copilot CLI

This harness has the `task` tool and `/fleet` for parallel subagents. It does **not** have `/loop` or `ultracode`. Never put those Claude Code commands in a Copilot prompt.

## Primitives

- **Spawn:** `task`. Prefix the prompt with builder or critic instructions. Custom agents `gauntlet-builder` / `gauntlet-critic` (`.agent.md`) when loaded.
- **Parallel independent pieces:** several `task` calls in one turn, or `/fleet` when the work is already split and file-disjoint. Same-file pieces stay serial — `/fleet` on overlapping files fights itself.
- **Resume builder:** resume the `task` if the tool offers it; otherwise a new `task` whose prompt includes the artifact path and the critic's gap.
- **Critic:** new `task` every time. Tools: `bash`, `view`, `create` (verdict file only), `glob`, `rg`. Do not give the critic `edit` on the product.
- File tools: `view` / `create` / `edit` / `apply_patch` / `bash`.

## Prompt last third

```
Use the selected, fetched references and recorded checks before implementation. Give fresh critics neutral immutable A/B artifacts with identities and builder history withheld. Require direct inspection of the shipped experience, evidence-backed A/B verdicts, and passing functional checks; improvement alone is not completion.

Keep looping until the critic picks ours blind — or, for a bar in a different medium than the product, until a challenger version stops beating the champion and no movable gap remains. Park any piece that loses twice on the same gap and report it. Do not stop before that. Do not name a round count.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn builders and critics with the task tool. Independent pieces may run in parallel or via /fleet. A critic is a new task every time. There is no /loop and no ultracode in this session.
```

## Run it here

Apply the evidence and completion contract in `loop.md` before these harness-specific steps. The lead supplies neutral immutable A/B artifacts, keeps identities private, and accepts only version-matched runtime evidence and passing checks. Follow its mode-specific completion rule for every piece and the integrated deliverable.

1. Write `gauntlet-progress.md` before the first builder.
2. Prepend `builder.md` / `critic.md` to each task prompt.
3. Independent pieces: parallel `task` or `/fleet`. Same-file pieces: one pair at a time.
4. Critic writes `{winner, gap, evidence}` with `create`. Fail closed on missing evidence.
5. After a loss, continue the builder (resume or new task with gap + artifact path).
6. Visual: fetch live with tools this Copilot session has (browser MCP if connected).
7. Finish only under the shared completion contract, including the integrated checks. Honor user stopping; report unresolved work without claiming success.
