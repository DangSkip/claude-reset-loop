# claude-reset-loop

**Auto-restart Claude Code with a fresh context window — forever (or till you decide).**

Drop it in any project, point it at an instruction file, and Claude will work, signal done, get killed, and come back fresh. Repeat.

**Difference with [Ralph Wiggum](https://github.com/anthropics/claude-code/blob/main/plugins/ralph-wiggum/README.md)?**
Ralph = loops to finish one thing.
This = loops to keep doing things — possibly forever — with a clean slate each time.

---

## How it works

```
  ┌─────────────────────────────────────┐
  │          claude-reset-loop          │
  │            (you run this)           │
  └──────────────────┬──────────────────┘
                     │ spawns
                     ▼
  ┌─────────────────────────────────────┐
  │          Claude session             │
  │                                     │
  │  1. reads your instruction file     │
  │  2. does the work                   │
  │  3. creates please-reset-loop ──────┼──► sentinel detects it
  └─────────────────────────────────────┘
                                                    │
                     ┌──────────────────────────────┘
                     │ kills Claude + all subprocesses
                     │ deletes sentinel file
                     │ waits 3 seconds
                     │
                     └──► spawns a fresh Claude session
                               (loop can repeat forever)

  Ctrl+C to stop at any time.
```

Claude never runs out of context mid-task — each session starts clean.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/DangSkip/claude-reset-loop/main/install.sh | bash
```

Then restart your terminal (or `source ~/.zshrc` / `source ~/.bashrc`).

---

## Usage

```bash
claude-reset-loop                              # runs forever, reads CLAUDE.md
claude-reset-loop -f claude-nextaction.md      # custom instruction file
claude-reset-loop -n 5                         # stop after 5 turns
claude-reset-loop -a my-agent -f task.md       # launch a specific Claude agent
```

Your instruction file just needs to end with:

```
When you are done, create a file called please-reset-loop.
```

> **Note:** The context window is always wiped between loops — a process kill clears everything. What does survive: Claude's own persistent memory at `~/.claude/`. Claude writes to it automatically as it works, and it's always there at the start of the next session. That's the memory Claude can actually rely on across loops.

---

## Examples

Open the folder, check the code, and watch it unfold.

### [1. Global predictions](examples/1-simple-global-predictions) — dumb simple
Claude appends five predictions for the next year to a file, then resets. Each loop adds another year. Runs forever or until the end of the world.

```bash
claude-reset-loop -f examples/1-simple-global-predictions/CLAUDE.md
```

### [2. Most badass action hero](examples/2-most-badass-action-hero) — light research
Claude researches iconic action heroes and fills a CSV — net worth, total films, most famous role. Adds 3 per loop, sorted by net worth.

```bash
claude-reset-loop -f examples/2-most-badass-action-hero/CLAUDE.md
```

### [3. Michael Scott's dev team](examples/3-michael-scott-agentic-dev-team) — full multi-agent
A full multi-agent workflow: Googler hunts for intel and assets, Webmaster builds a gloriously over-the-top 90s HTML site, Reviewer makes sure it reflects well on Michael, Chief coordinates and posts tantrums. Agents talk to each other. Each role is a proper Claude agent with scoped tools.

```bash
cd examples/3-michael-scott-agentic-dev-team
claude-reset-loop -a chief -f agents-one-shot.md
```

---

## Requirements

- [Claude CLI](https://github.com/anthropics/claude-code) installed and authenticated
- macOS or Linux

> **Windows:** The Claude CLI requires WSL anyway — run this there and it works fine.

---

## License

MIT
