Summary of changes and rationale
- Added a minimal Main Menu scene with New Game and Quit actions to provide a session framing entry point and a clean exit path.
- Set the project main scene to the new menu so the game launches into the session framing flow.

Files changed (with brief explanation per file)
- scenes/MainMenu.tscn: new menu layout with title, New Game, disabled Continue, Quit, and status label.
- scripts/MainMenu.gd: menu logic for starting a new game, guarding double clicks, and quitting.
- project.godot: updated main scene to MainMenu.

Assumptions made
- Switching scenes to MainGame is sufficient to start a fresh session using existing initialization logic.

Known limitations or TODOs
- Continue is a disabled placeholder; save/load flow is not implemented by design.
