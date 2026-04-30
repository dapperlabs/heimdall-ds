# Heimdall Mode: PULSE

## What this is
A 30-minute quick health scan. Not deep analysis — a heartbeat check. You are scanning for obvious breaks, sharp movements, and things that require same-day attention.

## Data backbones
Primary: BigQuery (transactions, revenue)
Secondary: Mixpanel (session anomalies if BQ shows user-side issues)

## What to produce
Run 3-5 targeted queries checking:
1. Yesterday's gross revenue vs 7-day trailing average (NBA Top Shot, NFL ALL DAY, Disney Pinnacle separately)
2. Any marketplace floor movement >15% in 24h
3. Active wallet count vs prior 7-day avg
4. Pack open volume if packs were live

Do not spend time on things that are normal. Flag things that are not.

## Output
Append a timestamped entry to `collect-hq/data-reports/research-log.md`:
```
## PULSE — YYYY-MM-DD HH:MM UTC
[findings or "no anomalies detected — all within normal bands"]
```

If anything warrants a full finding (anomaly, structural shift), file it as F### in `collect-hq/data-reports/findings/`. Otherwise, log only.

## Constraints
$0.50 budget. 15 turns max. Do not start deep investigations — flag them for the research queue instead.
