# Run on Codex

Use this for the Codex desktop app, CLI, and IDE. Bind to the tools and argument schemas exposed in the running session. No `/loop` or `ultracode`.

## Bind the tools

| Operation | Collaboration tools, when exposed | Legacy tools, when exposed |
|---|---|---|
| Spawn | `spawn_agent(task_name, message, fork_turns)` | `spawn_agent(message, fork_context)` |
| Fresh critic context | `fork_turns="none"` | `fork_context=false` |
| Give an idle builder its next gap | `followup_task(target, message)` | `send_input(id, message)` |
| Message a running builder | `send_message(target, message)` | `send_input(id, message)` |
| Wait | `wait_agent(timeout_ms)` wakes on mailbox activity; read delivered messages and final results | `wait_agent(ids, timeout_ms)` returns agent status/results |
| Inspect or interrupt | `list_agents`, `interrupt_agent`, if exposed | `close_agent`, if exposed |

These are schema sketches, not interchangeable signatures. Use the actual namespace. Call collaboration tools directly when the session requires it; do not assume they are callable inside a JavaScript execution tool. `send_message` does not wake an idle builder. Legacy `resume_agent(id)` only reopens a closed agent; send the next task with `send_input` afterward. Never resume or reuse a critic.

Use custom `gauntlet-builder` / `gauntlet-critic` roles only if listed and the spawn schema accepts role selection. Otherwise supply the role instructions in the message. If independent agents or fresh context are unavailable, report that prerequisite; do not have the builder certify itself.

## Astra with Ultra

Select `gpt-6-astra` and `ultra` using the client's model controls before starting. For a CLI that supports them:

```bash
codex -m gpt-6-astra -c 'model_reasoning_effort="ultra"'
```

The prompt cannot change its own model or effort. Check the running client's available model/effort combinations. If the requested combination is unavailable, report it without silently substituting another model or effort.

Keep the selected model and effort for builders and critics. Omit overrides when inheritance resolves to that pair; check `[agents]` defaults and custom role settings, which can override inheritance. When explicitly selecting Astra for a fresh child, pass both `model="gpt-6-astra"` and `reasoning_effort="ultra"` only if the spawn schema supports them. Full-history forks may disallow these overrides. The shipped roles omit model settings so other Codex users keep their own choices.

This workflow explicitly authorizes delegation. The lead owns all spawns; children do not spawn children. Ultra does not change that division of responsibility. Delegate bounded pieces with useful independent work; obey the live concurrency limit and reserve capacity for judging completed pieces. Serialize writes to overlapping files or shared browser state. Give each critic an immutable candidate snapshot and a unique verdict path.

## Prompt last third

```text
Use the session's actual Codex collaboration tools. Spawn builders and fresh-context critics; send builder follow-ups with the supported task-input tool. Keep the selected model and effort. Only the lead spawns agents.

Continue until each piece wins blind, or a cross-medium challenger stops beating its champion with no movable gap. Park two consecutive losses on the same gap and report the evidence while continuing independent pieces. Keep gauntlet-progress.md current. Never count a blocked comparison as a win.
```

## Run it here

1. Read `loop.md`, `builder.md`, and `critic.md`. Follow the user's requested scope. An explicit request to run already authorizes running; an explicit request to edit this skill authorizes editing, without first generating a goal prompt or asking for a bar.
2. Record the goal, fetched reference, per-piece comparison mode, acceptance checks, and actual model/tool choices in `gauntlet-progress.md`. The lead alone updates it. Preserve artifact versions, agent IDs, verdict paths, consecutive same-gap losses, parked pieces, and the next action so work can resume after compaction.
3. Spawn each builder with the builder instructions, assigned files, constraints, reference, required checks, and output contract. After completion, verify the actual artifact and relevant checks. A successful command or a builder's self-report is not a critic verdict.
4. Prepare neutral A/B artifacts with comparable presentation and record their identity mapping outside the critic's packet. For the classic contest, A/B are ours and the reference. For champion-challenger, A/B are the saved champion and the attempt, with the reference supplied separately. Vary the order. Keep builder explanations, previous verdicts, progress files, and identity mapping out of critic context. Tell the critic not to read them. If visible branding or required access reveals identities, disclose the limitation rather than claim full blindness.
5. Spawn a new critic with explicit fresh context. Include the critic role instructions, goal, constraints, mode, A/B paths or URLs, comparison criteria, and a unique verdict destination. For Codex, override the shared critic's identity-labelled output: return `{winner, gap, evidence}` with `winner` equal to `"A"` or `"B"`, or `null` if comparison is blocked. The lead alone maps that choice to ours/bar or champion/challenger. No movable gap is `gap: null`, with evidence explaining why. Require direct inspection of both artifacts and relevant check output. Missing, stale, inaccessible, or empty evidence invalidates the verdict. Prompt restrictions are not a filesystem sandbox; children inherit runtime permissions. If the critic cannot write, it returns the verdict and the lead saves it.
6. Wait only when dependent work needs a result. A mailbox wake, timeout, or successful spawn is not completion. Read final results and verdicts before accepting a piece. Do useful independent work while agents run; follow session limits for waits and progress updates.
7. Map the verdict and send the biggest gap back to the builder using the bound follow-up tool. Preserve its assignment and constraints; do not pass praise or a substitute review. If that builder is unavailable, spawn a replacement with the artifact and required context. Compare again with a new critic. Promote a winning challenger and retain the prior version for comparison.
8. Classic pieces finish only when ours wins with valid evidence and required checks pass. Cross-medium pieces converge only when the challenger stops beating the champion and the critic finds no movable gap. Two consecutive losses on the same named gap park that piece under the shared stall rule; parking is not success. Continue independent pieces and request user direction for parked work with evidence. A fetch failure or tool error is a blocked comparison, not a quality loss; repair it or report the blocker.
9. Honor user steering, cancellation, and explicit budgets. Use an available asynchronous question tool for missing text input while continuing independent work; do not treat silence as an answer. Ask for required files through normal chat. Save state on interruption or exhausted resources without marking success. Never invent an infinite background loop, automation, goal, or token budget. Finish only with each piece's evidence-backed status, remaining blockers, and deliverable locations.

See [Codex compatibility notes](codex-compatibility.md) for the checked release and sources.
