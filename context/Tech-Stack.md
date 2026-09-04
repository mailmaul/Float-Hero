# Tech Stack

**Status: ✅ LOCKED — Flutter + Flame, Android-only for MVP**

Links back to [[Home]]. See [[Open-Questions]] for the decision trail.

## Critical New Requirement: Floating Bubble Widget (Android chat-head style)
Core feature request: game shows as a **floating overlay bubble** (like Messenger chat heads) with an on/off toggle — the mobile-native equivalent of TBH's taskbar presence. This is a **platform capability**, not a game-engine feature, and it changes the recommendation.

### Platform reality (same for every engine)
- **Android**: Supported via `SYSTEM_ALERT_WINDOW` permission + `WindowManager` overlay / Bubble API. This is how Messenger, Truecaller, Facebook do chat heads.
- **iOS**: **Not possible, full stop.** Apple's sandboxing forbids any app from drawing over other apps — confirmed by Apple DTS forum responses ("not technically possible with the APIs in the iOS SDK"). No engine, no workaround. Floating bubble = **Android-only feature**, iOS gets a normal in-app experience (or skip iOS for v1).

## Primary: Flutter + Flame

**Decision: Switch primary to Flutter — floating bubble requirement outweighs the 17% Godot perf edge.**

### Why Flutter wins for THIS project
- **Ready-made plugins**: `floating_bubble_overlay`, `system_alert_window`, `flutter_floatwing` — all production-grade, all built specifically for Messenger-style chat heads. Drop-in, documented, maintained.
- **Godot has nothing built-in for this.** You'd write a custom native Android plugin in Java/Kotlin from scratch (WindowManager + SYSTEM_ALERT_WINDOW), then bridge it through Godot's Android plugin system — that's Android native dev, not game dev, and there's no existing example to fork.
- **You already know Dart** — the floating bubble plugin API is just another Flutter package, zero new language to learn on top of the overlay work.
- **Hot reload** still helps iterate on the bubble UI (size, drag behavior, tap-to-expand) fast.

### Tradeoff accepted
- ~5-10% slower on object-heavy scenes vs Godot (irrelevant for idle clicker — low object count).
- Larger APK (80-120MB vs Godot's ~40MB) — acceptable for this scope.
- Full tradeoff writeup already in chat history — nothing here overrides pure game-loop performance, only the bubble feature does.

### Setup
```
Framework: Flutter 3.x + Flame (game loop, sprites, animation)
Overlay: floating_bubble_overlay or flutter_floatwing
Target: Android 9+ (API 28+) ONLY for MVP — iOS deferred entirely, no in-app-only fallback build for v1
Permissions: SYSTEM_ALERT_WINDOW, FOREGROUND_SERVICE, POST_NOTIFICATIONS
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
