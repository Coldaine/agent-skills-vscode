# Agent Skills for VS Code Copilot

**Production-grade engineering skills for AI coding agents, packaged as a VS Code Copilot agent plugin.**

This is a VS Code Copilot-format conversion of [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (MIT-licensed, © 2025 Addy Osmani). The source repo ships a Claude Code plugin; this repo ships the equivalent as a VS Code Copilot agent plugin per the [official plugin format](https://code.visualstudio.com/docs/copilot/customization/agent-plugins).

The 21 skills encode the workflows, quality gates, and best practices senior engineers use across the full software development lifecycle:

```
  DEFINE          PLAN           BUILD          VERIFY         REVIEW          SHIP
 ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐
 │ Idea │ ───▶ │ Spec │ ───▶ │ Code │ ───▶ │ Test │ ───▶ │  QA  │ ───▶ │  Go  │
 │Refine│      │  PRD │      │ Impl │      │Debug │      │ Gate │      │ Live │
 └──────┘      └──────┘      └──────┘      └──────┘      └──────┘      └──────┘
```

## Install

**Option A — from GitHub** (once published):

```
Chat: Install Plugin From Source
# paste the repo URL
```

**Option B — local development**:

Clone this repo and add its path to VS Code settings:

```json
// settings.json
"chat.pluginLocations": {
  "/absolute/path/to/agent-plugins-vscode": true
},
"chat.plugins.enabled": true
```

Reload the window. The 21 skills appear in chat as `/agent-skills:{skill-name}` and auto-load when the model judges them relevant. The 3 agents appear in the agents dropdown.

## What's in this plugin

| Component | Count | Location |
|---|---|---|
| Skills | 21 | `skills/` |
| Custom agents | 3 | `agents/` |
| Reference checklists | 4 | `references/` |

### Skills, by lifecycle phase

- **Define** (2): `idea-refine`, `spec-driven-development`
- **Plan** (1): `planning-and-task-breakdown`
- **Build** (6): `incremental-implementation`, `test-driven-development`, `context-engineering`, `source-driven-development`, `frontend-ui-engineering`, `api-and-interface-design`
- **Verify** (2): `browser-testing-with-devtools`, `debugging-and-error-recovery`
- **Review** (4): `code-review-and-quality`, `code-simplification`, `security-and-hardening`, `performance-optimization`
- **Ship** (5): `git-workflow-and-versioning`, `ci-cd-and-automation`, `deprecation-and-migration`, `documentation-and-adrs`, `shipping-and-launch`
- **Meta** (1): `using-agent-skills`

### Custom agents

- `code-reviewer` — five-axis pre-merge review
- `security-auditor` — OWASP Top 10 + secrets + boundaries
- `test-engineer` — TDD and test-pyramid enforcement

## Differences from the upstream Claude Code plugin

This conversion is faithful where VS Code supports the feature, and explicit where it doesn't. See [`docs/MIGRATION.md`](docs/MIGRATION.md) for the full list. Summary:

- **Manifest moved** from `.claude-plugin/plugin.json` to `.github/plugin/plugin.json` (Copilot format)
- **Agent personas** rewritten from Claude persona `.md` to VS Code `.agent.md` schema (tools, model preference)
- **Hooks dropped**: the 5 shell hook scripts (`SessionStart`, `simplify-ignore` tool interceptors, `sdd-cache` WebFetch cache) have no Copilot equivalent — VS Code plugins can't intercept tool calls at that layer. The meta-skill `using-agent-skills` (which was injected via `SessionStart`) is now a regular skill users can invoke explicitly.
- **`idea-refine` script dropped**: the bash init script that created `docs/ideas/` is replaced by inline instructions in the SKILL.md body
- **Slash commands** (`/spec`, `/plan`, `/build`, `/test`, `/review`, `/ship`, `/code-simplify`): not separately registered. Instead, the corresponding skills are marked `user-invocable: true` and appear in chat as `/agent-skills:{skill-name}`.

## Credit

- Original skills and workflow design: **Addy Osmani** ([addyosmani/agent-skills](https://github.com/addyosmani/agent-skills), MIT License)
- VS Code plugin format: Microsoft / GitHub Copilot docs
- Source conventions cited in skills: SWE at Google, Google engineering practices

## License

MIT — see [LICENSE](LICENSE). Copyright © 2025 Addy Osmani (original work). All conversion changes fall under the same MIT license.
