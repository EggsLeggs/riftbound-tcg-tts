
# Components to keep

Objects confirmed for the Riftbound build.

---

## Zone / trigger infrastructure

Invisible TTS objects that define hand zones and scripting regions.

| GUID | Object |
|------|--------|
| 360dc1, 640235, a11f20, 7295a1 | HandTrigger ×4 (seats 1–4) |
| b798d6, 350f7f, 993f89, bb8c76 | HandTrigger ×4 (seats 5–8) |
| c20e3f, 8b3401, 56cd9d, 129eaa, 2365d0, 166036 | ScriptingTrigger ×6 |
| c04462, 033b34, 07dd80, 8b439a, debc40, 68549d | ScriptingTrigger ×6 |

---

## Core engine (load-bearing)

| GUID | Object |
|------|--------|
| 02e062 | Encoder — central API hub; `onload` depends on it |
| b93b40 | TyrantNomad's Easy Modules Unified |
| 82bf98 | PiecePack_Crowns (supports Easy Modules) |
| cd83de | Auto Player Promoter |
| b8b8df | Color Module |
| c369d7 | πMenu |
| 7a0067 | πNotepad |
| de4346 | πScry |
| def0af | πCounter |

---

## Per-player UI — 4× symmetrical sets

> **Needs Riftbound layout work.** Zone names (Untap/Scry/Mill), mulligan
> rules, and the overall action buttons will need updating for Riftbound's
> turn structure. The infrastructure (life trackers, hand counters, timers,
> highlight mats, reveal) is reusable as-is.

| GUID | Object |
|------|--------|
| 23e485, 448880, 37e533, 395037 | Life Tracker ×4 |
| 2f714c, 25f80a, 5b0cc8, b40ce7 | Hand Counter ×4 |
| 9d9dda, 0af44c, 9243e9, d29299 | Hand Counter (Self) ×4 |
| 3d7324, 5137aa, fcb7b5, 4563bf | Hand Counter Screen ×4 |
| 809133, 29f427, 57b8f3, 9df6a3 | Timer ×4 |
| 5cb175, 40b95f, a42baa, d1ae7b | Highlight Mat ×4 |
| c53ac6, 3b07ae, 47645d, e0a3bc | Mulligan tile ×4 |
| 86e447, 18fb5d, e2f7ae, 1f3e4a | Untap button ×4 |
| 885f49, 26775a, b49d50, 305c12 | Draw button ×4 |
| ffa67c, 614515, 4e19c8, 8a4c8b | Scry button ×4 |
| da5d0d, 57914a, d06889, 67b4a5 | Mill button ×4 |
| d67eb4, 0ad181, 59ab68, c489e1 | Reveal button ×4 |

---

## Counters and tokens

> **Note:** The +X/+Y Counter bags need to be relabeled / retextured as Might
> counters (or whatever Riftbound's stat-modifier equivalent is).

| GUID | Object |
|------|--------|
| beb998, d82eb8 | +X/+Y Counter bags ×2 |
| 4256ba, 917dc3 | Generic Counter bags ×2 |
| b02684, 7eeb77 | Text + Counter bags ×2 |
| 855d09, 195243 | Notecard bags ×2 |
| 3c7ad3, 82e64d | Drop-On-Card Counter bags ×2 |

---

## Turn / phase utilities

| GUID | Object | Note |
|------|--------|------|
| b653d2, 05b07c | Turn Skipper Puck ×2 | |
| aea3f4, 633ed3 | Turn Order card ×2 | |
| dc2d88 | Smart Mulligan | |
| 0ae315 | 4p playmat enabler | Chat command: `playmat <url>` / `playmat none` — game-agnostic |

---

## Fun props / table atmosphere

| GUID | Object | Note |
|------|--------|------|
| 540e21 | Pirate Cannon | Fires selected objects with physics; integrates with Who Goes First die |
| 5a7db4 | Bruh Button | |
| ee33ec | Who Goes First? (custom dice) | Sets turn order automatically when die lands |

---

## Dice

| GUID | Object |
|------|--------|
| 1d701a, ae70ca | d20 ×2 |
| 5c471e, e3ecb3 | d12 ×2 |
| 544ef3, 64d53e | d10 ×2 |
| 14da25, fcd8d9 | d8 ×2 |
| 979e78, b8b9ed | d6 ×2 |
| e86d81, cbcbea | d4 ×2 |
| 9cf532 | d2 ×1 |

---

## General utilities

| GUID | Object | Note |
|------|--------|------|
| fb6538 | hold alt (context-menu helper) | |
| 716ee6 | Is it a token? | |
| 7cf430 | Custom_Tile (scripted) | Purpose unknown — do not remove until identified |

---

## Unnamed / unidentified objects

Unknown purpose — do not remove until identified.

| GUID | Type |
|------|------|
| eb479b, a3e6a8, a7a029, 4c02f8, 9c553c, cb1610 | Custom_Assetbundle ×6 |
| 3d4319 | Custom_Model |

---

## Needs Riftbound update

Objects kept in the mod but requiring content changes before the table is
Riftbound-native.

### Finished rewrites

Components fully rewritten for Riftbound and no longer pending migration.

| GUID | Object |
|------|--------|
| c91a72, f4d8be | Riftbound Deck Loader ×2 — completely overhauled for Riftbound (legacy GUIDs: 5aebeb, 3ede22) |

### Keyword tokens

MTG keyword tokens (Defender, Flying, Hexproof, etc.). Keep the infinite bag
+ token infrastructure; replace artwork and labels with Riftbound status
keywords once the keyword set is known.

Two full sets (one per table half).

| Objects |
|---------|
| Defender, Deathtouch, Double Strike, First Strike, Flying, Hexproof, Haste |
| Indestructible, Lifelink, Menace, Monstrous, Reach, Trample, Vigilance |
| Goaded, Frozen |

### Mana / resource counters

MTG mana counters (Blue, Green, Red, etc.) and Suspend counters. Retexture
and relabel for Riftbound resource or status counters.

Two full sets (one per table half).

| Objects |
|---------|
| Blue, Green, Red, Black, White, Colorless Mana Counter ×2 sets |
| Suspend Counter ×2 sets |

### Deck importer

| GUID | Object |
|------|--------|
| 5006a4 | Deck Lister |

### πKeywords (ae12d3)

TyrantNomad keyword reference popup. Currently shows MTG keyword definitions
on right-click. Update the keyword list and definitions to match Riftbound's
keyword set.

### Chat Commands tile (7b59f7)

Currently lists MTG-specific chat commands. Update to document Riftbound
chat commands (including `playmat`).

### Table Instructions tile (e40450)

Currently shows MTG rules and setup instructions. Rewrite for Riftbound.
The × button that removes table clutter will need its `unnecessaryStuff`
GUID list updated as more objects are removed.
