{
  "job_type": "governance",
  "description": "Process/policy hardening and Codex governance updates. No runtime gameplay changes.",
  "default_blacklist": [
    "data/**",
    "scenes/MainGame.tscn",
    ".godot/**"
  ],
  "default_allowed_new_files_prefixes": [
    "codex/jobs/governance/"
  ],
  "notes": [
    "Governance jobs must not change runtime code unless explicitly scoped as a separate job type.",
    "Gate B approvals require scope proof."
  ]
}
