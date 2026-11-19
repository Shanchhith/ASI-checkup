*===============================================================================*
* PURPOSE
* File: 01c_extract_haryana_asi_1993_97.do
*
* Keep the Haryana records of the ASI plant file for rounds 1993-97, so the
* codes can be followed after the second renumbering.
* Unit: ASI return (one factory's report in one survey round).
* Years: rounds 1993 to 1997.
* Inputs:
*   $raw_9397/asi_93_97.dta (read-only)
* Key steps:
*   1. Keep Haryana (state code 8 in rounds 1991-92 to 1999-2000).
*   2. Split statedistblk into the district code.
*   3. Add a row key and save.
* Timing/identifiers:
*   statedistblk = state (2 digits) + district (2) + block (2): 80905 is state
*   08, district 09, block 05. It is missing for every 1997 return, so 1997 has
*   no district. 71 returns in 1993-96 have a value that is not a Haryana code;
*   they get no district (sdb_bad = 1). fact_id-year is not unique here
*   (1,190 repeats), so rec_id is the unique key.
* Saves:
*   $data/asi_haryana_1993_97.dta
*===============================================================================*

*-------------------------------------------------------------------------------
* 1. Load and keep Haryana.
*-------------------------------------------------------------------------------
use "$raw_9397/asi_93_97.dta", clear
keep if stcode == 8
assert _N == 9217
tabulate year

*-------------------------------------------------------------------------------
* 2. District code from statedistblk. A valid value starts with Haryana's state
*    code 8 (80000-81999). 71 Haryana returns in 1993-96 have a value that
*    does not (too short, e.g. 10 or 8100, or another state's prefix, e.g.
*    20900); they are kept, flagged, and given no district.
*-------------------------------------------------------------------------------
assert missing(statedistblk) == (year == 1997)
generate byte sdb_bad = !missing(statedistblk) & floor(statedistblk / 10000) != 8
count if sdb_bad
assert r(N) == 71
label variable sdb_bad "statedistblk filled in but not a Haryana code (keying error)"

generate int dist = mod(floor(statedistblk / 100), 100) if !sdb_bad
generate int blck = mod(statedistblk, 100) if !sdb_bad
label variable dist "ASI district code (from statedistblk)"
label variable blck "ASI block code (from statedistblk)"

*-------------------------------------------------------------------------------
* 3. Row key and save.
*-------------------------------------------------------------------------------
sort year fact_id, stable
generate long rec_id = _n
label variable rec_id "Row key: one ASI return"
isid rec_id

order rec_id year stcode dist blck statedistblk fact_id
compress

sort rec_id
cf * using "$data/asi_haryana_1993_97.dta"
save "$data/asi_haryana_1993_97.dta", replace
