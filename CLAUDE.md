# ASI checkup: instructions for coding agents

- **Stata only.** Before writing, editing, reviewing or running any Stata code, read `~/.claude/skills/stata-style/SKILL.md` and `~/.claude/skills/stata-style/references/STATA_STYLE.md` in full and follow them.
- **Paths:** every path global lives in `code/00_preamble.do` and nowhere else.
- **Read-only inputs:** `~/Dropbox/india_labor` and `~/Dropbox/ASI DATA` are shared folders. Read them, never write to them.
- **No data in git:** never commit `data/`, `output/`, `.dta`, `.csv`, `.xlsx` or logs. ASI microdata is confidential.
- **Go one step at a time:** the user checks each step by hand before the next. Every step gets a do-file and a note in `docs/` with what was found and a short "for you to check" list.
- **Style of notes:** simple Indian English, short sentences, numbers from the log.
- **ASI only:** match district codes with ASI data and district history (dates of district creation), not census data.
