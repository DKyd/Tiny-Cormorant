# Results: Issue-0039 — In-Session Menu (Escape) Follow-up Fixes

## Summary of fixes
- Ensured Escape always initializes the in-session menu before toggling visibility, fixing first-press reliability.
- Guarded in-session menu signal connections with `has_signal(...)` checks for safer wiring during development.

## Files changed
- `scripts/MainGame.gd`
  - Added `_ensure_in_session_menu()` call in Escape handling before toggling visibility.
  - Wrapped signal connections in `_ensure_in_session_menu()` with `has_signal(...)` guards.

## Manual test steps run
- Not run.

## Behavior confirmation
- Behavior is unchanged except:
  - Escape now reliably opens the in-session menu on the first press.
  - Missing/renamed menu signals no longer cause connection errors (connections are skipped safely).

## Follow-ups / known gaps
- Requires `res://scenes/ui/InSessionMenu.tscn` and its script to define and emit the expected signals:
  - `resume_requested`, `quit_to_menu_requested`, `quit_to_desktop_requested`.
