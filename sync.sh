#!/bin/sh
cd "$(dirname "$0")"
mkdir /tmp/fisharefriends.lock 2>/dev/null || exit 0
trap 'rmdir /tmp/fisharefriends.lock' EXIT
/usr/bin/python3 import.py
./test.sh
git add -A
git diff --cached --quiet || git commit -qm "photos $(date +%Y-%m-%d)"
git push -q origin main
