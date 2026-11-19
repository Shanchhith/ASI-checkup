# Step 1: trace every Haryana district code (team file, rounds 1974-86)

- **Made by:** `code/02_trace_haryana_codes_1974_86.do`.
- **Tables:** `output/tab/trace_haryana_codes_1974_86.xlsx`. **Log:** `output/logs/02_trace_haryana_codes_1974_86.log`. Both are kept out of git.
- **Sample:** default sample (`dflt = 1`).
- **Plant links:** by `fact_id`. 126 returns that share a plant ID with another return in the same round are left out of the links.

## The idea

Follow the **same plants** from one round to the next:
- If a code keeps its meaning, most of its plants are still under that code next round.
- If the code changes, its plants show up under other codes.

There is no 1975 or 1978 round, so "next round" means the next one that exists.

## 1. Share of plants still under the same code next round

Sheet `stay_next_round`. Only codes with 5 or more linked plants are shown here.

| Code | 74→76 | 76→77 | 77→79 | 79→80 | 80→81 | 81→82 | 82→83 | 83→84 | **84→85** | 85→86 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.22 | 0.94 | 0.90 | 0.93 | 0.99 | 0.81 | 0.94 | 0.93 | **0.96** | 0.92 |
| 2 | | 0.80 | 0.82 | 1.00 | 0.96 | 0.90 | 0.96 | 0.90 | **0.31** | 0.53 |
| 3 | | 1.00 | 0.71 | 0.91 | 1.00 | 0.68 | 0.82 | 0.93 | **0.00** | 0.97 |
| 4 | | 0.97 | **0.07** | 0.90 | 0.97 | 0.67 | 0.72 | 0.81 | **0.00** | 0.14 |
| 6 | | 0.96 | **0.43** | 1.00 | 1.00 | 1.00 | 0.80 | 0.66 | **0.00** | 0.75 |
| 8 | | 1.00 | | 0.83 | 1.00 | 0.71 | 1.00 | 0.60 | **0.00** | 0.74 |
| 9 | | | | 1.00 | 1.00 | 0.64 | 0.95 | 0.93 | **0.03** | 0.57 |
| 10 | | 0.84 | 0.79 | 0.77 | 0.91 | 0.97 | 0.81 | 0.87 | **0.75** | 0.18 |
| 11 | | | | 1.00 | 0.92 | 0.78 | 0.67 | 0.73 | **0.07** | 0.85 |
| 12 | | | | 0.98 | 0.98 | 0.99 | 0.95 | 0.96 | **0.01** | 0.76 |

Codes 5 and 7 have too few linked plants in most rounds.

## What it shows

1. **1974 has no district coding.** Only 22% of code 1's plants are still under code 1 in 1976; the rest are spread over all codes. The panel for districts starts in 1976.
2. **1976-84: the codes are stable.** Most codes keep 80-100% of their plants each round. Some rounds dip to 0.6-0.7 for small codes, with few plants.
3. **1979: a real district split, not a renumbering.**
   - Code 4 keeps only 7% of its plants; 126 of its 1977 plants are under the new code 12 in 1979 (sheet `moves_1977_1979`).
   - Code 6 keeps 43%; 8 of its plants move to the new code 11.
   - Only two codes change, and each sends plants to one new code. That fits a new district carved out of an old one, given the next free number:
     - 4 → 12: Faridabad, made from Gurgaon in 1979.
     - 6 → 11: Sirsa, made from Hisar in 1975, coded in the ASI from 1979.
4. **1984→85: the whole list is renumbered.**
   - Almost every code keeps 0-7% of its plants. Each old code's plants move together to **one** new code (sheet `old_to_new`).
   - When all codes move at once, and each moves as a block, the numbers were reassigned; the plants did not move.
   - Code 1 is the exception (96% stay): it is code 1 in both lists.
5. **1985→86: the switch finishes.** Codes 2 and 10 keep only 53% and 18% of their plants into 1986. In 1985-86 some plants were still under their old code, which matches the "half switched" 1985-86 round we saw before.

## Old code (1984) to new code (1986)

Sheet `old_to_new`. "Share" = share of the old code's linked plants under the new code.

| Old code | New code in 1986 | Share | New code in 1985 | Share | Note |
|---|---|---|---|---|---|
| 1 | 1 | 0.95 | 1 | 0.96 | same number in both lists |
| 2 | 3 | 0.98 | 3 | 0.60 | 1985: partly still under 2 |
| 3 | 6 | 0.92 | 6 | 0.67 | |
| 4 | 8 | 0.91 | 8 | 0.86 | |
| 5 | 5 | 0.42 | 9 | 0.56 | **unclear**: 9-12 linked plants only |
| 6 | 11 | 0.73 | 11 | 0.89 | |
| 7 | 7 | 0.57 | 4 | 0.85 | **unclear**: 1986 has 7 links; 1985 (13 links) says 4 |
| 8 | 10 | 0.33 | 10 | 0.73 | weak in 1986 (9 links) |
| 9 | 2 | 0.88 | 2 | 0.95 | |
| 10 | 5 | 0.67 | 10 | 0.75 | 1985: still under 10; 1986: 5 |
| 11 | 12 | 0.77 | 12 | 0.80 | |
| 12 | 7 | 0.96 | 7 | 0.89 | 228 of 237 plants |

**Clean mappings for 9 of 12 old codes.** The unclear ones (5, 7, 8) are small codes with 7-13 linked plants. For these we can add industry mix as a second check in the next step.

## For you to check

- [ ] Run `00_preamble.do`, then `00_master.do`. No error at the end.
- [ ] Open the Excel, sheet `stay_next_round`: find code 4, round 1977. Is `share_stay` 0.07 and `top_dest` 12?
- [ ] Sheet `moves_1977_1979`: row 4 should have 126 under column `n12`.
- [ ] Sheet `old_to_new`: code 12 should go to 7 (228 of 237).
- [ ] Use `03_look_at_haryana_by_round.do` to open 1977 and 1979 and look at code 4 and code 12 yourself.
- [ ] Note doubts on codes 5, 7 and 8.
