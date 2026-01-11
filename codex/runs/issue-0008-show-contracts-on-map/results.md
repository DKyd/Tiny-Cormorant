# Results: issue-0008-show-contracts-on-map

## Summary
- Exposed contract visibility in the galaxy map using functional, text-only indicators.
- Locations now display origin contract availability counts (contracts that can be accepted at that location).
- Systems auto-expand if they contain any locations with origin contract availability.
- Active contract destinations (system and location) are also shown as text markers (`Dest: N`) and cause systems to auto-expand.
- No visual highlighting, icons, colors, or UI polish were added.

## Files Changed
- `singletons/Contracts.gd`
  - Added a read-only helper `get_contract_count_for_location(location_id)` to expose origin contract availability for UI use.
- `scripts/MapPanel.gd`
  - Displays per-location origin contract counts as text markers.
  - Auto-expands systems if any location within the system has origin contract availability.
  - Displays active contract destination counts (`Dest: N`) at both system and location levels.
  - Auto-expands systems if they are destinations for any active contracts.
  - Removed destination-based counting from origin availability logic to keep semantics consistent.

## New Public APIs
- `Contracts.get_contract_count_for_location(location_id: String) -> int`

## Manual Test Steps
1. Dock at a location that generates contracts and open the galaxy map.
2. Verify that locations with available contracts show text markers like `Contracts: N`.
3. Verify that systems containing such locations auto-expand.
4. Accept one or more contracts and travel toward their destination.
5. Open the galaxy map and verify:
   - Destination systems show `Dest: N` in their labels.
   - Destination locations show `Dest: N` markers.
   - Destination systems auto-expand even if they have no origin contracts.
6. Complete or abandon contracts and verify destination markers update accordingly.
7. Confirm no colors, icons, or visual highlighting are used.

## Assumptions Made
- Origin contract availability comes exclusively from `Contracts.contracts_by_location_id`.
- Active contract destinations are derived from `GameState.active_contracts`.
- MapPanel is the authoritative UI for displaying contract-related map visibility.

## Known Limitations / Follow-ups
- Origin availability and destination relevance are represented textually only.
- Visual distinction, icons, colors, or filtering may be added in a future job.
- Destination and origin markers share the same visual weight by design in this job.
