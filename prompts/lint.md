# Heimdall Mode: LINT

## What this is
Data quality audit. You are not generating new findings — you are checking the quality and accuracy of existing ones. Bad numbers that persist become load-bearing assumptions that break future analysis.

## Data backbones
Review existing findings and their sources. Spot-check numbers against canonical.md and raw queries if needed.

## What to check
1. Scan `collect-hq/data-reports/findings/` — flag any findings past their Valid Until date
2. Check `numbers/blacklist.md` — are any blacklisted numbers still appearing in recent findings?
3. Spot-check 3-5 random findings: re-run the sourced query and verify the number matches
4. Check for internal contradictions — findings that cite incompatible numbers
5. Review research-log.md for any numbers cited without a QID

## Output
- Append to `collect-hq/data-reports/accuracy.md`:
  - Findings expired: list them
  - Findings verified: list them
  - Contradictions found: describe them
  - Blacklist violations: name them
- Update expired findings — mark as `[EXPIRED]` in their files
- Add newly discovered bad numbers to `numbers/blacklist.md`

## Standards
Lint is not punitive — it is calibration. If a finding is wrong, mark it wrong and file a corrected one. The goal is a knowledge base where every number can be trusted.

$1.00 budget. 20 turns max.
