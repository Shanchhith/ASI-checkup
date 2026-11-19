*===============================================================================*
* PURPOSE
* File: 01b_extract_haryana_raw_1984_90.do
*
* Read the raw ASI plant files for rounds 1984-85 to 1989-90 with their Stata
* dictionaries and keep Haryana, so the codes can be followed past 1986 (the
* team file stops in 1986).
* Unit: ASI return (one factory's report in one survey round).
* Years: rounds 1984-85 to 1989-90 (round_start = first calendar year).
* Inputs:
*   $raw_8490/as84fbm1.TXT ... as89fbm1.TXT (raw data, read-only)
*   $raw_8490/in8485.dic ... in8990.dic (column layouts and labels)
* Key steps:
*   1. Read each round with its dictionary and keep Haryana.
*   2. Append the six rounds.
*   3. Add the weight (mult has two hidden decimals: 200 = 2.00; no weight in
*      1987-88 and 1988-89, where the column is an empty filler) and a row key.
* Timing/identifiers:
*   Haryana's state code is 14 up to 1988-89 and 6 in 1989-90 (ASI state code
*   list). Industry is nic70 up to 1988-89 and nic87 from 1987-88. permid is the
*   file's "permanent serial no." but does not stay with a plant across rounds,
*   so it is not used as a plant ID. rec_id is the unique key.
* Saves:
*   $data/asi_haryana_raw_1984_90.dta
*===============================================================================*

*-------------------------------------------------------------------------------
* Setup: the rounds to read, as the two-digit start year used in the file names
* (as84fbm1.TXT goes with in8485.dic).
*-------------------------------------------------------------------------------
global raw_rounds_8490 "84 85 86 87 88 89"

*-------------------------------------------------------------------------------
* 1. Read each round and keep Haryana. Each round is held in a temporary file.
*-------------------------------------------------------------------------------
foreach y of global raw_rounds_8490 {
    local y_next = `y' + 1
    infile using "$raw_8490/in`y'`y_next'.dic", using("$raw_8490/as`y'fbm1.TXT") clear

    * Haryana: state code 14 until 1988-89, 6 in 1989-90.
    local hr_code = cond(`y' == 89, 6, 14)
    keep if stcode == `hr_code'

    generate int round_start = 1900 + `y'
    label variable round_start "Survey round (first calendar year)"
    tempfile round_`y'
    save `round_`y''
}

*-------------------------------------------------------------------------------
* 2. Append the rounds. Columns that exist only in some rounds (nic70, nic87,
*    nicframe, ...) are missing in the others.
*-------------------------------------------------------------------------------
clear
foreach y of global raw_rounds_8490 {
    append using `round_`y''
}

* Haryana returns per round; the total must match the Python extract checked
* earlier (1,796 + 2,008 + 1,944 + 1,577 + 1,621 + 1,610).
tabulate round_start
assert _N == 10556

*-------------------------------------------------------------------------------
* 3. Weight and row key.
*-------------------------------------------------------------------------------
* The weight is in mult for 1984-85, 1985-86, 1986-87 and 1989-90. In 1987-88
* and 1988-89 the same columns are an empty filler (fill_mult = 0, per the
* dictionaries), so those rounds have no weight and weight stays missing.
assert inlist(mult, 100, 200, 300) if !inlist(round_start, 1987, 1988)
assert missing(mult) & fill_mult == 0 if inlist(round_start, 1987, 1988)
generate double weight = mult / 100
label variable weight "Sampling weight (mult / 100); missing in 1987-88 and 1988-89"

label variable distcode "ASI district code"

sort round_start runslno, stable
generate long rec_id = _n
label variable rec_id "Row key: one ASI return"
isid rec_id

order rec_id round_start stcode distcode blckcode permid runslno
compress

sort rec_id
cf * using "$data/asi_haryana_raw_1984_90.dta"
save "$data/asi_haryana_raw_1984_90.dta", replace
