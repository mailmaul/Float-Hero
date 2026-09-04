# Float Hero — Design Vault

Central hub (MOC) for all design context. Every note below links back here — keep this the single entry point in Obsidian graph view.

## Status
🟢 **Pre-production LOCKED** — Core concept, tech stack (Flutter+Flame, Android-only MVP), team roles, and MVP scope all defined. Ready to begin development (Week 1: core idle loop).

---

## Core Design (Locked ✅)
- [[Core-Concept]] — TBH-like mobile idle game, pixelated, 1-month MVP + event launch
- [[Design-Pillars]] — 5 non-negotiable checks every feature must pass
- [[Tech-Stack]] — **Flutter + Flame** primary (switched from Godot — floating bubble overlay needs it), Godot 4.x fallback
- [[Team-Roles]] — You (design + dev), Fadil (art), nuga (design assist)

---

## Development Roadmap
- [[MVP-Scope]] — Week-by-week breakdown, success criteria
- [[Event-Roadmap]] — Post-MVP launch options (Ludum Dare, app store, local showcase)

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
- **2026-09-04 — Project Scaffolded** — `Game/float-hero/app/` created (`flutter create`, Android-only). Deps added: `flame`, `flame_audio`, `floating_bubble_overlay`, `shared_preferences`. `flutter analyze` clean, 0 issues. **Blocker**: Android SDK not installed on this machine — `flutter doctor` shows Android toolchain missing, needed before `flutter run`/APK build. Flutter SDK itself present at `~/flutter` (3.44.8).
