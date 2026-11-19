# ASI checkup

What each ASI district code means, for Haryana first, using only ASI data (no census). The ASI (Annual Survey of Industries) gives district codes but no district names, and the codes changed meaning in 1985 and again around 1990-93.

## Folders

| Folder | What | In git? |
|---|---|---|
| `code/` | Stata do-files | yes |
| `docs/` | One note per step: what was found, and what to check by hand | yes |
| `data/` | Haryana extracts made by the code | **no**: ASI microdata is confidential |
| `output/tab/`, `output/logs/` | Excel tables and Stata logs | **no** |

## How to run

1. Open Stata (version 18).
2. Run the preamble: `do "/Users/shanchhithsinghnayak/Dropbox/Indian District hb/ASI checkup/code/00_preamble.do"`.
3. In the same session, run all steps with `do "$code/00_master.do"`.
4. To look at the data: open `code/03_look_at_haryana_by_round.do` in the Do-file Editor, select one block (one round) and run only that block.

The preamble is the only file that sets paths. A new user adds their own block there.

### Where the data is

- **Raw ASI data is not in this repo.** The code reads it straight from the shared Dropbox folders listed under "Inputs" below. Nothing is copied, and those folders are never written to.
- **The Haryana extracts are made by the code.** They go to `data/` and `output/` inside your own copy of this repo, and git ignores both.

### First run on a new computer

1. **Clone the repo anywhere.**
2. **Add your block in `code/00_preamble.do`:** copy the existing `if "`c(username)'" == ...` block and set two paths:
   - `root`: where you cloned this repo;
   - `dropbox`: your Dropbox folder, the one that holds `india_labor` and `ASI DATA`.
3. **Make sure the input files are downloaded.** Dropbox may keep them online-only; open each input file once, or mark the folders "Available offline".
4. **Create the saved datasets once.** Each step checks its dataset against the last saved copy (`cf`) before replacing it. On the very first run there is no saved copy, so that check stops with an error.
   - For each step, run it without the `cf` line and save once.
   - After that, run normally with `00_master.do`.

## Inputs (all read-only, never changed)

| File | Rounds | Where |
|---|---|---|
| `ida_U.dta`, the team's cleaned ASI plant file | 1974-86 | `~/Dropbox/india_labor/ida_effects/data/` |
| raw ASI files `as84fbm1.TXT` ... `as89fbm1.TXT` with dictionaries `in8485.dic` ... | 1984-85 to 1989-90 | `~/Dropbox/ASI DATA/TO_DELETE/asi_check_permid/adrien/` |
| `asi_93_97.dta` | 1993-97 | `~/Dropbox/ASI DATA/asi_1992_1997/data/` |

## Files

| File | What it does | Saves |
|---|---|---|
| `code/00_preamble.do` | all paths; run first | |
| `code/00_master.do` | runs 01, 01b, 01c, 02, 04, 05 in order | |
| `code/01_extract_haryana_asi_1974_86.do` | Haryana returns from the team file | `data/asi_haryana_returns_1974_86.dta` |
| `code/01b_extract_haryana_raw_1984_90.do` | Haryana returns from the raw 1984-90 files | `data/asi_haryana_raw_1984_90.dta` |
| `code/01c_extract_haryana_asi_1993_97.do` | Haryana returns 1993-97 | `data/asi_haryana_1993_97.dta` |
| `code/02_trace_haryana_codes_1974_86.do` | Step 1: follow plants round to round, for every code | `data/asi_haryana_plant_round_1974_86.dta`, `output/tab/trace_haryana_codes_1974_86.xlsx` |
| `code/04_code_tracker_haryana_1976_86.do` | Code tracker: code used by each unit in each round, table and chart | `data/asi_haryana_code_map_1984_86.dta`, `output/tab/code_tracker_haryana_1976_86.xlsx`, `output/fig/code_tracker_haryana_1976_86.pdf` |
| `code/05_industry_mix_haryana_1983_86.do` | Second check on the 1985 renumbering: compares the industry mix of old and new codes (no plant IDs needed) | `output/tab/industry_mix_haryana_1983_86.xlsx` |
| `code/03_look_at_haryana_by_round.do` | open one round at a time to look by hand (run block by block) | nothing |

## Notes per step

- `docs/step1_trace_haryana_codes.md`
- `docs/code_tracker_haryana.md`
- `docs/step2_industry_mix_haryana.md`

## Rules

Stata code follows Kotia's stata-style guide. In short:
- every path global is in `00_preamble.do`;
- every do-file starts with a `PURPOSE` header;
- a saved dataset is checked with `cf` before `save, replace`;
- graphs are saved as PDF only.
