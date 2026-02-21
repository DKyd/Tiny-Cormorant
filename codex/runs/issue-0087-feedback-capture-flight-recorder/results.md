# Results

## Summary of changes and rationale
Implemented a lightweight “feedback capture” flight recorder to support UAT and future player-facing feedback submission. Logs now support dev-only entries and exportable tails, the Log panel can hide/show dev-only lines via the dev toggle, and an F8 hotkey triggers capture of a timestamped on-disk bundle containing a snapshot and both player/dev log tails.

## Files changed (with brief explanation per file)
- `codex/runs/ACTIVE_RUN.txt`
  - Set active run to `issue-0087-feedback-capture-flight-recorder`.
- `singletons/Log.gd`
  - Added `is_dev` flag to log entries and extended `add_entry` signature to accept `is_dev` (default false).
  - Updated skip logic so dev-only entries are never skipped.
  - Added tail export helpers (`get_tail`, `format_tail_text`) for flight-recorder bundles.
- `scripts/ui/LogPanel.gd`
  - Dev toggle now filters dev-only entries: OFF hides dev-only; ON shows all.
  - Preserved existing prefix behavior and category-based coloring.
- `singletons/FeedbackCapture.gd` (new)
  - Added `capture(note="", tags=[]) -> String` to write a timestamped bundle under `user://feedback/<YYYY-MM-DD_HH-MM-SS>/`:
    - `snapshot.json`
    - `player_log_tail.txt`
    - `dev_log_tail.txt`
    - `report.md`
  - Best-effort writes; directory failure returns `""` and emits a single dev-only log entry.
- `scripts/MainGame.gd`
  - Added a temporary F8 (non-echo) handler in `_unhandled_input` to invoke `FeedbackCapture.capture()` when autoload exists; logs a dev-only warning if missing and consumes input only when F8 is handled.
- `codex/runs/issue-0087-feedback-capture-flight-recorder/job.md`
  - Recreated authoritative job definition for this run.
- `codex/runs/issue-0087-feedback-capture-flight-recorder/results.md`
  - Populated with results (this file).

## Assumptions made
- `FeedbackCapture.gd` is (or will be) registered as an autoload singleton at `/root/FeedbackCapture` for the F8 trigger path to work.
- `GameState` may not always be present at capture time; snapshot uses safe defaults when missing.

## Known limitations / TODOs
- No UI for entering note/tags yet; capture uses defaults (future “Give Feedback” button can call `capture(note,tags)`).
- No network submission; bundles are local artifacts only.
- Capture does not include a full serialized game state beyond minimal tick/system/location; expand snapshot fields later as needed (e.g., cargo, credits, customs pressure context).
- Git CLI availability varies due to GitHub Desktop embedded Git; use embedded path for command-line diffs when system git is not on PATH.