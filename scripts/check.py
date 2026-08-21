#!/usr/bin/env python3
"""Correctness checks for the gauntlet-loop marketplace across all five harnesses.

Run from anywhere:  python3 scripts/check.py
Exits non-zero on any finding.
"""
import collections, glob, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
# The plugin's own manifest is the single source of truth for the version;
# every other manifest must agree with it.
VERSION = json.load(open("plugins/gauntlet-loop/plugin.json"))["version"]
issues = []


def bad(harness, msg):
    issues.append((harness, msg))


# --- marketplace manifests, one per harness -------------------------------
MARKETPLACES = {
    "claude":   ".claude-plugin/marketplace.json",
    "codex":    ".agents/plugins/marketplace.json",
    "copilot":  ".github/plugin/marketplace.json",
    "grok":     ".grok-plugin/marketplace.json",
    "opencode": ".opencode/catalog/index.json",
}
for harness, path in MARKETPLACES.items():
    if not os.path.exists(path):
        bad(harness, f"missing marketplace manifest {path}")
        continue
    try:
        data = json.load(open(path))
    except Exception as exc:
        bad(harness, f"{path}: invalid JSON: {exc}")
        continue
    for entry in data.get("plugins", []):
        source = entry.get("source")
        if isinstance(source, dict):
            source = source.get("path")
        if source and not os.path.exists(source):
            bad(harness, f"{path}: source {source} does not exist")
        if entry.get("version") not in (None, VERSION):
            bad(harness, f"{path}: version {entry['version']} != {VERSION}")
    # OpenCode's catalog enumerates skill files explicitly; they must resolve.
    for skill in data.get("skills", []):
        base = os.path.join(".opencode/skills", skill["name"])
        for rel in skill.get("files", []):
            if not os.path.exists(os.path.join(base, rel)):
                bad(harness, f"{path}: listed file {rel} missing under {base}")
        if skill.get("version") not in (None, VERSION):
            bad(harness, f"{path}: skill version {skill['version']} != {VERSION}")


# --- plugin manifests inside the shared payload ---------------------------
PLUGIN = "plugins/gauntlet-loop"
for name, manifest in [("grok/copilot", f"{PLUGIN}/plugin.json"),
                       ("claude", f"{PLUGIN}/.claude-plugin/plugin.json"),
                       ("codex", f"{PLUGIN}/.codex-plugin/plugin.json")]:
    try:
        data = json.load(open(manifest))
    except Exception as exc:
        bad(name, f"{manifest}: invalid JSON: {exc}")
        continue
    if data.get("version") != VERSION:
        bad(name, f"{manifest}: version {data.get('version')} != {VERSION}")
    for key in ("agents", "skills"):
        value = data.get(key)
        entries = [value] if isinstance(value, str) else (value or [])
        for rel in entries:
            if not os.path.exists(os.path.join(PLUGIN, rel.lstrip("./"))):
                bad(name, f"{manifest}: {key} entry {rel} does not exist")


# --- agent definitions ----------------------------------------------------
# The shared plugin agents/ dir intentionally holds two flavours of the same
# two agents: Claude/Grok read `<name>.md`, Copilot CLI reads `<name>.agent.md`.
# Claude globs *.md, so `.agent.md` collides with `.md` on the `name:` field
# unless .claude-plugin/plugin.json lists the two `.md` files explicitly.
CLAUDE_TOOLS = set("Read Write Edit Bash Grep Glob WebFetch WebSearch Agent "
                   "Task NotebookEdit TodoWrite".split())
COPILOT_TOOLS = set("bash view create edit glob rg fetch task".split())
OPENCODE_TOOLS = set("bash read write edit glob grep webfetch task todowrite "
                     "question skill".split())

AGENT_DIRS = {
    "repo-root":     "agents",
    "claude":        ".claude/agents",
    "grok":          ".grok/agents",
    "codex":         ".codex/agents",
    "opencode":      ".opencode/agent",
    "plugin-shared": f"{PLUGIN}/agents",
    "plugin-codex":  f"{PLUGIN}/.codex/agents",
}


def declared_name(filename, text):
    if filename.endswith(".toml"):
        match = re.search(r'^name\s*=\s*"([^"]+)"', text, re.M)
    else:
        match = re.search(r'^name:\s*(\S+)\s*$', text, re.M)
    # OpenCode derives the agent name from the filename, not frontmatter.
    return match.group(1) if match else filename.split(".")[0]


def declared_tools(filename, text):
    """Return (flavour, [tool names]) or (flavour, None) when unrestricted."""
    front = text.split("---")[1] if text.startswith("---") else ""
    inline = re.search(r'^tools:[^\S\n]*(\S[^\n]*)$', front, re.M)
    if inline:
        raw = inline.group(1).strip()
        if raw.startswith("["):
            return [t.strip().strip('"\'') for t in raw.strip("[]").split(",") if t.strip()]
        return [t.strip() for t in raw.split(",") if t.strip()]
    block = re.search(r'^tools:\s*$\n((?:\s+\S+:\s*\w+\s*\n)+)', front, re.M)
    if block:  # OpenCode's `tools:` YAML map of name -> bool
        return [m.group(1) for m in re.finditer(r'^\s+(\S+):', block.group(1), re.M)]
    return None


for harness, directory in AGENT_DIRS.items():
    if not os.path.isdir(directory):
        bad(harness, f"agent directory {directory} is missing")
        continue
    by_name = collections.defaultdict(list)
    for filename in sorted(os.listdir(directory)):
        path = os.path.join(directory, filename)
        if not os.path.isfile(path):
            continue
        text = open(path).read()
        by_name[declared_name(filename, text)].append(filename)

        tools = declared_tools(filename, text)
        if tools is None:
            continue
        if filename.endswith(".agent.md"):
            vocab, label = COPILOT_TOOLS, "Copilot"
        elif "/.opencode/" in path or path.startswith(".opencode/"):
            vocab, label = OPENCODE_TOOLS, "OpenCode"
        else:
            vocab, label = CLAUDE_TOOLS, "Claude"
        unknown = [t for t in tools if t not in vocab]
        if unknown:
            bad(harness, f"{path}: tools not in the {label} vocabulary: {unknown}")

    for name, files in by_name.items():
        if len(files) == 1:
            continue
        # A collision is only safe if every harness reading this directory
        # scopes itself to one flavour via an explicit manifest list.
        scoped = False
        if directory == f"{PLUGIN}/agents":
            listed = json.load(open(f"{PLUGIN}/.claude-plugin/plugin.json")).get("agents")
            scoped = isinstance(listed, list) and len(listed) == 2
        if not scoped:
            bad(harness, f"{directory}: name '{name}' declared by {len(files)} "
                         f"files {files} with no manifest scoping")


# --- skill references resolve at every install location -------------------
INSTALL_SKILL_DIRS = [
    ".claude/skills/gauntlet-loop", ".agents/skills/gauntlet-loop",
    ".github/skills/gauntlet-loop", ".grok/skills/gauntlet-loop",
    ".opencode/skills/gauntlet-loop", "skills/gauntlet-loop",
    f"{PLUGIN}/skills/gauntlet-loop",
]
for directory in INSTALL_SKILL_DIRS:
    skill = os.path.join(directory, "SKILL.md")
    if not os.path.exists(skill):
        bad("*", f"{skill} is missing")
        continue
    for ref in sorted(set(re.findall(r'(?:references|workflows)/[\w.-]+',
                                     open(skill).read()))):
        if not os.path.exists(os.path.join(directory, ref)):
            bad("*", f"{skill}: reference {ref} does not resolve")


# --- no harness is told to use another harness's primitives ---------------
# Matches only prescriptive use; lines that forbid a primitive are the point.
PRIMITIVES = {
    "claude":   [r'/loop\b(?!\.)', r'\bultracode\b'],
    "grok":     [r'\bspawn_subagent\b'],
    "codex":    [r'\bspawn_agent\b'],
    "copilot":  [r'/fleet\b'],
}
NEGATED = re.compile(r"\b(no|not|never|don't|do not|those are|instead of)\b", re.I)
for harness in ("claude", "grok", "codex", "copilot", "opencode"):
    skill = f"harnesses/{harness}/SKILL.md"
    if not os.path.exists(skill):
        bad(harness, f"{skill} is missing")
        continue
    for line in open(skill).read().splitlines():
        if NEGATED.search(line):
            continue
        for owner, patterns in PRIMITIVES.items():
            if owner == harness:
                continue
            for pattern in patterns:
                if re.search(pattern, line):
                    bad(harness, f"{skill}: uses {owner} primitive "
                                 f"{pattern!r}: {line.strip()[:60]}")


# --- mirrored copies stay identical ---------------------------------------
MIRRORS = [
    ("harnesses/claude/SKILL.md",   ".claude/skills/gauntlet-loop/SKILL.md"),
    ("harnesses/codex/SKILL.md",    ".agents/skills/gauntlet-loop/SKILL.md"),
    ("harnesses/copilot/SKILL.md",  ".github/skills/gauntlet-loop/SKILL.md"),
    ("harnesses/grok/SKILL.md",     ".grok/skills/gauntlet-loop/SKILL.md"),
    ("harnesses/opencode/SKILL.md", ".opencode/skills/gauntlet-loop/SKILL.md"),
    ("skills/gauntlet-loop/SKILL.md",
     f"{PLUGIN}/skills/gauntlet-loop/SKILL.md"),
    (".codex/agents/gauntlet-builder.toml",
     f"{PLUGIN}/.codex/agents/gauntlet-builder.toml"),
    (".codex/agents/gauntlet-critic.toml",
     f"{PLUGIN}/.codex/agents/gauntlet-critic.toml"),
    ("skills/gauntlet-loop/workflows/gauntlet.rhai",
     ".grok/workflows/gauntlet.rhai"),
]
for left, right in MIRRORS:
    if not (os.path.exists(left) and os.path.exists(right)):
        bad("*", f"mirror pair missing: {left} / {right}")
    elif open(left).read() != open(right).read():
        bad("*", f"out of sync: {left} != {right}")


print(f"{len(issues)} issue(s)")
for harness, message in sorted(issues):
    print(f"  [{harness}] {message}")
sys.exit(1 if issues else 0)
