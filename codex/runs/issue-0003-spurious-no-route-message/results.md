# issue-0003 - Remove spurious "No route from here to that system." message for intra-system docking

## Root cause summary
- `scripts/MapPanel.gd`: `_show_route_info_to_system` treated same-system selections as a missing route because `Galaxy.find_path` returned an empty/short path, triggering the "No route from here to that system." message when selecting intra-system locations.

## Fix summary
- Added a same-system guard in `_show_route_info_to_system` to show a neutral status for intra-system selections, while preserving the no-route message for true inter-system routing failures.

## Files changed
- `scripts/MapPanel.gd`

## Manual test steps
1. Launch the game.
2. Open the map and select multiple locations within the current system.
3. Verify the “No route from here to that system.” message never appears for these selections.
4. Dock to an intra-system location and confirm success + correct UI/log feedback.
5. Attempt an inter-system set course where no route exists (if possible) and confirm the message appears only in that failure case.
6. Perform a normal inter-system travel and confirm it still works.

## Regression checks
- Setting course / traveling to a different system still works as before.
- Docking to a location in a different system (issue-0002 behavior) still works and does not regress.
