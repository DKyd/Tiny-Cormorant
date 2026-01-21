# Bugfix Job

## Metadata (Required)
- Issue/Task ID: Issue-0059
- Short Title: Fix typed-GDScript Variant inference warnings in Galaxy influences
- Run Folder Name: issue-0059-bug-galaxy-variant-inference
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-01-21

---

## Bug Description
Godot reports parser errors (warnings treated as errors) in `Galaxy.gd` where local variables in `_build_base_influences()` have their types inferred from `Variant`-returning expressions. This blocks running the game or exporting when warnings-as-errors is enabled.

---

## Expected Behavior
The project should parse and run without typed inference warnings in `Galaxy.gd`, and no warnings should be treated as errors during parsing/export.

---

## Repro Steps
1. Enable (or keep enabled) “warnings treated as errors” in the Godot project settings (as currently configured).
2. Open or run the project.
3. Observe parser error(s) pointing at `Galaxy.gd` in `_build_base_influences()`.

---

## Observed Output / Error Text
- “The variable type is being inferred from a Variant value, so it will be typed as Variant. (Warning treated as error.)”

(Seen at/around `_build_base_influences()` for `roll`, `cartel_weight`, and `government_weight`.)

---

## Suspected Area (Optional)
- `singletons/Galaxy.gd` — `_build_base_influences()`

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.
- Do not change the logic/threshold behavior of influence generation; only address typing to satisfy the parser.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `singletons/Galaxy.gd`

Codex must restate this whitelist verbatim before making any code changes.

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

---

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ] Project parses and runs with “warnings treated as errors” enabled.
- [ ] No “Variant inference” warnings remain in `_build_base_influences()` for `roll`, `cartel_weight`, or `government_weight`.
- [ ] Influence generation behavior remains unchanged (no functional differences beyond typing).

---

## Regression Checks
List behaviors that must still work after the fix.

- Black market availability gating via `GameState.location_has_black_market(location_id)` behaves the same across reloads for the same locations.
- Port header still renders the org presence summary (Issue-0058) without crashes or missing text.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Run the project (or open the main scene) with “warnings treated as errors” enabled; confirm no parser errors occur.
2. Visit at least two different locations and open Port; confirm the org presence line renders.
3. Visit a location with no black market and a location with a black market (if available in current world); confirm Cantina Back Room gating still behaves correctly.

---

## Codex Scaffolding & Output Requirements (Mandatory)

Codex must perform the following before any code changes:

1) Create `codex/runs/issue-0059-bug-galaxy-variant-inference/`
2) Write this job verbatim to `codex/runs/issue-0059-bug-galaxy-variant-inference/job.md`
3) Create `codex/runs/issue-0059-bug-galaxy-variant-inference/results.md` if missing
4) Write `codex/runs/ACTIVE_RUN.txt` = `issue-0059-bug-galaxy-variant-inference`

Codex must STOP after scaffolding and await human approval before implementation.

Codex must write final results only to:
- `codex/runs/issue-0059-bug-galaxy-variant-inference/results.md`

Results must include:
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups
