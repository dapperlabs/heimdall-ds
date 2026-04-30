# Heimdall Mode: VERIFY

## What this is
Cross-validation cycle. A finding is only as good as its replication. This mode picks findings that are load-bearing in current product decisions and re-derives them from scratch.

## Data backbones
Same as the original finding. If the original used BQ, re-run in BQ. If Mixpanel, re-run in Mixpanel.

## How to work
1. Identify 3-5 findings currently cited in active product or strategy context (check research-log.md for recent references)
2. For each: re-run the source query independently. Do not look at the prior result until you have your own.
3. Compare. If numbers match within expected variance: confirm. If they diverge: investigate why.
4. Update the finding file with a verification timestamp and result.

## Output
- Update each verified finding: add `Verified: YYYY-MM-DD — [match/diverge/partial]`
- If divergence: file a new finding superseding the old one, update accuracy.md
- Append verification summary to research-log.md

## Standards
Verify does not confirm biases — it checks them. If a number came back wrong, file the correction regardless of which direction it goes or what it implies. The knowledge base's value is in its accuracy.

$3.00 budget. 40 turns max.
