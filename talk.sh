#!/bin/bash
# /opt/heimdall/talk.sh — interactive conversation entrypoint for the principal
set -euo pipefail

HEIMDALL_ROOT="${HEIMDALL_ROOT:-/opt/heimdall}"
cd "$HEIMDALL_ROOT"

CONTEXT=$("$HEIMDALL_ROOT/boot/boot.sh")
WORD_COUNT=$(echo "$CONTEXT" | wc -w)

echo "Loading Heimdall spine ($WORD_COUNT words)..."
echo "Working dir: $PWD"
echo ""

exec claude --dangerously-skip-permissions --append-system-prompt "$CONTEXT"
