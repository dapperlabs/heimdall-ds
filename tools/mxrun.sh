#!/usr/bin/env bash
# /opt/heimdall/tools/mxrun.sh — Mixpanel query runner for Heimdall
# Usage: mxrun.sh --qid QID --intent "description" --query 'JQL_SCRIPT' [--project PROJECT_ID]
#
# Mirrors bqrun.sh discipline: labeled, auditable, QID-tracked.
# Auth: MIXPANEL_USERNAME + MIXPANEL_SECRET from .env (Basic auth)
# API: Mixpanel JQL endpoint (https://data.mixpanel.com/api/2.0/jql)

set -euo pipefail

# Load credentials
source /opt/kaaos-daemon/.env 2>/dev/null || true

if [[ -z "${MIXPANEL_USERNAME:-}" ]] || [[ -z "${MIXPANEL_SECRET:-}" ]]; then
    echo "ERROR: MIXPANEL_USERNAME and MIXPANEL_SECRET required" >&2
    exit 1
fi

# Parse args
QID=""
INTENT=""
QUERY=""
PROJECT_ID="${MIXPANEL_PROJECT_ID:-}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --qid) QID="$2"; shift 2 ;;
        --intent) INTENT="$2"; shift 2 ;;
        --query) QUERY="$2"; shift 2 ;;
        --project) PROJECT_ID="$2"; shift 2 ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$QID" ]] || [[ -z "$QUERY" ]]; then
    echo "Usage: mxrun.sh --qid QID --intent 'description' --query 'JQL'" >&2
    exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "--- MIXPANEL QUERY ---"
echo "QID: $QID"
echo "Intent: $INTENT"
echo "Timestamp: $TIMESTAMP"
echo "---"

# Execute JQL query
RESPONSE=$(curl -s \
    --user "${MIXPANEL_USERNAME}:${MIXPANEL_SECRET}" \
    --data-urlencode "script=${QUERY}" \
    "https://data.mixpanel.com/api/2.0/jql/")

EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]; then
    echo "ERROR: Mixpanel API call failed (exit $EXIT_CODE)" >&2
    exit $EXIT_CODE
fi

# Check for API error in response
if echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'error' not in d else 1)" 2>/dev/null; then
    echo "$RESPONSE"
else
    echo "ERROR: Mixpanel returned error:" >&2
    echo "$RESPONSE" >&2
    exit 1
fi

echo "--- END MIXPANEL QUERY ---"
