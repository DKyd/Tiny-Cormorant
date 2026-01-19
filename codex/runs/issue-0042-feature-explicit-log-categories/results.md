## Summary of changes and rationale
- Added explicit SHIP and CUSTOMS categories to existing ship-action and customs inspection log entries so LogPanel color rendering is intentional and does not rely on inference.

## Files changed (with brief explanation per file)
- `singletons/GameState.gd`  
  Categorized travel, docking, auto-travel, and customs inspection result logs as SHIP or CUSTOMS, respectively.

- `scripts/Bridge.gd`  
  Categorized travel, routing, docking, and wait-related logs as SHIP.

- `scripts/Port.gd`  
  Categorized customs inspection availability and request logs as CUSTOMS.

## Assumptions made
- Ship-action failures (travel, docking, wait) should render with the SHIP category alongside successful actions.
- Explicit categorization at emission sites is preferred over heuristic inference.

## Known limitations or TODOs
- Log entries emitted outside the approved whitelist remain uncategorized and will render as OTHER.
- Additional categories (e.g., CONTRACT, ECONOMY) are intentionally deferred until relevant gameplay systems are finalized.
