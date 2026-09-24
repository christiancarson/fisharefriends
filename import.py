import pathlib, re, datetime, subprocess, plistlib, tomllib, json
from PIL import Image, ImageOps
src = pathlib.Path.home() / "Desktop" / "fish_are_friends"
dst = pathlib.Path("content/posts")
months = {m: i for i, m in enumerate(["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"], 1)}
clean = lambda s: re.sub(r"\s+", " ", s.replace("_", " ")).strip()
params = tomllib.loads(pathlib.Path("hugo.toml").read_text())["params"]
waters = {**params.get("tags", {}), **params.get("waters", {})}
species = tomllib.loads(pathlib.Path("data/species.toml").read_text())
water = lambda t: re.search(r" (River|Creek|Lake|Estuary|Harbour|Bay|Sound|Inlet|Ocean)$", t) is not None
group = lambda t: {"River": "rivers", "Creek": "rivers", "Lake": "lakes", "Estuary": "estuaries"}.get(t.split()[-1], "oceans")
def finder_tags(f):
    h = subprocess.run(["xattr", "-px", "com.apple.metadata:_kMDItemUserTags", str(f)], capture_output=True, text=True).stdout
    return [clean(t.split("\n")[0]) for t in plistlib.loads(bytes.fromhex(re.sub(r"\s", "", h)))] if h.strip() else []
slugify = lambda s: re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")
for folder in sorted(p for p in src.iterdir() if p.is_dir()):
    parts = folder.name.split("__")
    m = re.match(r"([A-Za-z]+)[ _](\d{4})", parts[0])
    if not m: continue
    date = datetime.date(int(m.group(2)), months[m.group(1).lower()], 1)
    title = clean(parts[1]) if len(parts) > 1 else f"{m.group(1).lower()} {m.group(2)}"
    out = dst / f"{date:%Y-%m}-{slugify(title)}"
    out.mkdir(parents=True, exist_ok=True)
    photos, home, videos, tags = [], [], [], set()
    for f in sorted(p for p in folder.iterdir() if not p.name.startswith(".")):
        bits = f.stem.split("__")
        name = clean(bits[0])
        desc = (folder / (bits[0] + ".txt")).read_text().strip() if (folder / (bits[0] + ".txt")).exists() else ""
        if f.suffix.lower() in (".jpg", ".jpeg", ".png", ".heic"):
            tag = [x for x in (waters.get(t, t) for t in finder_tags(f) or ([clean(t) for t in bits[1].split(",")] if len(bits) > 1 else ["fish"])) if x] or ["fish"]
            tags.update(tag)
            if any(slugify(t) in species for t in tag): tags.add("fish")
            for t in tag: name = clean(re.sub(r"(?i)\b" + re.escape(re.sub(r"(?i)\s+(river|lake|creek)$", "", t)) + r"(\s+(river|lake|creek))?\b", "", name)) or name
            name = re.sub(r"(?i)\s+(from|at|on|in|of|the|and|with)$", "", name)
            jpg = out / (slugify(name) + ".jpg")
            if not jpg.exists() or jpg.stat().st_mtime < f.stat().st_mtime:
                im = ImageOps.exif_transpose(Image.open(f)).convert("RGB")
                im.thumbnail((1600, 1600))
                im = ImageOps.fit(im, (1600, 900))
                im.save(jpg, quality=85)
            photos.append((sorted(t for t in tag if water(t)) or home[:1], f'![{desc}]({jpg.name} "{name} | {", ".join(tag)}")'))
        elif f.suffix == ".river":
            tags.update([name] + finder_tags(f))
            home.append(name)
        elif f.suffix == ".video":
            tags.update(["music"] + finder_tags(f))
            videos.append(f'{{{{< video {bits[1]} "{name}" >}}}}{desc}{{{{< /video >}}}}')
    cards = []
    for t in sorted(t for t in tags if water(t)):
        if not pathlib.Path(f"assets/maps/{slugify(t)}.svg").exists() and subprocess.run(["Rscript", "maps.R", t]).returncode: continue
        note = folder / (t.replace(" ", "_") + ".txt")
        if note.exists():
            d = pathlib.Path("data/rivers.toml")
            d.write_text(re.sub(r'(\["%s"\]\ntitle = "[^"]*"\nabout = )"[^"]*"' % re.escape(slugify(t)), lambda m: m.group(1) + json.dumps(note.read_text().strip()), d.read_text()))
        tags.update([group(t), "water"])
        cards.append('<div class="water">\n\n' + "\n\n".join([f'{{{{< map "{t}" >}}}}'] + [p for w, p in photos if w and w[0] == t]) + '\n\n</div>')
    cards += [p for w, p in photos if not w or not pathlib.Path(f"assets/maps/{slugify(w[0])}.svg").exists()] + videos
    for old in out.glob("*.jpg"):
        if old.name not in {p.split("](")[1].split(" ")[0] for w, p in photos}: old.unlink()
    if not cards: continue
    (out / "index.md").write_text(f'---\ntitle: "{title}"\ndate: {date}T12:00:00-07:00\ncategories: [{", ".join(sorted(tags))}]\n---\n' + "\n\n".join(cards) + "\n")
    print(out.name, len(cards))
