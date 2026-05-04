# Results

## Summary
- Triaged the recurring Godot 4.6.1 headless signal 11 crash as most likely sandbox/environment-related, not a current project-startup failure.
- Confirmed the Godot binary itself responds to `--version`.
- Confirmed no-project headless quit succeeds in the sandbox but reports denied editor/AppData directory writes.
- Confirmed project headless startup crashes with signal 11 inside the sandbox.
- Confirmed the same project headless startup succeeds outside the sandbox and reaches normal early boot/contract generation.
- Confirmed the issue-0131 script-style command does not crash outside the sandbox; it fails cleanly because `CustomsLevel3Reconciliation.gd` is a pure static helper and does not inherit `SceneTree` or `MainLoop`.
- No `.godot/**`, `.uid`, project, runtime, script, data, scene, singleton, or governance churn appeared.

## Capability Definition
For upcoming Level 3 work, a usable validation path means:
- Godot can start the project headlessly without signal 11.
- The command can run with enough filesystem/AppData access to avoid sandbox-induced engine/editor startup faults.
- Direct helper validation should run through a tiny `SceneTree`/`MainLoop` validation script or future harness, not by passing the pure static helper itself to `--script`.
- The validation path must produce deterministic output for clean, suspicious, and `not_evaluable` helper reports without wiring the helper into live inspections, UI, pressure, logs, or enforcement.

## Evidence Reviewed
- `issue-0121-fix-feedbackcapture-autoload-startup-uid`
  - Fixed the earlier `FeedbackCapture` UID autoload startup blocker by changing `project.godot` to use an explicit `res://` script path.
- `issue-0122-retry-pressure-only-customs-runtime-validation`
  - Confirmed headless startup reached normal early boot/contract generation after `issue-0121`.
  - Still found no deterministic non-interactive customs scenario harness.
- `issue-0126-add-inert-customs-mass-primitive`
  - Reported Godot 4.6.1 console headless project launch crashed with signal 11.
- `issue-0131-implement-level-3-read-only-reconciliation-helper`
  - Reported Godot 4.6.1 console headless script-style validation crashed with signal 11 before useful direct-call validation.

## Commands Attempted

### 1. Version Probe
Command:

```powershell
& 'C:\Users\akaph\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --version
```

Observed:

```text
4.6.1.stable.official.14d19694e
```

Result:
- `pass`
- The binary can launch for a trivial version query.

### 2. Sandbox Project Headless Startup
Command:

```powershell
& 'C:\Users\akaph\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path . --quit-after 5
```

Observed:

```text
CrashHandlerException: Program crashed with signal 11
Engine version: Godot Engine v4.6.1.stable.official (14d19694e0c88a3f9e82d899a0400f27a24c176e)
Dumping the backtrace.
[1] error(-1): no debug info in PE/COFF executable
...
[15] error(-1): no debug info in PE/COFF executable
-- END OF C++ BACKTRACE --
```

Result:
- `fail inside sandbox`
- Reproduces the signal 11 shape seen in `issue-0126` and `issue-0131`.

### 3. Sandbox Script-Style Headless Attempt
Command:

```powershell
& 'C:\Users\akaph\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path . --script scripts/customs/CustomsLevel3Reconciliation.gd --quit-after 2
```

Observed:

```text
CrashHandlerException: Program crashed with signal 11
Engine version: Godot Engine v4.6.1.stable.official (14d19694e0c88a3f9e82d899a0400f27a24c176e)
Dumping the backtrace.
[1] error(-1): no debug info in PE/COFF executable
...
[15] error(-1): no debug info in PE/COFF executable
-- END OF C++ BACKTRACE --
```

Result:
- `fail inside sandbox`
- Same crash shape as project startup.

### 4. Sandbox No-Project Headless Quit
Command:

```powershell
& 'C:\Users\akaph\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --quit-after 1
```

Observed:

```text
Godot Engine v4.6.1.stable.official.14d19694e - https://godotengine.org

ERROR: Could not create editor data directory: C:/Users/akaph/AppData/Roaming/Godot
ERROR: Could not create editor config directory: C:/Users/akaph/AppData/Roaming/Godot
ERROR: Could not create editor cache directory: C:/Users/akaph/AppData/Local/Godot
ERROR: Failed to read the root certificate store.
ERROR: Can't save resource to empty path. Provide non-empty path or a Resource with non-empty resource_path.
ERROR: Error saving editor settings to 
```

Result:
- `pass with environment errors`
- No signal 11.
- Strong evidence that sandboxed Godot has restricted AppData/root-certificate/editor settings access.

### 5. Escalated Project Headless Startup
Command:

```powershell
& 'C:\Users\akaph\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path . --quit-after 5
```

Observed:

```text
Godot Engine v4.6.1.stable.official.14d19694e - https://godotengine.org

Generated contract: { "id": "CON_0001", ... }
Generated contract: { "id": "CON_0002", ... }
Generated contract: { "id": "CON_0003", ... }
Generated contract: { "id": "CON_0004", ... }
```

Result:
- `pass outside sandbox`
- This distinguishes the recurring signal 11 from a current project-startup blocker.
- The project reaches normal early boot/contract generation when Godot is allowed normal filesystem/AppData access.

### 6. Escalated Script-Style Headless Attempt
Command:

```powershell
& 'C:\Users\akaph\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe' --headless --path . --script scripts/customs/CustomsLevel3Reconciliation.gd --quit-after 2
```

Observed:

```text
Godot Engine v4.6.1.stable.official.14d19694e - https://godotengine.org

ERROR: Can't load the script "scripts/customs/CustomsLevel3Reconciliation.gd" as it doesn't inherit from SceneTree or MainLoop.
   at: start (main/main.cpp:4253)
```

Result:
- `expected validation-command failure outside sandbox`
- No signal 11.
- The command is not a valid direct-call harness because the helper is intentionally a static helper, not an executable `SceneTree` or `MainLoop`.

## Working Tree / Churn Check
After every launch attempt, `git status --short` showed only:

```text
 M codex/runs/ACTIVE_RUN.txt
?? codex/runs/issue-0132-triage-godot-headless-validation-crash/
```

No churn appeared under:
- `.godot/**`
- `data/**`
- `scripts/**`
- `singletons/**`
- `scenes/**`
- `project.godot`
- `.desloppify/**`
- `Documentation/**`
- `codex/jobs/**`
- governance files

## Crash Characterization
Current best classification:
- `environment/sandbox-related headless crash`, medium risk

What the evidence supports:
- The Godot binary is valid and responds to `--version`.
- Headless no-project launch can run inside the sandbox, but it reports denied AppData/editor settings/root certificate access.
- Project headless startup crashes inside the sandbox.
- The same project headless startup succeeds outside the sandbox.
- The issue-0131 script-style command does not crash outside the sandbox; it reports a normal command-shape error because a pure helper script is not executable via `--script`.

What remains unresolved:
- Normal editor/game launch was not checked in this job because it would require a visible GUI launch/interaction outside the non-GUI planning scope.
- The exact Godot engine subsystem that crashes inside the sandbox is unknown because the backtrace lacks symbols.
- Direct Level 3 helper report validation still needs an executable validation wrapper or manual Godot-driven call path.

What this does not look like now:
- Not a confirmed project-startup bug.
- Not a confirmed `CustomsLevel3Reconciliation.gd` parse/runtime bug.
- Not the old `FeedbackCapture` UID autoload blocker from `issue-0121`.

## Dependencies and Blockers
Resolved for future validation:
- Project headless startup works outside the sandbox with the known Godot 4.6.1 console binary.

Still blocked:
- Running Godot project startup inside the sandbox is unreliable and can produce signal 11.
- Direct helper-call validation cannot be done by passing `CustomsLevel3Reconciliation.gd` directly to `--script`; it needs a `SceneTree`/`MainLoop` wrapper or other harness.
- No deterministic non-interactive customs/Level 3 validation harness exists yet.

## Recommended Validation Strategy
For near-term Level 3 work:
- Use escalated Godot headless commands for project startup validation when the command is important and sandboxed Godot crashes.
- Do not treat sandboxed signal 11 as project failure without rerunning outside the sandbox.
- Add a future narrow validation harness before live Level 3 inspection integration.
- Keep helper implementation and live integration separate from harness creation.

For manual validation:
- A human can launch the editor/game normally and run manual checks, but this job did not do so because visible GUI interaction was out of scope.

## Candidate Follow-Up Jobs

### 1. Add Minimal Level 3 Direct-Call Validation Harness
- Target job type: `feature` or `test`
- Risk level: medium
- Likely whitelist:
  - one narrow new validation script, likely under a future explicitly approved debug/test path
  - possibly `codex/runs/ACTIVE_RUN.txt`
  - future active run folder files
- Narrow goal:
  - provide a `SceneTree` or `MainLoop`-compatible script that calls `CustomsLevel3Reconciliation.build_level3_reconciliation_report(...)` with literal clean, mismatch, missing-docs, missing-cargo, unknown-commodity, malformed-policy, and missing-container-class contexts.
- Verification approach:
  - run Godot headless outside sandbox if needed
  - confirm deterministic printed or file-captured payload summaries
  - confirm no live gameplay integration, logs, pressure, cargo, saves, UI, or enforcement changes
- Explicit non-goals:
  - no crash fix, no live inspection integration, no UI, no pressure, no enforcement.

### 2. Document Godot Validation Execution Policy
- Target job type: `planning` or governance/documentation only if explicitly authorized
- Risk level: low
- Likely whitelist:
  - future active run folder only, unless governance/docs files are explicitly authorized
- Narrow goal:
  - record that Godot headless validation may require running outside the Codex sandbox on this Windows/OneDrive machine because sandboxed AppData/editor settings access can produce signal 11.
- Verification approach:
  - preserve exact commands and pass/fail distinction from this job.
- Explicit non-goals:
  - no runtime changes, no project settings, no code changes.

### 3. Investigate Sandboxed Godot Crash Separately
- Target job type: `bugfix` or `research`
- Risk level: medium-high
- Likely whitelist:
  - likely no repo files at first; possibly run-folder records only
  - any tool/environment changes must be explicitly scoped outside project runtime
- Narrow goal:
  - determine whether Godot can be configured with safe user/cache paths in sandbox, or whether the crash should simply be treated as a known tooling limitation.
- Verification approach:
  - compare `--headless` runs with alternate user/cache directory settings if supported, always checking for repo churn.
- Explicit non-goals:
  - no project behavior changes, no Level 3 integration.

### 4. Continue Level 3 Feature Work Only After Direct Validation Exists
- Target job type: `feature`
- Risk level: high if attempted before harness; medium-high after harness
- Likely whitelist:
  - `singletons/Customs.gd`
  - `scripts/customs/CustomsLevel3Reconciliation.gd`
  - future active run folder files
- Narrow goal:
  - integrate already-validated Level 3 report output into an explicit read-only audit context.
- Verification approach:
  - use the future harness and escalated headless startup path to prove no state mutation.
- Explicit non-goals:
  - no UI, no pressure-only consequences, no enforcement, no physical inspection.

## Recommended Next Job
Recommended next governed job:
- `feature` or `test`: Add Minimal Level 3 Direct-Call Validation Harness
- Risk level: medium

Reason:
- Project startup is not currently blocked outside the sandbox.
- The Level 3 helper itself remains unvalidated by direct runtime calls because it is not a `SceneTree`/`MainLoop`.
- A tiny harness is the narrowest way to prove deterministic helper behavior before any live integration.

Do not schedule a project-startup bugfix based on current evidence. The failing condition appears tied to sandboxed Godot execution rather than project startup.

## Governance / Path Follow-Up
- The current confirmed clone path remains `C:\Users\akaph\OneDrive\Desktop\Ozark Interactive\Games\Tiny Cormorant`, which is the Desktop path resolved through Windows/OneDrive redirection on this machine.
- This job did not modify governance files.

## Non-Goals Preserved
- No runtime game behavior changed.
- No project settings, `.godot/**`, runtime code, scenes, data, scripts, singletons, documentation, governance files, or validation harness files were modified.
- `CustomsLevel3Reconciliation.gd` remains unmodified, unintegrated, and unwired.
- Level 2 quantity/cargo reconciliation remains policy-disabled.
- No enforcement was introduced.
- This output is advisory only until converted into a complete future `job.md` or explicit active-run instructions.
