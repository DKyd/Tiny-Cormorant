Summary
- Clarified the authenticity rule: destroyed FreightDocs set authenticity_score to 0.
- Added runtime evidence/authenticity helpers in GameState to derive flags from edit events and compute authenticity with destruction forcing 0.

Files Changed
- codex/runs/issue-0024-freightdoc-authenticity-evidence-flags/job.md: updated acceptance criteria and manual test wording to specify authenticity_score = 0 on destroy.
- singletons/GameState.gd: added evidence flag constants, derivation helper, and public authenticity/evidence accessors.

Assumptions Made
- Evidence is derived solely from edit_events and is_destroyed, with no persistence changes.

Known Limitations / TODOs
- Authenticity tuning values are provisional and may need adjustment once inspections are implemented.
- Captain's Quarters inspector does not yet display authenticity/evidence; UI wiring is still required.
