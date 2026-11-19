*===============================================================================*
* PURPOSE
* File: 03_look_at_haryana_by_round.do
*
* Open the Haryana ASI data one survey round at a time, to look at it by hand.
* Nothing is saved. Run the preamble first, then select ONE block below and
* run only that block (select the lines, then Ctrl+D / Cmd+Shift+D). Each block
* loads one round, shows its size, the district codes used, the first 15
* returns, and opens the Data Browser.
* Unit: ASI return (one factory's report in one round).
* Years: 1974, 1976, 1977, 1979-1986 (team file); 1984-85 to 1989-90 (raw
*   files); 1993-1997.
* Inputs:
*   $data/asi_haryana_returns_1974_86.dta (01_extract_haryana_asi_1974_86.do)
*   $data/asi_haryana_raw_1984_90.dta     (01b_extract_haryana_raw_1984_90.do)
*   $data/asi_haryana_1993_97.dta         (01c_extract_haryana_asi_1993_97.do)
* Saves: nothing.
* Columns shown: rec_id = row key; fact_id / permid = plant number;
*   dist / distcode = ASI district code; nic = industry; worker / totwrkrs =
*   workers; weight = sampling weight. See haryana_manual_check/DATA_GUIDE.md.
*===============================================================================*

*===== A. Team file, rounds 1974-1986 ==========================================

*-------------------------------------------------------------------------------
* Round 1974-75, team file (no district detail: almost all returns under code 1)
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1974, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1976-77, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1976, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1977-78, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1977, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1979-80, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1979, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1980-81, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1980, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1981-82, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1981, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1982-83, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1982, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1983-84, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1983, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1984-85, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1984, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1985-86, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1985, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1986-87, team file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_returns_1974_86.dta" if year == 1986, clear
describe, short
tabulate dist
list rec_id fact_id dist nic_1970_4d worker weight dflt in 1/15, noobs abbreviate(10)
browse

*===== B. Raw ASI files, rounds 1984-85 to 1989-90 ============================

*-------------------------------------------------------------------------------
* Round 1984-85, raw file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_raw_1984_90.dta" if round_start == 1984, clear
describe, short
tabulate distcode
list rec_id permid distcode nic70 totwrkrs weight schcode in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1985-86, raw file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_raw_1984_90.dta" if round_start == 1985, clear
describe, short
tabulate distcode
list rec_id permid distcode nic70 totwrkrs weight schcode in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1986-87, raw file
*-------------------------------------------------------------------------------
use "$data/asi_haryana_raw_1984_90.dta" if round_start == 1986, clear
describe, short
tabulate distcode
list rec_id permid distcode nic70 totwrkrs weight schcode in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1987-88, raw file (no weight in this round)
*-------------------------------------------------------------------------------
use "$data/asi_haryana_raw_1984_90.dta" if round_start == 1987, clear
describe, short
tabulate distcode
list rec_id permid distcode nic70 totwrkrs weight schcode in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1988-89, raw file (no weight in this round)
*-------------------------------------------------------------------------------
use "$data/asi_haryana_raw_1984_90.dta" if round_start == 1988, clear
describe, short
tabulate distcode
list rec_id permid distcode nic70 totwrkrs weight schcode in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1989-90, raw file (state code 6 in this round)
*-------------------------------------------------------------------------------
use "$data/asi_haryana_raw_1984_90.dta" if round_start == 1989, clear
describe, short
tabulate distcode
list rec_id permid distcode nic87 totwrkrs weight schcode in 1/15, noobs abbreviate(10)
browse

*===== C. Rounds 1993-1997 ======================================================

*-------------------------------------------------------------------------------
* Round 1993
*-------------------------------------------------------------------------------
use "$data/asi_haryana_1993_97.dta" if year == 1993, clear
describe, short
tabulate dist
list rec_id fact_id dist nic87 totpersons weight statedistblk in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1994
*-------------------------------------------------------------------------------
use "$data/asi_haryana_1993_97.dta" if year == 1994, clear
describe, short
tabulate dist
list rec_id fact_id dist nic87 totpersons weight statedistblk in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1995
*-------------------------------------------------------------------------------
use "$data/asi_haryana_1993_97.dta" if year == 1995, clear
describe, short
tabulate dist
list rec_id fact_id dist nic87 totpersons weight statedistblk in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1996
*-------------------------------------------------------------------------------
use "$data/asi_haryana_1993_97.dta" if year == 1996, clear
describe, short
tabulate dist
list rec_id fact_id dist nic87 totpersons weight statedistblk in 1/15, noobs abbreviate(10)
browse

*-------------------------------------------------------------------------------
* Round 1997 (no district: statedistblk missing)
*-------------------------------------------------------------------------------
use "$data/asi_haryana_1993_97.dta" if year == 1997, clear
describe, short
tabulate dist
list rec_id fact_id dist nic87 totpersons weight statedistblk in 1/15, noobs abbreviate(10)
browse
