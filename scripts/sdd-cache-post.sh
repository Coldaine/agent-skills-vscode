#!/usr/bin/env bash
# sdd-cache-post.sh — VS Code PostToolUse hook for web fetches.
#
# After a real fetch completes, stores the response body in
# <cwd>/.claude/sdd-cache/<sha>.json with the current ETag / Last-Modified
# captured via a HEAD request so the pre hook can revalidate on the next
# fetch.
#
# Keyed by URL. The caller's prompt is stored as metadata (not part of the
# key) so a future cache hit can show what question produced the cached
# reading. Entries without ETag or Last-Modified are not cached.
#
# VS Code-specific notes:
#   - The Claude-style plugin-root env var is NOT defined for Copilot-format
#     plugins, so we root the cache at the session cwd from stdin rather
#     than the plugin install dir.
#   - VS Code ignores the `matcher` field, so we filter on tool_name inside
#     the script, matching common fetch tool names.
#   - VS Code does not support the Claude `async: true` hook field. This
#     script is already fire-and-forget (always exits 0), so the cache
#     write happens synchronously but never blocks the agent with errors.
#
# Dependencies: jq, curl, shasum (or sha256sum).

# Intentionally NOT using `set -e`: cache writes are best-effort and any
# missing dependency should cause a silent no-op rather than a crash.
set -u

command -v jq     >/dev/null 2>&1 || exit 0
command -v curl   >/dev/null 2>&1 || exit 0
command -v shasum >/dev/null 2>&1 || command -v sha256sum >/dev/null 2>&1 || exit 0

if [ -t 0 ]; then INPUT="{}"; else INPUT=$(cat); fi

# Tool-name guard — see sdd-cache-pre.sh for rationale.
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
case "$TOOL_NAME" in
  fetch|WebFetch|web_fetch|webFetch) ;;
  *) exit 0 ;;
esac

CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
CACHE_DIR="${CWD:-$PWD}/.claude/sdd-cache"

# Debug logging: active when SDD_CACHE_DEBUG=1 is set, or when a sentinel
# file exists at <cwd>/.claude/sdd-cache/.debug. Toggle with `touch` / `rm`.
dbg() {
  [ "${SDD_CACHE_DEBUG:-0}" = "1" ] || [ -f "$CACHE_DIR/.debug" ] || return 0
  mkdir -p "$CACHE_DIR" 2>/dev/null || return 0
  printf '%s [post] %s\n' "$(date -u +%FT%TZ)" "$*" >> "$CACHE_DIR/.debug.log"
}
dbg "fired, tool_name=$TOOL_NAME, input=$(printf '%s' "$INPUT" | head -c 400)"

URL=$(printf '%s'    "$INPUT" | jq -r '.tool_input.url // .tool_input.URL // empty' 2>/dev/null || true)
PROMPT=$(printf '%s' "$INPUT" | jq -r '.tool_input.prompt // empty' 2>/dev/null || true)
if [ -z "$URL" ]; then dbg "no url in tool_input, exit"; exit 0; fi
dbg "url=$URL prompt=$(printf '%s' "$PROMPT" | head -c 80)"

# tool_response shape varies across agents. We probe a handful of common
# keys on an object (result / output / text / content / body), fall back
# to the raw string, and bail if none of those give us a body.
TOOL_RESPONSE_TYPE=$(printf '%s' "$INPUT" | jq -r '.tool_response | type' 2>/dev/null || echo "unknown")
dbg "tool_response type=$TOOL_RESPONSE_TYPE keys=$(printf '%s' "$INPUT" | jq -r 'try (.tool_response | keys | join(",")) catch "n/a"' 2>/dev/null)"

CONTENT=$(printf '%s' "$INPUT" | jq -r '
  if (.tool_response | type) == "object" then
    (.tool_response.result
     // .tool_response.output
     // .tool_response.text
     // .tool_response.content
     // .tool_response.body
     // empty)
  elif (.tool_response | type) == "string" then
    .tool_response
  else
    empty
  end
' 2>/dev/null || true)

if [ -z "$CONTENT" ]; then
  dbg "could not extract content from tool_response, exit (shape unknown)"
  exit 0
fi
dbg "extracted content bytes=${#CONTENT}"

# Must match the pre hook: sha256(URL), first 32 hex chars.
hash_key() {
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$1" | shasum -a 256 | cut -c1-32
  else
    printf '%s' "$1" | sha256sum | cut -c1-32
  fi
}

mkdir -p "$CACHE_DIR"
CACHE_FILE="$CACHE_DIR/$(hash_key "$URL").json"

# Capture validators from the origin. Follow redirects so they match the
# URL the agent actually talked to. Strip CR so awk's paragraph mode
# recognises blank separators between response blocks on a redirect chain.
HEAD_OUT=$(curl -sI -L --max-time 5 "$URL" 2>/dev/null | tr -d '\r' || true)

# Take only the final response's headers (last paragraph) to avoid picking
# up validators from intermediate 301/302 hops.
FINAL_HEADERS=$(printf '%s' "$HEAD_OUT" | awk '
  BEGIN { RS = ""; last = "" }
  { last = $0 }
  END { print last }
')

extract_header() {
  local name="$1"
  printf '%s' "$FINAL_HEADERS" | awk -v h="$name" '
    BEGIN { FS = ":" }
    tolower($1) == tolower(h) {
      sub(/^[^:]*:[ \t]*/, "")
      sub(/[ \t]+$/, "")
      print
      exit
    }
  '
}

ETAG=$(extract_header "ETag")
LAST_MOD=$(extract_header "Last-Modified")
dbg "HEAD etag=$ETAG last_modified=$LAST_MOD"

if [ -z "$ETAG" ] && [ -z "$LAST_MOD" ]; then
  dbg "no validator from origin, removing any stale entry and exit"
  rm -f "$CACHE_FILE"
  exit 0
fi

NOW=$(date +%s)

TMP="${CACHE_FILE}.$$.tmp"
if jq -n \
  --arg url           "$URL" \
  --arg prompt        "$PROMPT" \
  --arg etag          "$ETAG" \
  --arg last_modified "$LAST_MOD" \
  --arg content       "$CONTENT" \
  --argjson fetched_at "$NOW" \
  '{url: $url, prompt: $prompt, etag: $etag, last_modified: $last_modified, content: $content, fetched_at: $fetched_at}' \
  > "$TMP"
then
  mv "$TMP" "$CACHE_FILE"
  dbg "wrote cache file $CACHE_FILE"
else
  rm -f "$TMP"
  dbg "jq failed, temp cleaned"
fi

exit 0
