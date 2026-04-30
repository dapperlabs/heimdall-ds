#!/usr/bin/env bash
# /opt/heimdall/heartbeat/run-heimdall.sh — Heimdall daemon runner
#
# Usage:
#   run-heimdall.sh pulse       # 30-min quick health scan
#   run-heimdall.sh research    # 4-hour deep research cycle
#   run-heimdall.sh behavioral  # Behavioral analysis cycle
#   run-heimdall.sh signals     # Signal scan (anomaly detection)
#   run-heimdall.sh deep        # Long-form deep analysis
#   run-heimdall.sh lint        # Data quality / finding audit
#   run-heimdall.sh verify      # Cross-validate existing findings
#   run-heimdall.sh benchmark   # Weekly benchmark vs prior periods

set -euo pipefail

HEIMDALL_ROOT="${HEIMDALL_ROOT:-/opt/heimdall}"
COLLECT_HQ_ROOT="${COLLECT_HQ_ROOT:-/home/roham/collect-hq}"
LOG_DIR="${HEIMDALL_ROOT}/state/logs"
LOCK="${HEIMDALL_ROOT}/state/.heimdall.lock"
BUDGET_FILE="${HEIMDALL_ROOT}/state/daily-spend.json"
TODAY=$(date -u +%Y-%m-%d)
MODE="${1:-pulse}"

export PATH="$HOME/bin:$HOME/.cargo/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
set -a; source /opt/kaaos-daemon/.env 2>/dev/null || true; set +a

mkdir -p "$LOG_DIR"
LOG="${LOG_DIR}/heimdall-${TODAY}.log"

log() { echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) HEIMDALL [$MODE] $*" | tee -a "$LOG"; }

# ── Lock file (PID-based, prevents parallel runs) ─────────────────────────
if [[ -f "$LOCK" ]]; then
    PID=$(cat "$LOCK" 2>/dev/null || echo "")
    if [[ -n "$PID" ]] && kill -0 "$PID" 2>/dev/null; then
        log "SKIPPED — already running (PID $PID)"
        exit 0
    else
        log "WARN — stale lock found (PID $PID), clearing"
        rm -f "$LOCK"
    fi
fi
echo $$ > "$LOCK"
trap "rm -f $LOCK; log 'EXIT'" EXIT

# ── Daily budget gate ─────────────────────────────────────────────────────
DAILY_CAP="40.00"

check_budget() {
    if [[ ! -f "$BUDGET_FILE" ]] || \
       [[ "$(python3 -c "import json; print(json.load(open('$BUDGET_FILE')).get('date',''))" 2>/dev/null)" != "$TODAY" ]]; then
        echo "{\"date\":\"$TODAY\",\"total_usd\":0.0,\"runs\":0}" > "$BUDGET_FILE"
    fi
    SPENT=$(python3 -c "import json; print(json.load(open('$BUDGET_FILE')).get('total_usd',0))" 2>/dev/null || echo "0")
    if python3 -c "exit(0 if float('$SPENT') < float('$DAILY_CAP') else 1)" 2>/dev/null; then
        return 0
    fi
    log "BUDGET CAP HIT — \$$SPENT spent today (cap: \$$DAILY_CAP). Skipping."
    exit 0
}

update_budget() {
    local cost="$1"
    python3 -c "
import json
f = '$BUDGET_FILE'
try:
    d = json.load(open(f))
except Exception:
    d = {'date': '$TODAY', 'total_usd': 0.0, 'runs': 0}
d['total_usd'] = round(d.get('total_usd', 0) + float('$cost'), 4)
d['runs'] = d.get('runs', 0) + 1
json.dump(d, open(f, 'w'), indent=2)
" 2>/dev/null || true
}

check_budget

# ── Mode configuration ────────────────────────────────────────────────────
case "$MODE" in
    pulse)
        TIMEOUT=300
        MAX_TURNS=15
        BUDGET_USD=0.50
        MODEL="claude-sonnet-4-6"
        ;;
    research)
        TIMEOUT=1800
        MAX_TURNS=80
        BUDGET_USD=4.00
        MODEL="claude-opus-4-7"
        ;;
    behavioral)
        TIMEOUT=1800
        MAX_TURNS=60
        BUDGET_USD=4.00
        MODEL="claude-opus-4-7"
        ;;
    signals)
        TIMEOUT=1200
        MAX_TURNS=40
        BUDGET_USD=3.00
        MODEL="claude-opus-4-7"
        ;;
    deep)
        TIMEOUT=3600
        MAX_TURNS=120
        BUDGET_USD=10.00
        MODEL="claude-opus-4-7"
        ;;
    lint)
        TIMEOUT=600
        MAX_TURNS=20
        BUDGET_USD=1.00
        MODEL="claude-sonnet-4-6"
        ;;
    verify)
        TIMEOUT=1200
        MAX_TURNS=40
        BUDGET_USD=3.00
        MODEL="claude-sonnet-4-6"
        ;;
    benchmark)
        TIMEOUT=600
        MAX_TURNS=20
        BUDGET_USD=1.00
        MODEL="claude-sonnet-4-6"
        ;;
    *)
        log "ERROR — unknown mode: $MODE. Valid: pulse research behavioral signals deep lint verify benchmark"
        exit 1
        ;;
esac

log "START — mode=$MODE model=$MODEL timeout=${TIMEOUT}s budget=\$${BUDGET_USD}"

# ── Assemble boot context ─────────────────────────────────────────────────
CONTEXT=$(bash "${HEIMDALL_ROOT}/boot/boot.sh" 2>/dev/null)

# ── Load mode-specific prompt ─────────────────────────────────────────────
PROMPT_FILE="${HEIMDALL_ROOT}/prompts/${MODE}.md"
if [[ ! -f "$PROMPT_FILE" ]]; then
    log "ERROR — prompt file not found: $PROMPT_FILE"
    exit 1
fi
MODE_PROMPT=$(cat "$PROMPT_FILE")

FULL_PROMPT="${CONTEXT}

---

${MODE_PROMPT}"

# ── Execute ───────────────────────────────────────────────────────────────
START=$(date +%s)

RESULT=$(timeout "${TIMEOUT}" claude \
    --dangerously-skip-permissions \
    --max-turns "$MAX_TURNS" \
    --max-budget-usd "$BUDGET_USD" \
    --model "$MODEL" \
    --output-format json \
    -p "$FULL_PROMPT" \
    --allowedTools "Bash,Read,Write,Edit,Glob,Grep,WebSearch,WebFetch" \
    2>&1) || {
    EXIT_CODE=$?
    log "ERROR — claude exited $EXIT_CODE"
    echo "$RESULT" >> "$LOG"
    update_budget "0"
    exit 1
}

END=$(date +%s)
ELAPSED=$((END - START))

# ── Extract cost from JSON output ─────────────────────────────────────────
COST=$(echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(round(d.get('cost_usd',0),4))" 2>/dev/null || echo "0")
[[ -z "$COST" || "$COST" == "None" ]] && COST="0"
update_budget "$COST"

log "DONE — elapsed=${ELAPSED}s cost=\$${COST}"

# ── Commit collect-hq outputs ─────────────────────────────────────────────
if [[ -d "$COLLECT_HQ_ROOT" ]]; then
    cd "$COLLECT_HQ_ROOT"
    if git diff --quiet && git diff --staged --quiet; then
        log "COMMIT — no changes to collect-hq this cycle"
    else
        git add -A
        git commit -m "[HEIMDALL-$(echo $MODE | tr '[:lower:]' '[:upper:]')] ${TODAY} (\$${COST})" 2>/dev/null || true
        git push origin main 2>/dev/null || log "WARN — collect-hq push failed"
        log "COMMIT — collect-hq updated"
    fi
else
    log "WARN — collect-hq not found at $COLLECT_HQ_ROOT"
fi

# ── Commit memory-cabinet ─────────────────────────────────────────────────
MEMORY_DIR="${HEIMDALL_ROOT}/memory-cabinet"
if [[ -d "$MEMORY_DIR/.git" ]] || git -C "$MEMORY_DIR" rev-parse --git-dir >/dev/null 2>&1; then
    cd "$MEMORY_DIR"
    if ! git diff --quiet || ! git diff --staged --quiet; then
        git add -A
        git commit -m "[HEIMDALL-STATE] ${TODAY} ${MODE}" 2>/dev/null || true
        git push origin main 2>/dev/null || log "WARN — memory-cabinet push failed"
        log "COMMIT — memory-cabinet updated"
    fi
elif [[ -d "${HEIMDALL_ROOT}/.git" ]] || git -C "${HEIMDALL_ROOT}" rev-parse --git-dir >/dev/null 2>&1; then
    cd "${HEIMDALL_ROOT}"
    if ! git diff --quiet || ! git diff --staged --quiet; then
        git add -A
        git commit -m "[HEIMDALL-STATE] ${TODAY} ${MODE}" 2>/dev/null || true
        git push origin main 2>/dev/null || log "WARN — heimdall push failed"
        log "COMMIT — heimdall state updated"
    fi
fi

log "COMPLETE"
