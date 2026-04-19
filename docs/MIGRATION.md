# Migration from Claude Code Plugin to VS Code Copilot Plugin

## Summary

All 21 skills and 4 reference checklists from [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) were ported intact. The plugin manifest was moved and reshaped for the Copilot format, and the 3 custom agents were rewritten into Copilot's `.agent.md` schema. Five shell hooks and seven explicit slash commands were **dropped** — VS Code Copilot has no equivalent plugin-level mechanisms for those features.

## Feature Mapping Table

| Source (Claude Code) | Target (VS Code Copilot) | Status | Reason |
|---|---|---|---|
| `.claude-plugin/plugin.json` | `.github/plugin/plugin.json` | Rewritten | Different manifest schema; added `skills` / `agents` roots, removed `commands` |
| `skills/*/SKILL.md` (21) | `skills/*/SKILL.md` | Kept (frontmatter renormalised) | Same shape and filename; Copilot's `SKILL.md` spec is compatible |
| `agents/*.md` (3) | `agents/*.agent.md` | Rewritten | Copilot's `.agent.md` schema differs from Claude Code's agent file format |
| `references/*.md` (4) | `references/*.md` | Kept as-is | Pure markdown docs, no host coupling |
| `hooks/hooks.json` + 5 scripts | — | **Dropped** | No plugin-level hook layer in Copilot |
| `.claude/commands/*.md` (7) | — | **Dropped** | No plugin-level slash-command registration in Copilot |
| `skills/idea-refine/scripts/idea-refine.sh` | Skill body instructions | Rewritten inline | Script logic now described in the skill so the model performs it directly |
| `CLAUDE.md` session hook auto-load | — | Dropped (auto-injection) | `using-agent-skills` is still bundled; user invokes it manually |

## What's Kept

- **All 21 skills.** Content and structure unchanged. Frontmatter gained `user-invocable: true` so skills appear as slash commands; the `SKILL.md` body text survives intact.
- **All 4 reference checklists** (`accessibility-checklist`, `performance-checklist`, `security-checklist`, `testing-patterns`).
- **Licence, author attribution, and repository links.**

## What's Rewritten

- **Plugin manifest.** Moved from `.claude-plugin/plugin.json` to `.github/plugin/plugin.json`. Removed the `commands` field (no equivalent) and added `skills` / `agents` roots so Copilot can discover each component.
- **Agent persona files.** The 3 agents (`code-reviewer`, `security-auditor`, `test-engineer`) were converted from Claude Code's agent schema to Copilot's `.agent.md` format. Body prompts are preserved verbatim from the source. The only frontmatter addition is a `model:` priority list; `tools:` is deliberately omitted so the agents inherit Copilot's default tool set, matching the source (which had no tool restriction).
- **`idea-refine` bootstrap.** The source shipped `scripts/idea-refine.sh`, which created `docs/ideas/` and emitted a JSON status payload to stdout (no file was written). In Copilot there is no guaranteed way for a skill to run a shell script at load time the way Claude Code executed skill scripts. The directory-creation logic is now described as inline instructions in the skill body — the model creates `docs/ideas/` and the per-idea file directly. The tool-internal JSON status payload had no user-visible purpose and was dropped without replacement.
- **Meta-skill injection.** In Claude Code, `session-start.sh` injected `using-agent-skills` into every session automatically. In the Copilot port, `using-agent-skills` is still bundled as a regular skill — but it is **not auto-loaded**. Users invoke `/agent-skills:using-agent-skills` when they want the discovery flowchart.

## What's Dropped — And Why

### 1. `SessionStart` hook (`session-start.sh`)

**What it did.** Read `skills/using-agent-skills/SKILL.md` and emitted a JSON `{priority: "IMPORTANT", message: ...}` payload so Claude Code prepended the meta-skill to every session's system context.

**Why dropped.** Copilot's plugin format has no `SessionStart` hook. The only hook event Copilot documents is `PostToolUse`, which is **Preview**, **agent-scoped** (declared in one `.agent.md`'s frontmatter), and cannot be registered at the plugin level to fire for every session.

**Workaround.** Invoke `/agent-skills:using-agent-skills` at session start, or add a reminder in `.github/copilot-instructions.md`.

### 2. `simplify-ignore` tool-interceptor hooks (`simplify-ignore.sh`, `simplify-ignore-test.sh`, `SIMPLIFY-IGNORE.md`)

**What they did.** Three hook points wrapped `Read` / `Edit` / `Write`: `PreToolUse Read` replaced `/* simplify-ignore-start */ … /* simplify-ignore-end */` blocks with `BLOCK_<hash>` placeholders in-place, backing the real file up to `.claude/.simplify-ignore-cache/`. `PostToolUse Edit|Write` expanded placeholders, merged the model's changes, and re-filtered. `Stop` restored originals. The script content-hashes each block, handles C / Python / HTML comment syntaxes, does crash recovery via a lockdir, and ships a 10-case test harness.

**Why dropped.** Synchronous file-content mutation wedged into the tool-call pipeline. Copilot has no `PreToolUse`, no `Stop`, and no way for a plugin to intercept `Read` / `Edit` / `Write`. `PostToolUse` alone cannot implement this protocol — the read side is the entire point.

**Workaround.** None that preserves the protocol. Users who need to shield blocks from a refactor should (a) add a standing instruction to the prompt ("do not modify blocks annotated `perf-critical`"), or (b) move the block to a file excluded from scope.

### 3. `sdd-cache` WebFetch cache hooks (`sdd-cache-pre.sh`, `sdd-cache-post.sh`, `SDD-CACHE.md`)

**What they did.** A URL-keyed HTTP cache around `WebFetch`. `PreToolUse WebFetch` sent a `HEAD` with `If-None-Match` / `If-Modified-Since`; on `304`, exited with code 2 and streamed the cached body on stderr so Claude Code returned it in lieu of re-fetching. `PostToolUse WebFetch` captured the body, issued a `HEAD` to record validators, and stored `{url, prompt, etag, last_modified, content, fetched_at}` as JSON. Entries without `ETag` / `Last-Modified` were never cached.

**Why dropped.** Two blockers: (1) no `PreToolUse` in Copilot — no way to short-circuit the fetch. (2) The cache-hit protocol relied on Claude Code forwarding exit-code-2 stderr as a tool error. Copilot has no documented equivalent.

**Workaround.** Run Copilot behind an HTTP caching proxy (e.g. `mitmproxy`, local Squid) configured to honour `ETag` / `Last-Modified`. Same "revalidate, don't memorise" property at a lower layer. `source-driven-development` still works — it just re-fetches every session.

### 4. Seven explicit slash commands (`/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship`, `/code-simplify`)

**What they did.** Each `.md` file in `.claude/commands/` registered a namespace-free slash command that (a) invoked a named skill and (b) added a short orchestration prologue — e.g. `/build` invoked `incremental-implementation` alongside `test-driven-development`, and `/test` included the Prove-It pattern for bug fixes.

**Why dropped.** Copilot has no plugin-level slash-command registration. The closest analog is a skill with `user-invocable: true`, which appears as `/agent-skills:{skill-name}` — so the commands' *functionality* is reachable, but the short aliases and the multi-skill orchestration prologues are not.

**Workaround.** Invoke the underlying skill directly:

| Dropped command | Invoke instead |
|---|---|
| `/spec` | `/agent-skills:spec-driven-development` |
| `/plan` | `/agent-skills:planning-and-task-breakdown` |
| `/build` | `/agent-skills:incremental-implementation` (add "use TDD" in the prompt) |
| `/test` | `/agent-skills:test-driven-development` |
| `/review` | `/agent-skills:code-review-and-quality` or the `code-reviewer` custom agent |
| `/ship` | `/agent-skills:shipping-and-launch` |
| `/code-simplify` | `/agent-skills:code-simplification` |

### 5. `idea-refine.sh` init script

**What it did.** Created `docs/ideas/` and wrote a JSON status payload.

**Why dropped.** No skill-attached script-execution hook in Copilot.

**Workaround.** None required — the skill now instructs the model to perform these steps directly.

## Installation and Usage in VS Code

See [`README.md`](../README.md) for install instructions. Short version: add the repo path to `chat.pluginLocations` in VS Code settings and reload. Skills appear as `/agent-skills:{skill-name}`; the 3 agents appear in the agents dropdown.

## Open Questions

- **`${CLAUDE_PLUGIN_ROOT}` / `${CLAUDE_PROJECT_DIR}` replacement.** Source scripts referenced these for plugin-install path and project root. Copilot's plugin format has **no documented equivalent env var injected into plugin-launched processes**. Since all five hook scripts that used them are dropped, this is not load-bearing for this port — but a future user writing a new Copilot-format hook will have to hard-code paths or rely on the agent's `cwd`, which does not match `CLAUDE_PROJECT_DIR` semantics.
- **`PostToolUse` in `.agent.md` frontmatter.** Preview, agent-scoped, cannot be bundled at the plugin root. None of the source hooks would work under that constraint. May become viable for per-agent post-processing if it graduates.
- **Session-start injection.** No Copilot analog to `SessionStart`. Revisit the meta-skill auto-load if one ships.
