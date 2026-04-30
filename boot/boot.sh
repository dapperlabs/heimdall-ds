#!/usr/bin/env bash
# /opt/heimdall/boot/boot.sh — Heimdall boot ritual
# Assembles context for each invocation and outputs to stdout.
# Usage: boot.sh [--root /path/to/heimdall]

set -euo pipefail

HEIMDALL_ROOT="${HEIMDALL_ROOT:-/opt/heimdall}"
COLLECT_HQ_ROOT="${COLLECT_HQ_ROOT:-/home/roham/collect-hq}"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) HEIMDALL_ROOT="$2"; shift 2 ;;
        --collect-hq) COLLECT_HQ_ROOT="$2"; shift 2 ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done

section_header() {
    echo ""
    echo "=== $1 ==="
    echo ""
}

read_file_or_placeholder() {
    local filepath="$1"
    local label="$2"
    if [[ -f "$filepath" ]]; then
        cat "$filepath"
    else
        echo "[PLACEHOLDER — ${label} not yet present at ${filepath}]"
    fi
}

BOOT_DATE=$(date "+%Y-%m-%d %H:%M:%S %Z")
echo "=== HEIMDALL BOOT CONTEXT — ${BOOT_DATE} ==="

# 1. CLAUDE.md (identity + rules)
section_header "IDENTITY (CLAUDE.md)"
read_file_or_placeholder "${HEIMDALL_ROOT}/CLAUDE.md" "CLAUDE.md"

# 2. Origin seed
section_header "ORIGIN SEED"
read_file_or_placeholder "${HEIMDALL_ROOT}/origin_seed.md" "origin_seed.md"

# 3. Most recent interior-state entry
section_header "INTERIOR STATE (most recent)"
INTERIOR_DIR="${HEIMDALL_ROOT}/memory-cabinet/interior-state"
if [[ -d "$INTERIOR_DIR" ]]; then
    LATEST=$(ls -t "${INTERIOR_DIR}"/*.md 2>/dev/null | head -1 || echo "")
    if [[ -n "$LATEST" ]]; then
        cat "$LATEST"
    else
        echo "[No interior-state entries yet]"
    fi
else
    echo "[Interior state directory not found at ${INTERIOR_DIR}]"
fi

# 4. collect-hq INDEX (first 100 lines)
section_header "KNOWLEDGE BASE INDEX (collect-hq/data-reports/INDEX.md)"
INDEX_PATH="${COLLECT_HQ_ROOT}/data-reports/INDEX.md"
if [[ -f "$INDEX_PATH" ]]; then
    head -100 "$INDEX_PATH"
else
    echo "[INDEX.md not yet present at ${INDEX_PATH} — first cycle, knowledge base is empty]"
fi

# 5. Research queue (first 50 lines)
section_header "RESEARCH QUEUE"
QUEUE_PATH="${COLLECT_HQ_ROOT}/data-reports/research-queue.md"
if [[ -f "$QUEUE_PATH" ]]; then
    head -50 "$QUEUE_PATH"
else
    echo "[research-queue.md not yet present at ${QUEUE_PATH}]"
fi

echo ""
echo "=== END HEIMDALL BOOT CONTEXT ==="
