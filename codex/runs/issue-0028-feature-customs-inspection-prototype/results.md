Summary
- Wired the Port Customs button to request a read-only inspection report and display it in the CustomsInspectionPanel.
- Converted randomized entry customs checks to report-only logging with no fee or money mutation.
- Added the CustomsInspectionPanel UI for displaying inspection details and connected close requests to Port-owned teardown.

Files Changed
- scripts/Port.gd: hooked CustomsButton to run inspections, log once, and open/close the panel from Port.
- scenes/Port.tscn: added CustomsButton to the facilities row.
- scripts/ui/CustomsInspectionPanel.gd: implemented read-only report display with safe placeholders.
- scenes/ui/CustomsInspectionPanel.tscn: created layout for the inspection panel.
- singletons/Customs.gd: removed fee logic and routed entry checks through GameState.run_customs_inspection.

Assumptions Made
- facility_host is the correct container for the inspection panel in Port.

Known Limitations / TODOs
- The inspection panel is static; rerun/refresh actions are out of scope.
- Entry checks pass an empty location_id when none is available.

Confirmation
- No save/load changes.
- No inspection-related state mutations (money/cargo/docs/rep/time).
