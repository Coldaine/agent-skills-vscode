---
name: git-workflow-and-versioning
description: Manages Git workflows, branching strategies, commit practices, and versioning. Use when establishing team Git conventions, planning releases, handling merge conflicts, or setting up automated versioning pipelines.
user-invocable: true
---

# Git Workflow and Versioning

## Overview

Git is more than version control — it's the coordination mechanism for teams building software together. How a team uses Git determines how smoothly they can collaborate, release, and debug. Good Git practices make code history readable, collaboration conflict-free, and releases predictable.

Versioning is the companion discipline: how software communicates compatibility guarantees to consumers and how releases are managed over time.

## Branching Strategies

### Trunk-Based Development (Recommended)

All developers commit to `main` (trunk) frequently — at least once per day. Feature flags gate in-progress work. Release branches, if used, are short-lived and created from trunk at release time.

**Advantages:**
- Eliminates long-lived branches and the merge pain they cause
- Forces continuous integration — divergence is caught immediately
- Simplifies the branching model dramatically
- Required for true continuous delivery

**Requirements:**
- Feature flag infrastructure
- Robust CI that runs on every commit
- Developer discipline to keep commits small and releasable

**Short-lived feature branches** (1-3 days max) are acceptable in trunk-based development. They're a coordination mechanism, not a long-running divergence.

### GitHub Flow

Simple model: `main` is always deployable. Features and fixes go in short-lived branches, merged via PR.

```
main ←── feature/add-login ─── (PR + review) ──→ merge
main ←── fix/null-pointer ───── (PR + review) ──→ merge
```

**Rules:**
1. Anything in `main` is deployable
2. Create a branch from `main` for new work
3. Commit to the branch regularly and push
4. Open a PR when ready for review (or earlier for feedback)
5. Merge only after approval and CI green
6. Deploy immediately after merge to main

Good fit for: teams deploying frequently, smaller teams, web applications.

### Git Flow

More complex model with multiple long-lived branches: `main` (always production-ready), `develop` (integration), feature branches, release branches, and hotfix branches.

```
main ────────────────────── v1.0 ─────────── v1.1
         ↑                          ↑
develop ─┴── feature/a ── feature/b ┴── release/1.1
```

Recommended primarily for: software with explicit versioned releases, multiple active release versions, strict release coordination (packaged software, mobile apps).

**Avoid Git Flow for web applications** — it adds process overhead without benefit when you deploy continuously.

### Choosing a Strategy

| Factor | Trunk-Based | GitHub Flow | Git Flow |
|--------|-------------|-------------|----------|
| Deploy frequency | Continuous | Frequent | Scheduled releases |
| Team size | Any | Small-medium | Any |
| Parallel releases | No | No | Yes |
| Complexity | Low | Low | High |

## Commit Practices

### Write Good Commit Messages

The commit message is documentation. Future readers (including yourself) will use it to understand what changed and why.

**Format:**
```
<type>(<scope>): <summary>

<body — explain why, not what>

<footer — breaking changes, issue references>
```

**Subject line rules:**
- 50 characters or fewer (hard limit: 72)
- Imperative mood: "Add feature" not "Added feature"
- Capitalize first word, no period at end
- Type prefix when using Conventional Commits

**Types (Conventional Commits):**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no logic change
- `refactor`: Neither fix nor feature
- `perf`: Performance improvement
- `test`: Adding/updating tests
- `chore`: Tooling, config, dependencies
- `ci`: CI/CD configuration
- `revert`: Reverts a prior commit

**Examples:**
```
feat(auth): add OAuth2 login with Google

Users can now sign in using their Google account. This uses the
standard OAuth2 authorization code flow. The existing email/password
login is unchanged.

Closes #142
```

```
fix(payments): prevent double-charge on network timeout

When payment provider response timed out, we were retrying without
checking if the original request succeeded. Added idempotency key
based on order ID to prevent duplicate charges.

Fixes #891
```

### Atomic Commits

Each commit should represent a single logical change. It should:
- Pass all tests in isolation
- Be reversible without affecting other commits
- Have a clear, single-sentence description

Avoid:
- Multi-feature commits ("Add user auth and fix the login page and update dependencies")
- Work-in-progress commits in final history
- Commits that break tests or builds

### Interactive Rebase for Clean History

Before merging, clean up messy branch history:

```bash
git rebase -i main  # interactive rebase against main
```

Operations:
- `pick`: keep as-is
- `reword`: change commit message
- `squash`: combine with previous commit
- `fixup`: combine, discard this commit's message
- `drop`: remove the commit

**Only rebase commits that haven't been pushed, or force-push to branches you own alone.**

## Merging Strategies

### Merge vs. Rebase vs. Squash

**Merge commit**: Preserves branch history, adds merge commit.
```
main: A─B─C─────M
              ↗
branch:    D─E
```
Use when: branch history is meaningful, team prefers explicit merge points.

**Rebase**: Replays branch commits on top of target.
```
main: A─B─C─D'─E'
```
Use when: linear history is preferred, commits are atomic and meaningful.

**Squash merge**: All branch commits become one commit on main.
```
main: A─B─C─DE
```
Use when: branch had messy intermediate commits, you want clean main history, one PR = one commit.

Pick one and enforce it consistently via repository settings. GitHub allows enforcing squash-only or merge-only.

### Pull Request Practices

**Size**: Small PRs (< 400 lines changed) get better reviews, merge faster, and are easier to revert. Split large features into sequential smaller PRs.

**Description**: Include:
- What changed and why
- Testing instructions or proof it works (screenshot, test output)
- Notes for reviewers on non-obvious decisions
- Link to related issues

**Review**: Reviewers should check for:
- Correctness and edge cases
- Tests coverage
- Performance implications
- Security considerations
- Consistency with existing patterns

**Draft PRs**: Use draft PRs for in-progress work that needs feedback or visibility, not for review.

## Semantic Versioning

Semantic versioning (semver) communicates the nature of changes: `MAJOR.MINOR.PATCH`.

| Version part | Increment when |
|-------------|----------------|
| MAJOR | Breaking changes; backward-incompatible API changes |
| MINOR | New features; backward-compatible additions |
| PATCH | Bug fixes; backward-compatible corrections |

**Pre-release**: `1.0.0-alpha.1`, `2.0.0-beta.3`, `1.5.0-rc.1`
**Build metadata**: `1.0.0+build.123` (ignored in precedence)

**Rules:**
- Once released, a version is immutable. Fix by releasing a new version.
- Major version zero (0.x.y) is for initial development; public API is not yet stable.
- Communicate breaking changes clearly in changelogs.

### Version Bumping

Manual bumping is error-prone. Automate based on commit types:

**Conventional Commits + semantic-release or Release Please:**
- `fix:` → PATCH bump
- `feat:` → MINOR bump
- `BREAKING CHANGE:` footer or `feat!:` → MAJOR bump

## Release Automation

### Release Please (GitHub Actions)

Automates changelog generation and version bumping:

```yaml
# .github/workflows/release.yml
name: Release Please
on:
  push:
    branches: [main]
jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          release-type: node  # or python, go, etc.
```

Release Please opens a PR updating version and CHANGELOG.md whenever new conventional commits land. Merging the PR creates the release.

### semantic-release

Fully automated release pipeline:

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github"
  ]
}
```

On every merge to main: analyzes commits, determines version bump, generates release notes, publishes package, creates GitHub release.

## CHANGELOG Management

Maintain a human-readable changelog:

```markdown
# Changelog

## [2.1.0] - 2024-03-15

### Added
- OAuth2 login with Google (#142)
- Export to CSV for reports (#156)

### Fixed
- Double-charge on network timeout (#891)
- Incorrect totals when cart is empty (#834)

### Changed
- API rate limits reduced to 1000 req/hour (was 5000)

## [2.0.0] - 2024-02-01

### Breaking Changes
- `createUser` now returns a Promise instead of callback
- Minimum Node.js version bumped to 18
```

Follow [Keep a Changelog](https://keepachangelog.com) conventions: categories are Added, Changed, Deprecated, Removed, Fixed, Security.

## Git Hooks and Quality Gates

### Pre-commit Hooks

Run fast checks before each commit:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-merge-conflict
  - repo: local
    hooks:
      - id: lint
        name: Run linter
        entry: npm run lint --fix
        language: system
```

Tools: Husky (Node.js), pre-commit (Python/polyglot), Lefthook (fast, polyglot).

**Keep pre-commit hooks fast** (< 10 seconds). Slow hooks get disabled. Run full test suites in CI, not in hooks.

### Branch Protection Rules

Enforce quality on `main`:
- Require pull request before merging
- Require CI to pass (specify required checks)
- Require at least 1 review approval
- Dismiss stale reviews when new commits pushed
- Do not allow force push to main

## Common Operations

### Resolving Merge Conflicts

```bash
git fetch origin
git rebase origin/main  # or merge, depending on strategy
# Resolve conflicts in editor
git add <resolved-files>
git rebase --continue
```

For complex conflicts:
- Use a three-way merge tool (`git mergetool`)
- Understand both sides of the conflict before choosing
- When in doubt, ask the author of the conflicting commit

### Recovering from Mistakes

```bash
# Undo last commit (keep changes staged)
git reset --soft HEAD~1

# Undo last commit (keep changes unstaged)
git reset --mixed HEAD~1

# Undo last commit (discard changes) — destructive!
git reset --hard HEAD~1

# Revert a specific commit (creates new commit)
git revert <commit-sha>

# Find lost commits (reflog is your safety net)
git reflog
git checkout <sha-from-reflog>
```

**Never force-push to shared branches.** Force-push to personal/feature branches is fine; force-push to `main` is a team incident.

### Bisect for Bug Hunting

Binary search through history to find when a bug was introduced:

```bash
git bisect start
git bisect bad             # current commit is broken
git bisect good v1.2.0     # this version was fine
# Git checks out midpoint; test it
git bisect good/bad        # mark result
# Repeat until git identifies the first bad commit
git bisect reset
```

## Checklist

### Commit Quality

- [ ] Commit message follows team convention (subject ≤ 50 chars, imperative mood)
- [ ] Commit represents a single logical change
- [ ] All tests pass at this commit
- [ ] No debug code, console.logs, or commented-out code

### PR Quality

- [ ] PR is small enough to review meaningfully (< 400 lines)
- [ ] Description explains what and why
- [ ] CI is passing
- [ ] Self-reviewed before requesting review

### Release Quality

- [ ] Version follows semver correctly
- [ ] CHANGELOG updated with user-facing changes
- [ ] Breaking changes clearly documented
- [ ] Release tested before tagging
