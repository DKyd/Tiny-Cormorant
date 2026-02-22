# Refactor Job

## Metadata (Required)
- Issue/Task ID: issue-0101
- Short Title: Extract freight doc rules and customs report formatting from GameState
- Run Folder Name: issue-0101-extract-doc-rules-and-customs-report-formatting
- Job Type: refactor
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Goal
Reduce `GameState.gd` scope and coupling by extracting:
- freight document schema/rules + surface validation helpers
- customs report/log formatting helpers (including Level-2 snippet formatting)
into dedicated pure modules.
No behavior change; only structure and call-site redirection.

---

## Non-Goals
- No gameplay changes.
- No feature additions.
- No behavior changes beyond structure/readability.

---

## Invariants (Must Remain True)
- Time advances only via `GameState.advance_time(reason)`.
- Docked UI interactions do not advance time.
- GameState remains authoritative for transitions.
- UI does not mutate state directly.
- Economy determinism remains keyed by `(system_id, tick, market_kind)`.

Job-specific invariants:
- Freight document dict shapes and required fields remain unchanged.
- Surface validation outcomes (ok/issues arrays, codes/messages/paths) remain unchanged.
- Customs inspection report formatting strings remain unchanged (including Level-2 snippets and truncation).
- Save/load format remains unchanged (no new saved fields, no migrations).
- No changes to customs roll seeds, pressure buckets, or depth resolution.

---

## Scope

### Files Allowed to Modify (Whitelist)
- `res://singletons/GameState.gd`
- `res://scripts/freight/FreightDocRules.gd` (new)
- `res://scripts/customs/CustomsReportFormatter.gd` (new)

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Extract freight doc “codified rules” and validation helpers from `GameState.gd` into `FreightDocRules.gd`.
   - Move constants: `SURFACE_COMPLIANCE_RULES`, `SURFACE_ACTION_REQUIREMENTS`
   - Move functions: `validate_freight_doc_surface`, `validate_freight_docs_for_action`, `validate_action_surface_compliance`
   - Move only the helpers these functions depend on (`_validate_*`, `_append_surface_issue`, `_is_non_empty_string`, etc).
   - Maintain identical output dictionaries and issue list ordering.

2) Extract customs report/log formatting helpers from `GameState.gd` into `CustomsReportFormatter.gd`.
   - Move functions: `_format_customs_log_entry`, `_format_level2_log_snippet`, `_build_level2_invariant_log_summary`
   - Move dependent helpers used exclusively for formatting/sorting/trimming (`_trim_for_customs_log`, `_normalize_customs_classification`, sort helpers, etc).
   - Preserve exact string output and truncation behavior.

3) Update `GameState.gd` call sites to use the new modules.
   - Replace internal calls with `FreightDocRules.*` and `CustomsReportFormatter.*`
   - Keep method signatures stable at call sites (pass in required data explicitly; no hidden singleton state).

4) Fix minor hygiene if encountered during refactor (still “no behavior change”):
   - Add trailing newline to `codex/runs/ACTIVE_RUN.txt` if it lacks one (allowed as part of refactor run artifacts only).

---

## Verification

### Manual Test Steps
1. Start a new run; dock at a location; accept a contract; confirm freight doc creation log still reads identically.
2. Buy goods (legal market) to generate a purchase order; sell goods to generate bill of sale; confirm logs remain identical and no crashes occur.
3. Trigger a customs inspection (entry/departure/sale) and confirm the printed CUSTOMS log line matches pre-refactor formatting, including Level-2 snippet if depth >= 2.

### Regression Checklist
- [ ] No UI action advances time
- [ ] No state mutation moved into UI
- [ ] Logs still reflect real player actions
- [ ] No protected paths touched

---

## Git Preflight Gate (Mandatory)
Before ANY code changes, Codex must run and report:

- `git branch --show-current`
- `git status --short`
- `git log --oneline -n 5 --decorate`
- `git show HEAD:codex/runs/ACTIVE_RUN.txt`
- `git fetch origin`
- `git status -sb`
- Preferred wrapper: `powershell -ExecutionPolicy Bypass -File codex/tools/git_gates.ps1 -Mode Preflight`

Rules:
- If `git status --short` is not empty (modified OR untracked files), Codex MUST STOP and ask the user to choose ONE:
  A) Stash WIP (must include untracked): `git stash push -u -m "wip: <short description>"`
  B) Run the current issue’s Closeout Gate (stage ? staged diff review ? commit ? push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/<Run Folder Name>/**`
  - Whitelisted files for this job
- Then show:
  - `git diff --stat --staged`
  - `git diff --staged`
- Show staged diffs, then auto-closeout unless a gate violation is detected.
- STOP and request user input only if a gate violation or ambiguity is detected.

2) Closeout Gate (Commit + Push)
- If all gates pass and the staged set is whitelist-clean, Codex MUST auto-run closeout immediately (no explicit approval required).
- STOP conditions (user input required):
  - Working tree is dirty.
  - Branch is behind origin.
  - Staged set includes files outside ACTIVE_RUN.txt, codex/runs/<Run Folder Name>/**, or job whitelist.
  - Scope/whitelist/blacklist conflict or ambiguous instruction.
- Run:
  - `git commit -m "issue-0101: Extract freight doc rules and customs report formatting from GameState"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/<Run Folder Name>/`
2) Write this job verbatim to `codex/runs/<Run Folder Name>/job.md`
3) Create `codex/runs/<Run Folder Name>/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `<Run Folder Name>`

Codex must write final results only to:
- `codex/runs/<Run Folder Name>/results.md`

Results must include:
- Summary of refactor
- Files changed
- Manual test results
- Confirmation behavior is unchanged
- Follow-ups / known gaps (if any)

---

## Migration Notes
None.

---

## Logging Checklist
- [ ] No debug spam added
- [ ] No meaningful logs removed
- [ ] `print()` removed or debug-only
- [ ] Log volume appropriate