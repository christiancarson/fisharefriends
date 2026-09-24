import pathlib, re, datetime, subprocess, plistlib, tomllib, json
from PIL import Image, ImageOps
src = pathlib.Path.home() / "Desktop" / "fish_are_friends"
dst = pathlib.Path("content/posts")
months = {m: i for i, m in enumerate(["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"], 1)}
clean = lambda s: re.sub(r"\s+", " ", s.replace("_", " ").replace(".", "")).strip()
params = tomllib.loads(pathlib.Path("hugo.toml").read_text())["params"]
waters = {**params.get("tags", {}), **params.get("waters", {})}
species = tomllib.loads(pathlib.Path("data/species.toml").read_text())
kids = {k: (v["title"], v["parent"]) for k, v in tomllib.loads(pathlib.Path("data/tags.toml").read_text()).items()} if pathlib.Path("data/tags.toml").exists() else {}
parents = params.get("parents", ["friends", "fish", "music", "works", "things"])
used = set()
nest = {k.lower(): v for k, v in params.get("nest", {}).items()}
crop = pathlib.Path.home() / "Library/Caches/fisharefriends/crop"
if not crop.exists() or crop.stat().st_mtime < pathlib.Path("crop.swift").stat().st_mtime:
    crop.parent.mkdir(parents=True, exist_ok=True); subprocess.run(["swiftc", "-O", "crop.swift", "-o", str(crop)], check=True)
def gps(f):
    try:
        g = Image.open(f).getexif().get_ifd(0x8825); lat, lon = g.get(2), g.get(4)
        if not lat or not lon: return None
        dd = lambda v, r: (float(v[0]) + float(v[1]) / 60 + float(v[2]) / 3600) * (-1 if r in ("S", "W") else 1)
        return dd(lat, g.get(1)), dd(lon, g.get(3))
    except Exception: return None
def focus(im):
    small = im.copy(); small.thumbnail((1024, 1024)); tmp = pathlib.Path("/tmp/faf-focus.jpg"); small.save(tmp, quality=85)
    j = json.loads(subprocess.run([str(crop), str(tmp)], capture_output=True, text=True).stdout or "{}")
    boxes = j.get("faces") or j.get("salient") or []
    if not boxes: return 0.5, 0.5
    return (min(b[0] for b in boxes) + max(b[0] + b[2] for b in boxes)) / 2, (min(b[1] for b in boxes) + max(b[1] + b[3] for b in boxes)) / 2
latin = tomllib.loads(pathlib.Path("data/latin.toml").read_text())
isfish = lambda t: t.lower() in latin or (" " in t.strip() and re.search(r"(?i)\b(trout|salmon|char|steelhead|whitefish|grayling|varden|bass|pike|sturgeon|perch|surfperch|rockfish|greenling|sole|flounder|sanddab|halibut|cod|pollock|hake|herring|smelt|anchovy|sardine|dogfish|shark|skate|ray|sculpin|tuna|mackerel|bonito|marlin|trevally|pompano|runner|corvina|seabass|snapper|pargo|grouper|cabrilla|triggerfish|barracuda|bonefish|hogfish|needlefish|mullet|porgy|grunt|guitarfish|eel|lance|tomcod|jack) *$", t) is not None)
water = lambda t: re.search(r"(?i) (river|creek|lake|estuary|harbour|bay|sound|inlet|ocean|slough|lagoon|pond|strait|channel|passage|cove)$", t) is not None
group = lambda t: {"river": "rivers", "creek": "rivers", "lake": "lakes", "pond": "lakes", "estuary": "estuaries", "slough": "estuaries", "lagoon": "estuaries"}.get(t.split()[-1].lower(), "oceans")
ignore = {"water", "rivers", "lakes", "estuaries", "oceans", "river", "lake", "estuary", "ocean", "creek", "slough", "journal", "trips", "contact", "go fish"}
cased = lambda t: t.title() if water(t) and t == t.lower() else t
def finder_tags(f):
    h = subprocess.run(["xattr", "-px", "com.apple.metadata:_kMDItemUserTags", str(f)], capture_output=True, text=True).stdout
    return [clean(t.split("\n")[0]) for t in plistlib.loads(bytes.fromhex(re.sub(r"\s", "", h)))] if h.strip() else []
slugify = lambda s: re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")
for k in nest: kids[slugify(k)] = (k, nest[k]); used.add(slugify(k))
toml = lambda rows: "".join(f'["{k}"]\n' + "".join(f"{a} = {json.dumps(b)}\n" for a, b in v.items()) + "\n" for k, v in rows.items())
for folder in sorted(p for p in src.iterdir() if p.is_dir()):
    parts = folder.name.split("__")
    m = re.match(r"([A-Za-z]+)[ _](\d{4})", parts[0])
    if not m: continue
    if m.group(1).lower() not in months: print("skipped", folder.name); continue
    date = datetime.date(int(m.group(2)), months[m.group(1).lower()], 1)
    title = clean(parts[1]) if len(parts) > 1 else f"{m.group(1).lower()} {m.group(2)}"
    out = dst / f"{date:%Y-%m}-{slugify(title)}"
    out.mkdir(parents=True, exist_ok=True)
    photos, videos, tags, where = [], [], set(), {}
    home = [clean(p.stem.split("__")[0]) for p in folder.iterdir() if p.suffix == ".river"]
    for f in sorted(p for p in folder.iterdir() if not p.name.startswith(".")):
        bits = f.stem.split("__")
        name = clean(bits[0])
        desc = (folder / (bits[0] + ".txt")).read_text().strip() if (folder / (bits[0] + ".txt")).exists() else ""
        if f.suffix.lower() in (".jpg", ".jpeg", ".png", ".heic"):
            tag = [cased(x) for x in (waters.get(t, t) for t in finder_tags(f) or ([clean(t) for t in bits[1].split(",")] if len(bits) > 1 else ["fish"])) if x and x.lower() not in ignore] or ["fish"]
            tags.update(tag)
            pt = gps(f)
            for t in tag:
                if water(t) and pt: where.setdefault(t, []).append(pt)
            for t in tag:
                if slugify(t) not in species and isfish(t):
                    species[slugify(t)] = {"title": t, "latin": latin.get(t.lower(), "")}
                    pathlib.Path("data/species.toml").write_text(toml(species))
            if any(slugify(t) in species for t in tag): tags.add("fish")
            for t in tag:
                if t.lower() in nest: kids[slugify(t)] = (t, nest[t.lower()]); used.add(slugify(t))
            for t in tag:
                if water(t) or slugify(t) in species: name = clean(re.sub(r"(?i)\b" + re.escape(re.sub(r"(?i)\s+(river|lake|creek)$", "", t)) + r"(\s+(river|lake|creek))?\b", "", name)) or name
                elif t not in parents and not water(t):
                    if t.lower() in nest: kids[slugify(t)] = (t, nest[t.lower()])
                    if "fish" in tag and slugify(t) == slugify(clean(bits[0])): kids.setdefault(slugify(t), (t, "fish"))
                    for p in parents:
                        if p in tag: kids.setdefault(slugify(t), (t, p)); break
                    used.add(slugify(t))
            name = re.sub(r"(?i)\s+(from|at|on|in|of|the|and|with)$", "", name)
            if re.match(r"(?i)screenshot|img_|dsc_|image", name): name = ""
            jpg = out / ((slugify(name) or slugify(bits[0])) + ".jpg")
            if not jpg.exists() or jpg.stat().st_mtime < f.stat().st_mtime:
                im = ImageOps.exif_transpose(Image.open(f)).convert("RGB")
                W, H = im.size
                w, h = (int(H * 16 / 9), H) if W / H > 16 / 9 else (W, int(W * 9 / 16))
                cx, cy = focus(im)
                x, y = min(max(int(cx * W - w / 2), 0), W - w), min(max(int(cy * H - h / 2), 0), H - h)
                im = im.crop((x, y, x + w, y + h)).resize((1600, 900), Image.LANCZOS)
                im.save(jpg, quality=85)
            photos.append((sorted(t for t in tag if water(t)) or home[:1], {"type": "photo", "file": jpg.name, "title": name, "caption": desc, "tags": tag}))
        elif f.suffix == ".river":
            tags.update([name] + finder_tags(f))
        elif f.suffix == ".video":
            tags.update(["music"] + finder_tags(f))
            for t in finder_tags(f):
                if t not in ("fish", "friends", "music"): kids.setdefault(slugify(t), (t, "music")); used.add(slugify(t))
            videos.append({"type": "video", "id": bits[1], "title": name, "caption": desc, "tags": ["music"] + [t for t in finder_tags(f) if t != "music"]})
    groups = []
    for t in sorted(t for t in tags if water(t)):
        pts = where.get(t, [])
        mid = [str(sorted(p[i] for p in pts)[len(pts) // 2]) for i in (0, 1)] if pts else []
        if not pathlib.Path(f"assets/maps/{slugify(t)}.svg").exists() and subprocess.run(["Rscript", "maps.R", t, t, ""] + mid).returncode: continue
        note = folder / (t.replace(" ", "_") + ".txt")
        if note.exists():
            rivers = tomllib.loads(pathlib.Path("data/rivers.toml").read_text())
            rivers.setdefault(slugify(t), {"title": t})["about"] = note.read_text().strip()
            pathlib.Path("data/rivers.toml").write_text(toml(rivers))
        tags.update([group(t), "water"])
        groups.append({"water": t, "cards": [p for w, p in photos if w and w[0] == t]})
    loose = [p for w, p in photos if not w or not pathlib.Path(f"assets/maps/{slugify(w[0])}.svg").exists()] + videos
    if loose: groups.append({"water": None, "cards": loose})
    for old in out.glob("*.jpg"):
        if old.name not in {p["file"] for w, p in photos}: old.unlink()
    for t in list(tags):
        k = slugify(t)
        for _ in range(5):
            if k in kids: tags.add(kids[k][1]); k = slugify(kids[k][1])
            elif k in species: tags.add("fish"); k = "fish"
            else: break
    if not groups: continue
    (out / "index.md").write_text(json.dumps({"title": title, "date": f"{date}T12:00:00-07:00", "categories": sorted(tags), "groups": groups}, ensure_ascii=False, indent=1) + "\n")
    print(out.name, sum(len(g["cards"]) for g in groups) + sum(1 for g in groups if g["water"]))
pathlib.Path("data/tags.toml").write_text(toml({k: {"title": t, "parent": p} for k, (t, p) in sorted(kids.items()) if k in used}))
