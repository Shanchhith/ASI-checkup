*===============================================================================*
* PURPOSE
* File: 02_trace_haryana_codes_1974_86.do
*
* Step 1: trace every Haryana ASI district code through the panel by following
* the same plants (fact_id) from one round to the next. A code that keeps its
* meaning keeps most of its plants; a break shows up as plants moving to other
* codes. At the 1985 renumbering this also gives the old-to-new code mapping.
* Unit: plant-round for the links; tables are code-round and code-by-code.
* Years: survey rounds 1974, 1976, 1977, 1979-1986 (no 1975 or 1978 round in
*   the team file). "Next round" means the next round that exists.
* Inputs:
*   $data/asi_haryana_returns_1974_86.dta (from 01_extract_haryana_asi_1974_86.do)
* Key steps:
*   1. Build a plant-round panel (default sample, one row per fact_id-round).
*   2. Returns by code and round.
*   3. For every code and round: plants seen again next round, share still under
*      the same code, and the code most of them moved to.
*   4. Full code-to-code tables for the rounds around the breaks.
*   5. Old-to-new mapping: where the 1984 plants of each code are in 1985 and 1986.
* Sample: default ASI sample (dflt = 1, manufacturing). Returns that share a
*   plant ID within a round (63 pairs, 126 returns) cannot be linked one-to-one
*   and are left out of the links; they are counted in the log.
* Saves:
*   $data/asi_haryana_plant_round_1974_86.dta (plant-round panel; key fact_id year)
*   $tab/trace_haryana_codes_1974_86.xlsx
*   $logs/02_trace_haryana_codes_1974_86.log
*===============================================================================*

*-------------------------------------------------------------------------------
* Setup: round pairs for full code-to-code tables (from_to), and the rounds
* after the 1985 renumbering used for the old-to-new mapping.
*   1977_1979: Faridabad district made in 1979; codes 11 and 12 first appear.
*   1984_1985, 1984_1986, 1985_1986: the renumbering.
*-------------------------------------------------------------------------------
global trace_pairs      "1977_1979 1983_1984 1984_1985 1984_1986 1985_1986"
global trace_new_rounds "1985 1986"

log using "$logs/02_trace_haryana_codes_1974_86.log", replace text name(trace)

*-------------------------------------------------------------------------------
* 1. Plant-round panel.
*    Keep the default sample, drop returns whose plant ID is repeated in the
*    same round (they cannot be told apart), and number the rounds in order.
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta", clear
keep if dflt == 1

duplicates tag fact_id year, generate(dup_in_sample)
count if dup_in_sample > 0
assert r(N) == 126
drop if dup_in_sample > 0

keep fact_id year dist
isid fact_id year
egen round = group(year)
label variable round "Survey round in order (1 = 1974, 2 = 1976, 3 = 1977, ...)"

* Save the panel: the tracker (04_code_tracker_haryana_1976_86.do) uses it too.
sort fact_id year
cf * using "$data/asi_haryana_plant_round_1974_86.dta"
save "$data/asi_haryana_plant_round_1974_86.dta", replace

tempfile panel
save `panel'

*-------------------------------------------------------------------------------
* 2. Returns by code (rows) and round (columns), all codes.
*-------------------------------------------------------------------------------
use `panel', clear
contract dist year, freq(plants)
reshape wide plants, i(dist) j(year)
mvencode plants*, mv(0)
list, noobs abbreviate(10)

#d ;
export excel using "$tab/trace_haryana_codes_1974_86.xlsx",
    sheet("plants_by_code_round") firstrow(variables) replace;
#d cr

*-------------------------------------------------------------------------------
* 3. Next-round links. Each plant in round t is matched by fact_id to round t+1.
*    _merge 1: not in the next round (closed, not sampled, or last round 1986).
*    _merge 2: plant new in the next round; not needed here and dropped.
*    _merge 3: plant in both rounds; these are the links.
*-------------------------------------------------------------------------------
use `panel', clear
rename (year dist round) (year_to dist_to round_to)
tempfile panel_next
save `panel_next'

use `panel', clear
rename (year dist) (year_from dist_from)
generate round_to = round + 1
drop round
merge 1:1 fact_id round_to using `panel_next'
drop if _merge == 2
keep if year_from < 1986
generate byte linked    = _merge == 3
generate byte same_code = linked & dist_to == dist_from
drop _merge

* Next round's year, for labelling (the same for all links from a round).
bysort year_from: egen year_next = max(year_to)

tempfile links
save `links'

* 3a. Most common destination code of each code's linked plants.
keep if linked
contract year_from dist_from dist_to, freq(plants_to_top)
gsort year_from dist_from -plants_to_top dist_to
by year_from dist_from: keep if _n == 1
rename dist_to top_dest
tempfile top_dest
save `top_dest'

* 3b. One row per code and round: plants, links, share staying, top destination.
use `links', clear
collapse (count) plants = fact_id (sum) linked same_code (max) year_next, by(year_from dist_from)
merge 1:1 year_from dist_from using `top_dest'
assert _merge != 2
drop _merge
generate share_linked = linked / plants
generate share_stay   = same_code / linked
generate share_top    = plants_to_top / linked
format share_* %4.2f

label variable plants        "Plants under the code this round"
label variable linked        "Of these, seen again next round"
label variable same_code     "Seen again and still under the same code"
label variable share_stay    "Share of linked plants still under the same code"
label variable top_dest      "Code most linked plants are under next round"
label variable plants_to_top "Linked plants under that code"
label variable share_top     "Share of linked plants under that code"

order dist_from year_from year_next plants linked share_linked same_code share_stay top_dest plants_to_top share_top
sort dist_from year_from

* Overview for the log: share staying, code by round (round = from-round).
table (dist_from) (year_from) if linked >= 5, statistic(mean share_stay) nformat(%4.2f) nototals

#d ;
list dist_from year_from year_next plants linked same_code share_stay top_dest share_top,
    sepby(dist_from) noobs abbreviate(10);
export excel using "$tab/trace_haryana_codes_1974_86.xlsx",
    sheet("stay_next_round", replace) firstrow(varlabels);
#d cr

*-------------------------------------------------------------------------------
* 4. Full code-to-code tables for the round pairs in $trace_pairs.
*    Rows: code in the first round. Columns: code in the second round.
*    Cells: plants seen in both rounds. Only plants in both rounds are used.
*-------------------------------------------------------------------------------
foreach p of global trace_pairs {
    local a = substr("`p'", 1, 4)
    local b = substr("`p'", 6, 4)

    use fact_id dist year using `panel' if year == `b', clear
    drop year
    rename dist dist_`b'
    tempfile in_b
    save `in_b'

    use fact_id dist year using `panel' if year == `a', clear
    drop year
    rename dist dist_`a'
    merge 1:1 fact_id using `in_b', keep(match) nogenerate

    display _n "Plants in both `a' and `b': rows = code in `a', columns = code in `b'"
    tabulate dist_`a' dist_`b'

    contract dist_`a' dist_`b', freq(n)
    reshape wide n, i(dist_`a') j(dist_`b')
    mvencode n*, mv(0)
    export excel using "$tab/trace_haryana_codes_1974_86.xlsx", sheet("moves_`a'_`b'", replace) firstrow(variables)
}

*-------------------------------------------------------------------------------
* 5. Old-to-new mapping. For each code in 1984, the code where most of its
*    plants are found in each round of $trace_new_rounds, and that share.
*-------------------------------------------------------------------------------
use dist year using `panel' if year == 1984, clear
drop year
contract dist, freq(plants_1984)
rename dist dist_1984
tempfile old_to_new
save `old_to_new'

foreach b of global trace_new_rounds {
    use fact_id dist year using `panel' if year == `b', clear
    drop year
    rename dist dist_new
    tempfile in_new
    save `in_new'

    use fact_id dist year using `panel' if year == 1984, clear
    drop year
    rename dist dist_1984
    merge 1:1 fact_id using `in_new', keep(match) nogenerate

    * Linked plants per old code, then the most common new code and its share.
    contract dist_1984 dist_new, freq(n)
    bysort dist_1984: egen linked_`b' = total(n)
    gsort dist_1984 -n dist_new
    by dist_1984: keep if _n == 1
    rename (dist_new n) (to_code_`b' to_plants_`b')
    generate share_`b' = to_plants_`b' / linked_`b'
    format share_`b' %4.2f
    label variable linked_`b'  "1984 plants seen again in `b'"
    label variable to_code_`b' "Code most of them are under in `b'"
    label variable share_`b'   "Share under that code in `b'"

    merge 1:1 dist_1984 using `old_to_new'
    assert _merge != 1
    drop _merge
    save `old_to_new', replace
}

use `old_to_new', clear
sort dist_1984
label variable dist_1984   "Code in 1984 (old numbering)"
label variable plants_1984 "Plants under the code in 1984"
list, noobs abbreviate(12)

#d ;
export excel using "$tab/trace_haryana_codes_1974_86.xlsx",
    sheet("old_to_new", replace) firstrow(varlabels);
#d cr

log close trace
