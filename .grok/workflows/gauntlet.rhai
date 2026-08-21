let meta = #{
    name: "gauntlet",
    description: "Fetch a real quality bar, split the work, run builder then critic on each piece until the critic picks ours",
    when_to_use: "User already picked a fetchable bar and wants Grok 4.6 to loop builder/critic pairs until the work wins a blind comparison",
    phases: [
        #{ title: "Split", detail: "smallest judgeable pieces" },
        #{ title: "Loop", detail: "builder then critic until ours wins" },
    ],
};

const MAX_PIECES = 12;

let pieces_schema = #{
    "type": "object", "required": ["pieces"],
    "properties": #{
        "pieces": #{
            "type": "array", "maxItems": 12,
            "items": #{
                "type": "object", "required": ["name"],
                "properties": #{
                    "name": #{ "type": "string" },
                    "judge_as": #{ "type": "string" },
                },
            },
        },
    },
};

let builder_schema = #{
    "type": "object", "required": ["artifact"],
    "properties": #{
        "artifact": #{ "type": "string" },
        "notes": #{ "type": "string" },
    },
};

let critic_schema = #{
    "type": "object", "required": ["winner", "gap", "evidence"],
    "properties": #{
        "winner": #{ "type": "string", "enum": ["ours", "bar"] },
        "gap": #{ "type": "string" },
        "evidence": #{ "type": "string" },
    },
};

fn trimmed(s) {
    if type_of(s) == "string" { s.trim(); s } else { "" }
}

fn text_of(v) {
    if v == () { "" } else if type_of(v) == "string" { v } else { json_encode(v) }
}

fn write_progress(goal, bar, states, note) {
    let s = "# Gauntlet progress\n\n";
    s += "- Goal: "; s += goal; s += "\n";
    s += "- Bar: "; s += bar; s += "\n\n";
    s += "| Piece | Status | Last gap |\n|---|---|---|\n";
    for p in states {
        let status = "in play";
        if p.won { status = "ours won"; }
        if p.blocked { status = "blocked"; }
        let gap = text_of(p.gap);
        s += "| "; s += text_of(p.name); s += " | "; s += status; s += " | "; s += gap; s += " |\n";
    }
    s += "\n"; s += note; s += "\n";
    write_scratch_file("progress.md", s);
}

let goal = ();
let bar = ();
let measurable = "";
let incoming = ();
if args != () {
    goal = args.goal;
    bar = args.bar;
    if args.measurable != () { measurable = text_of(args.measurable); }
    if args.pieces != () { incoming = args.pieces; }
}
if goal == () || trimmed(text_of(goal)) == "" {
    pause("verification", "Pass args.goal — the thing to build.");
}
if bar == () || trimmed(text_of(bar)) == "" {
    pause("verification", "Pass args.bar — a named, fetchable reference, not a category.");
}

let goal_s = trimmed(text_of(goal));
let bar_s = trimmed(text_of(bar));
let goal_q = json_encode(goal_s);
let bar_q = json_encode(bar_s);

let raw = [];
if incoming != () && type_of(incoming) == "array" {
    raw = incoming;
} else {
    phase("Split");
    let split_prompt = "Decompose this gauntlet-loop goal into the smallest pieces that can be improved and judged on their own.";
    split_prompt += " Goal (JSON): "; split_prompt += goal_q; split_prompt += ".";
    split_prompt += " Bar (JSON): "; split_prompt += bar_q; split_prompt += ".";
    split_prompt += " Use tools. Fetch the bar before you split so the pieces match what can actually be compared.";
    split_prompt += " Return at most 12 pieces as {name, judge_as}.";
    split_prompt += " name is a short label. judge_as is how a critic should compare that piece to the bar.";
    split_prompt += " Do not implement the work. Do not spawn subagents.";
    let split = agent(split_prompt, #{
        label: "split",
        capability_mode: "execute",
        output_schema: pieces_schema,
    });
    if split != () && split.success && split.output != () && split.output.pieces != () {
        raw = split.output.pieces;
    }
}

let states = [];
let dropped = 0;
for item in raw {
    if states.len() >= MAX_PIECES {
        dropped += 1;
    } else {
        let pname = "";
        let judge = "";
        if type_of(item) == "string" {
            pname = trimmed(item);
        } else if type_of(item) == "map" {
            pname = trimmed(text_of(item.name));
            if item.judge_as != () { judge = trimmed(text_of(item.judge_as)); }
        }
        if pname == "" {
            dropped += 1;
        } else {
            states.push(#{
                name: pname,
                judge_as: judge,
                builder_id: (),
                artifact: "",
                won: false,
                blocked: false,
                gap: "",
            });
        }
    }
}
if dropped > 0 {
    log(dropped.to_string() + " piece(s) dropped (empty name or over the " + MAX_PIECES.to_string() + " cap)");
}
if states.len() == 0 {
    complete(#{
        ok: false,
        summary: "No judgeable pieces. Pass args.pieces or re-run so split can fetch the bar.",
        path: "",
    });
}

write_progress(goal_s, bar_s, states, "Pieces locked. Starting builder/critic loop.");

phase("Loop");
let idx = 0;
while idx < states.len() {
    let piece = states[idx];
    if piece.won || piece.blocked {
        idx += 1;
    } else {
        let bgt = budget();
        if bgt.remaining < 2 {
            log("agent budget remaining under 2; stopping with unfinished pieces");
            break;
        }

        let piece_q = json_encode(piece.name);
        let judge_q = json_encode(piece.judge_as);
        let gap_q = json_encode(piece.gap);
        let art_q = json_encode(piece.artifact);

        let bprompt = "You are the builder in a gauntlet loop on grok-4.6.";
        bprompt += " Do the work. Do not spawn subagents. Do not score yourself.";
        bprompt += " Goal (JSON): "; bprompt += goal_q; bprompt += ".";
        bprompt += " Bar (JSON): "; bprompt += bar_q; bprompt += ".";
        bprompt += " Piece (JSON): "; bprompt += piece_q; bprompt += ".";
        bprompt += " How this piece is judged (JSON): "; bprompt += judge_q; bprompt += ".";
        if measurable != "" {
            bprompt += " Measurable half (JSON): "; bprompt += json_encode(measurable); bprompt += ".";
        }
        if piece.gap != "" {
            bprompt += " The critic picked the bar. Fix only this gap (JSON): "; bprompt += gap_q; bprompt += ".";
        }
        if piece.artifact != "" {
            bprompt += " Prior artifact (JSON): "; bprompt += art_q; bprompt += ".";
        }
        bprompt += " Fetch anything you need. Ship pages and apps as code.";
        bprompt += " Stills and clips use image_gen, image_edit, or image_to_video when those tools exist.";
        bprompt += " Return {artifact, notes}. artifact is a path or URL the critic can open.";

        let bopts = #{
            label: "builder:" + piece.name,
            capability_mode: "all",
            output_schema: builder_schema,
        };
        if piece.builder_id != () {
            bopts.resume_from = piece.builder_id;
        }
        let bres = agent(bprompt, bopts);

        let artifact = piece.artifact;
        let builder_id = piece.builder_id;
        if bres != () {
            if bres.agent_id != () { builder_id = bres.agent_id; }
            if bres.success && bres.output != () && bres.output.artifact != () {
                artifact = trimmed(text_of(bres.output.artifact));
            }
        }

        let cprompt = "You are a harsh critic in a gauntlet loop on grok-4.6.";
        cprompt += " You did not build this. Fetch the bar yourself and fetch our work yourself.";
        cprompt += " Memory is not the bar. A description of the bar is not the bar.";
        cprompt += " Goal (JSON): "; cprompt += goal_q; cprompt += ".";
        cprompt += " Bar (JSON): "; cprompt += bar_q; cprompt += ".";
        cprompt += " Piece (JSON): "; cprompt += piece_q; cprompt += ".";
        cprompt += " How to judge (JSON): "; cprompt += judge_q; cprompt += ".";
        cprompt += " Our artifact (JSON): "; cprompt += json_encode(artifact); cprompt += ".";
        if measurable != "" {
            cprompt += " Measurable half — run this number, do not recall it (JSON): ";
            cprompt += json_encode(measurable); cprompt += ".";
        }
        cprompt += " Open both. For visuals, use a browser MCP and look at the screenshots.";
        cprompt += " Put them next to each other with labels stripped.";
        cprompt += " Pick one. winner is ours or bar. Not a tie. Not a score.";
        cprompt += " gap is the single biggest remaining hole if the bar wins; empty if ours wins.";
        cprompt += " evidence is what you fetched (URLs, paths, screenshot paths, command output).";
        cprompt += " If you cannot fetch the bar, winner is bar and evidence says what failed.";
        cprompt += " Do not edit the product. Do not spawn subagents.";

        let cres = agent(cprompt, #{
            label: "critic:" + piece.name,
            output_schema: critic_schema,
        });

        let usable = false;
        let winner = "";
        let gap = "";
        let evidence = "";
        if cres != () && cres.success && cres.output != () {
            winner = trimmed(text_of(cres.output.winner));
            gap = trimmed(text_of(cres.output.gap));
            evidence = trimmed(text_of(cres.output.evidence));
            if (winner == "ours" || winner == "bar") && evidence != "" {
                usable = true;
            }
        }

        let won = false;
        let blocked = false;
        let note = "";
        if !usable {
            blocked = true;
            gap = "critic returned no usable verdict";
            note = "Blocked " + piece.name + " — critic verdict missing or empty evidence.";
        } else if winner == "ours" {
            won = true;
            gap = "";
            note = "Ours won on " + piece.name + ".";
        } else {
            if gap == "" { gap = "unnamed gap"; }
            note = "Bar still wins on " + piece.name + ". Next builder gets the gap.";
        }

        states[idx] = #{
            name: piece.name,
            judge_as: piece.judge_as,
            builder_id: builder_id,
            artifact: artifact,
            won: won,
            blocked: blocked,
            gap: gap,
        };
        write_progress(goal_s, bar_s, states, note);
        log(note);

        if won || blocked {
            idx += 1;
        }
    }
}

let won_n = 0;
let blocked_n = 0;
let open_n = 0;
for p in states {
    if p.won { won_n += 1; }
    else if p.blocked { blocked_n += 1; }
    else { open_n += 1; }
}

let summary = won_n.to_string() + "/" + states.len().to_string() + " pieces won blind";
if blocked_n > 0 { summary += ", " + blocked_n.to_string() + " blocked"; }
if open_n > 0 { summary += ", " + open_n.to_string() + " unfinished"; }

let report = summary + "\n";
for p in states {
    report += "- "; report += p.name; report += ": ";
    if p.won { report += "ours"; }
    else if p.blocked { report += "blocked"; }
    else { report += "unfinished"; }
    if p.gap != "" { report += " — "; report += p.gap; }
    report += "\n";
}
let path = write_scratch_file("report.md", report);
write_progress(goal_s, bar_s, states, summary);

complete(#{
    ok: won_n == states.len() && blocked_n == 0 && open_n == 0,
    summary: summary,
    path: path,
    won: won_n,
    blocked: blocked_n,
    unfinished: open_n,
});
