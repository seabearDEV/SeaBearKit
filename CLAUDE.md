## Bootstrap

Call `codex_context` as your first tool call to load all stored project knowledge.

## Prefer MCP tools over direct file reads

Always use codexCLI MCP tools (`codex_get`, `codex_set`, `codex_find`, etc.) to interact with `.codexcli.json`. Direct file reads bypass audit logging, alias resolution, and interpolation. The only acceptable reason to read `.codexcli.json` directly is debugging the MCP server itself.

## Before exploring code

- Check `codex_get` with key `files.<name>` before globbing/grepping for a source file.
- Check `codex_get` with key `arch.<area>` before reading code to understand a subsystem.
- Check `codex_get` with key `conventions.<topic>` before making style/pattern decisions.

## Write back

When you discover something non-obvious (a gotcha, an architectural decision, a pattern), store it with `codex_set` before the session ends. Future sessions benefit from what you learn now.

## Do not store

Things derivable from package.json, README, or the code itself. The codex is for insights that would otherwise be lost between sessions.

## First session (fresh project)

When `codex_context` returns only scaffold-level entries (no `arch.*`, no `context.*` beyond `context.initialized`), perform a deep codebase analysis before starting the user's task:

1. Read key source files to understand the architecture
2. Populate `arch.*` with architecture decisions and patterns
3. Populate `context.*` with non-obvious gotchas and edge cases
4. Enrich `files.*` with descriptions of what each key file does
5. Update `context.initialized` to "complete"

This runs once per project. Keep entries concise — insights, not code.
