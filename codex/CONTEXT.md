# Tiny Cormorant — Project Context

This document defines **project-wide truths, conventions, and constraints** for the Tiny Cormorant Godot project.

All Codex jobs must comply with this context unless explicitly overridden by a job.

If information is missing, Codex must **not assume**. When in doubt, ask.

---

## Project Overview

**Tiny Cormorant** is a 2D space trading simulation.

Core gameplay pillars:
- Trading and market interaction
- Ship, cargo, and inventory management
- Economic feedback driven by systems, not scripted events
- Player-driven decision making over reflex gameplay

Design priority: **clarity, debuggability, extensibility** over premature optimization.

---

## Engine & Language

- Engine: **Godot**
- Godot version: **4.x** (pin exact minor version when known)
- Language: **GDScript**
- Target perspective: **2D / top-down**
- No C# unless explicitly introduced later

Codex must follow idiomatic GDScript and Godot best practices for the pinned major version.

---

## Repository Structure (High Level)

Primary directories:
- `scenes/` — Godot scenes (`.tscn`)
- `scripts/` — Gameplay and UI scripts
- `singletons/` — Autoloaded global systems
- `data/` — Static or semi-static data (resources, configs)

Do not invent new top-level folders without approval.

---

## Singletons & Global State

Global systems are implemented as **autoload singletons** under `singletons/`.

Rules:
- Singletons manage shared state and cross-scene coordination
- Do not duplicate global logic in scene scripts
- Access singletons explicitly; do not hide dependencies
- If new global state is required, call it out explicitly in the job

---

## Scenes & Scripts

Conventions:
- One primary script per scene (unless the job explicitly requires otherwise)
- Scene scripts coordinate behavior; logic-heavy systems belong in dedicated scripts/singletons
- Avoid fragile/deep node paths where possible

Prefer:
- Clear node naming
- Explicit references over magic strings
- Readable structure over cleverness

---

## UI Rules

- UI logic must not own authoritative game state.
- Game state changes flow through systems/singletons, not UI widgets.

---

## UI Conventions (Gameplay HUD Ownership)

- There is exactly one gameplay root UI scene responsible for persistent HUD elements.
- Persistent HUD elements (e.g., LogPanel) must be instantiated **exactly once** by the gameplay root UI scene (currently `scenes/MainGame.tscn`).
- Feature panels and sub-scenes must **not** instance persistent HUD elements.
- If a new gameplay root scene is introduced, it must either reuse `scenes/MainGame.tscn` or include the same persistent HUD elements exactly once (no duplicates).
- LogPanel is a singleton UI instance **by convention** (not an autoload); it is owned by the gameplay root UI.

---

## Data & Economy

Prefer:
- Data-driven definitions where possible
- Separation of data from presentation
- Structured data over scattered constants
- Centralized definitions over duplication

---

## Coding Standards

- No unused variables or dead code
- No commented-out blocks left behind
- Prefer small, readable functions
- Favor explicitness over abstraction
- Naming: clear, descriptive, consistent; avoid abbreviations unless obvious

---

## Change Discipline

Codex must:
- Make the smallest change that satisfies the job
- Avoid speculative refactors
- Avoid touching unrelated files
- Explain *why* a change exists, not just *what* changed

If a change would benefit from a refactor, recommend it; do not perform it automatically.

---

## Assumptions Codex Must NOT Make

- Do not assume multiplayer
- Do not assume save/load systems unless present
- Do not assume persistence formats
- Do not assume future features
- Do not assume performance constraints beyond reason

Only work with what is explicitly present.

---

## Final Instruction

When uncertain: **Stop and ask.**
