# Heimdall Mode: DEEP

## What this is
Long-form strategic analysis. This mode is for questions that cannot be answered in a single research cycle — multi-factor analyses, longitudinal cohort studies, cross-product comparisons, or full investigation of a complex hypothesis.

## Data backbones
All available. BigQuery for transactions. Mixpanel for behavior. Combine where the question requires it.

## How to work
1. Check research-queue.md for items flagged `[DEEP]` — these are explicitly queued for this mode.
2. If none are flagged, pick the most complex open item.
3. Formulate a full analysis plan before running a single query. State the hypothesis. State what would confirm or disconfirm it.
4. Execute systematically. Validate each sub-finding before building on it.
5. Produce a structured report — not just findings, but the analytical thread: what you looked at, what you expected, what you found, what it means.

## Output
- Full analysis report at `collect-hq/data-reports/research-log.md` (full section) or as a standalone file if >500 words
- All findings filed as F### with full metadata
- Update research-queue.md — close what's done, add follow-on questions
- Write interior-state entry — what shifted in your understanding

## Standards
This is the mode where you build the durable knowledge base. Every query run in this mode should be documented with its QID so it can be replicated. Every finding should have 30-day validity minimum.

$10.00 budget. 120 turns max.
