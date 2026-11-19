*===============================================================================*
* PURPOSE
* File: 00_master.do
*
* Run the ASI checkup steps in order: Haryana extract, then each matching step.
* Unit: Not applicable (runs the child do-files).
* Years: rounds 1974-75 to 1997-98.
* Inputs: see each child file.
* Key steps:
*   01.  Keep Haryana returns from the team ASI file (1974-86).
*   01b. Read the raw ASI files 1984-85 to 1989-90 and keep Haryana.
*   01c. Keep Haryana returns from the 1993-97 ASI file.
*   02. Step 1: trace every Haryana district code by following the same plants.
*   04. Code tracker: one table and one chart of the code each unit uses.
*   05. Industry mix: second check on the 1985 renumbering, without plant IDs.
* Saves:
*   $data/asi_haryana_returns_1974_86.dta (01)
*   $data/asi_haryana_raw_1984_90.dta (01b)
*   $data/asi_haryana_1993_97.dta (01c)
*   $data/asi_haryana_plant_round_1974_86.dta and $tab/trace_haryana_codes_1974_86.xlsx (02)
*   $data/asi_haryana_code_map_1984_86.dta, $tab/code_tracker_haryana_1976_86.xlsx
*     and $fig/code_tracker_haryana_1976_86.pdf (04)
*   $tab/industry_mix_haryana_1983_86.xlsx (05)
* How to run: in Stata, first run code/00_preamble.do, then this file, in the
* same session. 03_look_at_haryana_by_round.do is not run here: it is for
* looking at the data by hand, one block at a time.
*===============================================================================*

do "$code/01_extract_haryana_asi_1974_86.do"
do "$code/01b_extract_haryana_raw_1984_90.do"
do "$code/01c_extract_haryana_asi_1993_97.do"
do "$code/02_trace_haryana_codes_1974_86.do"
do "$code/04_code_tracker_haryana_1976_86.do"
do "$code/05_industry_mix_haryana_1983_86.do"
