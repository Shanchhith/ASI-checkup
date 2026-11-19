*===============================================================================*
* PURPOSE
* File: 04_code_tracker_haryana_1976_86.do
*
* Build a code tracker for Haryana: one row per district unit (one code in the
* 1986 numbering), showing which ASI district code that unit has in each round
* 1976-86 and how many plants sit under it. This turns the step 1 plant links
* into one table and one chart that show where and how the codes change.
* Unit: district unit (row of the tracker) x survey round.
* Years: rounds 1976, 1977, 1979-1986 (1974 has no district coding).
* Inputs:
*   $data/asi_haryana_plant_round_1974_86.dta (02_trace_haryana_codes_1974_86.do)
* Key steps:
*   1. Old-to-new mapping: for each 1984 code, the 1986 code most of its plants
*      are under; each new code can belong to only one old code.
*   2. Codes first used in 1979: the 1977 code most of their plants came from.
*   3. Plants under each code in each round.
*   4. Tracker: code used by each unit in each round, with plant counts.
*   5. Excel table and a PDF chart.
* Timing/identifiers:
*   Units are numbered by their 1986 code. 1985-86 is shown with the new codes
*   but was only partly switched (some plants still under old codes).
*   Before 1979 the units with codes 11 and 12 did not have their own code;
*   their plants were under the parent code, shown with a star (e.g. "4*").
*   Only codes 1-12 are mapped; codes above 12 have 1-12 plants in all rounds
*   and are treated as keying errors.
* Saves:
*   $data/asi_haryana_code_map_1984_86.dta (old code -> new code, one row per
*     old code; used by 05_industry_mix_haryana_1983_86.do)
*   $tab/code_tracker_haryana_1976_86.xlsx
*   $fig/code_tracker_haryana_1976_86.pdf
*   $logs/04_code_tracker_haryana_1976_86.log
*===============================================================================*

*-------------------------------------------------------------------------------
* Setup: rounds shown in the tracker, in order.
*-------------------------------------------------------------------------------
global tracker_rounds "1976 1977 1979 1980 1981 1982 1983 1984 1985 1986"

log using "$logs/04_code_tracker_haryana_1976_86.log", replace text name(tracker)

*-------------------------------------------------------------------------------
* 1. Old-to-new mapping.
*    Link the 1984 plants (old codes 1-12) to 1985 and to 1986 by fact_id and
*    keep, for each old code, the new code most of its plants are under.
*-------------------------------------------------------------------------------
use fact_id dist year using "$data/asi_haryana_plant_round_1974_86.dta" if year == 1984, clear
keep if inrange(dist, 1, 12)
keep fact_id dist
rename dist old_code
tempfile plants_1984
save `plants_1984'

foreach b in 1985 1986 {
    use fact_id dist year using "$data/asi_haryana_plant_round_1974_86.dta" if year == `b', clear
    keep fact_id dist
    rename dist new_code_seen
    merge 1:1 fact_id using `plants_1984', keep(match) nogenerate

    * Linked plants per old code, then the most common new code and its count.
    contract old_code new_code_seen, freq(n)
    bysort old_code: egen linked_`b' = total(n)
    gsort old_code -n new_code_seen
    by old_code: keep if _n == 1
    rename (new_code_seen n) (to_`b' n_to_`b')
    tempfile map_`b'
    save `map_`b''
}

use `map_1986', clear
merge 1:1 old_code using `map_1985'
assert _merge == 3
drop _merge

* One new code per old code. Old codes are taken from the most linked plants
* down: an old code takes its 1986 destination unless a larger old code has
* already taken it; then it takes its 1985 destination. (1985-86 is only partly
* switched, so 1986 is used first.)
gsort -linked_1986 old_code
generate new_code = .
generate str40 basis = ""
forvalues i = 1/`=_N' {
    local c86 = to_1986[`i']
    quietly count if new_code == `c86'
    if r(N) == 0 {
        quietly replace new_code = `c86' in `i'
        quietly replace basis = "1986 plant links" in `i'
    }
    else {
        quietly replace new_code = to_1985[`i'] in `i'
        quietly replace basis = "1985 plant links (1986 code taken)" in `i'
    }
}
isid new_code

* Strength of each mapping, from the links behind the chosen new code.
generate n_chosen      = cond(basis == "1986 plant links", n_to_1986, n_to_1985)
generate linked_chosen = cond(basis == "1986 plant links", linked_1986, linked_1985)
generate share_chosen  = n_chosen / linked_chosen
format share_chosen %4.2f
* strong: 80%+ of 20+ linked plants; medium: 60%+ of 10+; weak: otherwise.
#d ;
generate str6 strength = cond(share_chosen >= 0.8 & linked_chosen >= 20, "strong",
    cond(share_chosen >= 0.6 & linked_chosen >= 10, "medium", "weak"));
#d cr

list old_code new_code basis linked_chosen n_chosen share_chosen strength, noobs abbreviate(14)
keep old_code new_code basis linked_chosen n_chosen share_chosen strength

* Save the plant-link mapping (one row per old code) so step 05 can compare it
* with the industry-mix match.
isid old_code
sort old_code
cf * using "$data/asi_haryana_code_map_1984_86.dta"
save "$data/asi_haryana_code_map_1984_86.dta", replace

tempfile mapping
save `mapping'

*-------------------------------------------------------------------------------
* 2. Codes first used in 1979 (new districts). Their parent is the 1977 code
*    that most of their 1979 plants were under.
*-------------------------------------------------------------------------------
use fact_id dist year using "$data/asi_haryana_plant_round_1974_86.dta" if inrange(year, 1976, 1984), clear
keep if inrange(dist, 1, 12)
bysort dist: egen first_round = min(year)
levelsof dist if first_round == 1979, local(codes_new_1979)
display "Codes first used in 1979: `codes_new_1979'"

use fact_id dist year using "$data/asi_haryana_plant_round_1974_86.dta" if year == 1977, clear
keep fact_id dist
rename dist parent_code
tempfile plants_1977
save `plants_1977'

use fact_id dist year using "$data/asi_haryana_plant_round_1974_86.dta" if year == 1979, clear
keep fact_id dist
rename dist old_code
generate byte new_1979 = 0
foreach c of local codes_new_1979 {
    replace new_1979 = 1 if old_code == `c'
}
keep if new_1979
merge 1:1 fact_id using `plants_1977', keep(match) nogenerate
contract old_code parent_code, freq(n_parent)
bysort old_code: egen linked_parent = total(n_parent)
gsort old_code -n_parent parent_code
by old_code: keep if _n == 1
list, noobs
tempfile parents
save `parents'

use `mapping', clear
merge 1:1 old_code using `parents', nogenerate
save `mapping', replace

*-------------------------------------------------------------------------------
* 3. Plants (linkable returns) under each code in each round.
*-------------------------------------------------------------------------------
use dist year using "$data/asi_haryana_plant_round_1974_86.dta", clear
contract year dist, freq(plants)
rename dist code_used
tempfile counts
save `counts'

*-------------------------------------------------------------------------------
* 4. Tracker: every unit in every round. The code a unit uses is
*      1985 and 1986: its new code;
*      1979-1984: its old code;
*      1976-1977: its old code, or its parent's code for units made in 1979.
*-------------------------------------------------------------------------------
clear
local n_rounds : word count $tracker_rounds
set obs `n_rounds'
generate int year = .
forvalues i = 1/`n_rounds' {
    replace year = `: word `i' of $tracker_rounds' in `i'
}
cross using `mapping'
isid new_code year

generate byte in_parent = year < 1979 & !missing(parent_code)
generate code_used = cond(year >= 1985, new_code, cond(in_parent, parent_code, old_code))

merge m:1 year code_used using `counts', keep(master match) nogenerate
replace plants = 0 if missing(plants)

generate str4 code_label = string(code_used) + cond(in_parent, "*", "")
generate byte period = cond(year < 1979, 1, cond(year < 1985, 2, 3))
label define period_lab 1 "1976-77" 2 "1979-84 (old codes)" 3 "1985-86 (new codes)"
label values period period_lab

sort new_code year
list new_code year code_label plants if inlist(year, 1977, 1979, 1984, 1985, 1986), sepby(new_code) noobs

tempfile tracker_long
save `tracker_long'

*-------------------------------------------------------------------------------
* 5a. Excel: one row per unit; for each round the code used and its plants.
*-------------------------------------------------------------------------------
keep new_code old_code parent_code basis linked_chosen n_chosen share_chosen strength year code_label plants
reshape wide code_label plants, i(new_code) j(year)
order new_code old_code parent_code strength share_chosen n_chosen linked_chosen basis code_label* plants*

label variable new_code      "Unit = code from 1985 (new numbering)"
label variable old_code      "Code 1979-84 (old numbering)"
label variable parent_code   "Code 1976-77 if the unit got its own code in 1979"
label variable strength      "Old-to-new mapping strength"
label variable share_chosen  "Share of linked old-code plants under the new code"
label variable n_chosen      "Linked plants under the new code"
label variable linked_chosen "Old-code plants seen again"
label variable basis         "Which round's links decided the new code"
foreach y of global tracker_rounds {
    label variable code_label`y' "Code `y'"
    label variable plants`y'     "Plants `y'"
}
list new_code old_code parent_code strength code_label1977 code_label1984 code_label1986, noobs

#d ;
export excel using "$tab/code_tracker_haryana_1976_86.xlsx",
    sheet("tracker") firstrow(varlabels) replace;
#d cr

*-------------------------------------------------------------------------------
* 5b. Chart: units (rows) by round (columns). The number is the code the unit
*     uses in that round; the circle size is the number of plants. Dashed lines
*     mark the 1979 district split and the 1985 renumbering.
*-------------------------------------------------------------------------------
use `tracker_long', clear
generate unit_row = 13 - new_code

* No circle is drawn for:
*   units still inside their parent code (1976-77), so the parent's plants
*   are not drawn twice;
*   1985, because that round is only partly switched: some plants are still
*   under old numbers, so plant counts by new code would be wrong.
generate plants_drawn = cond(in_parent | year == 1985, 0, plants)

* Row labels in plain words: "Old 12 = New 7". Codes whose plant links are
* weak (step 04) get "(less sure)".
forvalues u = 1/12 {
    quietly summarize old_code if new_code == `u', meanonly
    local old = r(mean)
    quietly levelsof strength if new_code == `u', local(str) clean
    local tag = cond("`str'" == "weak", " (less sure)", "")
    label define unit_lab `=13 - `u'' "Old `old' = New `u'`tag'", add
}
label values unit_row unit_lab

#d ;
twoway
    (scatter unit_row year [aweight = plants_drawn] if period == 1 & plants_drawn > 0, msymbol(circle) msize(*0.45) mcolor(gs12%60) mlcolor(gs8))
    (scatter unit_row year [aweight = plants_drawn] if period == 2 & plants_drawn > 0, msymbol(circle) msize(*0.45) mcolor(navy%35) mlcolor(navy))
    (scatter unit_row year [aweight = plants_drawn] if period == 3 & plants_drawn > 0, msymbol(circle) msize(*0.45) mcolor(orange%35) mlcolor(orange))
    (scatter unit_row year if year != 1985, msymbol(none) mlabel(code_label) mlabposition(0) mlabcolor(black) mlabsize(small))
    (scatter unit_row year if year == 1985, msymbol(none) mlabel(code_label) mlabposition(0) mlabcolor(gs9) mlabsize(small)),
    xline(1978, lpattern(dash) lcolor(gs8))
    xline(1984.5, lpattern(dash) lcolor(cranberry))
    xlabel($tracker_rounds, labsize(small))
    ylabel(1(1)12, valuelabel angle(0) labsize(small) nogrid)
    xtitle("Year of the ASI survey") ytitle("")
    title("Haryana: district numbers in the ASI, 1976-86", size(medium))
    subtitle("Each row is one district. The number is what ASI called it that year."
             "Bigger circle = more factories.", size(small) margin(b+2))
    note("1979 (grey line): two new districts get numbers 11 and 12."
         "Before that, 4* = still part of district 4, and 6* = still part of district 6."
         "1985 (red line): every district gets a new number; the districts themselves do not change."
         "1985 is shown in grey with no circles: that year some factories were still under their old number."
         "Checked two ways: same factories followed year to year, and same industries in each district.", size(vsmall))
    legend(order(1 "1976-77" 2 "1979-84 old numbers" 3 "1986 new numbers") rows(1) size(small) position(6))
    graphregion(color(white) margin(l+6 r+2)) plotregion(color(white))
    xsize(9) ysize(6.5);
#d cr

graph export "$fig/code_tracker_haryana_1976_86.pdf", replace

log close tracker
