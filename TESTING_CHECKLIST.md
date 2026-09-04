# Float Hero — Testing Checklist (Weeks 1-2)

## Quick Start
```bash
cd app
flutter run
```

---

## Features to Test

### **Idle Loop (Week 1)** ✅
- [ ] **Gold Display** — Updates in real-time, yellow text at top
- [ ] **Income Per Second** — Green text shows $/sec (starts at 1.0)
- [ ] **TAP Button** — Cyan button; tapping adds 1.5x income instantly
- [ ] **Passive Income** — Gold increases automatically every 100ms
- [ ] **Offline Earnings** — Kill app, wait 30sec, reopen → gold increases by ($/sec × offline_time)

### **Shop Screen (Week 1)** ✅
- [ ] **Navigate** — Tap SHOP button to open shop
- [ ] **Hero Tab** — Shows available heroes (e.g., "Spark")
  - [ ] Can purchase if gold >= cost (e.g., Spark costs 10 gold)
  - [ ] Purchased heroes show "OWNED" badge
  - [ ] Unlocking hero increases income by 5%
- [ ] **Upgrades Tab** — Shows 2 upgrades:
  - [ ] Income Multiplier (1.15x per level, cost scales)
  - [ ] Tap Power (1.10x per level, cost scales)
  - [ ] Can purchase if gold >= cost
  - [ ] Each level shows in badge
- [ ] **Back** — Tap back arrow to return to idle screen

### **Roguelike Run (Week 2)** ✅
- [ ] **Start Run** — Tap RUN button
  - [ ] Hero selected (Spark by default if unlocked)
  - [ ] Opens combat arena screen
- [ ] **Combat Arena** — Shows:
  - [ ] Hero health bar (green when >50%, orange when <50%)
  - [ ] Current wave number (1-5)
  - [ ] Gold earned this run
  - [ ] XP earned this run
  - [ ] Enemy list with health bars
- [ ] **Combat Loop** — Enemies auto-attack every 500ms
  - [ ] Hero health decreases when enemies attack
  - [ ] Screen doesn't freeze (async combat)
- [ ] **Attack Button** — Red "ATTACK!" button
  - [ ] Tapping damages first enemy
  - [ ] Enemy dies when health <= 0
  - [ ] Dead enemies removed from list
  - [ ] Gold/XP collected automatically
- [ ] **Wave Progression** — After all enemies die:
  - [ ] Next wave spawns (more enemies, harder)
  - [ ] Max 5 waves before run ends
- [ ] **Run End** — When hero health <= 0:
  - [ ] Run stops (button disabled)
  - [ ] Screen returns to idle after 0.5sec
  - [ ] Gold from run added to idle gold
  - [ ] Snackbar shows "Run Complete! Earned X Gold"

### **Persistence (Week 1)** ✅
- [ ] **Auto-Save** — Every 5 seconds:
  - [ ] Gold is saved to SQLite
  - [ ] Heroes unlocked state saved
  - [ ] Upgrade levels saved
- [ ] **App Restart** — Kill app completely:
  - [ ] Reopen app
  - [ ] All gold/heroes/upgrades are restored
  - [ ] Offline earnings calculated + applied

### **State Consistency** ✅
- [ ] No crashes after 5 min continuous play
- [ ] No crashes through 3 runs
- [ ] No crashes switching screens (Shop ↔ Idle ↔ Run)
- [ ] UI updates smoothly (no lag taps)

---

## Known Limitations (Week 3-4)

❌ **Floating Bubble** — Not implemented yet  
❌ **Sprite Art** — Using placeholder icons (star icon for hero, colored boxes)  
❌ **Sound** — No audio yet  
❌ **VFX** — No animations, screen shake, number pops  
❌ **Themes** — Basic dark theme only  

---

## Expected Console Output

```
✓ Game initialized
✓ Persistence loaded (or created new save)
✓ Economy manager running (income loop started)
✓ Idle screen displayed
```

---

## Bugs to Report

If you find anything unexpected:
1. **Crash with stack trace** → Copy error from VS Code console
2. **Gold not saving** → Kill app, reopen, check if gold restored
3. **Tap doesn't register** → Try multiple taps, check if income increases
4. **Run won't start** → Check if any heroes are unlocked (purchase "Spark" first)
5. **Enemy health bar stuck** → Force-close app, reopen

---

## Performance Notes

- **Target:** 60 FPS on Android 9+
- **Placeholder art:** Minimal perf impact
- **Income ticks:** 10 per second (100ms interval) — should be smooth
- **Combat ticks:** 2 per second (500ms interval) — intentional delay

---

## Enjoy! 🎮

This is a **playable milestone** — all core systems functional. Week 3-4 will add polish, art, sound, and mobile-specific features (bubble overlay).
