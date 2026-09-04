# Tech Stack

**Status: ✅ LOCKED — Flutter + Flame, Android-only for MVP**

Links back to [[Home]]. See [[Open-Questions]] for the decision trail.

## Critical New Requirement: Floating Bubble Widget (Android chat-head style)
Core feature request: game shows as a **floating overlay bubble** (like Messenger chat heads) with an on/off toggle — the mobile-native equivalent of TBH's taskbar presence. This is a **platform capability**, not a game-engine feature, and it changes the recommendation.

### Platform reality (same for every engine)
- **Android**: Supported via `SYSTEM_ALERT_WINDOW` permission + `WindowManager` overlay / Bubble API. This is how Messenger, Truecaller, Facebook do chat heads.
- **iOS**: **Not possible, full stop.** Apple's sandboxing forbids any app from drawing over other apps — confirmed by Apple DTS forum responses ("not technically possible with the APIs in the iOS SDK"). No engine, no workaround. Floating bubble = **Android-only feature**, iOS gets a normal in-app experience (or skip iOS for v1).

## Primary: Flutter + Flame

**Decision: Flutter for the app shell + UI, Flame for gameplay rendering.** (Switched from Godot.)

Two independent reasons — do NOT conflate them:

### Reason 1 — Gameplay rendering → Flame
- Flame gives the game loop (`update(dt)`/`render`), `SpriteSheet`/`SpriteAnimationComponent`, particles, camera/parallax, and collisions. The side-view pixel scenes (home + roguelike runs) live here.
- **Status: in use.** Home screen is a Flame `FlameGame` (side-view, hero vs rival, CC0 sprite sheet). `flame` 1.38.2 in `pubspec.yaml`.

### Reason 2 — Floating bubble overlay → native Android, NOT an engine choice
- The Messenger-style chat-head is a **platform capability** (`SYSTEM_ALERT_WINDOW` + foreground service), unrelated to whether the game renders in Flame or plain Flutter. Flutter just has ready-made overlay plugins (`floating_bubble_overlay`, `flutter_floatwing`); Godot would need a custom native Android plugin. That plugin availability — not Flame — is the Flutter win for the bubble.

### Why Flutter over Godot (recap)
- You already know Dart; hot reload; ready-made overlay plugins for the bubble; Flame covers the 2D game-loop needs. Accepted tradeoff: ~5–10% slower on object-heavy scenes and a larger APK — irrelevant for a low-object idle clicker.

### Setup (actual)
```
Framework: Flutter 3.44.8 (Dart SDK ^3.8.1) + Flame 1.38.2
Persistence: sqflite (SQLite) + path   [NOT shared_preferences]
Rendering: Flame FlameGame for scenes; Flutter widgets for HUD/shop/menus
Sprites: CC0 "PixelKnight" (OpenGameArt), assets/images/knight.png, 48x48 sheet
Audio: flame_audio 2.12.2 — 8-bit chiptune SFX in assets/audio/ (procedurally generated, ~59KB)
Target: Android 9+ (API 28+) ONLY for MVP — iOS deferred entirely
Not yet added: floating bubble / overlay plugins, home_widget
Permissions (future, for bubble): SYSTEM_ALERT_WINDOW, FOREGROUND_SERVICE, POST_NOTIFICATIONS
```

### Fallback: Godot 4.x
Still valid if bubble feature gets cut/deprioritized post-MVP — pure perf/lightweight/2D-native advantages from the earlier writeup stand. Revisit if bubble turns out to be low-priority.

---

## Database & Backend
- **Local storage first** (MVP): `SQLite` for save data, async offload to cloud later if live events are needed.
- **Optional cloud sync** (post-MVP): If roguelike runs should sync across devices, add a simple REST API (Node.js + PostgreSQL, or Firebase for rapid setup).

---

## Art Pipeline
- **Tool**: Aseprite or Piskel (free) for pixel sprites.
- **Format**: PNG spritesheets, 16/32px base tile size, max 32-color palettes per sprite.
- **Flutter/Flame integration**: `SpriteSheet` + `SpriteAnimationComponent` for characters, `TiledComponent` or manual tile rendering for environments.

---

## Sound Design
- **Tool**: itch.io freebies + `flame_audio` package (wraps `audioplayers`).
- **SFX**: 8-bit chiptune style (Chiptone.io, sfxr). Keep <100KB total per sound.
- **Music**: Looping ambient tracks (1–2 min loops). Store separately from code.

---

## Deliverables
- GitHub repo: `Game/float-hero/` with `lib/` (Dart source), `assets/` (art + audio), `docs/` (design docs).
- Build pipeline: GitHub Actions to auto-build Android APK on push to `main` (optional for MVP, useful post-launch).
