# codexCLI store — do not hand-edit

This directory is managed by codexCLI. Each `*.json` file is a single
store entry written through the CLI or MCP tools.

**Internal sidecar files** (prefix `_`, safe to ignore):

- `_README.md` — this file
- `_aliases.json` — short-name aliases for entries
- `_confirm.json` — entries that require confirmation before running
- `_epoch.json` — internal commit counter for crash safety; the integer
  climbs by 2 with every save and is used by readers to detect a writer
  mid-commit. You should never need to touch it.

**Edit via one of:**

- `ccli set <key> <value>` (and the rest of the CLI)
- The codexCLI MCP tools (`codex_set`, `codex_get`, etc.)
- A future UI

Direct edits to these files desync per-entry metadata (created/updated
timestamps, future verified/agent fields) and silently break staleness
signals. The wrapper format `{ value, meta }` assumes only the official
tools touch it.

If you need to bulk-import or restructure, do it through the CLI.
