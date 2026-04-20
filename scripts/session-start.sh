#!/usr/bin/env bash
# session-start.sh — VS Code SessionStart hook for the agent-skills plugin.
#
# Injects a short activation note into every new session so the agent knows
# the plugin is loaded and which skills exist. We do NOT dump the full
# using-agent-skills SKILL.md — it's too long for every session. Instead, we
# point the agent at the discovery skill so it can fetch the flowchart when
# (and only when) it needs one.
#
# VS Code SessionStart output format (see copilot/customization/hooks.md):
#   {
#     "hookSpecificOutput": {
#       "hookEventName": "SessionStart",
#       "additionalContext": "...string..."
#     }
#   }
# This is NOT the same shape as Claude Code's {"priority","message"} output,
# which is why the original source/agent-skills/hooks/session-start.sh can't
# be reused verbatim.
#
# Note: the Claude-style plugin-root env var is not defined for
# Copilot-format plugins, so we do not reference it here. The hook ships
# with no filesystem lookups — the activation note is embedded.

# Do NOT use `set -e`: a missing jq must degrade to a plain echo fallback,
# not crash the hook.
set -u

# Drain stdin safely. VS Code passes a JSON payload (possibly with a
# `source` field); we don't need anything from it, but some shells will
# complain if stdin is left unread when the parent closes the pipe early.
if [ ! -t 0 ]; then
  cat >/dev/null 2>&1 || true
fi

read -r -d '' CONTEXT <<'EOF'
agent-skills plugin loaded. 21 engineering skills available as /agent-skills:{skill-name}.
Run /agent-skills:using-agent-skills to see the skill discovery guide and decide which skill fits your task.
Key skills: /agent-skills:spec-driven-development (start here), /agent-skills:code-review-and-quality, /agent-skills:test-driven-development, /agent-skills:security-and-hardening, /agent-skills:shipping-and-launch.
Agents: @code-reviewer, @security-auditor, @test-engineer.
EOF

if command -v jq >/dev/null 2>&1; then
  jq -n --arg ctx "$CONTEXT" '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: $ctx
    }
  }'
else
  # Fallback: hand-built JSON. $CONTEXT has no embedded double quotes or
  # backslashes (we control its content), so simple substitution is safe.
  # Newlines inside a JSON string must be escaped as \n.
  ESCAPED=${CONTEXT//$'\n'/\\n}
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$ESCAPED"
fi

exit 0
