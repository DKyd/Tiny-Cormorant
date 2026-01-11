# Summary
- Updated travel contract completion to require BOTH destination system AND destination location matches (location-specific completion). Contracts missing destination data now log an error and remain active.
- Completion log now includes the contract id while preserving the existing side-effect order (pay reward → clear cargo → mark freight docs → log).

# Files Changed
- singletons/GameState.gd: enforce destination system + location match; log missing destination system/location; include contract id in completion log.

# New Public APIs
- None.

# Manual Test Steps
1. Start a game where at least one travel contract exists from an origin location to a destination location.
2. Dock at the origin location and accept the contract. Confirm cargo capacity is reduced / cargo is loaded/reserved per issue-0005 behavior.
3. Travel to the destination system, but do not dock at the destination location yet. Verify the contract is still active and no completion log/reward occurs.
4. Dock at a different location in the destination system (if available). Verify the contract still does not complete.
5. Dock at the contract’s destination location. Verify:
   - contract cargo is removed
   - freight document is marked completed
   - credits increase by the contract reward
   - contract is no longer active
   - a completion log entry appears (includes contract id)
6. Dock at the destination location again. Verify no duplicate reward and no duplicate completion.

# Assumptions Made
- Valid travel contracts include BOTH destination system id and destination location id.
- Contract completion checks are invoked on docking via GameState.set_current_location() (not on system entry).

# Known Limitations / Follow-ups
- Legacy/system-only contracts (missing destination_location_id) will not complete and will log an error until contract generation/data is updated.
