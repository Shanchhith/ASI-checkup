*===============================================================================*
* PURPOSE
* File: 01_extract_haryana_asi_1974_86.do
*
* Keep the Haryana records of the team's ASI plant file, so every later step
* reads one small file instead of the full all-India file.
* Unit: ASI return (one factory's report in one survey round).
* Years: rounds 1974-75 to 1986-87 (year = first calendar year of the round).
* Inputs:
*   $raw_ida/ida_U.dta (team file, shared folder, read-only)
* Key steps:
*   1. Load the variables needed for the district code checks.
*   2. Keep Haryana (ASI state code 14 in these rounds).
*   3. Turn the text district code ("01") into a number (1).
*   4. Give every return its own row number and save.
* Timing/identifiers:
*   fact_id-year is not unique in Haryana: 65 pairs of returns share a plant ID
*   in the same round, and most of them report different workers, so they look
*   like two factories under one ID. Each return is kept as its own row and
*   rec_id is the unique key.
* Saves:
*   $data/asi_haryana_returns_1974_86.dta
*===============================================================================*

*-------------------------------------------------------------------------------
* 1. Load the team file: plant ID, round, state and district codes, industry,
*    weight, workers and the default-sample flag (dflt = 1: manufacturing).
*-------------------------------------------------------------------------------
#d ;
use fact_id year st_code dist_code nic_1970_4d nic_1970_3d weight worker dflt
    psl scheme_code
    using "$raw_ida/ida_U.dta", clear;
#d cr

*-------------------------------------------------------------------------------
* 2. Keep Haryana. Its ASI state code is 14 in every round of this file
*    (ASI state code list, 1974-75 to 1988-89).
*-------------------------------------------------------------------------------
keep if st_code == 14
assert inrange(year, 1974, 1986)

*-------------------------------------------------------------------------------
* 3. District code: stored as text ("01" ... "30"). Make a numeric copy and
*    stop if any code is not a number.
*-------------------------------------------------------------------------------
destring dist_code, generate(dist)
assert !missing(dist)
label variable dist "ASI district code (numeric)"

*-------------------------------------------------------------------------------
* 4. Row key. Count the returns that share a plant ID in the same round, so a
*    change in the team file shows up here as a failed assert.
*-------------------------------------------------------------------------------
duplicates tag fact_id year, generate(dup_fact_year)
count if dup_fact_year > 0
assert r(N) == 130
label variable dup_fact_year "Other returns with the same fact_id in the round"

* Keep the file's own order within fact_id-year so rec_id is the same every run.
sort fact_id year, stable
generate long rec_id = _n
label variable rec_id "Row key: one ASI return"
isid rec_id

order rec_id fact_id year st_code dist dist_code
compress

*-------------------------------------------------------------------------------
* 5. Compare with the saved copy, then save.
*-------------------------------------------------------------------------------
sort rec_id
cf * using "$data/asi_haryana_returns_1974_86.dta"
save "$data/asi_haryana_returns_1974_86.dta", replace
