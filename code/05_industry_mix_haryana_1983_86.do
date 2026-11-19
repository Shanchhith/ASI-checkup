*===============================================================================*
* PURPOSE
* File: 05_industry_mix_haryana_1983_86.do
*
* Second check on the 1985 renumbering, using industry mix instead of plant
* links. Each district has its own mix of industries (e.g. many brick kilns in
* one, many metal-utensil plants in another). If old code 12 became new code 7,
* then code 12 in 1984 and code 7 in 1986 should have a similar industry mix.
* This check uses all plants in each round, not only plants linked by fact_id,
* so it does not depend on the plant IDs.
* Unit: district code x round (shares); old code x new code (similarity).
* Years: rounds 1983-84 to 1986-87 (labelled 1983-1986).
* Inputs:
*   $data/asi_haryana_returns_1974_86.dta (01_extract_haryana_asi_1974_86.do)
*   $data/asi_haryana_code_map_1984_86.dta (04_code_tracker_haryana_1976_86.do)
* Key steps:
*   1. Industry shares: for each code and round, the share of its plants in
*      each 3-digit NIC 1970 industry.
*   2. Fingerprint: the top 3 industries of each code in each round.
*   3. Similarity: for every old code (first round) and new code (second
*      round), overlap = sum over industries of the smaller of the two shares.
*      1 = identical mix, 0 = no industry in common.
*   4. Compare the best industry match with the plant-link mapping.
* Timing/identifiers:
*   1983 -> 1984 is a benchmark: no renumbering, so each code should match
*   itself. It shows how well industry mix can tell codes apart at all.
*   Plants are counted unweighted (one return = one plant), default sample
*   (dflt == 1), codes 1-12 only.
* Saves:
*   $tab/industry_mix_haryana_1983_86.xlsx
*   $logs/05_industry_mix_haryana_1983_86.log
*===============================================================================*

*-------------------------------------------------------------------------------
* Setup: round pairs compared (first round _ second round).
*   1983_1984: benchmark, same numbering in both rounds.
*   1984_1985: renumbering round, only partly switched.
*   1984_1986: renumbering complete.
*-------------------------------------------------------------------------------
global mix_pairs  "1983_1984 1984_1985 1984_1986"
global mix_rounds "1983 1984 1985 1986"

log using "$logs/05_industry_mix_haryana_1983_86.log", replace text name(mix)

*-------------------------------------------------------------------------------
* 1. Industry shares by code and round.
*    Count default-sample returns by round, code and 3-digit industry; share =
*    plants in the industry / all plants under the code that round.
*-------------------------------------------------------------------------------
use year dist nic_1970_3d dflt using "$data/asi_haryana_returns_1974_86.dta" if inrange(year, 1983, 1986), clear
keep if dflt == 1 & inrange(dist, 1, 12)
assert !missing(nic_1970_3d)

contract year dist nic_1970_3d, freq(plants)
bysort year dist: egen code_plants = total(plants)
generate share = plants / code_plants
isid year dist nic_1970_3d
tempfile shares
save `shares'

* Plants under each code in each round (used to show code size next to matches).
collapse (first) code_plants, by(year dist)
rename dist old_code
isid year old_code
tempfile sizes
save `sizes'

*-------------------------------------------------------------------------------
* 2. Fingerprint: top 3 industries per code and round, as "NIC (share%)".
*-------------------------------------------------------------------------------
use `shares', clear
gsort year dist -plants nic_1970_3d
by year dist: generate rank = _n
keep if rank <= 3
generate str16 top = string(nic_1970_3d) + " (" + string(round(100 * share)) + "%)"
keep year dist code_plants rank top
reshape wide top, i(year dist) j(rank)
rename dist code
order year code code_plants top1 top2 top3
sort year code
label variable code_plants "Plants under the code"
label variable top1 "Top industry (NIC 1970 3-digit, share)"
label variable top2 "2nd industry"
label variable top3 "3rd industry"

#d ;
export excel using "$tab/industry_mix_haryana_1983_86.xlsx",
    sheet("fingerprint") firstrow(varlabels) replace;
#d cr

*-------------------------------------------------------------------------------
* 3. Similarity of every old code (round a) with every new code (round b).
*    joinby pairs the two codes on each industry they share; the smaller of the
*    two shares is the part of the mix they have in common. Summing over
*    industries gives the overlap (0 to 1).
*-------------------------------------------------------------------------------
tempfile all_pairs
foreach p of global mix_pairs {
    local a = substr("`p'", 1, 4)
    local b = substr("`p'", 6, 4)

    use dist nic_1970_3d share year using `shares' if year == `a', clear
    keep dist nic_1970_3d share
    rename (dist share) (code_a share_a)
    tempfile shares_a
    save `shares_a'

    use dist nic_1970_3d share year using `shares' if year == `b', clear
    keep dist nic_1970_3d share
    rename (dist share) (code_b share_b)
    joinby nic_1970_3d using `shares_a'

    generate common = min(share_a, share_b)
    collapse (sum) overlap = common, by(code_a code_b)

    * Code pairs with no industry in common get overlap 0. All 12 x 12 pairs
    * must then be present (each code has plants in both rounds).
    fillin code_a code_b
    replace overlap = 0 if _fillin
    drop _fillin
    assert _N == 144
    isid code_a code_b

    generate str9 pair = "`p'"
    generate int year_a = `a'
    generate int year_b = `b'
    if "`p'" != word("$mix_pairs", 1) append using `all_pairs'
    save `all_pairs', replace
}

*-------------------------------------------------------------------------------
* 3a. Excel: one similarity matrix per pair (rows old code, columns new code).
*-------------------------------------------------------------------------------
foreach p of global mix_pairs {
    use code_a code_b overlap pair using `all_pairs' if pair == "`p'", clear
    drop pair
    replace overlap = round(overlap, 0.01)
    reshape wide overlap, i(code_a) j(code_b)
    rename overlap* new_*
    rename code_a old_code
    #d ;
    export excel using "$tab/industry_mix_haryana_1983_86.xlsx",
        sheet("overlap_`p'") firstrow(variables) sheetreplace;
    #d cr
}

*-------------------------------------------------------------------------------
* 4. Best industry match for each old code, and where the plant-link code
*    ranks. The plant-link code is the code itself for the 1983_1984
*    benchmark and the mapped new code (step 04) for the other pairs.
*-------------------------------------------------------------------------------
use `all_pairs', clear
rename code_a old_code
merge m:1 old_code using "$data/asi_haryana_code_map_1984_86.dta", keepusing(new_code strength) assert(match) nogenerate
generate link_code = cond(pair == "1983_1984", old_code, new_code)
drop new_code

* Rank new codes by overlap within each old code (1 = most similar).
gsort pair old_code -overlap code_b
by pair old_code: generate ind_rank = _n
by pair old_code: generate best_code      = code_b[1]
by pair old_code: generate best_overlap   = overlap[1]
by pair old_code: generate second_code    = code_b[2]
by pair old_code: generate second_overlap = overlap[2]

* Overlap and rank of the plant-link code.
generate link_rank_row    = ind_rank if code_b == link_code
generate link_overlap_row = overlap  if code_b == link_code
by pair old_code: egen link_rank    = max(link_rank_row)
by pair old_code: egen link_overlap = max(link_overlap_row)
assert !missing(link_rank, link_overlap)

by pair old_code: keep if _n == 1
generate byte agree = link_rank == 1
* Gap between the best and the 2nd-best match: a small gap means industry mix
* cannot separate the two codes well.
generate gap = best_overlap - second_overlap

* Code size in round a, so small codes can be read with care. Many-to-one:
* two pairs (1984_1985, 1984_1986) start in the same round. Every code has
* plants in round a, so all rows must match.
generate int year = year_a
merge m:1 year old_code using `sizes', keep(master match) assert(match using) nogenerate keepusing(code_plants)
rename code_plants plants_a
drop year
keep pair old_code plants_a link_code strength link_rank link_overlap best_code best_overlap second_code second_overlap gap agree
isid pair old_code
sort pair old_code
foreach v of varlist link_overlap best_overlap second_overlap gap {
    replace `v' = round(`v', 0.01)
}

label variable pair           "Rounds compared"
label variable old_code       "Code in first round"
label variable plants_a       "Plants under the code, first round"
label variable link_code      "Code from plant links (benchmark: same code)"
label variable strength       "Plant-link strength (step 04)"
label variable link_rank      "Industry rank of the plant-link code (1 = best)"
label variable link_overlap   "Overlap with the plant-link code"
label variable best_code      "Best industry match"
label variable best_overlap   "Overlap with best match"
label variable second_code    "2nd best industry match"
label variable second_overlap "Overlap with 2nd best"
label variable gap            "Best minus 2nd best overlap"
label variable agree          "1 = industry and plant links agree"

list pair old_code plants_a link_code link_rank link_overlap best_code best_overlap gap, sepby(pair) noobs abbreviate(12)
table pair, statistic(sum agree) statistic(count agree)

#d ;
export excel using "$tab/industry_mix_haryana_1983_86.xlsx",
    sheet("check") firstrow(varlabels) sheetreplace;
#d cr

log close mix
