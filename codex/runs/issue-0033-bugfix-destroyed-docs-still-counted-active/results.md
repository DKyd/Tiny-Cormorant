Root cause
- Destination doc queries treat FreightDocs with status "active" as valid, and destroying a doc did not change its status, so destroyed docs were still counted.

Fix summary
- Mark destroyed FreightDocs with status "destroyed" on the successful destruction path so active-only filters ignore them.

Files changed + purpose
- singletons/GameState.gd: set doc status to "destroyed" when a FreightDoc is destroyed.

Manual test steps executed
- Not run (not requested).

Regression checks
- Not run (not requested).

Assumptions made
- Galaxy Map destination indicators rely on FreightDoc status being "active" (not just is_destroyed).

Follow-ups
- None.
