# Codex compatibility notes

Checked September 4, 2026 against repository commit
`7f7cec8e37042f2ed2b83c7ac0d9faf35f5dbe33`, current official documentation,
Codex release source, and the running desktop tool schemas.
The Gauntlet Loop repository had no GitHub releases at the time of checking;
its plugin manifests identified version 1.1.0. The Codex compatibility update
is packaged as version 1.1.1.

## Release baseline

The newest stable release returned by OpenAI's release feed was
[Codex CLI 0.153.3](https://github.com/openai/codex/releases/tag/rust-v0.153.3),
published September 4. It corrects Astra's asynchronous clarification guidance
and adds Astra to Bedrock catalogs. The installed CLI used for local inspection
was 0.153.1. A desktop app's embedded runtime can differ from the shell CLI.

[0.153.1](https://github.com/openai/codex/releases/tag/rust-v0.153.1) added Astra
API configuration support without changing the default model or picker.
[0.153.2](https://github.com/openai/codex/releases/tag/rust-v0.153.2) corrected
Fast-tier display text; that does not alter this loop.
[0.153.0](https://github.com/openai/codex/releases/tag/rust-v0.153.0) added
structured asynchronous questions and optional experimental context management.
The loop uses those tools only if exposed. It does not enable experimental
settings or require a context-reset tool. The feed also listed
[0.154.0-alpha.3](https://github.com/openai/codex/releases/tag/rust-v0.154.0-alpha.3)
as a prerelease; the stable baseline is used here.

## Why the instructions changed

- [OpenAI's subagent documentation](https://developers.openai.com/codex/subagents)
  describes explicit local delegation, model/effort inheritance, overriding
  agent settings, live permission inheritance, and concurrency configuration.
  Keep Gauntlet's explicit delegation and lead-owned spawns, including on Ultra.
- [The 0.153.3 tool definitions](https://github.com/openai/codex/blob/rust-v0.153.3/codex-rs/core/src/tools/handlers/multi_agents_spec.rs)
  contain both collaboration and legacy tool families. They distinguish
  `followup_task` from `send_message`, and define legacy `resume_agent` as
  reopening a closed agent. The running desktop session exposed the
  collaboration family. Bind by schema, not by the client's name or version.
- [The collaboration spawn implementation](https://github.com/openai/codex/blob/rust-v0.153.3/codex-rs/core/src/tools/handlers/multi_agents_v2/spawn.rs)
  supports `fork_turns`. Full-history inheritance is incompatible with a
  critic who must not see the builder's account. Explicitly request fresh context
  and supply a self-contained comparison packet.
- [The collaboration wait implementation](https://github.com/openai/codex/blob/rust-v0.153.3/codex-rs/core/src/tools/handlers/multi_agents_v2/wait.rs)
  wakes on mailbox activity. A wake is not proof that a critic has completed.
- [Using GPT-6 Astra](https://developers.openai.com/api/docs/guides/latest-model)
  recommends clear delegation, explicit instruction priority, continued work on
  authorized tasks, and verification proportional to the change. This supports
  removing conflicting stop instructions and preventing unnecessary permission
  pauses. API-level async tool settings are not Codex tool arguments.
- [Codex models](https://learn.chatgpt.com/docs/models) documents the model
  controls, Astra, and Ultra. [Subagents](https://developers.openai.com/codex/subagents)
  documents `ultra` where supported and how defaults affect child settings.
  Select Astra/Ultra in the client; writing those words in a prompt does not
  configure the lead. Do not silently downgrade an explicit request.

The real reference, separate builder and critic, binary contest, champion/challenger
comparison for different media, same-gap stall rule, and absence of a default
round cap remain the loop's quality contract. Neutral A/B verdicts are a Codex
adapter for that contract; the lead maps them to the shared winner semantics.

## Verification and limits

Run `python3 scripts/check.py` from the checkout. It checks marketplace paths,
agent definitions, reference resolution, cross-harness tools, packaged reference
copies, and mirrored Codex role files. Run `git diff --check` for patch formatting.

This update was checked against documentation, release source, the live tool
schemas, TOML parsing, and repository checks. It was not an end-to-end Astra/Ultra
quality evaluation. Prompt-level critic restrictions do not enforce filesystem
isolation. Report identity leaks when artifacts cannot be fully anonymized.

## Loading an updated installation

Refresh the marketplace and install its latest plugin version:

```bash
codex plugin marketplace upgrade gauntlet-loop
codex plugin add gauntlet-loop@gauntlet-loop
```

Then start a new Codex task or CLI session. [Plugin documentation](https://developers.openai.com/codex/plugins)
says bundled skills become available in new chats or CLI sessions after
installation. Existing conversations can retain earlier instructions.
The IDE supports the repository's skill setup, but does not currently support
plugin installation; use the desktop app or CLI for the plugin.
