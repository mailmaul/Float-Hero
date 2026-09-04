# Open Questions

Living decision log. Move resolved items into [[Core-Concept]] or [[Design-Pillars]] once locked, keep the answer here for history.

## Unresolved
5. **"Event game"** — what does this mean? A live-service game with recurring in-game events? A build targeting a specific external event/deadline (game jam, expo, launch date)? Need this clarified before scoping.
10. **Live surface role — home widget vs floating bubble?** Both can mirror game state; only the bubble is truly live over other apps ([[HomeScreen-Widget-Plan]]). Which is "the core"? Decide before building either.

## Resolved
9. **iOS scope** → [[MVP-Scope]] — **Android-only for MVP.** iOS deferred entirely (no fallback build), revisit post-MVP once bubble feature has traction.
1. **Core fantasy** → [[Core-Concept]] — TBH-inspired idle/roguelike, mobile pixel art.
2. **Genre/camera** → [[Core-Concept]] — 2D, idle + roguelike runs.
3. **Platform** → [[Core-Concept]] — Mobile (Android priority, iOS secondary).
4. **Engine/tech stack** → [[Tech-Stack]] — **Flutter + Flame**, confirmed in use. Corrected rationale: Flame is for **gameplay rendering** (game loop, sprites, particles); the floating bubble is a **native `SYSTEM_ALERT_WINDOW`** concern, NOT why Flame was chosen. Godot dropped (custom native plugin needed for overlay; Dart familiarity; Flame covers 2D loop).
6. **Target audience** → casual mobile idle-game players (implied by genre).
7. **Team/skillset** → [[Team-Roles]] — You (design+dev+AI), Fadil (art), nuga (design assist).
8. **Scope for v1** → [[MVP-Scope]] — core MVP first, 4-week build.
10. **Gameplay renderer** → [[Tech-Stack]] — **Flame** for scenes (home screen live in Flame), Flutter widgets for HUD/shop/menus. CustomPainter prototype removed.
11. **Home hero sprite** → CC0 "PixelKnight" (OpenGameArt), 48x48 sheet, `assets/images/knight.png`. Placeholder rival = same sheet flipped + red tint until a dedicated enemy sprite lands.
12. **Run rewards** → [[MVP-Scope]] — **full gold on victory, half (floored) on defeat.** Implemented as `RunManager.rewardFor`.
13. **On-device build** → RESOLVED — Android SDK installed, device detected. Kotlin 2.3.20 incremental-cache bug worked around in `android/gradle.properties` (`kotlin.incremental=false`, in-process compiler). Debug APK builds clean; `flutter run` unblocked.
