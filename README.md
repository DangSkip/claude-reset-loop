# claude-reset-loop

**Auto-restart Claude with a fresh context window — forever.**

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
curl -fsSL https://raw.githubusercontent.com/dangerouslyskippermissions/claude-reset-loop/main/install.sh | bash
```

Then restart your terminal (or `source ~/.zshrc` / `source ~/.bashrc`).

---

## Usage

```bash
claude-reset-loop                              # runs forever, reads CLAUDE.md
claude-reset-loop -f examples/story/CLAUDE.md # custom instruction file
claude-reset-loop -n 5                         # stop after 5 turns
claude-reset-loop -a my-agent -f task.md       # launch a specific Claude agent
claude-reset-loop -n 10 --persist              # keep session history between loops
```

Your instruction file just needs to end with:

```
When you are done, create a file called please-reset-loop.
```

---

## Examples

### story
Claude writes an ongoing story, one paragraph per loop — each session picks up where the last left off via the file on disk.

```bash
claude-reset-loop -f examples/story/CLAUDE.md
```

### action-heroes
Claude researches badass action hero actors and fills a CSV — net worth, total films, most famous role. Adds 3 actors per loop until the list is complete.

```bash
claude-reset-loop -f examples/action-heroes/CLAUDE.md
```

### dev-loop
A full agentic workflow: Planner → Coder → Reviewer, rotating each session. A `memory.md` file persists project state across the clean-slate loops.

```bash
claude-reset-loop -f examples/dev-loop/CLAUDE.md
```

---

## Requirements

- [`claude` CLI](https://github.com/anthropics/claude-code) installed and authenticated
- macOS or Linux

> **Windows:** The Claude CLI requires WSL anyway — run this there and it works fine.

---

## License

MIT
