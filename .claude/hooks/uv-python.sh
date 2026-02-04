#!/bin/bash
# Replaces python/python3/pip commands with uv equivalents

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

MODIFIED="$COMMAND"

# Replace python/python3 at start of command with uv run python
MODIFIED=$(echo "$MODIFIED" | sed -E 's/^python3?([^0-9]|$)/uv run python\1/')

# Replace pip/pip3 at start of command with uv pip
MODIFIED=$(echo "$MODIFIED" | sed -E 's/^pip3?([^0-9]|$)/uv pip\1/')

if [ "$MODIFIED" != "$COMMAND" ]; then
  jq -n --arg cmd "$MODIFIED" '{
    "decision": "allow",
    "updatedInput": {"command": $cmd}
  }'
fi
