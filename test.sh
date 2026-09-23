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
grep -q 'symbol id="fishdaisy"' public/index.html
grep -q 'filter id="wobble"' public/index.html
grep -q -- '--paper: #fff' public/css/site.css
grep -q 'come upon my lie' public/index.html
grep -q 'href="/posts/">all' public/index.html
grep -q 'href="/trips/squamish-river/">squamish river</a></h2>' public/index.html
grep -q '<p class="date">September 22, 2026</p>' public/index.html
grep -q 'href="/posts/welcome/">welcome' public/posts/index.html
grep -q '# by critty | 2026-09-22 12:00 | <a href="/categories/life/">life</a>' public/posts/index.html
grep -q 'class="doodle sep"' public/posts/index.html
grep -q '<title>welcome | fish are friends</title>' public/posts/welcome/index.html
grep -q 'href="/posts/welcome/">welcome' public/categories/life/index.html
grep -q '<dt>when</dt><dd>Saturday, June 6, 2099</dd>' public/trips/sample-trip/index.html
grep -q 'data-to="crittycar@gmail.com" data-subject="count me in: sample trip"' public/trips/sample-trip/index.html
grep -q '0 of 4 taken' public/index.html
grep -q '<h2 class="sub">upcoming</h2>' public/trips/index.html
grep -q 'href="/trips/sample-trip/">sample trip' public/trips/index.html
grep -q 'id="september-2026">September 2026' public/archive/index.html
grep -q 'href="/posts/welcome/">welcome' public/archive/index.html
grep -q '<dt>what</dt><dd>raft fishing</dd>' public/trips/sample-trip/index.html
grep -q '<option>M</option>' public/trips/sample-trip/index.html
grep -q 'name="gear"' public/trips/sample-trip/index.html
grep -q 'src="/js/signup.js"' public/index.html
grep -q '<dt>licence</dt><dd><a href="https://www2.gov.bc.ca/gov/content/sports-culture/recreation/fishing-hunting/fishing/recreational-freshwater-fishing-licence">bc freshwater fishing licence</a>' public/trips/sample-trip/index.html
grep -q '<dt>what</dt><dd>walk and wade</dd>' public/trips/squamish-river/index.html
grep -q '<dt>when</dt><dd>Saturday, October 17, 2026</dd>' public/trips/squamish-river/index.html
grep -q 'href="/trips/squamish-river/">squamish river' public/archive/index.html
grep -q 'runners you can trash :)' public/trips/squamish-river/index.html
grep -q 'I need gear (waders, rod)' public/trips/squamish-river/index.html
grep -q 'class="doodle blue mark" aria-hidden="true"><use href="#fishdaisy"/>' public/index.html
hugo build -d public --quiet --cleanDestinationDir
test ! -e public/trips/sample-trip
grep -q 'href="/trips/squamish-river/">squamish river' public/trips/index.html
