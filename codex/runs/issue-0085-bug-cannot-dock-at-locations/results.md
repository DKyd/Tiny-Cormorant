# Results - issue-0085-bug-cannot-dock-at-locations

## Root cause summary
The docking path in `scripts/MapPanel.gd` built location row metadata from `loc.get("id", "")` while iterating dictionaries returned by `Galaxy.get_locations_for_system(sys_id)`.
If a location dictionary lacks an embedded `id` field, `location_id` becomes empty in tree metadata, so docking later fails the real guard in `_set_course_to_location` (`dest_loc == ""` => `Invalid destination location.`).

## Fix summary
- Switched MapPanel location row construction to use authoritative IDs from `Galaxy.get_location_ids_for_system(sys_id)`.
- For each ID, MapPanel now resolves the location via `Galaxy.get_location(loc_id)` and skips invalid entries.
- Added one action-bounded log on the real dock request path:
  - `Dock requested: location_id=... system_id=...` (category `SHIP`) in `_set_course_to_location`.
- `Close` behavior remains unchanged (`_on_close_pressed` still emits `close_requested`).

## Files changed (and why)
- `scripts/MapPanel.gd`: Fix empty-location-id gating bug in dock metadata path; add minimal docking-action log.
- `codex/runs/ACTIVE_RUN.txt`: Set active run to `issue-0085-bug-cannot-dock-at-locations`.
- `codex/runs/issue-0085-bug-cannot-dock-at-locations/job.md`: Bugfix job scaffold.
- `codex/runs/issue-0085-bug-cannot-dock-at-locations/results.md`: This report.

## Investigation steps performed
1. Traced real dock action path: `MapPanel._set_course_to_location` -> `navigate_to_location_requested` -> `Bridge._on_map_navigate_to_location_requested` -> `GameState.set_current_location`.
2. Verified close path remains separate: `MapPanel._on_close_pressed` -> `close_requested`.
3. Identified exact gating condition preventing docking: empty `dest_loc` generated from non-authoritative `loc.get("id", "")` metadata source.
4. Added minimal logging only on player-triggered dock action path.

## Manual tests performed
- In-engine manual test execution is blocked in this environment.
- Attempted to locate Godot executable:
  - `Get-Command godot*,*godot*` -> not found
  - `where.exe godot` / `where.exe godot4` -> not found
- Because of this, runtime steps could not be executed here.

## Regression checks performed
- Static code-path check: selecting a system still follows existing system navigation flow.
- Static code-path check: location listing still resolves names from location dictionaries after switching to ID-based iteration.
- Static code-path check: Close action unchanged (`emit_signal("close_requested")`).

## Remaining risks or follow-ups
- Runtime confirmation still required in-editor for:
  - docking at two different valid locations,
  - correct `current_location_id` transitions and docked UI state,
  - expected dock-request log values,
  - graceful behavior in zero-location systems.
