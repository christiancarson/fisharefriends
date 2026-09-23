#!/bin/sh
set -e
hugo build -D -d public --quiet --cleanDestinationDir
grep -q '<title>welcome</title>' public/index.xml
grep -q '<title>fish are friends</title>' public/index.html
grep -q 'class="brand" href="/">fish are friends' public/index.html
grep -q 'href="/trips/">trips' public/index.html
grep -q 'href="/trips/sample-trip/">sample trip' public/index.html
grep -q 'href="/categories/life/">life' public/index.html
grep -q 'href="/archive/#september-2026">September 2026' public/index.html
grep -q 'crittycar (at) gmail.com' public/index.html
grep -q 'href="/index.xml">rss' public/index.html
grep -q 'symbol id="fish"' public/index.html
grep -q 'filter id="wobble"' public/index.html
grep -q -- '--paper: #fff' public/css/site.css
