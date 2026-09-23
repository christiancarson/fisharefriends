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
grep -q '<p class="date">September 22, 2026</p>' public/index.html
grep -q 'href="/posts/welcome/">welcome' public/index.html
grep -q '# by Christian | 2026-09-22 12:00 | <a href="/categories/life/">life</a>' public/index.html
grep -q 'class="doodle sep"' public/index.html
grep -q '<title>welcome | fish are friends</title>' public/posts/welcome/index.html
grep -q 'href="/posts/welcome/">welcome' public/categories/life/index.html
test -f public/page/1/index.html
grep -q '<dt>when</dt><dd>Saturday, June 6, 2099</dd>' public/trips/sample-trip/index.html
grep -q 'mailto:crittycar@gmail.com?subject=count%20me%20in%3a%20sample%20trip' public/trips/sample-trip/index.html
grep -q '0 of 4 taken' public/index.html
grep -q '<h2 class="sub">upcoming</h2>' public/trips/index.html
grep -q 'href="/trips/sample-trip/">sample trip' public/trips/index.html
grep -q 'id="september-2026">September 2026' public/archive/index.html
grep -q 'href="/posts/welcome/">welcome' public/archive/index.html
hugo build -d public --quiet --cleanDestinationDir
test ! -e public/trips/sample-trip
grep -q 'nothing planned yet' public/trips/index.html
