# Bugfix Job

## Metadata (Required)
- Issue/Task ID: issue-0086
- Short Title: Dock button error — triage, root cause, and fix
- Run Folder Name: issue-0086-bug-dock-button-error
- Job Type: bugfix
- Author (human): Douglass Kyd
- Date: 2026-02-21

---

## Bug Description
Pressing the Dock button sometimes (or always) triggers an error and/or fails to dock correctly.
This is a regression-blocking bug affecting the dock ? Port flow.

Observable symptoms may include:
- Godot error in Output when Dock is pressed
- Dock action does nothing / does not transition UI
- Dock action transitions but leaves state inconsistent (e.g., still “in space”)

(Exact error text will be added below when available.)

---

## Expected Behavior
When the player presses Dock while at a valid dockable location:
- The dock action completes without errors.
- GameState transitions to docked state consistently.
- The UI transitions to the docked/Port interface as designed.
- Docked UI interactions do not advance time.

---

## Repro Steps
Provide the minimal steps required to reproduce the issue reliably.

1. Start game and load into MainGame.
2. Navigate to a system/location where Dock is available.
3. Press Dock.
4. Observe output/errors and whether docking + UI transition occur.

(If repro is conditional, Codex must discover and document the condition(s) in results.md.)

---

## Observed Output / Error Text
TBD — Codex must locate any relevant error logs, printed errors, or UI messages related to Dock flow.

Codex must:
- Search the repo for log strings / error text that match “Dock”, “dock”, “docked”, “Port”, “undock”.
- Identify where Dock errors would surface (Godot Output, Log.gd categories, etc.)
- Document findings in results.md.

---

## Suspected Area (Optional)
Likely involved systems (hint only):
- Dock button signal handler (Bridge UI / MainGame UI)
- GameState docking transition method(s)
- Port scene embedding / transition logic
- Node paths for Dock button or Port container

---

## Scope Constraints
- Changes are limited strictly to fixing the described bug.
- No refactors, cleanup, stylistic changes, or redesigns.
- No new features may be introduced.
- No scene layout changes unless they are required to fix a broken node path / signal connection causing Dock to error.

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `scripts/MainGame.gd`
- `scripts/Bridge.gd`            # if Dock button lives here / signal handler is here
- `scripts/Port.gd`              # only if Dock flow references Port incorrectly
- `singletons/GameState.gd`
- `singletons/Customs.gd`        # only if Dock triggers clearance checks and is failing there
- `singletons/Log.gd`            # only if required to repair an existing logging call (no new logging features)

(If Codex needs different files, it must STOP and justify in results.md why the current whitelist is insufficient.)

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `data/**`
- `scenes/MainGame.tscn`

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:

-
-

---

## Acceptance Criteria (Must Be Testable)
All items must pass for the fix to be considered complete.

- [ ] Pressing Dock at a valid dockable location produces no Godot errors in Output.
- [ ] Docking results in a consistent GameState docked status (no half-docked state).
- [ ] UI transitions to the expected docked/Port interface (or remains stable if already docked).
- [ ] Docked UI interactions still do not advance time.

---

## Regression Checks
List behaviors that must still work after the fix.

- Market open/close still works when docked.
- Black market open/close still works when docked.
- Undock (if present) still returns to space state cleanly.
- Customs pressure / clearance checks (if run on dock) still behave deterministically and do not throw.

---

## Manual Test Plan
Step-by-step instructions a human can follow in Godot to verify the fix.

1. Launch game; load into MainGame.
2. Fly to a system/location where Dock is available; press Dock.
3. Confirm:
   - no Output errors
   - Port UI appears
   - state reflects docked
4. Open Market ? close; open Black Market ? close.
5. (If available) Undock ? confirm return to space state without errors.
6. Repeat Dock/Undock cycle 3 times to check for “second time” regressions.

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
- Root cause summary
- Fix summary
- Files changed (and why)
- Manual tests performed
- Regression checks performed
- Remaining risks or follow-ups

---

## Mandatory Investigation Protocol (Codex must do this BEFORE editing)
Codex must do the following static triage steps and write the findings to results.md **before** making any changes:

1) **Locate Dock entrypoint(s)**
   - Find where the Dock button node exists (scene path and script owner)
   - Find the pressed signal hookup (editor connection or `.connect()` in code)
   - Identify the handler function name(s)

2) **Trace Dock call chain**
   - From the handler, list the next calls (MainGame ? GameState, etc.)
   - Identify which GameState fields are read/written for docking
   - Identify any guard conditions (already docked, no location, etc.)

3) **Identify likely failure modes**
   - Missing node path / renamed node
   - Handler still referenced but removed/renamed
   - Null/empty `location_id` or `system_id` at time of dock
   - Dock invoked while already docked or while UI state is inconsistent
   - Dock triggers clearance checks with missing context

4) **Propose minimal fix**
   - Codex must state: “Smallest change that prevents the error is X”
   - Fix must be localized and must not introduce new behavior beyond preventing the bug

If Codex cannot determine root cause from static analysis, it must:
- Document exactly what information is missing (e.g., exact runtime error text),
- Provide a minimal suggestion for what to capture during manual repro (e.g., Output error, printed state),
- STOP without making speculative code changes.
