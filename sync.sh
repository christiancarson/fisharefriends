#!/bin/sh
set -e
cd "$(dirname "$0")"
mkdir /tmp/fisharefriends.lock 2>/dev/null || exit 0
trap 'rmdir /tmp/fisharefriends.lock' EXIT
/opt/homebrew/Caskroom/miniconda/base/bin/python3 import.py
hugo build -d public --quiet --cleanDestinationDir
git add -A
git diff --cached --quiet || git commit -qm "photos $(date +%Y-%m-%d)"
git push -q origin main
