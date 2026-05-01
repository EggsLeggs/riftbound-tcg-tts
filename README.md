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

Additional attribution for reused assets:

- A small subset of visual assets in this fork (notably some card back art variants)
  is adapted from a community Tabletop Simulator Workshop mod. Full credit remains
  with the original Workshop author(s).

If you're one of the above and want changes to attribution or licensing here, open an issue.

## Repo layout

```
mod/Riftbound.json       The TTS save file. This is what TTS loads.
scripts/global.lua       Global script (extracted from the JSON).
scripts/objects/*.lua    One file per scripted object, named {GUID}_{slug}.lua.
ui/global.xml            Global XmlUI (extracted from the JSON).
tools/extract.py         Pull scripts/UI out of the JSON into source files.
tools/inject.py          Push scripts/UI back into the JSON.
vendor/                  Patched VS Code extension and other vendored deps.
```

The `.lua` and `.xml` files are the readable source of truth. The JSON is the
build artifact TTS actually loads. Both are committed so the mod is loadable
straight from a clone.

## Setup (macOS)

### 1. Clone

```bash
git clone git@github.com:YOUR_USERNAME/riftbound-tcg-tts.git
cd riftbound-tcg-tts
```

### 2. Symlink the save into TTS

This makes editing in the repo equivalent to editing the save TTS loads.

```bash
ln -s "$(pwd)/mod/Riftbound.json" "$HOME/Library/Tabletop Simulator/Saves/Riftbound.json"
```

In TTS: Create → Singleplayer → Save & Load → **Saves** tab → Riftbound. The
table should load identically to the original workshop mod.

### 3. Install the patched VS Code extension

The marketplace build of rolandostar's "Tabletop Simulator Lua" extension is
broken on recent VS Code versions. A patched `.vsix` is vendored in this repo
at `vendor/Tabletop Simulator Lua 1.1.3 Patched.vsix`.

If you have an old/broken version installed, uninstall it cleanly first:

```bash
# In VS Code: Extensions panel → Tabletop Simulator Lua → cog → Uninstall
# Then quit VS Code (Cmd+Q), and clear any leftover extension dir:
rm -rf ~/.vscode/extensions/rolandostar.tabletopsimulator-lua-*
```

Install the patched build:

```bash
code --install-extension "vendor/Tabletop Simulator Lua 1.1.3 Patched.vsix"
```

If `code` isn't on your PATH, install via the UI instead: `Cmd+Shift+P` →
"Extensions: Install from VSIX..." → pick `vendor/Tabletop Simulator Lua 1.1.3 Patched.vsix`.

Reopen VS Code, open this repo, then open `scripts/global.lua` to activate the
extension.

### 4. Verify the dev loop

1. Launch TTS, load the Riftbound save.
2. In VS Code: `Cmd+Shift+P` → **Tabletop Simulator: Get Lua Scripts**.
3. The extension dumps scripts into `~/Documents/Tabletop Simulator/` and
   opens them. From there, edit and use **Tabletop Simulator: Save And Play**
   to push changes back into the live game.

> **Note on script location.** The rolandostar extension dumps scripts into
> `~/Documents/Tabletop Simulator/`, not into this repo. Day-to-day editing
> happens there. When you save the mod in TTS itself (via the in-game save
> menu), the JSON in `mod/Riftbound.json` updates via the symlink — and you
> can run `python3 tools/extract.py` to regenerate the readable `.lua` files
> in `scripts/` for committing.

## Workflow

### Edit / test cycle

1. Launch TTS, load the Riftbound save.
2. `Cmd+Shift+P` → **Tabletop Simulator: Get Lua Scripts** (pulls from the running game).
3. Edit the scripts the extension opened.
4. `Cmd+Shift+P` → **Tabletop Simulator: Save And Play** (pushes back, TTS reloads).
5. When happy, save the mod in TTS itself — this writes the JSON via the symlink.
6. Run `python3 tools/extract.py` to refresh `scripts/*.lua` from the new JSON.
7. `git diff` to review, then commit both the JSON and the regenerated scripts.

### Rebuilding the JSON manually

If the JSON ever drifts from the source files (or for CI):

```bash
python3 tools/inject.py
```

This rewrites `mod/Riftbound.json` using the current `.lua` and `.xml` files.

## License

The original mod has no explicit license. This fork is published in the same
spirit — free for personal use and modification, please credit upstream authors
if you fork further or publish derivatives.