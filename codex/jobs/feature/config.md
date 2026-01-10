{
  "job_type": "feature",
  "primary_goal": "Implement new functionality or wire existing functionality into the game loop with minimal, reviewable diffs.",
  "default_principles": [
    "small blast radius",
    "explicit scope",
    "no speculative refactors",
    "clear, testable acceptance criteria",
    "prefer explicit, readable code over abstraction"
  ],
  "required_sections_in_job_md": [
    "Goal",
    "Non-Goals",
    "Files: Allowed to Modify (Whitelist)",
    "Files: Forbidden to Modify (Blacklist)",
    "Acceptance Criteria (Must Be Testable)",
    "Manual Test Plan"
  ],
  "diff_policy": {
    "prefer_minimal_changes": true,
    "no_unrelated_formatting_changes": true,
    "avoid_renames_unless_required": true
  },
  "file_policy": {
    "whitelist_enforced": true,
    "new_files_must_be_predeclared": true,
    "forbidden_list_enforced": true
  },
  "implementation_preferences": {
    "language": "GDScript",
    "engine": "Godot",
    "favor_data_driven_design": true,
    "ui_does_not_own_state": true,
    "prefer_single_responsibility_modules": true
  },
  "output_policy": {
    "must_write_results_md": true,
    "results_md_required_sections": [
      "Summary",
      "Files Changed",
      "New Public APIs",
      "Manual Test Steps",
      "Assumptions Made",
      "Known Limitations / Follow-ups"
    ]
  },
  "stop_conditions": [
    "Acceptance criteria ambiguous",
    "Requires modifying files outside whitelist",
    "Requires creating files not predeclared",
    "Multiple plausible approaches with significant tradeoffs",
    "Would require a refactor outside scope"
  ]
}
