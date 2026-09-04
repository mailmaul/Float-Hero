# Float Hero — Design Vault

Central hub (MOC) for all design context. Every note below links back here — keep this the single entry point in Obsidian graph view.

## Status
🟠 **In development** — Core idle loop, save/load (SQLite), offline earnings, and roguelike combat implemented and unit-tested (14/14 green). Home screen now rendered in **Flame** as a side-view pixel scene. Engine is **Flutter + Flame** (Flame confirmed in use). Next: on-device build (Android SDK blocker), then roguelike run visuals in Flame. See [[MVP-Scope]].

---

## Core Design (Locked ✅)
- [[Core-Concept]] — TBH-like mobile idle game, pixelated, 1-month MVP + event launch
- [[Design-Pillars]] — 5 non-negotiable checks every feature must pass
- [[Tech-Stack]] — **Flutter + Flame** (Flutter for UI/HUD + future overlay; Flame for gameplay rendering; switched from Godot)
- [[Team-Roles]] — You (design + dev), Fadil (art), nuga (design assist)

---

## Development Roadmap
- [[MVP-Scope]] — Week-by-week breakdown, success criteria
- [[Event-Roadmap]] — Post-MVP launch options (Ludum Dare, app store, local showcase)
- [[HomeScreen-Widget-Plan]] — Android home-screen App Widget (WhatsApp-style) showing the hero fighting; feasibility + phased plan

---

## Decisions in Flight
- [[Open-Questions]] — Live log of unresolved questions (update as we go)

---

## Notes-to-Create (as needed)
- **Mechanics Deep-Dive** — Idle formula, roguelike run structure, balancing equations
- **Character Design** — Hero roster, abilities, attack animations
- **UI/UX Layout** — Screen mockups, button flow, HUD design
- **Asset Pipeline** — Sprite sheet specs, color palettes, animation timing
- **Roadmap (Post-MVP)** — Seasonal events, new heroes, live features

---

## Build & Sync
- **Dev starts**: Week 1 (idle loop framework in Flutter/Flame)
- **Art starts**: Parallel with Week 1 (hero sprite direction, tileset)
- **Sync cadence**: Weekly design reviews, daily art check-ins
- **Release target**: EOMonth + 1-2 weeks for event submission

---

## Log
- **2026-09-04 — Concept Locked** — Core fantasy defined as TBH-like idle/roguelike, Godot 4.4 chosen initially, team roles assigned, MVP scope set for 4 weeks.
- **2026-09-04 — Engine Revised** — Floating bubble overlay (Messenger chat-head style) is a core requirement → switched primary engine to **Flutter + Flame** (ready-made overlay plugins exist; Godot has none built-in). iOS confirmed incompatible with floating overlays at the OS level (Android-only feature). See [[Tech-Stack]] and [[Open-Questions]].
- **2026-09-04 — Platform Scope Locked** — MVP is **Android-only**. iOS deferred entirely post-MVP. Removes ambiguity from [[Tech-Stack]] target line.
- **2026-09-04 — Home Widget Planned** — Drafted [[HomeScreen-Widget-Plan]]: standard Android App Widget via `home_widget` + native RemoteViews. Feasible but **not a live Flame render** (looped sprites + throttled snapshots + native HP/gold views). Overlaps the [[Tech-Stack]] floating bubble (the truly-live surface) — role decision needed before build.
- **2026-09-04 — Project Scaffolded** — `Game/float-hero/app/` created (`flutter create`, Android-only). Deps added: `flame`, `flame_audio`, `floating_bubble_overlay`, `shared_preferences`. `flutter analyze` clean, 0 issues. **Blocker**: Android SDK not installed on this machine — `flutter doctor` shows Android toolchain missing, needed before `flutter run`/APK build. Flutter SDK itself present at `~/flutter` (3.44.8).
- **2026-09-04 — Core Loop Shipped** — Idle income, tap, upgrade shop, SQLite save/load (auto-save + save-on-pause), and capped offline earnings implemented. Managers refactored to `ChangeNotifier`. Fixed critical bugs: progress never persisted, roguelike victory soft-lock, phantom run gold, tap-power upgrade. Unit + widget tests added.
- **2026-09-04 — Flame Adopted (home scene)** — Reintroduced `flame` (1.38.2) as the gameplay renderer. Home screen ported from a CustomPainter prototype to a Flame `FlameGame`: flat orthographic side view, hero (idle/attack) sparring a rival, crisp pixels. Sprite = CC0 "PixelKnight" (OpenGameArt), 48x48 sheet. Old CustomPainter scene removed (clean cutover).
- **2026-09-04 — Dependency Reality Check** — Actual `pubspec.yaml` deps: `flame`, `sqflite`, `path`, `cupertino_icons`. The earlier "scaffolded" note listing `flame_audio`/`floating_bubble_overlay`/`shared_preferences` was aspirational — those are NOT yet added. Persistence uses `sqflite` (not `shared_preferences`). Android SDK still not installed → on-device run/build remains blocked.
- **2026-09-04 — Roguelike in Flame + Polish** — Ported the run screen to a Flame battle (`RunGame` over `RunManager`): hero vs HP-barred enemy row, reconciled each frame. Added hero-selection draft (pick 1 of 3), defeat keeps half gold (`RunManager.rewardFor`). Polish/VFX: screen shake, floating `+gold`/`-damage` numbers, enemy hit-flash, and 8-bit `flame_audio` SFX (tap/buy/hit/win/lose, procedurally generated, ~59KB). Shared `Fighter` + `PixelGame` base. 16/16 tests green.
- **2026-09-04 — Android Build Unblocked** — SDK now installed; device detected (`21051182G`). `flutter run` first failed in `:audioplayers_android:compileDebugKotlin` — a Kotlin 2.3.20 Build Tools API bug ("Could not close incremental caches … is already registered") under parallel builds, not our code. Fixed via `android/gradle.properties`: `kotlin.incremental=false` + `kotlin.compiler.execution.strategy=in-process`, then `flutter clean`. `flutter build apk --debug` now succeeds (~132s). Ready to run on device.
