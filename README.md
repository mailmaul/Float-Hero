# Float Hero — Mobile Idle Game

A **pixelated, mobile-first idle/roguelike game** built with **Flutter + Flame**, inspired by Task Bar Hero. Float Hero combines passive income mechanics with strategic roguelike runs for a rewarding, bite-sized gaming experience.

**Status:** 🟢 **Playable MVP** (Weeks 1–2 complete) | 🟡 **Week 3–4 in progress**

---

## 🎮 Overview

**Float Hero** is an Android-only (MVP) idle game where:
- **Passive income** generates gold automatically ($/sec)
- **Tap multiplier** accelerates earnings (1.5x per tap)
- **Hero roster** unlocks with progressively higher costs
- **Roguelike runs** (5–10 min) offer strategic combat, loot, and replayability
- **Floating bubble overlay** keeps the game ticking while your phone is locked *(Week 3)*
- **Pixel art aesthetic** stays charming and production-efficient

### Core Fantasy
> **Rise from the bottom of the taskbar to hero** — incremental power fantasy with instant gratification, offline earnings, and strategic depth.

---

## ✨ Features

### ✅ Implemented (Weeks 1–2)

#### **Week 1: Core Idle Loop**
- ✅ Passive income generator ($/sec ticker, updates every 100ms)
- ✅ Tap-to-accelerate (1.5x multiplier on tap)
- ✅ Hero roster with unlock progression
- ✅ Upgrade shop (income multipliers, tap power scaling)
- ✅ Persistent save/load via **SQLite** (auto-save every 5 sec)
- ✅ Offline earnings calculation on app relaunch
- ✅ State management via listener pattern + Flutter Provider

#### **Week 2: Roguelike Run System**
- ✅ **Wave-based combat** (1–5 waves, difficulty scales)
- ✅ **Hero selection** before run start
- ✅ **Enemy AI** (auto-attack every 500ms)
- ✅ **Tap-to-attack** hero action
- ✅ **Loot system** (gold drops, XP rewards)
- ✅ **Loot carry-back** (50% loss on defeat, full gain on victory)
- ✅ **Run summary screen** with stats
- ✅ **Roguelike run UI** (health bars, wave counter, enemy list)

### 🟡 In Progress (Weeks 3–4)

#### **Week 3: Floating Bubble & Art**
- 🟡 Floating bubble overlay (Android chat-head style)
- 🟡 Foreground service (idle income while backgrounded)
- 🟡 Hero sprite assets (pixel art, 32x32 base)
- 🟡 Enemy sprite assets
- 🟡 HUD display in bubble (live gold/$sec counter)

#### **Week 4: Polish & VFX**
- 🟡 VFX system (number pops, screen shake, hit flash)
- 🟡 SFX integration (8-bit chiptune, <100KB/sound)
- 🟡 UI transitions (smooth screen fades, button animations)
- 🟡 Balance pass (hero costs, enemy difficulty curve)
- 🟡 Physical device testing (Android 9+ validation)

### ❌ Not in MVP

- ❌ iOS support (Android-only; iOS deferred post-MVP)
- ❌ Procedural roguelike rooms
- ❌ Hero gacha/randomization
- ❌ Leaderboards or multiplayer
- ❌ Live event scheduling
- ❌ Cloud sync (local SQLite only)

---

## 🏗️ Architecture

### Folder Structure
```
app/
├── lib/
│   ├── main.dart                      # Entry point, game initialization
│   ├── game/
│   │   ├── float_hero_game.dart       # Flame game scaffold
│   │   ├── components/                # Flame game entities (soon)
│   │   ├── systems/                   # Physics, animation, VFX (soon)
│   │   └── particles/                 # Particle effects (soon)
│   ├── game_state/
│   │   ├── models/
│   │   │   ├── game_hero.dart         # Hero data model
│   │   │   ├── upgrade.dart           # Upgrade data model
│   │   │   ├── run_state.dart         # Roguelike run state
│   │   │   └── game_save.dart         # Full save snapshot
│   │   ├── managers/
│   │   │   ├── economy_manager.dart   # Income, purchases, upgrades
│   │   │   └── run_manager.dart       # Roguelike combat & waves
│   │   └── services/
│   │       └── persistence_service.dart # SQLite auto-save
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── idle_screen.dart       # Main idle loop UI
│   │   │   ├── shop_screen.dart       # Hero & upgrade shop
│   │   │   └── run_screen.dart        # Roguelike combat arena
│   │   ├── widgets/                   # Reusable UI components (soon)
│   │   └── theme/
│   │       └── game_theme.dart        # Colors, typography
│   ├── bubble/                        # Floating overlay (Week 3)
│   └── data/
│       ├── database/
│       │   └── db_helper.dart         # SQLite CRUD
│       └── repositories/              # Data layer (soon)
├── android/
│   ├── app/src/main/AndroidManifest.xml  # Permissions, activities
│   ├── gradle/wrapper/gradle-wrapper.properties
│   ├── gradle.properties               # Gradle config, JVM args
│   └── settings.gradle.kts            # AGP version (9.0.1)
├── pubspec.yaml                        # Dependencies
└── test/                               # Unit/widget tests

context/                                # Design docs (read-only archive)
├── Home.md
├── Core-Concept.md
├── Design-Pillars.md
├── Tech-Stack.md
├── MVP-Scope.md
├── Event-Roadmap.md
└── Open-Questions.md
```

### State Management
- **Game State** ← Managed by `EconomyManager` + `RunManager`
- **UI Listeners** ← Manager callbacks trigger `setState()` in Flutter widgets
- **Persistence** ← `PersistenceService` auto-saves every 5 sec to SQLite
- **No Redux/BLoC** ← Lightweight observer pattern for idle game (scales to ~100K objects before optimization needed)

### Key Design Decisions

| Decision | Why |
|----------|-----|
| **Flutter + Flame** | Floating bubble overlay requires flutter; Flame handles game loop |
| **SQLite** | Structured save data, fast queries; scales better than SharedPreferences |
| **Listener pattern** | Low boilerplate for idle game; avoids BLoC overhead |
| **Android-only MVP** | iOS floating bubble not possible (OS-level sandbox); deferred post-MVP |
| **Pixel art** | Fast iteration (<2 hrs/sprite); charming aesthetic; small assets |

---

## 🚀 Building & Running

### Prerequisites
- **Flutter:** 3.47.2 (latest stable — required for AGP 9 compatibility)
- **Dart:** 3.13.2
- **Android SDK:** API 28+ (target: API 36)
- **JDK:** 17+ (for Gradle 9)
- **Device:** Physical Android phone with USB debugging enabled

### Setup

```bash
# Clone repo
git clone https://github.com/mailmaul/Float-Hero.git
cd Float-Hero/app

# Install dependencies
flutter pub get

# Verify setup
flutter doctor
```

### Build & Deploy

```bash
# List connected devices
flutter devices

# Run on device (first build: 5–10 min)
flutter run -d <device_id>

# Run in release mode (faster gameplay)
flutter run --release -d <device_id>

# Build APK only
flutter build apk --release
```

### Build Troubleshooting

**Issue:** `Gradle task assembleDebug failed`
- **Fix:** Ensure `android.newDsl=false` in `gradle.properties` (AGP 9 compatibility)

**Issue:** `Unresolved reference 'fileMode'`
- **Fix:** Update Flutter to 3.47+ (earlier versions have AGP 9 bugs)

**Issue:** Device not detected
- **Fix:** Enable USB Debugging on phone (`Settings > Developer Options > USB Debugging`)
- Run `adb devices` to verify connection

---

## 📊 Current State

### Metrics (Weeks 1–2)
| Metric | Value |
|--------|-------|
| Lines of code | ~2,500 |
| Architecture layers | 5 (UI, State, Game, Data, Persistence) |
| Test coverage | 0% (tests added in Week 4) |
| Performance (target) | 60 FPS on Android 9+ |
| APK size (debug) | ~120 MB |
| Auto-save interval | 5 seconds |
| Combat tick rate | 500ms (2 ticks/sec) |

### Known Limitations
- ⚠️ **No sprite art yet** (placeholder icons; Fadil to deliver Week 3)
- ⚠️ **No sound** (audio/SFX added Week 4)
- ⚠️ **No VFX** (animations, screen shake, pops added Week 4)
- ⚠️ **No floating bubble** (Week 3 feature)
- ⚠️ **Basic UI only** (dark theme; final polish Week 4)

---

## 🧪 Testing

### Manual Test Checklist (Weeks 1–2)

**Idle Loop:**
- [ ] Gold increases passively (~1/sec)
- [ ] TAP button adds 1.5x income instantly
- [ ] SHOP: Can buy hero "Spark" (costs 10 gold)
- [ ] SHOP: Can purchase upgrades (income multiplier scales cost)
- [ ] Gold persists after app restart
- [ ] Offline earnings calculated on relaunch (e.g., 30 sec offline = +30 gold)

**Roguelike Run:**
- [ ] RUN button starts a combat arena
- [ ] Hero health decreases when enemies attack (500ms ticks)
- [ ] Tap ATTACK! button damages first enemy
- [ ] Dead enemies are removed from list
- [ ] Wave counter increments after wave 1–5
- [ ] Gold/XP displayed live during run
- [ ] Run ends when hero health ≤ 0 or wave 5 completed
- [ ] Gold earned during run is added to idle gold on return
- [ ] No crashes after 3+ consecutive runs

**State Persistence:**
- [ ] Save data survives app restart
- [ ] Offline earnings calculated correctly
- [ ] Hero unlock state persists
- [ ] Upgrade levels persist

### Automated Tests (Week 4)

- Unit tests for `EconomyManager` (income calc, purchases)
- Unit tests for `RunManager` (combat, loot, waves)
- Widget tests for `IdleScreen`, `ShopScreen`, `RunScreen`
- Integration tests for full game flow (5 min timeout)

---

## 📋 Roadmap

### Week 3: Bubble & Art (Current)
- [ ] Implement floating bubble overlay widget
- [ ] Set up foreground service (keep income ticking while backgrounded)
- [ ] Integrate hero/enemy sprite assets
- [ ] Create HUD display in bubble (live gold counter)
- [ ] Physical device testing (60 FPS validation)

### Week 4: Polish & Launch
- [ ] VFX system (number pops, screen shake, hit flash)
- [ ] SFX integration (8-bit chiptune, tap/purchase/run-end sounds)
- [ ] UI transitions (smooth fades, button animations)
- [ ] Balance pass (hero costs, enemy difficulty, income scaling)
- [ ] Final testing on Android 9–16 devices
- [ ] Build final APK for event submission (Ludum Dare / app store)

### Post-MVP (Future)
- 🔮 **iOS support** (normal in-app UI; floating bubble not possible)
- 🔮 **Procedural roguelike rooms** (tileset variety, boss encounters)
- 🔮 **Hero gacha system** (randomized runs, rare heroes)
- 🔮 **Leaderboards** (cloud sync via Firebase)
- 🔮 **Live events** (seasonal content, limited-time heroes)
- 🔮 **Prestige system** (soft reset with permanent bonuses)

---

## 🤝 Contributing

### Development Setup
```bash
# Install Flutter/Dart skills (recommended)
npx skills add dart-lang/skills
npx skills add flutter/agent-plugins

# Format code
dart format lib/ test/

# Analyze for issues
flutter analyze

# Run tests (Week 4+)
flutter test
```

### Code Style
- **Dart style guide:** https://dart.dev/guides/language/effective-dart/style
- **Max line length:** 80 chars (flexible for URLs/long names)
- **Naming:** camelCase for variables/methods, PascalCase for classes
- **Comments:** Doc comments (`///`) on public APIs; inline for complex logic

### PR Process
1. Create a feature branch: `git checkout -b feat/your-feature`
2. Make changes, test locally
3. `flutter analyze` must pass
4. Commit with clear messages: `feat: add VFX for enemy hit`
5. Push and open PR with description of changes

---

## 📄 License

Float Hero is **open source** (license TBD — currently private repo).

---

## 👥 Team

| Role | Name |
|------|------|
| Design + Dev | You (maulmaul) |
| Art | Fadil |
| Design Assist | nuga |

---

## 📞 Questions?

Refer to:
- **Architecture & design:** `context/` folder (design docs)
- **API/integration:** Code comments + this README
- **Troubleshooting:** Build section above

---

**Last Updated:** 2026-09-04 (Week 2 complete)  
**Next Milestone:** Week 3 (Bubble + Art) — Target: 2026-09-11
