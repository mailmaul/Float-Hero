# MVP Scope (1-Month Build)

**Status: 🟡 IN PROGRESS — Android-only. Core Loop ✅ done & tested; Roguelike combat ✅ done (visuals pending Flame port); home scene ✅ in Flame; bubble/widget not started.**

Links back to [[Home]].

## Core Loop (Week 1–2)
- [x] Idle income generator ($/sec, tap = incomePerSecond × tapMultiplier, default 1.5)
- [x] Hero unit (tappable character sprite — Flame side-view hero, tap = attack swing)
- [x] Upgrade shop (buy heroes, buy income/tap multipliers, scrollable list)
- [x] Persistent save/load (SQLite via sqflite, auto-save every 5s + save-on-pause)
- [x] Offline earnings ($/sec × offline_duration on launch, capped at 8h)

## Roguelike Run System (Week 2–3)
- [x] Short runs (single-screen arena, waves 1–5) — rendered in **Flame** (side-view)
- [x] Hero selection — draft up to 3 candidates from unlocked heroes; pick 1 to run
- [x] Combat (tap to attack, enemies auto-attack back, victory/defeat both resolve)
- [x] Loot (enemies drop gold + XP, carried back to main game)
- [x] Loss condition — run ends on 0 HP; **keeps half** gold on defeat, full on victory

## Visual & Camera Style (Home ✅ / Runs ✅)
- [x] 2D side view, flat orthographic camera, crisp pixel art (`FilterQuality.none`)
- [x] Home screen: Flame scene — sky/ground, hero vs rival, CC0 PixelKnight sprite
- [x] Roguelike run screen now uses the same side-view Flame rendering
- [ ] Replace placeholder rival/enemy with dedicated enemy sprites (art handoff)

## Floating Bubble Widget (Week 3–4)
- [ ] SYSTEM_ALERT_WINDOW permission request flow (first-launch prompt + settings deep-link if denied)
- [ ] In-app toggle: "Show floating bubble" on/off
- [ ] Bubble shows live game state (e.g. current gold, or hero idle animation)
- [ ] Tap bubble → reopen full app; drag bubble → reposition; long-press → close
- [ ] Foreground service keeps idle income ticking while bubble is active and app is backgrounded

## Polish & VFX (Week 3–4)
- [x] Number pop-ups — floating `+gold` on tap and `-damage` on enemy hit (XP tracked in HUD)
- [x] Screen shake on hero attack (home + run)
- [x] Color flash on enemy hit (white flash via `Fighter.flash`)
- [ ] Smooth UI transitions (buttons, screens)
- [x] SFX for tap, purchase, hit, run win/lose — 8-bit chiptune via `flame_audio` (~59KB total)

## NOT in MVP (Post-Launch)
- [ ] Procedural roguelike rooms
- [ ] Hero gacha/randomization system
- [ ] Leaderboards or multiplayer
- [ ] Live event scheduling
- [ ] Advanced progression (ascension systems, prestige, etc.)

---

## Success Criteria
- [ ] Game runs 60fps on Android 9+ device (tested on physical phone)
- [ ] Can play 20 min idle loop without crash
- [ ] Can complete 5 full roguelike runs without crash
- [ ] Save/load preserves gold and hero selection after app restart
- [ ] Floating bubble toggles on/off, persists idle income while app is backgrounded
- [ ] Visual polish is charming (animations, colors, feedback feel good)

---

## Build Timeline
| Week | Goal | Lead |
|------|------|------|
| 1 | Core idle loop + save system | You |
| 2 | Roguelike run framework + basic combat | You |
| 3 | Art assets (all sprites) + integration | Fadil |
| 4 | SFX, VFX, balance pass, bugfix | Team |
