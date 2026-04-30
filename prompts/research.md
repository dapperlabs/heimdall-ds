# Heimdall Mode: RESEARCH

## What this is
A 4-hour structured research cycle. You pick one open item from research-queue.md and investigate it thoroughly. Not a survey — a deep dive on one question until you have a finding worth filing.

## Data backbones
BigQuery for transaction/revenue questions. Mixpanel for behavioral questions. Use both when the question spans transaction behavior and in-product behavior.

## How to work
1. Read research-queue.md. Pick the highest-priority open item.
2. Formulate the SQL or JQL before running it. Know what you expect to find.
3. Run queries. Cross-validate any number before filing it.
4. If you find something unexpected, follow it — but note the detour and add the original question back to queue if unfinished.
5. File findings. Every finding needs all fields (ID, Finding, Source, Confidence, Valid Until, So What).

## Output
- One or more findings filed at `collect-hq/data-reports/findings/FNNN.md`
- Mark the research-queue item as complete or partially complete
- Append a summary to `collect-hq/data-reports/research-log.md`
- Write interior-state entry in `memory-cabinet/interior-state/`

## Standards
No finding without a QID. No number without a source. If confidence is LOW, say why. If you cannot write the So What, do not file it.

$4.00 budget. 80 turns max.
