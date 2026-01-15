# Logging & Debug Output Guide — Tiny Cormorant

This document defines when and how to use logging in Tiny Cormorant.

Logs exist to make the game predictable, debuggable, and explainable — not to act as a full historical record or telemetry system.

---

## Purpose of Logs

Logs exist to support:
- **Predictability** — what happened, in what order
- **Debuggability** — why a state change occurred
- **Recent context** — what the player did in the last few turns

Logs are **not**:
- a permanent history
- analytics or telemetry
- a transcript of UI interaction

Log history is capped and should be treated as ephemeral.

---

## What SHOULD Produce a Log Entry

Log entries should map to **player-visible outcomes** or **authoritative state transitions**.

### Always log when:

#### 1) Time advances
- Every time tick advance must be logged
- Include a clear reason

Examples:
- `Waited dockside. +3 ticks.`
- `Traveled to Vega Station (inter-system). +2 ticks.`

---

#### 2) Authoritative state changes
- Docking / undocking
- System changes
- Location changes while docked
- Contract accepted / completed / failed / expired
- Trade transactions

Examples:
- `Docked at Yoshino Port.`
- `Moved to Dry Dock (intra-system). +5 ticks.`
- `Contract accepted: C-104 to Vega Station.`

---

#### 3) Explicit action outcomes
- Player attempts an action with a clear success or failure

Examples:
- `You must be docked to wait.`
- `Cannot undock: insufficient fuel.` (future example)

---

#### 4) Rule enforcement / blocked actions
- Any time the game says “no”
- The reason should be explicit and human-readable

---

#### 5) Mode or context changes
- Market kind changes (legal ↔ black)
- Tariff regime changes
- Contract state transitions

---

## What Should NOT Produce a Log Entry

Do **not** log:

- UI navigation (opening panels, switching tabs)
- Rendering or layout updates
- Hover/select events
- Per-frame or per-tick loops
- Deterministic recalculations that occur *because* of a logged cause

**Rule of thumb:**  
Log the **cause**, not every downstream effect.

---

## Message Style & Formatting

### General guidance
- One line per event
- Human-readable
- Concise but specific
- Prefer names over IDs when available

### Tense & tone
- Past tense
- Neutral, factual language

### Avoid
- Dumping raw dictionaries or arrays
- Internal variable names
- Excess punctuation or emojis

---

## Recommended Message Patterns

### Time advancement
<Action description>. +<N> ticks.


### Blocked action
<Action> failed: <reason>.


### State change
<Clear description of new state>.


---

## Debug Prints vs Logs

Use `Log.add_entry()` for:
- Player-facing outcomes
- State transitions
- Rule enforcement

Use `print()` only if:
- It is debug-only
- Temporary
- Gated behind a debug flag

If the message helps the player understand what happened, it belongs in the log.

---

## Event Frequency Rule (Anti-Spam)

If something can happen:
- per frame
- many times per second
- inside a loop over items/contracts

…it does **not** belong in the log.

Logs should roughly correlate to **explicit player actions** and **system transitions**.

---

## Capacity Awareness

Log history is capped (currently 300 entries).

Therefore:
- Keep messages short
- Log causes, not effects
- Do not rely on logs for long-term history
