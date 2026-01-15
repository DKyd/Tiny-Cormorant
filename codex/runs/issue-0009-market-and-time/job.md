# Feature Job

## Metadata
- Issue/Task ID: Issue-0009-market-and-time 
- Short Title: Deterministic tick-based economy with legal/black contexts + clipboard export
- Author (human): Douglass Kyd
- Date: Jan 2026

---

## Goal
Upgrade the existing economy/market pricing so that price lists are deterministic and tied to an explicit monotonic `GameState.time_tick`, while supporting two parallel market contexts (`legal` and `black`) and a plain-text export suitable for copying to the OS clipboard.

All market data must remain query-driven and debuggable.

---

## Non-Goals
This job must NOT:

- Add a dynamic supply/demand simulation or inventory depletion
- Add legality rules, faction rules, access gating, or reputation systems
- Add new UI polish, icons, colors, sorting, filtering, or layout changes
- Persist market snapshots to disk
- Modify contracts, freight docs, travel, docking, or map behavior
- Introduce speculative refactors or rename/move existing systems
- Modify `data/**`
- Modify `scenes/MainGame.tscn`

---

## Context
- A basic pricing system already exists at `res://singletons/Economy.gd`.
  - It computes commodity prices using system traits (`system_type`, `population`) plus producer/consumer weighting.
  - It caches price lists per `system_id` in `price_cache`.
  - It currently introduces nondeterminism via `_ready(): randomize()` and `randf()` noise.
- There is not yet an explicit global time step; markets do not evolve in a controlled, reproducible way.
- The design requires two parallel market “views” at a place:
  - a legal market (`legal`)
  - an illicit/back-room market (`black`)
  - For now, these may differ only by deterministic “noise profile” or simple factor, not by legality rules.
- The design also requires a player-facing way to copy market info as text (market-card-like intel).

---

## Proposed Approach
- Add an explicit monotonic tick counter to `GameState`:
  - `time_tick` increments only through `GameState.advance_time(reason)`
- Replace nondeterministic RNG usage in `Economy.gd` with deterministic pseudo-random “noise” derived from stable inputs:
  - `(system_id, commodity_id, time_tick, market_kind)`
  - Noise must not depend on call order or global RNG state.
- Extend economy price caching so it is stable per:
  - `(system_id, time_tick, market_kind)`
- Add an API to return a formatted plain-text market table suitable for clipboard copying.
- If a UI hook is needed to trigger clipboard copy, keep it minimal and text-only (no layout/polish).

---

## Files: Allowed to Modify (Whitelist)
Only these files may be edited.

- `res://singletons/GameState.gd`
- `res://singletons/Economy.gd`
- `res://singletons/Log.gd` (only if needed to log time advancement / clipboard events)
- (Optional, only if required to trigger clipboard copy in-game): one existing UI script, explicitly named in `results.md` with rationale

---

## Files: Forbidden to Modify (Blacklist)
These files/directories must not be touched.

- `res://data/**`
- `res://scenes/MainGame.tscn`
- Any contract-related scripts
- Any map-related scripts
- Any other files not listed in the whitelist

---

## New Files Allowed?
- [ ] Yes (must list exact paths below)
- [x] No

If Yes, list exact new file paths:
- (None)

---

## Public API Changes
List any new or modified public methods, signals, or resources.

**GameState**
- `var time_tick: int`
- `func advance_time(reason: String) -> void`
- (Optional signal, only if needed for UI refresh): `signal time_advanced(new_tick: int, reason: String)`

**Economy**
- `func get_price_list_for_system_at(system_id: String, tick: int, market_kind: String) -> Array`
- `func get_price_list_text_for_system_at(system_id: String, tick: int, market_kind: String) -> String`
- (Optional) retain existing `get_price_list_for_system(system_id)` behavior as “current tick legal” wrapper if needed for compatibility

---

## Acceptance Criteria (Must Be Testable)
- [ ] `GameState.time_tick` exists and can only change via `GameState.advance_time()`
- [ ] For the same inputs `(system_id, tick, market_kind)`, economy price lists are identical:
  - across repeated calls
  - across different call orders
  - across fresh launches (no reliance on `randomize()` / `randf()`)
- [ ] `market_kind="legal"` and `market_kind="black"` yield different (but deterministic) price lists for the same `(system_id, tick)`
- [ ] Clipboard export copies a plain-text market table, including tick + system name/id + market kind
- [ ] No forbidden files are modified; no new files are created

---

## Manual Test Plan
1. Run the game and note the current system id.
2. Using a minimal debug hook (or temporary button), call:
   - `GameState.advance_time("test")` twice and note `time_tick` increments by 1 each time.
3. For a fixed `(system_id, tick, legal)`, call the price list function twice:
   - confirm values are identical.
4. Call price list for `(system_id, same tick, black)`:
   - confirm values differ from legal but remain stable across repeated calls.
5. Restart the game and repeat step 3 for a known `(system_id, tick, market_kind)`:
   - confirm the outputs match previous run.
6. Trigger clipboard export and paste into a text editor:
   - confirm output includes header + rows and is readable plain text.

---

## Edge Cases / Failure Modes
- Invalid `system_id` ? returns empty list / safe default text
- Invalid `market_kind` ? safe default (treat as `legal`) or empty result; must not crash
- Clipboard copy fails / unavailable ? log a message; must not crash
- Tick values that are negative or extremely large ? clamp or handle safely; must not crash

---

## Risks / Notes
- Existing callers of `Economy.get_price_list_for_system(system_id)` may assume caching behavior. Any compatibility changes must be explicit and documented in `results.md`.
- Deterministic noise must not use global RNG state or `randomize()`.
- This job intentionally does not resolve “per-location markets” yet; system-based pricing remains acceptable.

---

## Codex Output Requirements
Codex must write results to:

- `codex/runs/issue-0009/results.md`

If `results.md` does not exist, Codex is permitted to create it.  
No other new files may be created.

Results must include:
- Summary of changes and rationale
- Files changed with brief explanation per file
- Assumptions made
- Known limitations or TODOs
