*===============================================================================*
* PURPOSE
* File: 00_preamble.do
*
* Set up a Stata session for the ASI checkup project: Stata version, path
* globals for every folder the code reads or writes, and the output folders.
* Unit: Not applicable (session setup).
* Years: Not applicable.
* Inputs: none.
* Key steps:
*   1. Reset the session and fix the Stata version.
*   2. Detect the user and set the project root and the shared data folder.
*   3. Define all other path globals from those two roots.
*   4. Create the data and output folders if they do not exist yet.
* Saves: nothing.
* Run this file once at the start of every Stata session, then run the
* step do-files in the same session.
*===============================================================================*

clear all
set more off
version 18

*-------------------------------------------------------------------------------
* 1. Roots. Add a block for each new user; any other user stops with an error
*    so no code ever runs against a wrong path.
*-------------------------------------------------------------------------------
if "`c(username)'" == "shanchhithsinghnayak" {
    global root    "/Users/shanchhithsinghnayak/Dropbox/Indian District hb/ASI checkup"
    global dropbox "/Users/shanchhithsinghnayak/Dropbox"
}
else {
    display as error "Unknown user `c(username)': add your roots to code/00_preamble.do"
    exit 198
}

*-------------------------------------------------------------------------------
* 2. All path globals, defined only here.
*    raw_ida:  the team's cleaned ASI plant file (shared folder, read-only).
*    raw_8490: raw ASI files 1984-85 to 1989-90 with Stata dictionaries
*              (shared folder ASI DATA, read-only).
*    raw_9397: ASI plant file 1993-97 (shared folder ASI DATA, read-only).
*    data:     Haryana extracts made by this project (kept out of git).
*    tab:      Excel tables; fig: PDF charts; logs: Stata logs (kept out of git).
*-------------------------------------------------------------------------------
global code     "$root/code"
global data     "$root/data"
global out      "$root/output"
global tab      "$root/output/tab"
global logs     "$root/output/logs"
global fig      "$root/output/fig"
global raw_ida  "$dropbox/india_labor/ida_effects/data"
global raw_8490 "$dropbox/ASI DATA/TO_DELETE/asi_check_permid/adrien"
global raw_9397 "$dropbox/ASI DATA/asi_1992_1997/data"

*-------------------------------------------------------------------------------
* 3. Create the project's own data and output folders when missing.
*    direxists() returns 1 when the folder is already there.
*-------------------------------------------------------------------------------
foreach d in "$data" "$out" "$tab" "$fig" "$logs" {
    mata: st_local("exists", strofreal(direxists(`"`d'"')))
    if `exists' == 0 mkdir `"`d'"'
}
