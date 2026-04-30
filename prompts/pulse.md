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
Write to a daily pulse file — do NOT read or touch `research-log.md`. Use bash to append:
```bash
TODAY=$(date -u +%Y-%m-%d)
mkdir -p collect-hq/data-reports/pulse
echo "## PULSE — $(date -u +%Y-%m-%d\ %H:%M) UTC" >> collect-hq/data-reports/pulse/${TODAY}.md
echo "[your findings or 'no anomalies detected — all within normal bands']" >> collect-hq/data-reports/pulse/${TODAY}.md
echo "" >> collect-hq/data-reports/pulse/${TODAY}.md
```

The pulse directory files stay small (one day per file, fresh each day). Never read research-log.md in pulse mode — it can be hundreds of KB.

If anything warrants a full finding (anomaly, structural shift), file it as F### in `collect-hq/data-reports/findings/`. Otherwise, log to the daily pulse file only.

## Constraints
$2.00 budget. 25 turns max. Do not start deep investigations — flag them for the research queue instead.
