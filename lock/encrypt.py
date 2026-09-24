import sys, os, json, pathlib, base64, hashlib, shutil
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
src, out, password = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
salt = os.urandom(16)
key = hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 300000, 32)
files = {}
for p in sorted(src.rglob("*")):
    if p.is_file() and p.name != "CNAME":
        rel = p.relative_to(src).as_posix()
        files[rel] = base64.b64encode(p.read_bytes()).decode()
blob = json.dumps(files).encode()
nonce = os.urandom(12)
ct = AESGCM(key).encrypt(nonce, blob, None)
if out.exists(): shutil.rmtree(out)
out.mkdir(parents=True)
(out / "site.bin").write_bytes(salt + nonce + ct)
if (src / "CNAME").exists(): shutil.copy(src / "CNAME", out / "CNAME")
(out / "robots.txt").write_text("User-agent: *\nDisallow: /\n")
page = pathlib.Path(__file__).with_name("unlock.html").read_text().replace("fetch('/site.bin'", "fetch('/site.bin?v=%s'" % hashlib.sha256(ct).hexdigest()[:12])
(out / "index.html").write_text(page)
(out / "404.html").write_text(page)
print(len(files), "files,", len(ct) // 1024, "KiB")
