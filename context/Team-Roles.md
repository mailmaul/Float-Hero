# Team & Roles

**Status: ✅ LOCKED**

Links back to [[Home]].

## Team
- **You** (Game Design, Development, AI Engineer)
- **Fadil** (Art Direction, Pixel Designer)
- **nuga** (Design Support, Assistant)

---

## Responsibility Breakdown

### You — Game Design + Development
- **Design leadership**: Core mechanics, progression tuning, balance, roguelike run structure
- **Code**: All GDScript implementation (main.gd, player.gd, idle loop, save/load, roguelike state machine)
- **Build/export**: Handle Android/iOS builds, packaging, release pipeline
- **AI engineering**: Post-MVP — if live events or procedural generation needed, your domain

**Handoff to Fadil**: Approved design specs (pixel counts, animation frames, color palettes), clear sprite requirements, animation timing docs.

### Fadil — Art Direction + Pixel Design
- **Character design**: Hero sprites (8 idle frames, 4 attack frames, death frame each)
- **Environmental**: Tileset (background, UI panels, roguelike room layouts)
- **UI/UX polish**: Button sprites, health bars, resource icons, transition effects
- **Animation direction**: Confirm animation timing with You during implementation

**Handoff to You**: Spritesheet PNGs (organized by character/tile), palette file (for consistency), animation timing notes (e.g., "attack is frame 2–4, 0.2s per frame").

### nuga — Design Support + Flexibility
- **Narrative/flavor**: Item descriptions, hero backstories, roguelike room themes
- **Level design assist**: Help You balance roguelike run difficulty curves
- **Polish pass**: UI copywriting, SFX/music curation from itch.io freebies
- **QA feedback**: Play test runs, report bugs, suggest rebalancing

---

## Sync Cadence (Suggested)
- **Weekly design reviews** (15 min async in context notes): What's done, blockers, next sprint
- **Daily art check-ins**: Fadil uploads sprite batches; You integrate and confirm animation timing
- **Async updates**: Post status in this file's "Weekly Log" section when major milestones hit
