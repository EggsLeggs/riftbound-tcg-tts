# Riftbound TCG — Tabletop Simulator Table

A scripted Tabletop Simulator table for the Riftbound TCG, forked from the excellent
[MTG 4 player table - scripted](https://steamcommunity.com/sharedfiles/filedetails/?id=2296042369)
by Oops I Baked a Pie.

This is a work in progress. Reskinning a mature MTG mod into a Riftbound-native
table — different zones, different counters, deck importer pointed at Riftseer
instead of Scryfall, no mana bags, etc.

## Credits

The original mod is the work of several authors over five years. None of the
scripted infrastructure in this repo is mine in origin:

- **Oops I Baked a Pie** — original table, global script, life trackers, overall design
- **TyrantNomad** — Easy Modules Unified, the πMenu / πNotepad / πScry / πKeywords suite
- **rikrassen** — MTG Deck/Draft/Cube Importer
- Encoder API author (unattributed in source — happy to credit if identified)

If you're one of the above and want changes to attribution or licensing here, open an issue.

## Repo layout

```
mod/Riftbound.json       The TTS save file. This is what TTS loads.
scripts/global.lua       Global script (extracted from the JSON).
scripts/objects/*.lua    One file per scripted object, named {GUID}_{slug}.lua.
ui/global.xml            Global XmlUI (extracted from the JSON).
tools/extract.py         Pull scripts/UI out of the JSON into source files.
tools/inject.py          Push scripts/UI back into the JSON.
```

The `.lua` and `.xml` files are the readable source of truth. The JSON is the
build artifact TTS actually loads. Both are committed so the mod is loadable
straight from a clone.

## Workflow

### One-time setup (macOS)

```bash
# Clone the repo
git clone git@github.com:YOUR_USERNAME/riftbound-tcg-tts.git
cd riftbound-tcg-tts

# Symlink the save into TTS so editing in the repo is editing in TTS
ln -s "$(pwd)/mod/Riftbound.json" ~/Library/Tabletop\ Simulator/Saves/Riftbound.json
```

Install the [Tabletop Simulator Lua](https://marketplace.visualstudio.com/items?itemName=rolandostar.tabletopsimulator-lua)
VS Code extension. Configure it to use this repo's `scripts/` folder.

### Edit / test cycle

1. Launch TTS, load the Riftbound save (Save & Load → Saves).
2. In VS Code, `Cmd+Shift+P` → **Tabletop Simulator: Get Lua Scripts**.
   This pulls the current state of the mod out of the running game.
3. Edit `.lua` files in VS Code.
4. `Cmd+Shift+P` → **Tabletop Simulator: Save And Play**. TTS reloads with the changes.
5. When happy, save in TTS (this updates `mod/Riftbound.json`). Commit both
   the JSON and the changed `.lua` files.

### Rebuilding the JSON manually

If the JSON gets out of sync with the source files (or for CI):

```bash
python3 tools/inject.py
```

This rewrites `mod/Riftbound.json` using the current `.lua` and `.xml` files.

## License

The original mod has no explicit license. This fork is published in the same
spirit — free for personal use and modification, please credit upstream authors
if you fork further or publish derivatives.
