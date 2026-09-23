#!/bin/sh
set -e
hugo build -D -d public --quiet --cleanDestinationDir
grep -q '<title>September 2026</title>' public/index.xml
grep -q '<title>fish are friends</title>' public/index.html
grep -q 'class="brand" href="/">fish are friends' public/index.html
grep -q 'href="/trips/">trips' public/trips/squamish-river/index.html
grep -q 'href="/trips/sample-trip/">sample trip' public/index.html
grep -q 'href="/categories/fishies/">fishies' public/index.html
grep -q '<li><details><summary>rivers</summary><ul class="plain nest"><li><a href="/categories/rivers/">all rivers</a></li><li><a href="/categories/atnarko-river/">Atnarko River</a>' public/index.html
grep -q '<summary>lakes</summary><ul class="plain nest"><li><a href="/categories/lakes/">all lakes</a></li><li><a href="/categories/boot-lake/">Boot Lake</a>' public/index.html
grep -q '<summary>places</summary><ul class="plain nest"><li><a href="/categories/bella-coola/">Bella Coola</a>' public/index.html
! grep -q 'spey fishing\|fly tying' public/index.html
grep -q 'data-tags="lakes kennedy-lake"' public/posts/2020-07-july-2020/index.html
grep -q 'data-tags="rivers dean-river"' public/categories/dean-river/index.html
test $(grep -c 'data-tags="rivers dean-river"' public/categories/dean-river/index.html) -eq 1
test $(grep -n 'figure class="card map"' public/categories/dean-river/index.html | head -1 | cut -d: -f1) -lt $(grep -n 'figure class="card" ' public/categories/dean-river/index.html | head -1 | cut -d: -f1)
grep -q 'data-tags="rivers bitteroot-river"' public/categories/bitteroot-river/index.html
grep -q 'href="/archive/#september-2026">September 2026' public/index.html
grep -q 'critty (at) fisharefriends.org' public/index.html
grep -q 'href="/index.xml">rss' public/index.html
grep -q 'symbol id="fishdaisy"' public/index.html
grep -q 'filter id="wobble"' public/index.html
grep -q -- '--paper: #fff' public/css/site.css
grep -q 'href="https://dyun5.exblog.jp/">slow fishing' public/index.html
! grep -q 'class="plain menu"' public/index.html
grep -q '<dt>donate</dt><dd><a href="https://www.squamishwatershed.com/#/">Squamish River Watershed Society</a></dd>' public/trips/squamish-river/index.html
grep -q 'See you on the water:)' public/index.html
grep -q 'please wait for the next float trip' public/trips/index.html
! grep -q '<nav>' public/index.html
! grep -q 'class="domain"' public/index.html
! grep -q 'by critty</p>' public/index.html
! grep -q 'count me out' public/trips/squamish-river/index.html
grep -q 'data-trip="squamish-river" data-spots="4"' public/trips/squamish-river/index.html
grep -q '<dd class="spots">0 of 4 taken</dd>' public/trips/squamish-river/index.html
grep -q 'width="484" height="272"' public/posts/2026-09-september-2026/index.html
grep -q '<figcaption><a class="ftitle" href="/categories/fishies/">Ruby</a><p>Ruby fish from the Morice on Sunday and the first fish I caught in nearly two weeks of being up here. She nearly took my arm off. Her name is Ruby and she is beautiful.</p></figcaption>' public/posts/2026-09-september-2026/index.html
grep -q '<a class="ftitle" href="/posts/2026-09-september-2026/">Ruby</a>' public/categories/fishies/index.html
! grep -q 'card video\|card map\|<article' public/categories/fishies/index.html
grep -q '<a class="ftitle" href="/posts/2026-09-september-2026/">The Morice River</a>' public/categories/rivers/index.html
grep -q '<a class="ftitle" href="/posts/2026-09-september-2026/">Banquet by Bloc Party</a>' public/categories/music/index.html
! grep -q '<figure class="card"><a' public/categories/music/index.html
grep -q 'youtube.com/embed/P-i0jw61niE' public/posts/2026-09-september-2026/index.html
grep -q '<figure class="card video" data-tags="music"><div class="frame"><iframe src="https://www.youtube.com/embed/P-i0jw61niE"' public/posts/2026-09-september-2026/index.html
grep -q '<a class="ftitle" href="/categories/music/">Banquet by Bloc Party</a>' public/posts/2026-09-september-2026/index.html
! grep -q 'ftitle" href="[^"]*">September 2026' public/posts/2026-09-september-2026/index.html
grep -q '<figure class="card" data-tags="fishies"><a href="/posts/2026-09-september-2026/ruby.jpg"><img src="/posts/2026-09-september-2026/ruby_hu' public/posts/2026-09-september-2026/index.html
grep -q '<a class="ftitle" href="/categories/rivers/">The Morice River</a></figcaption>' public/posts/2026-09-september-2026/index.html
grep -q 'preserveAspectRatio="xMinYMin meet"' public/posts/2026-09-september-2026/index.html
test -f public/posts/2026-09-september-2026/ruby.jpg
! grep -q 'squamish-river/">squamish river</a></h2>' public/index.html
! grep -q '<footer class="wrap"><svg' public/index.html
grep -q 'viewBox="0 0 640 360"' public/posts/2026-09-september-2026/index.html
test $(grep -n 'class="ftitle" href=' public/posts/2026-09-september-2026/index.html | head -1 | cut -d: -f1) -lt $(grep -n 'figure class="card map"' public/posts/2026-09-september-2026/index.html | head -1 | cut -d: -f1)
test $(grep -n 'figure class="card map"' public/posts/2026-09-september-2026/index.html | head -1 | cut -d: -f1) -lt $(grep -n 'youtube.com/embed' public/posts/2026-09-september-2026/index.html | head -1 | cut -d: -f1)
grep -q "v.src += '?autoplay=1&playsinline=1'" public/posts/2026-09-september-2026/index.html
! grep -q 'autoplay=1' public/categories/music/index.html
! grep -q 'autoplay=1' public/posts/index.html
grep -q 'come upon my lie' public/index.html
grep -q 'href="/posts/">all' public/index.html
grep -q 'id="random" href="/posts/">take me to a random post' public/index.html
grep -q '"/posts/2026-09-september-2026/"' public/index.html
grep -q '<a class="ftitle" href="/posts/2022-08-august-2022/">Josh</a>' public/categories/fishies/index.html
grep -q '<a class="ftitle" href="/posts/2022-08-august-2022/">Christian in action</a>' public/categories/friends/index.html
! grep -q 'Christian in action' public/categories/fishies/index.html
grep -q 'data-tags="rivers morice-river"' public/categories/morice-river/index.html
! grep -q 'squamish-river' public/archive/index.html
! grep -q 'href="/archive/#september-2026">September 2026' public/trips/index.html || true
! grep -q '<article' public/index.html
grep -q '<p class="date">September 1, 2026</p>' public/posts/2026-09-september-2026/index.html
grep -q 'href="/posts/2026-09-september-2026/">September 2026' public/posts/index.html
grep -q '# by critty | 2026-09-01 12:00 | <a href="/categories/morice-river/">Morice River</a> | <a href="/categories/fishies/">fishies</a> | <a href="/categories/music/">music</a> | <a href="/categories/rivers/">rivers</a>' public/posts/index.html
grep -q 'class="doodle sep"' public/posts/index.html
grep -q '<title>September 2026 | fish are friends</title>' public/posts/2026-09-september-2026/index.html
grep -q '<dt>when</dt><dd>Saturday, June 6, 2099</dd>' public/trips/sample-trip/index.html
grep -q 'data-to="critty@fisharefriends.org" data-subject="fish are friends: count me in: sample trip"' public/trips/sample-trip/index.html
grep -q '0 of 3 taken' public/trips/index.html
grep -q '<h2 class="sub">upcoming</h2>' public/trips/index.html
grep -q 'href="/trips/sample-trip/">sample trip' public/trips/index.html
grep -q 'id="september-2026">September 2026' public/archive/index.html
grep -q 'href="/posts/2026-09-september-2026/">September 2026' public/archive/index.html
grep -q '<dt>what</dt><dd>raft fishing</dd>' public/trips/sample-trip/index.html
grep -q '<option>M</option>' public/trips/sample-trip/index.html
grep -q 'name="gear"' public/trips/sample-trip/index.html
grep -q 'src="/js/signup.js"' public/index.html
grep -q '<dt>licence</dt><dd><a href="https://www2.gov.bc.ca/gov/content/sports-culture/recreation/fishing-hunting/fishing/recreational-freshwater-fishing-licence">bc freshwater fishing licence</a>' public/trips/sample-trip/index.html
grep -q '<dt>what</dt><dd>walk and wade to learn the basics</dd>' public/trips/squamish-river/index.html
grep -q '<dt>when</dt><dd>Saturday, October 17, 2026</dd>' public/trips/squamish-river/index.html
grep -q 'href="/trips/squamish-river/">squamish river' public/archive/index.html
grep -q '<dt>bring</dt><dd>a pair of runners, rain jacket' public/trips/squamish-river/index.html
grep -q 'I need gear (waders, rod)' public/trips/squamish-river/index.html
grep -q 'class="doodle blue mark" aria-hidden="true"><use href="#fishdaisy"/>' public/index.html
grep -q '<figure class="card map" data-tags="rivers squamish-river"><div class="doodle" aria-hidden="true"><svg' public/trips/squamish-river/index.html
grep -q '<a class="ftitle" href="/categories/rivers/">The Squamish River</a></figcaption>' public/trips/squamish-river/index.html
hugo build -d public --quiet --cleanDestinationDir
test ! -e public/trips/sample-trip
grep -q 'href="/trips/squamish-river/">squamish river' public/trips/index.html
