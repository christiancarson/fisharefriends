import sys, os, json, pathlib, hashlib, shutil, gzip, mimetypes
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
src, out, password = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
text = (".html", ".css", ".js", ".xml", ".json", ".txt", ".svg", ".webmanifest")
salt = hashlib.sha256(b"fish are friends").digest()[:16]
key = AESGCM(hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 300000, 32))
if out.exists(): shutil.rmtree(out)
(out / "x").mkdir(parents=True)
files, blobs = {}, {}
for p in sorted(src.rglob("*")):
    if not p.is_file() or p.name == "CNAME": continue
    rel, data = p.relative_to(src).as_posix(), p.read_bytes()
    if p.suffix.lower() in text:
        files[rel] = data.decode("utf-8")
        continue
    name = hashlib.sha256(data).hexdigest()[:24]
    nonce = hashlib.sha256(b"nonce" + data).digest()[:12]
    (out / "x" / f"{name}.bin").write_bytes(nonce + key.encrypt(nonce, data, None))
    blobs[rel] = [name, mimetypes.guess_type(p.name)[0] or "application/octet-stream"]
nonce = os.urandom(12)
core = salt + nonce + key.encrypt(nonce, gzip.compress(json.dumps({"files": files, "blobs": blobs}).encode(), 9), None)
(out / "core.bin").write_bytes(core)
if (src / "CNAME").exists(): shutil.copy(src / "CNAME", out / "CNAME")
(out / "robots.txt").write_text("User-agent: *\nDisallow: /\n")
page = pathlib.Path(__file__).with_name("unlock.html").read_text().replace("/core.bin'", "/core.bin?v=%s'" % hashlib.sha256(core).hexdigest()[:12])
(out / "index.html").write_text(page)
(out / "404.html").write_text(page)
print(len(files), "pages,", len(blobs), "images,", len(core) // 1024, "KiB to unlock")
