import pathlib, re, datetime, subprocess
from PIL import Image, ImageOps, ImageFilter
src = pathlib.Path.home() / "Desktop" / "fish_are_friends"
dst = pathlib.Path("content/posts")
months = {m: i for i, m in enumerate(["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"], 1)}
clean = lambda s: re.sub(r"\s+", " ", s.replace("_", " ")).strip()
slugify = lambda s: re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")
for folder in sorted(p for p in src.iterdir() if p.is_dir()):
    parts = folder.name.split("__")
    m = re.match(r"([A-Za-z]+)[ _](\d{4})", parts[0])
    if not m: continue
    date = datetime.date(int(m.group(2)), months[m.group(1).lower()], 1)
    title = clean(parts[1]) if len(parts) > 1 else f"{m.group(1).capitalize()} {m.group(2)}"
    out = dst / f"{date:%Y-%m}-{slugify(title)}"
    out.mkdir(parents=True, exist_ok=True)
    photos, rivers, videos, tags = [], [], [], set()
    for f in sorted(p for p in folder.iterdir() if not p.name.startswith(".")):
        bits = f.stem.split("__")
        name = clean(bits[0])
        desc = (folder / (bits[0] + ".txt")).read_text().strip() if (folder / (bits[0] + ".txt")).exists() else ""
        if f.suffix.lower() in (".jpg", ".jpeg", ".png", ".heic"):
            tag = [clean(t) for t in bits[1].split(",")] if len(bits) > 1 else ["fishies"]
            tags.update(tag)
            jpg = out / (slugify(name) + ".jpg")
            if not jpg.exists() or jpg.stat().st_mtime < f.stat().st_mtime:
                im = ImageOps.exif_transpose(Image.open(f)).convert("RGB")
                im.thumbnail((1600, 1600))
                box = (1600, 900)
                if im.height > im.width:
                    bg = ImageOps.fit(im, box).filter(ImageFilter.GaussianBlur(40))
                    im = ImageOps.contain(im, box)
                    bg.paste(im, ((box[0] - im.width) // 2, 0))
                    im = bg
                else:
                    im = ImageOps.fit(im, box)
                im.save(jpg, quality=85)
            photos.append(f'![{desc}]({jpg.name} "{name} | {", ".join(tag)}")')
        elif f.suffix == ".river":
            tags.update(["rivers", name])
            if not pathlib.Path(f"assets/maps/{slugify(name)}.svg").exists(): subprocess.run(["Rscript", "maps.R", name], check=True)
            rivers.append(f'{{{{< map "{name}" >}}}}')
        elif f.suffix == ".video":
            tags.add("music")
            videos.append(f'{{{{< video {bits[1]} "{name}" >}}}}{desc}{{{{< /video >}}}}')
    cards = photos + rivers + videos
    if not cards: continue
    (out / "index.md").write_text(f'---\ntitle: "{title}"\ndate: {date}T12:00:00-07:00\ncategories: [{", ".join(sorted(tags))}]\n---\n' + "\n\n".join(cards) + "\n")
    print(out.name, len(cards))
