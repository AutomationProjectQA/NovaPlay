/// Sound/feedback cues emitted by the game loop, routed to audio + haptics by
/// the app layer (docs/ANALYTICS.md sfx events). Keeps the Flame engine
/// decoupled from app services — it just reports what happened.
enum GameSfx { launch, bounce, starLit, win, lose }
