# Results: issue-0017-feature-disable-port-button-while-undocked

## Summary
- Disabled the Bridge Port button when not docked at a location that appears to provide port access, re-enabling it when docked.
- Updates are driven by existing state refreshes (no per-frame polling, no UI-only logs).

## Files Changed
- scripts/Bridge.gd: added a port-access check tied into _refresh_status to enable/disable the Port button.

## Assumptions
- A docked location with an empty spaces list should be treated as lacking port access.

## Known Limitations / TODOs
- TODO in code: replace the spaces-size heuristic with a dedicated port-access flag when available.

## Manual Test Steps
- Not run locally; follow the job’s manual test plan to verify enable/disable behavior on dock/undock and across loads.
