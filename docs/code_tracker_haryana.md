# Haryana code tracker, 1976-86

- **Made by:** `code/04_code_tracker_haryana_1976_86.do`.
- **Outputs:**
  - `output/tab/code_tracker_haryana_1976_86.xlsx` (table)
  - `output/fig/code_tracker_haryana_1976_86.pdf` (chart)
- Both outputs are kept out of git.

## How to read it

- **One row = one "unit".** A unit is one ASI district code in the new numbering (1985-86), followed back in time through the same plants.
- **One column = one ASI round.**
- **In each cell:**
  - the **number** is the code that unit has in that round;
  - in the chart, the **circle size** is the number of plants under that code;
  - a **star** (e.g. `4*`) means the unit did not have its own code yet; its plants were still under that parent code.
- **In the chart:**
  - rows are labelled "Old 12 = New 7";
  - "(less sure)" marks the two codes with weak plant links (old 5 and old 8). Step 2 (industry mix) agrees with both;
  - **1985 is grey with no circles**: that round is only half switched, so plant counts by new code would be wrong there.
- **Strength** says how sure the old-to-new link is, from the plants seen in both 1984 and 1986 (or 1985):
  - **strong:** 80%+ of 20+ linked plants;
  - **medium:** 60%+ of 10+;
  - **weak:** less than that.

## What it shows

| Unit (new code) | 1976-77 | 1979-84 | 1985-86 | Strength |
|---|---|---|---|---|
| 1 | 1 | 1 | 1 | strong |
| 2 | 9 | 9 | 2 | strong |
| 3 | 2 | 2 | 3 | strong |
| 4 | 7 | 7 | 4 | medium |
| 5 | 10 | 10 | 5 | medium |
| 6 | 3 | 3 | 6 | medium |
| 7 | inside 4 | 12 | 7 | strong |
| 8 | 4 | 4 | 8 | strong |
| 9 | 5 | 5 | 9 | weak |
| 10 | 8 | 8 | 10 | weak |
| 11 | 6 | 6 | 11 | medium |
| 12 | inside 6 | 11 | 12 | medium |

**Three kinds of change:**
1. **1979: new district, new code at the end.** Codes 11 and 12 are added. Their plants come out of codes 6 and 4, and the old codes keep their numbers.
2. **1985: whole list renumbered.** Every unit gets a new number, but its plants stay together. Code 1 is the only one that keeps its number.
3. **1985-86 is only half switched.** Some plants are still under old codes that round, so for 1985-86 use plant-level links, not just the code.

**Weak links (units 9 and 10, old codes 5 and 8):** these are small codes with 9 linked plants each. Next step: check them with industry mix.

## Rule used to give each old code one new code

- Old codes are taken in order of how many plants link them, largest first.
- Each takes the 1986 code most of its plants are under.
- If a larger old code has already taken that 1986 code, it takes its 1985 code instead.
- This happened for old 5 (→ 9) and old 7 (→ 4).

## For you to check

- [ ] Open the chart. Is each row's number the same from 1979 to 1984, then one jump at 1985?
- [ ] Excel sheet `tracker`: does `Code 1984` → `Code 1986` match the table above?
- [ ] Unit 7: `4*` in 1976-77, 12 in 1979-84, 7 in 1985-86. Check in `03_look_at_haryana_by_round.do` that code 4 is big in 1977 and small in 1979.
