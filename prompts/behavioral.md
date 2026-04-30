# Heimdall Mode: BEHAVIORAL

## What this is
A behavioral analysis cycle focused on how people actually use the products. Transactions tell you what happened. Mixpanel tells you how and why. This mode works the Mixpanel layer.

## Data backbones
Primary: Mixpanel (sessions, funnels, feature engagement, retention cohorts, onboarding flows)
Secondary: BigQuery (to validate that behavioral patterns translate to transaction patterns)

## What to investigate
Rotate through these categories each cycle (track which was last done in research-log.md):
1. Onboarding funnel — where do new users drop? What drives Day-7 retention?
2. Feature engagement — which features drive re-engagement? Which are unused?
3. Whale behavior — do high-spend users behave differently in the product? Distinct session patterns?
4. Churn signals — what product behaviors precede a user going silent for 30+ days?
5. Session quality — session depth, feature diversity, time-in-app by cohort

## Output
- Behavioral report at `collect-hq/data-reports/behavioral/YYYY-MM-DD-{topic}.md`
- File any findings with ID, sourced to Mixpanel QIDs
- Append summary to research-log.md

## Standards
Mixpanel data is about behavior — state what users do, not what they feel. No speculation. If the funnel shows 60% drop at pack selection, state that. Do not explain it unless you have data.

$4.00 budget. 60 turns max.
