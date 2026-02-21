# issue-0085 Results

## Summary of Refactor
- Removed redundant Port-local Bridge navigation from the Port header by deleting `ToBridgeButton` and its script wiring.
- Increased Port header/tab breathing room to reduce cramped presentation in embedded MainGame context:
  - outer margin increased
  - vertical stack separation increased
  - header row control spacing increased
  - facilities row button spacing set explicitly
- Tab logic, docking/state flow, and gameplay behavior were not changed.

## Files Changed
- `scenes/Port.tscn`
  - Removed `MarginContainer/VBoxContainer/HeaderRow/ToBridgeButton` node.
  - Adjusted layout spacing constants:
    - `MarginContainer` margins: `left/right 24`, `top/bottom 22`
    - `VBoxContainer` separation: `16`
    - `HeaderRow` separation: `12`
    - `FacilitiesRow` separation: `10`
- `scripts/Port.gd`
  - Removed `to_bridge_button` cached node reference.
  - Removed `to_bridge_button.pressed.connect(_on_ToBridgeButton_pressed)` hookup.
  - Removed `_on_ToBridgeButton_pressed()` handler.
- `codex/runs/ACTIVE_RUN.txt`
  - Set to `issue-0085-port-header-spacing-remove-to-bridge` per scaffolding requirement.
- `codex/runs/issue-0085-port-header-spacing-remove-to-bridge/job.md`
  - Added verbatim job definition.
- `codex/runs/issue-0085-port-header-spacing-remove-to-bridge/results.md`
  - Added this results report.

## Manual Test Results
- Not executed in this shell environment (no Godot runtime/editor session available here).
- Required manual checks pending in-editor:
  1. Open Port in MainGame and verify no missing-node/signal errors.
  2. Confirm `To Bridge` is gone and header/tabs spacing is improved.
  3. Confirm global MainGame nav still provides Bridge/Port/Quarters navigation.
  4. Open/close Market, Contracts, Ship, Cantina, Docs, Customs; verify layout remains stable.

## Confirmation Behavior Is Unchanged
- No state mutation logic was moved or altered.
- No time-advance pathways were changed.
- No gameplay/economy/customs behavior was modified.
- This change is limited to Port-local redundant navigation UI removal and spacing constants.

## Follow-ups / Known Gaps
- Visual spacing values may need one iteration after live review in your target playtest resolution(s).
