# Home-Screen App Widget Plan

**Status: 🟡 PROPOSED — awaiting decision on rendering approach + surface role**

Links back to [[Home]]. Related: [[Tech-Stack]] (floating bubble), [[MVP-Scope]], [[Core-Concept]], [[Open-Questions]].

> Goal: add a **standard Android home-screen App Widget** (like the WhatsApp widget) that shows the hero fighting enemies — meant to be the *core always-visible surface* of Float Hero, echoing the "taskbar hero" fantasy.

---

## TL;DR — Is it possible?

**Yes, a real App Widget is possible. No, it cannot be a live 60fps Flame battle.**

Home-screen widgets are **RemoteViews**, drawn by the launcher's process — there is **no Flutter engine, no Canvas/SurfaceView, no real-time game loop** available on the widget itself. "Live fighting" is achieved by combining:

1. **Looping sprite frames** (`ViewFlipper` / `AdapterViewFlipper`) — auto-cycles pre-rendered frames on the launcher's own timer → continuous "aliveness" with **zero battery cost and zero pushes**.
2. **Periodic scene snapshots** — render the battle as a Flutter widget → PNG via `HomeWidget.renderFlutterWidget`, push into an `ImageView`. Reflects *real* state (which enemy, HP, action) but every push is a RemoteViews update → **throttled** (seconds while active, minutes while idle).
3. **Native stat views** — `ProgressBar` for hero/enemy HP, `TextView` for gold/wave.
4. **Tap → `PendingIntent`** opens the app; optionally an interactive button runs Dart in the background (attack/claim) with ~1–2s cold-start latency.

### Widget vs. the already-planned Floating Bubble — do not conflate

| | **Home-screen App Widget** (this doc) | **Floating Bubble overlay** ([[Tech-Stack]]) |
|---|---|---|
| Mechanism | RemoteViews in launcher process | `SYSTEM_ALERT_WINDOW` + real Flutter/Flame view |
| Truly live animation | ❌ looped frames / throttled snapshots | ✅ real-time render (it's an actual Flutter surface) |
| Always visible | ✅ on home screen without launching | Only while overlay toggled on + service running |
| Interactivity | Tap-to-open / background Dart action | Full touch, drag, tap-to-expand |
| Battery/permission | Light; WorkManager throttled | Heavier; foreground service + overlay permission |

**Decision to lock (see [[Open-Questions]]):** if "hero visibly fighting in real time" is non-negotiable, the **bubble** is the live surface and the **widget** is the lightweight status/ambient loop. They can coexist and share the same state bridge.

---

## Recommended MVP shape

- **Ambient loop, push-free:** `ViewFlipper` cycles a short hero idle/attack sprite loop so the widget always looks alive even when the app is closed.
- **State overlay:** hero HP + enemy HP as `ProgressBar`s, gold + wave as `TextView`s, refreshed on real state changes.
- **Scene fidelity (phase 3+):** replace/augment the loop with a `renderFlutterWidget` snapshot of the actual Flame scene so it reflects the true fight, pushed on app events + a periodic background refresh.
- **Tap the widget → open the app** at the run/idle screen. Interactive "attack/claim" is a later optional layer.

---

## Architecture

```
Flutter (Dart)                         Native (Kotlin)                 Launcher
─────────────                          ───────────────                 ────────
EconomyManager / RunManager            FloatHeroWidgetProvider          RemoteViews
   (ChangeNotifier)                      extends HomeWidgetProvider        float_hero_widget.xml
        │ listener                            │ onUpdate()                   ├─ ViewFlipper (hero frames)
        ▼                                     ▼ reads SharedPreferences      ├─ ImageView  (enemy / scene bmp)
   WidgetBridge (new)                    build RemoteViews  ───────────────▶ ├─ ProgressBar x2 (HP)
    HomeWidget.saveWidgetData(...)            │ setImageViewBitmap           ├─ TextView   (gold / wave)
    HomeWidget.renderFlutterWidget(...)       │ setProgressBar               └─ root PendingIntent → app
    HomeWidget.updateWidget(name:)            │ setTextViewText
        ▲ background (workmanager)            ▲
        └──────── HomeWidget.registerBackgroundCallback / interactivity ─────┘
```

- **Shared state store:** `home_widget` writes to Android `SharedPreferences` group (`HomeWidget.saveWidgetData<T>`). Single source of truth pushed from Dart.
- **State mapped:** `gold`, `incomePerSecond`, `wave`, `heroHpPct`, `enemyHpPct`, `action` (idle/attack/hurt), `sceneBitmap` (optional PNG path), `runActive`.
- **Bridge hook:** our managers already extend `ChangeNotifier` (from the recent refactor) — `WidgetBridge` subscribes and debounces pushes (e.g. max 1/sec while foreground). Also flush on `AppLifecycleState.paused` (mirrors the save-on-pause we just added in `main.dart`).
- **Package set:** `home_widget: ^0.9.x` (Flutter≥3.38/SDK≥3.10 — our SDK is `^3.8.1`, **verify/bump**), `workmanager` for periodic background refresh.

### Native files to add (Android)
- `android/app/src/main/kotlin/com/floathero/float_hero/FloatHeroWidgetProvider.kt`
- `android/app/src/main/res/layout/float_hero_widget.xml` (FrameLayout + ViewFlipper + ImageView + 2×ProgressBar + TextViews)
- `android/app/src/main/res/xml/float_hero_widget_info.xml` (`AppWidgetProviderInfo`: initialLayout, minWidth/Height, `updatePeriodMillis`, previewImage, `resizeMode`, `widgetCategory="home_screen"`)
- `AndroidManifest.xml`: `<receiver android:name=".FloatHeroWidgetProvider" android:exported="false">` with `APPWIDGET_UPDATE` intent-filter + meta-data pointing at the info XML.
- Sprite frames as `drawable-*` (for ViewFlipper) — from Fadil ([[Team-Roles]]).

---

## Update cadence — the hard limits (be realistic)

- Native `updatePeriodMillis` **minimum is 30 min** (1,800,000 ms). Anything faster needs a scheduler.
- `WorkManager` periodic minimum is **15 min**; exact `AlarmManager` alarms are **restricted on Android 12+/13+** (need `SCHEDULE_EXACT_ALARM`/user permission).
- Aggressive OEM battery killers (Xiaomi/Oppo/Samsung) may throttle background updates further.

**Cadence model:**
- **Idle/closed:** ViewFlipper loop animates for free; stats refresh via WorkManager (~15 min) — enough for an idle game.
- **App foreground / backgrounded-with-service:** push every N seconds for near-live reflection.
- Do **not** promise second-by-second combat on the widget while the app is fully killed — the OS won't allow it without a persistent foreground service (battery cost).

---

## Phased execution

### Phase 0 — Decide & spec
- [ ] Lock: widget = ambient/status surface, bubble = live surface? (or widget-only?)
- [ ] Lock rendering approach: **A** ViewFlipper native frames (push-free loop, fixed animation) vs **B** `renderFlutterWidget` snapshot (reuses Flame art, reflects real fight, throttled) vs **Hybrid** (A for idle loop + B on events). *Recommended: Hybrid, ship B-on-events first.*
- [ ] Art list from Fadil: hero idle loop (4–6 frames), attack loop, enemy frame(s), widget background matching `#1a1a2e`.

### Phase 1 — Native scaffold (static)
- [ ] Add `home_widget`; bump `environment.sdk` if needed.
- [ ] Provider + layout XML + info XML + manifest receiver.
- [ ] Widget appears in launcher picker, shows dummy hero + HP bars, tap opens app.

### Phase 2 — Data bridge (real stats)
- [ ] `WidgetBridge` (Dart): map manager state → `saveWidgetData` + `updateWidget`.
- [ ] Subscribe to `EconomyManager`/`RunManager` ChangeNotifier; debounce; flush on pause.
- [ ] ProgressBars + TextViews reflect real gold/wave/hero HP/enemy HP.

### Phase 3 — Scene rendering
- [ ] Build a compact `BattleScene` Flutter widget reusing existing sprites.
- [ ] `renderFlutterWidget` → PNG → `setImageViewBitmap` on each state push.

### Phase 4 — Background refresh
- [ ] `workmanager` periodic task → recompute offline progress → push.
- [ ] Handle Android 12+ constraints; graceful when throttled.

### Phase 5 — Interactivity (optional)
- [ ] `registerInteractivityCallback` + background: widget "Attack"/"Claim" runs Dart, mutates state + save, re-renders. Document cold-start latency.

### Phase 6 — Polish
- [ ] ViewFlipper idle shimmer, resize support, preview image, multiple sizes, theming, victory/defeat flourish.

---

## Risks & constraints
- **No live real-time render on the widget** — expectation management with stakeholders is the #1 risk given "main core / exactly like taskbar hero."
- **Update throttling & battery** — OS limits + OEM killers cap freshness.
- **`renderFlutterWidget` in background** needs an attachable engine context; background snapshots have caveats — validate early.
- **Build/verify blocker:** Android SDK not installed on this machine (see [[Home]] log 2026-09-04). A device/emulator is required to see the widget at all — **cannot be verified locally until the toolchain is set up.**
- **SDK version:** `home_widget` 0.9.x wants Flutter ≥3.38 / Dart ≥3.10; current pubspec is `sdk: ^3.8.1` — confirm the installed Flutter (Home.md notes 3.44.8) and set constraints accordingly, or pin an older `home_widget`.
- **Art dependency** on Fadil for frame sets.

## Open questions (mirror to [[Open-Questions]])
1. Is the home widget the "core" surface, or does the **floating bubble** own the live fight and the widget just mirrors state?
2. Rendering approach A / B / Hybrid?
3. Should the widget be **interactive** (tap = attack/claim) or **display-only + open app**?
4. Acceptable freshness vs battery (foreground service yes/no)?
5. Minimum Android version and target launcher sizes (1×1, 2×2, 4×2)?

---

## Log
- **2026-09-04 — Plan drafted** — Home-screen App Widget scoped via `home_widget` + native RemoteViews + `workmanager`. Confirmed feasible but **not a live Flame render**; "fighting" = ViewFlipper loop + throttled `renderFlutterWidget` snapshots + native HP/gold views. Flagged overlap with the [[Tech-Stack]] floating bubble (the actually-live surface) — needs a role decision before Phase 1.
