# MVP Scope (1-Month Build)

**Status: 🟡 IN PROGRESS — Android-only**

Links back to [[Home]].

## Core Loop (Week 1–2)
- [ ] Idle income generator ($/sec, tap to 1.5x multiplier)
- [ ] Hero unit (tappable character sprite, responds to clicks)
- [ ] Upgrade shop (buy heroes, buy income multipliers, list is scrollable)
- [ ] Persistent save/load (SQLite, auto-save every 5 sec)
- [ ] Offline earnings (calculate $/sec × offline_duration on launch)

## Roguelike Run System (Week 2–3)
- [ ] Short runs (5–10 min, single-screen arena, waves of enemies)
- [ ] Hero selection (pick 1 of 3 random heroes for the run)
- [ ] Combat (tap enemies to attack, enemies auto-attack back)
- [ ] Loot (enemies drop gold + XP, carry gold back to main game)
- [ ] Loss condition (health reaches 0 → run ends, keep half the gold earned)

## Floating Bubble Widget (Week 3–4)
- [ ] SYSTEM_ALERT_WINDOW permission request flow (first-launch prompt + settings deep-link if denied)
- [ ] In-app toggle: "Show floating bubble" on/off
- [ ] Bubble shows live game state (e.g. current gold, or hero idle animation)
- [ ] Tap bubble → reopen full app; drag bubble → reposition; long-press → close
- [ ] Foreground service keeps idle income ticking while bubble is active and app is backgrounded

## Polish & VFX (Week 3–4)
- [ ] Number pop-ups on tap (+$, +XP, damage numbers)
- [ ] Screen shake on hero attack
- [ ] Color flash on enemy hit
- [ ] Smooth UI transitions (buttons, screens)
- [ ] SFX for tap, purchase, run completion (8-bit chiptune, <100KB total)

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
