# Refactor Job Rules — Tiny Cormorant

Refactor jobs change *structure* (naming, organization, factoring, call routing) while preserving behavior unless explicitly declared.

## Primary goals
- Preserve existing gameplay behavior and architectural authority boundaries.
- Improve clarity, safety, or maintainability with small, reviewable diffs.
- Make correctness and debugging easier (logs, reasons, signals, explicit APIs).

## Default stance: behavior-preserving
Unless the job explicitly declares otherwise, a refactor must be behavior-preserving.

**Behavior-preserving means:**
- No new time advancement paths.
- No new implicit state changes.
- No changes to authoritative ownership (GameState remains authority for time/location/system transitions).
- UI remains read-only over systems (no direct state mutation).

## Allowed change types
- Renames (fields, methods, signals, variables) with full call-site updates.
- Extracting helpers / consolidating duplicated logic.
- Moving code to more appropriate files/modules (within repo rules).
- Introducing small internal data structures to reduce duplication.
- Replacing print spam with centralized logging (or debug-gated output).

## Prohibited unless explicitly scoped
These changes are **not allowed** unless clearly called out in the job goal + acceptance criteria:
- New gameplay features.
- New UI/UX polish work beyond what’s needed to keep behavior intact.
- Changing save formats / persistent data formats without migration notes.
- Changes to protected paths: `data/**`, `scenes/MainGame.tscn`.

## Required sections in every refactor job
Each job **must** include:

1) **Goal** (1–2 sentences)
2) **Non-goals** (explicitly list what you’re not doing)
3) **Invariants** (truths that must remain true after the refactor)
4) **Scope / Files Allowed** (explicit whitelist)
5) **Approach** (high-level steps, not implementation minutiae)
6) **Verification**
   - Manual test steps (short, deterministic)
   - Rename verification (if renaming): search/grep for old identifiers returns no hits
7) **Migration Notes** (required if any data schema/field names change)

## Invariants (baseline checklist)
Unless a job explicitly declares a behavior change, the following must remain true:
- Time advances only via `GameState.advance_time(reason)` and only from explicit actions.
- Docked UI actions do not advance time.
- Economy prices remain deterministic per `(system_id, tick, market_kind)`.
- Systems expose read-only APIs to UI; UI does not mutate state directly.
- Log entries remain centralized (prefer `Log.add_entry` over `print`) and remain explainable.

## Output quality bar
- Small diffs. If a change feels big, split into multiple refactor jobs.
- Update or add log messages only when it improves debugging clarity.
- Prefer explicit naming (`*_system_id` vs `*_location_id`) over shorthand.

## When to escalate
If the refactor requires changing behavior, declare it as:
- **Behavioral refactor** — include explicit behavior diffs in acceptance criteria.

If it touches more than ~5 files or crosses multiple systems, split the job.
