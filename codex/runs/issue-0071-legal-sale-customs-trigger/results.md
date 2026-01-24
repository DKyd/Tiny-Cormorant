# Results

Summary of changes and rationale:
- Updated action registry to use `SELL_CARGO_LEGAL` and moved the legal-market customs inspection trigger to occur after validation but before any sale state mutation, preserving the player-action boundary and keeping black market sales uninspected.

Files changed (with brief explanation per file):
- `res://singletons/GameState.gd`: renamed the sell action key and repositioned the legal-market `run_customs_inspection` call to pre-mutation.

Assumptions made:
- Running the inspection immediately before `remove_cargo`, money updates, and bill-of-sale creation satisfies the action-boundary requirement.

Known limitations or TODOs:
- No additional legal-sell triggers were added elsewhere; this relies on the existing `sell_manifest_goods` call path.
