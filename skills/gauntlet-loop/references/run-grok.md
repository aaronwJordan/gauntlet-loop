# Run on Grok Build

This harness has `spawn_subagent` and a `gauntlet` workflow. It does **not** have `/loop` or `ultracode` — those are Claude Code. Never put them in a Grok prompt.

## Primitives

- **Spawn:** `spawn_subagent`. `subagent_type` is `gauntlet-builder` or `gauntlet-critic` when those agents are installed; otherwise `general-purpose`. Prefix `description` with `[builder]` or `[critic]`.
- **Depth 1.** Only the lead may spawn. A builder cannot spawn a critic. If the prompt tells a child to fan out, the run dies.
- **Resume builder:** `spawn_subagent` with `resume_from` set to that builder's id. Never `resume_from` a critic into a critic, and never resume a builder as a critic.
- **Workflow:** use the lead-managed procedure below. The bundled legacy `gauntlet.rhai` exposes identities and does not enforce the shared evidence and completion contract; do not dispatch it for this workflow.
- **Imagine:** Grok 4.6 is text+image in, text out. Pages are code. Stills and clips go through `image_gen` / `image_edit` / `image_to_video` when those tools exist.
- **500k context is for the lead's board.** Keep critic packets small. Input past 200k tokens is billed at the long-context rate.

## Prompt last third

```
Use the selected, fetched references and recorded checks before implementation. Give fresh critics neutral immutable A/B artifacts with identities and builder history withheld. Require direct inspection of the shipped experience, evidence-backed A/B verdicts, and passing functional checks; improvement alone is not completion.

Keep looping until the critic picks ours blind — or, for a bar in a different medium than the product, until a challenger version stops beating the champion and no movable gap remains. Park any piece that loses twice on the same gap and report it. Do not stop before that. Do not name a round count.

Keep a live progress file updating as the work evolves so I can watch it.

Spawn builders and critics from this session with spawn_subagent. Depth 1 — a child must not spawn. Fetch bars live. For anything visual, open the real page and compare screenshots Grok can see.
```

## Run it here

Apply the evidence and completion contract in `loop.md` before these harness-specific steps. The lead supplies neutral immutable A/B artifacts, keeps identities private, and accepts only version-matched runtime evidence and passing checks. Follow its mode-specific completion rule for every piece and the integrated deliverable.

Use the lead-managed loop. Apply an agent budget only if the user set a ceiling.

You are the lead:

1. Write `gauntlet-progress.md` before the first builder.
2. Prepend `builder.md` / `critic.md` to child prompts. Do not pass a `persona` argument.
3. Builders: `capability_mode` omitted or `all`. Same workspace. Do not default `isolation: worktree`.
4. Critics: omit `capability_mode` (they write a verdict file). New child every time. Fail closed on missing evidence.
5. After a loss, resume that piece's builder with `resume_from`. Send only the gap.
6. Visual: browser MCP, matching viewports, images the critic can see.
7. Independent pieces may run as parallel pairs. Same-file pieces run one at a time.
8. Finish only under the shared completion contract, including the integrated checks. Honor user stopping; report unresolved work without claiming success. If a workflow budget is exhausted, say which pieces have not won. Do not declare victory.
