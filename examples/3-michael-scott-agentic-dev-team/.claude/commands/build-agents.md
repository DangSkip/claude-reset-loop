Read the agents source file at `$ARGUMENTS` (default: `examples/3-michael-scott-agentic-dev-team/agents-one-shot.md` if no argument given).

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
6. Append `\nWhen you are done, create a file called please-reset-loop.` to each system prompt

Create or overwrite the corresponding file at `.claude/agents/<name>.md`.

Do not modify the source file.

After creating all agents, list what was created/updated and summarize the tools and permissions assigned to each.
