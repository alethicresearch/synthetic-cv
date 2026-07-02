# Experiment - WTP C - 2025OCT19: Single Variant Demographic + Per Belief - Cleaned Data

> Column legend: `S/O` = support\_oppose, `O/S` = oppose\_support · `window` = first run start → last run finish (2025 unless noted) · elapsed values unchanged from source.

| variant | sub\_variant | provider | runs | window | wall\_clock | cum\_elapsed | avg\_elapsed | iterations | errors | total\_w\_err | err\_pct |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| demog+1belief | O/S | deepseek-chat-v3.1 | 14 | 10-23 06:58→08:21 | 0d 1h 22m | 0d 19h 17m | 0d 1h 22m | 14016 | 1 | 14017 | 0.0071 |
| demog+1belief | O/S | deepseek-r1 | 15 | 10-23 08:22→13:52 | 0d 5h 30m | 0d 77h 7m | 0d 5h 8m | 14141 | 0 | 14141 | 0.0000 |
| demog+1belief | O/S | gemini-2.5-flash | 14 | 10-23 05:20→05:57 | 0d 0h 37m | 0d 8h 45m | 0d 0h 37m | 14140 | 0 | 14140 | 0.0000 |
| demog+1belief | O/S | gemini-2.5-flash-lite | 14 | 10-23 14:33→15:13 | 0d 0h 40m | 0d 9h 21m | 0d 0h 40m | 14140 | 0 | 14140 | 0.0000 |
| demog+1belief | O/S | llama-4-scout | 14 | 10-23 18:26→19:11 | 0d 0h 44m | 0d 10h 22m | 0d 0h 44m | 14140 | 0 | 14140 | 0.0000 |
| demog+1belief | O/S | mistral-medium-3.1 | 14 | 10-23 05:57→06:38 | 0d 0h 40m | 0d 9h 27m | 0d 0h 40m | 14138 | 2 | 14140 | 0.0141 |
| demog+1belief | O/S | mistral-small-3.2-24b-instruct | 15 | 10-23 13:52→14:35 | 0d 0h 42m | 0d 10h 7m | 0d 0h 40m | 14155 | 0 | 14155 | 0.0000 |
| demog+1belief | O/S | kimi-k2 | 14 | 10-23 04:18→05:05 | 0d 0h 47m | 0d 11h 3m | 0d 0h 47m | 14125 | 15 | 14140 | 0.1061 |
| demog+1belief | O/S | gpt-5-mini | 15 | 10-23 15:13→18:26 | 0d 3h 12m | 0d 48h 4m | 0d 3h 12m | 14162 | 0 | 14162 | 0.0000 |
| demog+1belief | S/O | deepseek-chat-v3.1 | 14 | 10-23 06:58→08:21 | 0d 1h 22m | 0d 19h 18m | 0d 1h 22m | 14016 | 1 | 14017 | 0.0071 |
| demog+1belief | S/O | deepseek-r1 | 15 | 10-23 08:21→13:52 | 0d 5h 30m | 0d 77h 7m | 0d 5h 8m | 14141 | 0 | 14141 | 0.0000 |
| demog+1belief | S/O | gemini-2.5-flash | 14 | 10-23 05:20→05:57 | 0d 0h 37m | 0d 8h 46m | 0d 0h 37m | 14140 | 0 | 14140 | 0.0000 |
| demog+1belief | S/O | gemini-2.5-flash-lite | 14 | 10-23 14:33→15:13 | 0d 0h 40m | 0d 9h 21m | 0d 0h 40m | 14140 | 0 | 14140 | 0.0000 |
| demog+1belief | S/O | llama-4-scout | 14 | 10-23 18:26→19:11 | 0d 0h 44m | 0d 10h 22m | 0d 0h 44m | 14140 | 0 | 14140 | 0.0000 |
| demog+1belief | S/O | mistral-medium-3.1 | 14 | 10-23 05:57→06:38 | 0d 0h 40m | 0d 9h 27m | 0d 0h 40m | 14138 | 2 | 14140 | 0.0141 |
| demog+1belief | S/O | mistral-small-3.2-24b-instruct | 15 | 10-23 13:52→14:44 | 0d 0h 51m | 0d 10h 11m | 0d 0h 40m | 14155 | 0 | 14155 | 0.0000 |
| demog+1belief | S/O | kimi-k2 | 14 | 10-23 04:18→05:05 | 0d 0h 47m | 0d 11h 3m | 0d 0h 47m | 14137 | 3 | 14140 | 0.0212 |
| demog+1belief | S/O | gpt-5-mini | 15 | 10-23 15:13→18:26 | 0d 3h 12m | 0d 48h 7m | 0d 3h 12m | 14162 | 0 | 14162 | 0.0000 |

## Summary by model (errors are rough estimates — see note below)

| provider | iterations | errors | total\_w\_err | err\_pct |
| :--- | :--- | :--- | :--- | :--- |
| kimi-k2 | 28,262 | 18 | 28,280 | 0.0636 |
| mistral-medium-3.1 | 28,276 | 4 | 28,280 | 0.0141 |
| deepseek-chat-v3.1 | 28,032 | 2 | 28,034 | 0.0071 |
| deepseek-r1 | 28,282 | 0 | 28,282 | 0.0000 |
| gemini-2.5-flash | 28,280 | 0 | 28,280 | 0.0000 |
| gemini-2.5-flash-lite | 28,280 | 0 | 28,280 | 0.0000 |
| llama-4-scout | 28,280 | 0 | 28,280 | 0.0000 |
| mistral-small-3.2-24b-instruct | 28,310 | 0 | 28,310 | 0.0000 |
| gpt-5-mini | 28,324 | 0 | 28,324 | 0.0000 |

## Error integration (from `wtp-c-errors.xlsx`)

**Interpretation note — rough estimates, not exact accounting.** These error counts
are a general approximation: transient errors, run restarts, graph-structure changes,
and cleanup/rerun cycles skew the numbers, and some errors cannot be fully attributed.
Do not expect them to sum exactly against run totals. They remain a valid directional
indication of which models have major issues generating valid tokens that can be
parsed consistently and correctly. Future runs will capture exact values.


Columns `errors`, `total_incl_errors`, `error_pct` were merged in from the monitoring
error export (`experiments/wtp/wtp-c-errors.xlsx`): non-transient pipeline errors per
provider × state (mapping per `experiments/wtp/wtp-errors-experiment-mapping.csv`;
"Results Demographic + Single Belief (…)" → demog + one belief sub_variants).
`total_incl_errors = iteration_count + errors`; `error_pct = 100 × errors /
total_incl_errors`.

Not mapped to line items: 3 errors (1 each: deepseek-chat-v3.1, llama-4-scout,
gemini-2.5-flash) on the `respondents (1010) x beliefs (14)` case-expansion state —
dated 2026, they postdate these 2025-10-23 runs. Unattributed errors (1,257, 2025)
are also excluded.
