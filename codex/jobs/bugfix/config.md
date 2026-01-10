{
  "job_type": "bugfix",
  "primary_goal": "Fix the described incorrect behavior with minimal changes and no scope expansion.",
  "default_principles": [
    "minimal diff",
    "no refactors",
    "no redesign",
    "behavior change only where necessary",
    "protect against regressions"
  ],
  "required_sections_in_job_md": [
    "Bug Description",
    "Expected Behavior",
    "Repro Steps",
    "Files: Allowed to Modify (Whitelist)",
    "Acceptance Criteria (Must Be Testable)",
    "Regression Checks",
    "Manual Test Plan"
  ],
  "diff_policy": {
    "prefer_minimal_changes": true,
    "no_unrelated_formatting_changes": true,
    "avoid_renames": true
  },
  "file_policy": {
    "whitelist_enforced": true,
    "new_files_disallowed_by_default": true,
    "forbidden_list_enforced": true
  },
  "output_policy": {
    "must_write_results_md": true,
    "results_md_required_sections": [
      "Root Cause",
      "Fix Summary",
      "Files Changed",
      "Manual Test Steps",
      "Regression Checks",
      "Assumptions Made",
      "Known Limitations / Follow-ups"
    ]
  },
  "stop_conditions": [
    "Cannot reproduce from steps",
    "Multiple plausible fixes with tradeoffs",
    "Requires modifying files outside whitelist",
    "Requires refactor or new system"
  ]
}
