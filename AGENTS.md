# Shell

* Use PowerShell for Windows commands.
* Always read and write text files as UTF-8.
* Never change file encoding unless explicitly requested.
* Do not re-encode Korean text.
* Preserve all existing Korean comments and string literals.
* If terminal output shows garbled Korean text, assume it is a console encoding issue and do not modify source files because of it.

# File Encoding

* All source files must remain UTF-8.
* When reading files in PowerShell, use UTF-8 explicitly.
* When writing files in PowerShell, use UTF-8 explicitly.
* Never replace Korean text with escaped Unicode sequences.

# Flutter Project

* This project contains Korean comments and UI strings.
* Keep Korean text unchanged.
* Do not rewrite Korean text unless requested.
* The first single-file prototype is complete; keep new code in the split structure under `screens/`, `widgets/`, `models/`, and `logic/`.
* Continue using `StatefulWidget` and `setState()` for state management until the user asks for a different approach.
* Do not add external packages for UI, state management, or game logic unless the user explicitly approves it.
* Keep game-rule logic out of painter widgets when practical; prefer `logic/game_rules.dart` for pure rule checks.
