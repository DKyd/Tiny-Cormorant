# issue-0086 Results

## Investigation (Before Code Changes)

### Dock Button Handler + File Path
- Map panel script: `scripts/MapPanel.gd`
- Dock-labeled control node: `CloseButton` at `scenes/MapPanel.tscn` path `PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/CloseButton`
- Connected handler in `scripts/MapPanel.gd`:
  - `close_button.pressed.connect(_on_close_pressed)`
  - `_on_close_pressed()` emits `close_requested`

### Signals Emitted On Dock Press
- Pressing the UI button labeled `Dock` does **not** emit a docking signal.
- It emits only:
  - `close_requested`
- Docking/travel signals are emitted only by explicit course commit path:
  - `_on_set_course_pressed()` -> `_set_course_to_system()` emits `navigate_to_system_requested`
  - `_on_set_course_pressed()` -> `_set_course_to_location()` emits `navigate_to_location_requested`

### Where Signals Are Wired (MainGame/Bridge)
- `scripts/Bridge.gd` `_wire_map_panel(panel)`:
  - `navigate_to_system_requested` -> `_on_map_navigate_to_system_requested`
  - `navigate_to_location_requested` -> `_on_map_navigate_to_location_requested`
  - `close_requested` -> `_on_map_close_requested`
- `scripts/MainGame.gd` `_wire_map_panel(panel)`:
  - `navigate_to_system_requested` -> `_on_map_navigate_to_system_requested`
  - `navigate_to_location_requested` -> `_on_map_navigate_to_location_requested`
  - `close_requested` -> `_on_map_close_requested`

### Location Selection Storage / Read Path
- No dedicated `selected_location_id` field exists in `scripts/MapPanel.gd`.
- Selection is read on demand from `systems_tree` via `_get_selected_meta()`.
- Dock/course commit reads this metadata only inside `_on_set_course_pressed()`.
- The Dock-labeled button path (`_on_close_pressed`) does not read selection at all.

### Exact Missing Link
- The button labeled `Dock` is wired to `close_requested` (close-only path) instead of the docking request path.
- Missing call on Dock press: `_on_set_course_pressed()` (which is the code path that emits `navigate_to_location_requested` and ultimately produces `Docking at`, `In-system travel to`, and `Docked at` logs).

## Root Cause Summary
- UI label/action mismatch in `MapPanel`: Dock-labeled button executes close signal, not docking request.
- Therefore location docking handler chain is never invoked when pressing that button.

## Minimal Fix Proposal
- Keep close non-committing.
- Make Dock explicitly use the existing explicit commit path that emits docking signals.
- Smallest implementation:
  - Set `set_course_button.text = "Dock"` (commit action)
  - Set `close_button.text = "Close"` (non-committing close action)
- This reuses existing `navigate_to_location_requested` -> receiver -> `GameState.set_current_location(...)` flow that already produces docking logs.

---
Proceeding to apply that minimal fix.

## Fix Summary (Applied)
- `scripts/MapPanel.gd`
  - `set_course_button.text = "Dock"`
  - `close_button.text = "Close"`
  - Existing behavior preserved:
    - Dock-labeled button uses existing commit path (`_on_set_course_pressed` -> emit navigation signals)
    - Close button remains non-committing (`_on_close_pressed` -> `close_requested` only)
- `scenes/MapPanel.tscn`
  - `SetCourseButton` text set to `Dock`
  - `CloseButton` text set to `Close`

## Manual Test Plan
1. Open Galaxy Map from Bridge/MainGame.
2. Select a location and press `Dock`; confirm logs include `Docking at ...` then `Docked at ...` (and `In-system travel to ...` when applicable).
3. Open Galaxy Map and press `Close`; confirm map closes with no route/docking log entries.
4. Select a system (not location) and press `Dock`; confirm normal system travel path still logs `Setting course ...` and travel/customs entries.

## Follow-up Fix (Dock/Close Separation)
- Root cause reaffirmed: UI label/action mismatch.
- Set Course unchanged:
  - `SetCourseButton` remains labeled `Set Course` and keeps commit behavior.
- Dock is explicit:
  - Added `DockButton` wired to the same existing commit path (`_on_set_course_pressed`).
- Close remains non-committing:
  - `CloseButton` emits `close_requested` only via `_on_close_pressed`.
