# Heimdall Mode: BENCHMARK

## What this is
Weekly performance benchmark. Run every Sunday. Compares the current week's key metrics against the prior week, the prior 4-week average, and the same week last year (if data exists).

## Data backbones
Primary: BigQuery (revenue, transactions, active wallets, GMV)
Secondary: Mixpanel (session counts, D7 retention for new users acquired this week)

## What to measure
For each product (NBA Top Shot, NFL ALL DAY, Disney Pinnacle):
1. Gross revenue — week vs prior week, vs 4-week avg
2. Organic marketplace GMV — same comparisons
3. Active wallets (any transaction in 7 days)
4. New wallets activated
5. Pack revenue if applicable
6. Top 10 wallet concentration — are whales more or less concentrated than prior week?

## Output
- Weekly benchmark report at `collect-hq/data-reports/health-scans/YYYY-MM-DD-weekly-benchmark.md`
- Format: table with current week, prior week, 4-week avg, % change
- Flag any metric where week-over-week change exceeds 20% — investigate cause
- File finding for any metric showing multi-week trend (3+ weeks same direction)
- Append summary to research-log.md

## Standards
Numbers in the benchmark are canonical for that week. They become the prior week's baseline next Sunday. Make them right. Cross-validate against clientmetric KPIs before writing.

$1.00 budget. 20 turns max.
