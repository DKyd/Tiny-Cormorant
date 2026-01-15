{
  "job_type": "refactor",
  "intent": "Structure-preserving changes with explicit invariants and verification.",
  "default_branching": {
    "small_diffs": true,
    "prefer_multiple_jobs_over_one_large": true
  },
  "protected_paths": [
    "data/**",
    "scenes/MainGame.tscn"
  ],
  "required_sections": [
    "Goal",
    "Non-goals",
    "Invariants",
    "Scope",
    "Approach",
    "Verification",
    "Migration Notes"
  ],
  "verification_requirements": {
    "manual_test_steps_required": true,
    "rename_search_required_if_renaming": true,
    "no_behavior_change_unless_declared": true
  },
  "style_expectations": {
    "explicit_reason_strings": true,
    "prefer_Log_add_entry_over_print": true,
    "ui_read_only": true
  }
}
