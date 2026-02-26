---
name: build-agents
description: Read an agents source file and create or update the corresponding agent files in .claude/agents/
---

Read the agents source file at `$ARGUMENTS` (default: `agents-one-shot.md` if no argument given).

If the project is a git repo, first run `git diff HEAD -- <source-file>`. If the output is empty, the source hasn't changed since last commit — print "source unchanged, nothing to rebuild" and stop.

For each role defined in that file:
1. Determine the agent's `name` (lowercase, hyphenated)
2. Write a one-line `description` for when this agent should be invoked
3. Estimate the appropriate `tools` based on what the role does:
   - Web research / downloads → WebSearch, WebFetch, Bash
   - File reading → Read
   - File writing/creating → Write
   - Editing existing files → Edit
   - Running shell commands → Bash
   - Coordinating / dispatching other agents → Task
4. Set `permissionMode: acceptEdits` only for agents that make frequent file edits (e.g. the one building HTML)
5. Use the role's description from the source file verbatim as the agent's system prompt

Create or overwrite the corresponding file at `.claude/agents/<name>.md`.

Do not modify the source file.

After creating all agents, list what was created/updated and summarize the tools and permissions assigned to each.
