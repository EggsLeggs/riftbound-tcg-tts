"""Extract Lua scripts and XmlUI from the TTS save into a readable source tree.

Run from the repo root:
    python3 tools/extract.py

Reads mod/Riftbound.json. Writes:
    scripts/global.lua
    scripts/objects/{GUID}_{slug}.lua  (one per scripted object, including nested)
    ui/global.xml

Safe to re-run; overwrites existing files.
"""
import json
import re
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SAVE = REPO / 'mod' / 'Riftbound.json'


def slug(s: str) -> str:
    """Turn an object nickname into a safe filename fragment."""
    if not s:
        return 'unnamed'
    # Strip TTS rich text tags like [b]...[/b], [00B4FF], [-]
    s = re.sub(r'\[/?[A-Za-z0-9]*\]', '', s)
    s = re.sub(r'[^A-Za-z0-9]+', '_', s).strip('_').lower()
    return s[:50] or 'unnamed'


def walk(obj, seen, out_dir):
    if not isinstance(obj, dict):
        return
    guid = obj.get('GUID')
    script = obj.get('LuaScript') or ''
    if guid and script and guid not in seen:
        seen.add(guid)
        nick = obj.get('Nickname') or obj.get('Name', 'unknown')
        fname = f"{guid}_{slug(nick)}.lua"
        (out_dir / fname).write_bytes(script.encode('utf-8'))
    for child in (obj.get('ContainedObjects') or []):
        walk(child, seen, out_dir)
    for child in (obj.get('ChildObjects') or []):
        walk(child, seen, out_dir)
    for state_obj in (obj.get('States') or {}).values():
        walk(state_obj, seen, out_dir)


def main():
    with open(SAVE) as f:
        data = json.load(f)

    # Write bytes with newline='' equivalent: preserve \r\n exactly as TTS stored it.
    (REPO / 'scripts' / 'global.lua').write_bytes(
        data.get('LuaScript', '').encode('utf-8'))
    (REPO / 'ui' / 'global.xml').write_bytes(
        data.get('XmlUI', '').encode('utf-8'))

    obj_dir = REPO / 'scripts' / 'objects'
    obj_dir.mkdir(parents=True, exist_ok=True)
    seen = set()
    for top in data.get('ObjectStates', []):
        walk(top, seen, obj_dir)

    print(f"Extracted {len(seen)} object scripts -> scripts/objects/")
    print(f"Wrote scripts/global.lua ({len(data.get('LuaScript', ''))} chars)")
    print(f"Wrote ui/global.xml ({len(data.get('XmlUI', ''))} chars)")


if __name__ == '__main__':
    main()
