#!/bin/sh
set -e
cd "$(dirname "$0")"
lock=/tmp/fisharefriends.lock
if [ -f "$lock" ] && kill -0 "$(cat "$lock")" 2>/dev/null; then exit 0; fi
echo $$ > "$lock"
trap 'rm -f "$lock"' EXIT
/opt/homebrew/Caskroom/miniconda/base/bin/python3 import.py
hugo build -d public --quiet --cleanDestinationDir
git add content data assets/maps
git diff --cached --quiet || git commit -qm "photos $(date +%Y-%m-%d)"
git push -q origin main
