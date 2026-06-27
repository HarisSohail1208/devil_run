# Devil Run

A complete one-screen 2D trap platformer for Android built with Flutter and the Flame game loop.

## Game

- Catalog-driven levels with visible start and door positions.
- Fixed camera: the whole level is scaled into one screen.
- Black silhouette player with walk and jump animation.
- Instant respawn after death, with a death counter.
- Traps include spikes, hidden spikes, moving hazards, fake platforms, falling platforms, disappearing platforms, fake doors, reverse controls, and moving doors.
- Main menu, level select, settings, pause, restart, level complete, and exit flows.
- Persistent progress and settings through `shared_preferences`.
- Music, sound effects, and vibration toggles.

## Levels

`lib/levels/level_catalog.dart` is the only file you need to edit to add,
remove, or change levels. Paste or delete JSON entries inside `_rawLevels`; the
level select screen, save clamping, unlocks, next-level flow, and completion
percentage all derive from the catalog length.

## Run

```bash
flutter pub get
flutter run
```

The app locks to landscape and uses touch controls on screen. Keyboard controls also work on desktop/web builds:

- `A` / Left arrow: move left
- `D` / Right arrow: move right
- `W` / Up arrow / Space: jump
- Escape: pause

## Structure

- `lib/game/` contains the Flame game loop, world simulation, entity runtime, input state, and painter.
- `lib/levels/` contains the JSON level catalog.
- `lib/screens/` contains menus and game screens.
- `lib/services/` contains audio and save handling.
- `lib/widgets/` contains reusable buttons and touch controls.
