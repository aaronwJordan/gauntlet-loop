# Shared loop (all harnesses)

The user gives a goal. You give back ONE short prompt they can paste into a fresh session of the **same harness**. You are not doing the work until they say to run it.

## Flow

1. **Read the goal.** One line restatement in your head, not on screen.
2. **Set the bar before implementation.** Inspect a user-supplied reference and use it if accessible and comparable; do not ask for the same choice again. Otherwise fetch **2 or 3 candidate bars**, state which concrete aspect each benchmarks, and wait for their pick before writing the prompt or building. If the user delegates selection, choose and record the rationale. A reference sets quality, not permission to copy its design or replace the user's concept. Read-only discovery can continue while selection is pending.
3. **Write the prompt.** One block, paste-ready, no preamble, no headings inside it, no narration after it. Use the **current harness** run file for the last third (spawn, loop, tools).
4. **Offer to run it.** One flat line under the prompt: "I can run this here." Not a question.

**Stall rule.** A piece whose challenger loses twice in a row on the same named gap does not get a third identical round. It parks, and the lead escalates to the user with the critic's evidence and the builder's account of why the gap will not move. Parking is escalation, not an exit — the loop never self-certifies. This is different from a round cap: a piece that keeps improving keeps looping.

**Cheapest decisive comparison first.** Open every piece at the fidelity it actually ships at — the live viewport, the play-scale pixel height, the published length. A piece that wins there is done; magnified or long-form rounds are only for pieces that fail cheap. Expensive scrutiny is a response to failure, not a default.

## The bar is the whole trick

A bar has to pass three tests:

- **Named.** A specific thing, not a category. "Stripe's pricing page" works. "Award-winning SaaS sites" does not.
- **Fetchable by this session.** The critic can actually get it with tools this session has. If the session cannot obtain the reference, it will hallucinate the comparison. Do not offer a bar this session cannot fetch.
- **Comparable.** Both can sit side by side and a judge can pick one. If you cannot imagine the A/B, it is not a bar.

Knowledge cutoff is not a substitute for a fetch. "Current", "latest", and "the live page" must be retrieved now.

| Goal | Bar that works |
|---|---|
| Website, app, UI | The live site of a specific best-in-class product, screenshotted at the same viewport |
| Game, 3D, visual | Real footage or screenshots from a named shipped title |
| Writing | A specific published piece by a named author or publication, same length and format |
| Code, tooling | A named repo's implementation, plus its benchmark or test suite as the measurable half |
| Research, analysis | A named analyst report or a paper's methods section, judged on rigour and coverage |
| Deck, doc, deliverable | A real artifact from a firm known for it, same page count |
| Image or video asset | A named existing image, frame, or clip the critic can open |

When you propose bars, prefer the hardest one the agent can genuinely reach. A bar that is too easy makes the loop exit on round one.

If the goal has a measurable half (load time, token cost, benchmark score, word count, pass rate), name it alongside the reference.

If a visual bar needs a browser and none is connected, say so and offer a different fetchable bar. Do not pretend a text description of a page is a screenshot.

**Match the contest to the medium.** A bar in the same medium as the product (text vs text, code vs code, a shipped UI vs your UI) runs the classic contest: ours vs bar, critic picks the winner. A bar in a different medium than the product (concept art vs a 3D render, a photo vs CG, a napkin sketch vs a page) can never lose an identity contest — a render never becomes a painting. Those pieces run **champion-challenger**: the critic gets the bar plus two unlabeled versions of ours — the reigning champion and the new attempt — and picks which sits closer to the bar. Every round is winnable, and the exit is real: the piece converges when the challenger stops beating the champion and no movable gap remains.

**A split piece may name its own referent.** When the work is decomposed, the lead assigns each piece the referent that actually shows it — a piece judged against a bar that cannot see it converges on nothing.

## Evidence and completion contract

These requirements apply to every harness and comparison mode, including direct requests to run. Harness-specific tool instructions do not replace them.

**Lock the comparison before building.** Record each piece's reference, fetched evidence, comparison mode, judged aspects, and functional acceptance checks. The reference must actually demonstrate those aspects. A visual reference cannot establish networking reliability or speech-recognition accuracy. Keep the agreed bar stable across rounds; do not lower it or switch modes to obtain a win. If it becomes inaccessible, repair access or report the comparison blocked. User-approved scope changes may revise the bar explicitly.

**Make blind comparison operational.** The lead prepares immutable A/B snapshots with comparable presentation and keeps their identity mapping outside the critic packet. Vary A/B order between rounds. Start a fresh critic without inherited history; exclude builder explanations, previous verdicts, progress files, and mappings. Supply only the goal, constraints, mode, comparison criteria, artifacts, required check evidence, and a separate reference for champion-challenger mode. The critic directly inspects both artifacts and returns `{winner, gap, evidence}`, with winner `A` or `B`, or `null` when blocked. The lead alone maps the result back to identities. If branding or necessary access reveals an identity, disclose the limitation instead of claiming full blindness. Prompt exclusions are not filesystem isolation.

**Judge the shipped experience.** Inspect the actual deliverable at its intended size and in its intended environment. For interactive products, exercise complete user flows in the runnable build, including relevant audio, input, timing, and interactions. Multiplayer claims require separate clients completing a shared session. Screenshots support visual findings; they do not prove interaction or audio works. Recorded checks must identify the candidate version, environment, exercised behavior, and observed result. Missing hardware, tools, or access leaves that check blocked, not passed. Require acceptance checks on the integrated final artifact as well as individual pieces; later changes invalidate affected evidence.

**Keep convergence conditional.** In classic mode, finish a piece only after a valid win against its agreed external reference and passing required checks. In cross-medium mode, a winning challenger becomes champion; improvement alone is not completion. Finish only when a challenger stops beating the champion and a fresh critic finds no remaining movable gap against the external reference, with required checks passing. `gap: null` requires an explanation tied to inspected evidence. Two consecutive losses on the same gap park the piece for escalation; parking, blocked checks, exhausted resources, and missing evidence never count as success. Continue independent work and report unresolved pieces. Whole-task completion requires all pieces and the integrated deliverable to pass.

## Length and voice

Short. Around 120 to 180 words. If the prompt needs a heading to stay readable, it is too long.

Plain sentences. No bullet lists inside the prompt.

## Fill-in rules

- Bake the bar in as a concrete, fetchable thing. URL, product name, repo, title.
- Add a budget or cost ceiling line **only if the user named one**. No default cap. A harness agent-budget is a stop, not "good enough after N rounds".
- Add tool names only if the goal needs them, and only tools this harness actually has.
- Preserve the evidence and completion contract in generated prompts: selected references before implementation, fresh blind A/B critics, direct inspection of the shipped experience, and checks plus the mode-specific exit. If the installed skill is available to the destination session, explicitly direct it to read the shared loop and matching run file; otherwise include these requirements in the prompt itself.
- Everything else stays out. No architecture, no file layout, no decomposition, no round count, no stack choice unless the user demanded it.

## What breaks a gauntlet loop

- **A vague bar.** The critic invents a comparison and approves everything.
- **The builder judging its own work.** The critic must be a separate agent with fresh context.
- **A soft critic.** Binary pick, not a score out of 10.
- **Named exit after N rounds.** The exit is winning, or the user stopping.
- **Mixing harness primitives.** `/loop` and `ultracode` are Claude Code only. Do not put them in a Grok, Codex, Copilot, or OpenCode prompt.
- **Over-specifying.**
- **A cross-medium identity contest.** Looping until a render is mistaken for a painting burns tokens forever. Champion-challenger, not is-it-the-painting.
- **A third round on an unmoved gap.** That is the stall rule's job.
