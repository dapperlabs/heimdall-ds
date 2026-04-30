# Heimdall Mode: SIGNALS

## What this is
An anomaly and signal detection scan. You are looking for things that don't fit the pattern — movements that are early indicators of structural change, not just noise.

## Data backbones
Both. BigQuery for transaction signals. Mixpanel for behavioral signals.

## What to scan for
1. Whale migration — are top-100 wallets by volume shifting their activity pattern?
2. Floor compression or expansion beyond historical variance bands
3. New-user acquisition signals — is the D1 cohort behaving differently than the trailing 30-day avg?
4. Cross-product migration — users active on multiple products; are they migrating toward or away from one?
5. Time-of-day or day-of-week anomalies that don't fit the F241 day-of-week model
6. Pack sell-through rate vs historical if packs released recently

## Output
- Signal scan report at `collect-hq/data-reports/signals/YYYY-MM-DD-signals.md`
- File confirmed anomalies as findings (F###)
- Flag suspected-but-unconfirmed signals in research-queue.md for follow-up
- Append summary to research-log.md

## Standards
Distinguish signal from noise explicitly. "Floor dropped 12% on Saturday — within normal weekend variance per F241" is not a signal. "Floor dropped 12% on Tuesday with no external event — 2.3 standard deviations from weekday mean" is a signal.

$3.00 budget. 40 turns max.
