# Refactor Job

## Metadata (Required)
- Issue/Task ID: issue-0096
- Short Title: Centralize inspection max-depth resolution (incl. depth_bias) and unify call sites
- Run Folder Name: issue-0096-centralize-inspection-max-depth-resolution
- Job Type: refactor
- Author (human): Douglass Kyd
- Date: 2026-02-22

---

## Goal
Centralize the logic that resolves Customs inspection `max_depth` (including the deterministic `depth_bias` from issue-0095) into a single authoritative code path, and update all Customs inspection entry points to use it. This prevents drift between “preview” and “actual” depth selection and keeps the API boundary clean.

No behavior change.

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
- Inspection depth remains deterministic for identical `(system_id, location_id, tick)` inputs.
- “Heightened scrutiny” log line occurs at most once per triggered inspection (no duplication).

---

## Scope

### Files Allowed to Modify (Whitelist)
- `res://singletons/GameState.gd`
- `res://singletons/Customs.gd`

### Files Forbidden to Modify (Blacklist)
- `data/**`
- `scenes/MainGame.tscn`

---

## Approach (High Level)
1) Consolidate max-depth resolution (including preview validation + clamp + depth_bias) into one authoritative helper (preferably in `GameState`, or in `Customs` if already the sole consumer, but only one public/usable entry point).
2) Update all Customs inspection entry points (`run_entry_check`, `run_departure_check`, `run_sale_check`, and any other inspection triggers found in whitelist files) to use the consolidated helper instead of re-deriving depth.
3) Preserve behavior equivalence by ensuring the resolved `max_depth` value and the “heightened scrutiny” log emission conditions match current behavior (same inputs → same depth; same logging frequency; no new randomness).

---

## Verification

### Manual Test Steps
1. Trigger each known Customs inspection path (entry, departure, sale) in a scenario with no recent L2 violations and confirm `max_depth` behavior matches pre-refactor (and no heightened scrutiny log appears).
2. Create a recent Level-2 invariant violation at a location, then trigger the same inspection paths within the window and confirm:
   - resolved `max_depth` matches pre-refactor behavior
   - heightened scrutiny log appears once per triggered inspection (not duplicated)

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
  B) Run the current issue's Closeout Gate (stage → staged diff review → commit → push)
- If `git status -sb` shows the branch is behind origin (e.g. `[behind N]`), Codex MUST STOP and instruct `git pull --ff-only` (or stash-or-closeout first if the tree is dirty).
- Codex must not proceed with any implementation until the working tree is clean AND the branch is not behind origin.

## Git Postflight & Closeout Gate (Mandatory)
After implementation is complete, Codex must perform these gates in order:

1) Review Gate (Staged Diff)
- Stage ONLY:
  - `codex/runs/ACTIVE_RUN.txt`
  - `codex/runs/issue-0096-centralize-inspection-max-depth-resolution/**`
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
  - `git commit -m "issue-0096: Centralize inspection max-depth resolution (incl. depth_bias)"`
  - `git push --porcelain`
- Then show proof:
  - `git log --oneline -n 3`
  - `git show HEAD:codex/runs/ACTIVE_RUN.txt`
  - `git status --short` (must be clean)
- STOP.

---
## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0096-centralize-inspection-max-depth-resolution/`
2) Write this job verbatim to `codex/runs/issue-0096-centralize-inspection-max-depth-resolution/job.md`
3) Create `codex/runs/issue-0096-centralize-inspection-max-depth-resolution/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0096-centralize-inspection-max-depth-resolution`

Codex must write final results only to:
- `codex/runs/issue-0096-centralize-inspection-max-depth-resolution/results.md`

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
