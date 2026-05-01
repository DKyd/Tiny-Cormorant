# Results

## Summary
- Re-ran the Godot 4.6.1 headless startup path that failed in `issue-0120` and confirmed that the `FeedbackCapture` startup blocker fixed by `issue-0121` remains resolved.
- Headless startup now reaches normal early project boot and contract generation without the prior autoload UID failure.
- No `.godot/**` churn or other forbidden repo churn appeared during the retry.
- Full live validation of Level 1 and Level 2 customs outcome branches is still blocked in this environment because there is no documented non-interactive harness or command-line scenario driver for forcing specific inspection states without modifying runtime code.

## Environment and Evidence
- Canonical workspace:
  - `C:\Users\akaph\Desktop\Ozark Interactive\Games\Tiny Cormorant`
- Godot runtime binary used:
  - `C:\Users\akaph\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe`
- Prior evidence reused:
  - `issue-0120-validate-pressure-only-customs-consequence-matrix`
  - `issue-0121-fix-feedbackcapture-autoload-startup-uid`
- Additional repo checks:
  - searched for built-in command-line or debug validation hooks related to customs, `customs_inspection_completed`, `FeedbackCapture`, and command-line user args
  - no existing command-line scenario harness or documented runtime-driving hook was found

## Runtime Validation Matrix

| Scenario | Setup | Action | Expected result | Observed result | Status |
| --- | --- | --- | --- | --- | --- |
| Startup blocker regression check | Clean canonical clone, Godot 4.6.1 console binary, post-`issue-0121` project state | Run `Godot_v4.6.1-stable_win64_console.exe --headless --path <project> --quit-after 5` | Project starts without `FeedbackCapture` autoload failure | Startup advanced into normal early boot and generated contracts; no `FeedbackCapture` UID/autoload error appeared | `pass` |
| Repo-churn check after retry | Same as above | Run `git status --short` after the headless retry | No forbidden `.godot/**` or other repo churn | Working tree showed only this planning job's whitelisted run files | `pass` |
| Level 1 clean outcome validation | Requires a deterministic clean-document scenario and runtime-driving path | Attempt to identify or invoke a non-interactive scenario harness | Observe clean classification with no scrutiny increase and no enforcement | No built-in harness found; scenario could not be driven from this shell without code changes | `blocked` |
| Level 1 suspicious outcome validation | Requires deterministic authenticity/modification setup and runtime-driving path | Attempt to identify or invoke a non-interactive scenario harness | Observe suspicious classification without enforcement | No built-in harness found; scenario could not be driven from this shell without code changes | `blocked` |
| Level 1 invalid outcome validation | Requires deterministic invalid-document setup and runtime-driving path | Attempt to identify or invoke a non-interactive scenario harness | Observe invalid classification, scrutiny increase, logs, and still no enforcement | No built-in harness found; scenario could not be driven from this shell without code changes | `blocked` |
| Level 2 suspicious/invalid/not-evaluable validation | Requires deterministic Level 2 trigger at inspection depth 2 and runtime-driving path | Attempt to identify or invoke a non-interactive scenario harness | Observe `level2_audit` classification and findings behavior live | No built-in harness found; scenario could not be driven from this shell without code changes | `blocked` |
| Save/load persistence observation | Requires elevated scrutiny state plus runtime-driving path to save/reload | Attempt to identify or invoke a non-interactive scenario harness | Observe scrutiny and recent Level 2 violation memory surviving save/load | No built-in harness found; scenario could not be driven from this shell without code changes | `blocked` |
| Deterministic decay observation | Requires elevated scrutiny state plus runtime-driving path to advance time | Attempt to identify or invoke a non-interactive scenario harness | Observe scrutiny decay deterministically over ticks | No built-in harness found; scenario could not be driven from this shell without code changes | `blocked` |

## Startup Resolution Check
- The startup blocker from `issue-0120` remains resolved.
- The retry did not reproduce:
  - `ERROR: Unrecognized UID: "uid://djwab4xr50ujm".`
  - `ERROR: Resource file not found: res:// (expected type: unknown)`
  - `ERROR: Failed to instantiate an autoload, can't load from path: .`
- Observed startup output instead advanced into normal runtime boot, including generated contract lines.

## Runtime Observability Limits
- This environment can now boot the project headlessly, but it still cannot confidently exercise customs gameplay branches without one of the following:
  - a documented manual Godot session driven by a human
  - an existing deterministic debug command or command-line harness
  - a future governed job that adds a narrow validation harness
- Current repo search did not reveal:
  - `OS.get_cmdline_user_args()` usage
  - a dedicated runtime validation scene or startup switch for customs scenarios
  - a documented debug action for forcing specific inspection outcomes from the shell

## Pressure-Only and No-Enforcement Boundary
- Newly live-confirmed in this job:
  - the project can now start normally under the same headless startup path that previously failed
- Still source-confirmed rather than live-branch-confirmed:
  - no fines, holds, seizures, travel blocking, reputation effects, cargo mutation, credit mutation, or document mutation are automatically applied by the customs inspection path
  - current pressure-only behavior remains the expected model from `issue-0120`
- Reason this remains partial:
  - without scenario-driving affordances, the customs branches themselves could not be exercised live from this CLI session

## Dependencies, Blockers, and Ambiguities
- Resolved:
  - `FeedbackCapture` autoload startup failure from `issue-0120`
- Remaining blocker:
  - no deterministic non-interactive scenario harness exists for forcing Level 1 and Level 2 inspection outcomes from this environment without modifying code
- Ambiguity:
  - it remains unknown whether a manual in-editor validation pass by a human would expose any runtime-only issue in the pressure/preview/log flow, because this session could not drive those interactions

## Recommendation
- The startup blocker is no longer the reason to delay follow-up work.
- The next safest governed job is still the read-only Level 2 audit surfacing feature identified earlier, unless the team first wants a narrow planning or bugfix job that adds a deterministic validation path.
- If stronger runtime confidence is required before any new feature work, schedule a small validation-enabler job with an explicit whitelist and verification plan rather than broadening scope inside a planning job.

## Advisory Candidate Follow-Up Jobs

### 1. Read-only Level 2 audit surfacing in inspection UI
- Target job type: `feature`
- Risk level: medium
- Likely whitelist:
  - `scripts/ui/CustomsInspectionPanel.gd`
  - `scenes/ui/CustomsInspectionPanel.tscn`
  - possibly one narrow helper under `scripts/ui/**`
- Narrow goal:
  - surface the existing `level2_audit` payload to the player without changing customs logic or introducing enforcement.
- Verification approach:
  - use the now-working startup path and a manual Godot session to trigger a Level 2 inspection and confirm read-only display.

### 2. Deterministic customs validation harness
- Target job type: `bugfix` or `planning`, depending on implementation choice
- Risk level: medium
- Likely whitelist:
  - to be defined narrowly by a future job
- Narrow goal:
  - provide a reproducible, non-interactive way to force specific Level 1 and Level 2 inspection outcomes for future validation jobs.
- Verification approach:
  - from CLI or a debug scene, produce known clean, suspicious, invalid, and not-evaluable cases without altering production gameplay semantics.

### 3. Manual runtime verification pass
- Target job type: `planning`
- Risk level: low
- Likely whitelist:
  - run-folder files only, or a documentation target if explicitly allowed
- Narrow goal:
  - capture a human-run Godot validation matrix for customs outcomes now that startup is fixed.
- Verification approach:
  - follow a step-by-step manual checklist and record observed classifications, logs, persistence, decay, and absence of enforcement.
