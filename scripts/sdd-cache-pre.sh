#!/usr/bin/env bash
# sdd-cache-pre.sh — VS Code PreToolUse hook for web fetches.
#
# HTTP resource cache keyed by URL. Freshness is delegated to the origin via
# HTTP validators; 304 Not Modified is the only signal to serve from cache.
# On hit, exits 2 and writes the cached body to stderr so VS Code can deliver
# it to the agent in place of the real fetch result (confirmed in
# copilot/customization/hooks.md: exit 2 blocks and shows stderr to the
# model). Otherwise exits 0 and the fetch proceeds normally.
#
# VS Code-specific notes:
#   - The Claude-style plugin-root env var is NOT defined for Copilot-format
#     plugins, so we do not reference it. Cache dir is rooted at the session
#     cwd (from the hook stdin payload), not at the plugin install dir.
#   - VS Code ignores the `matcher` field in hooks.json, so we filter on
#     tool_name inside the script. We accept common fetch tool names across
#     VS Code / Copilot CLI / Claude Code variants.
#   - Dependencies (jq, curl, shasum/sha256sum) are soft: if any is missing
#     we exit 0 and let the fetch through. Do NOT use `set -e`.
#
# Dependencies: jq, curl, shasum (or sha256sum).

# Intentionally NOT using `set -e`: a missing dependency should let the
# fetch proceed, not fail the hook.
set -u

# Graceful degradation: if any dependency is missing, let the fetch through.
command -v jq     >/dev/null 2>&1 || exit 0
command -v curl   >/dev/null 2>&1 || exit 0
command -v shasum >/dev/null 2>&1 || command -v sha256sum >/dev/null 2>&1 || exit 0

if [ -t 0 ]; then INPUT="{}"; else INPUT=$(cat); fi

# Tool-name guard. VS Code ignores the matcher field, so every PreToolUse
# fires this hook. Exit immediately unless the tool looks like a web fetch.
# Common names across agents: VS Code `fetch`, Claude Code `WebFetch`,
# Copilot `web_fetch` / `webFetch`. An empty tool_name means this wasn't a
# tool event at all (e.g. Stop) — also exit.
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
case "$TOOL_NAME" in
  fetch|WebFetch|web_fetch|webFetch) ;;
  *) exit 0 ;;
esac

# Workspace root comes from the hook stdin (VS Code provides .cwd). Fall
# back to $PWD if absent so local smoke-testing still works.
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
CACHE_DIR="${CWD:-$PWD}/.claude/sdd-cache"

# Debug logging: active when SDD_CACHE_DEBUG=1 is set, or when a sentinel
# file exists at <cwd>/.claude/sdd-cache/.debug. Toggle with `touch` / `rm`.
dbg() {
  [ "${SDD_CACHE_DEBUG:-0}" = "1" ] || [ -f "$CACHE_DIR/.debug" ] || return 0
  mkdir -p "$CACHE_DIR" 2>/dev/null || return 0
  printf '%s [pre]  %s\n' "$(date -u +%FT%TZ)" "$*" >> "$CACHE_DIR/.debug.log"
}
dbg "fired, tool_name=$TOOL_NAME"

URL=$(printf '%s' "$INPUT" | jq -r '.tool_input.url // .tool_input.URL // empty' 2>/dev/null || true)
if [ -z "$URL" ]; then dbg "no url in tool_input, exit"; exit 0; fi
dbg "url=$URL"

# Cache key is sha256(URL), truncated to 128 bits.
hash_key() {
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$1" | shasum -a 256 | cut -c1-32
  else
    printf '%s' "$1" | sha256sum | cut -c1-32
  fi
}

CACHE_FILE="$CACHE_DIR/$(hash_key "$URL").json"

if [ ! -f "$CACHE_FILE" ]; then dbg "no cache file at $CACHE_FILE, exit"; exit 0; fi
dbg "cache file exists: $CACHE_FILE"

FETCHED_AT=$(jq -r '.fetched_at // 0' "$CACHE_FILE" 2>/dev/null || echo 0)
ORIGINAL_PROMPT=$(jq -r '.prompt // empty' "$CACHE_FILE" 2>/dev/null || true)
ETAG=$(jq -r '.etag // empty' "$CACHE_FILE" 2>/dev/null || true)
LAST_MOD=$(jq -r '.last_modified // empty' "$CACHE_FILE" 2>/dev/null || true)

# No validator means we cannot verify freshness — never serve from cache.
if [ -z "$ETAG" ] && [ -z "$LAST_MOD" ]; then
  dbg "cached entry has no etag/last-modified, cannot revalidate, bypass"
  exit 0
fi

HEADERS=()
[ -n "$ETAG" ]     && HEADERS+=(-H "If-None-Match: $ETAG")
[ -n "$LAST_MOD" ] && HEADERS+=(-H "If-Modified-Since: $LAST_MOD")

STATUS=$(curl -sI -o /dev/null -w "%{http_code}" \
  --max-time 5 -L \
  "${HEADERS[@]}" \
  "$URL" 2>/dev/null || echo "000")
dbg "revalidation HEAD status=$STATUS"

if [ "$STATUS" != "304" ]; then
  dbg "not 304, letting fetch proceed"
  exit 0
fi

# Server confirmed content unchanged. Serve cached copy to the agent.
CONTENT=$(jq -r '.content // empty' "$CACHE_FILE" 2>/dev/null || true)
if [ -z "$CONTENT" ]; then dbg "cache file has empty content field, bypass"; exit 0; fi
dbg "cache HIT, blocking fetch with ${#CONTENT} bytes of cached content"

VERIFIED_AT_ISO=$(date -u -r "$FETCHED_AT" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null \
              || date -u -d "@$FETCHED_AT" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null \
              || echo "unknown")

# Emit the payload with printf so $CONTENT is never interpreted by the shell
# (docs contain backticks, $vars, and backslashes in code examples; an
# unquoted heredoc would treat them as command substitution).
{
  printf '[sdd-cache] Cache hit for %s\n\n' "$URL"
  printf 'Revalidated via HTTP 304; unchanged since %s. Use the cached\n' "$VERIFIED_AT_ISO"
  printf 'content below as if the fetch had just returned it.\n\n'
  if [ -n "$ORIGINAL_PROMPT" ]; then
    printf 'Original fetch prompt: "%s". If your angle differs, judge\n' "$ORIGINAL_PROMPT"
    printf 'whether this reading still covers it.\n\n'
  fi
  printf -- '----- BEGIN CACHED CONTENT -----\n'
  printf '%s\n' "$CONTENT"
  printf -- '----- END CACHED CONTENT -----\n'
} >&2
exit 2
