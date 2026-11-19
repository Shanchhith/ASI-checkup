# Step 2: industry mix check on the 1985 renumbering

- **Made by:** `code/05_industry_mix_haryana_1983_86.do`.
- **Table:** `output/tab/industry_mix_haryana_1983_86.xlsx`. **Log:** `output/logs/05_industry_mix_haryana_1983_86.log`. Both are kept out of git.
- **Sample:** default sample (`dflt = 1`), codes 1-12, plants counted unweighted.

## The idea

Each district has its own **industry fingerprint**. For example, old code 1 is about one-third metal utensils (NIC 345), and old code 9 is mostly grain mills (204) and brick kilns (320).

If old code 12 became new code 7, then:
- code 12 in 1984 and code 7 in 1986 should have a **similar industry mix**;
- this uses **all plants** in each round, not only plants we can link by `fact_id`;
- so it is a check that does **not** depend on the plant IDs.

**Overlap score** (0 to 1): for each industry, take the smaller of the two codes' shares, then add these up over all industries.
- 1 means the same mix.
- 0 means no industry in common.

## 1. Benchmark: does the method work? (1983 → 1984)

There is no renumbering between 1983 and 1984, so every code should match itself.

- **12 of 12 codes** match themselves best.
- The overlap with itself is 0.58–0.88. The gap to the next-best code is 0.12–0.53.

So industry mix can tell the Haryana codes apart, even the small ones.

## 2. The 1985 renumbering (1984 → 1986)

Sheet `check`, pair `1984_1986`. "Rank 1" means industry mix picks the same new code as the plant links.

| Old code | Plants 1984 | New code (plant links) | Industry rank | Overlap | Gap to 2nd | Read |
|---|---|---|---|---|---|---|
| 1 | 315 | 1 | 1 | 0.84 | 0.39 | agrees |
| 2 | 250 | 3 | 1 | 0.83 | 0.22 | agrees |
| 3 | 69 | 6 | 1 | 0.56 | 0.12 | agrees |
| 4 | 83 | 8 | 1 | 0.62 | 0.13 | agrees |
| 5 | 45 | 9 | 1 | 0.38 | 0.05 | agrees, but low overlap |
| 6 | 72 | 11 | 1 | 0.75 | 0.26 | agrees |
| 7 | 23 | 4 | **2** | 0.60 | | best is 2 (0.62), almost a tie |
| 8 | 21 | 10 | 1 | 0.35 | 0.13 | agrees, but low overlap |
| 9 | 79 | 2 | 1 | 0.82 | 0.26 | agrees |
| 10 | 106 | 5 | 1 | 0.63 | 0.06 | agrees |
| 11 | 27 | 12 | 1 | 0.73 | 0.20 | agrees |
| 12 | 541 | 7 | 1 | 0.86 | 0.30 | agrees |

**11 of 12** agree with the plant links.

The one that doesn't is **old 7**:
- Old 7 is a small code, mostly grain mills (204, 61%).
- In 1986, new 2 and new 4 are **both** grain-mill codes, so the scores are nearly equal (0.62 vs 0.60).
- New 2 already belongs to old 9 (overlap 0.82, strong plant links), so old 7 → 4 still holds.
- 1984 → 1985 also points to 4, clearly (rank 1, overlap 0.81).

## 3. The half-switched round (1984 → 1985)

- 9 of 12 agree.
- **Old 10 matches new 10 best in 1985**, not 5. Its plants were still under code 10 that round, which fits "1985-86 only half switched".
- Old 2 and old 9 also look mixed in 1985. By 1986 both match their new codes cleanly.

## What this means

1. Two methods that don't depend on each other (plant links and industry mix) give the **same old → new mapping** for 1984 → 1986.
2. Old 5 and old 8 now have a second, independent check that agrees. It's weaker than for the big codes (overlap 0.35–0.38), because these are small codes with mixed industries.
3. Old 7 → 4 rests on the 1985 links, the 1985 industry mix, and the fact that code 2 is taken.
4. So the 1985 change is a **renumbering of the same districts**: the industry fingerprints carry over, they just sit under new numbers.

**On your idea:** industry doesn't *cause* the number change. ASI changed the list and every district got a new number. What industry does is let us **recognise** each district under its new number, because the same industries stay in the same place.

## For you to check

- [ ] Excel, sheet `fingerprint`: compare code 12 in 1984 with code 7 in 1986. Are the top industries similar?
- [ ] Sheet `fingerprint`: old 1 (1984) and new 1 (1986) should both have 345 (metal utensils) on top.
- [ ] Sheet `overlap_1984_1986`: in each row, is the highest number in the column of the new code from the tracker?
- [ ] Sheet `check`: confirm 12/12 for `1983_1984` and 11/12 for `1984_1986`.
- [ ] Look at old 7 → new 2 vs new 4. Do you agree with the tie-break?
