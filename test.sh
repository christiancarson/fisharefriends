#!/bin/sh
set -e
hugo build -D -d public --quiet --cleanDestinationDir
grep -q '<title>september 2026</title>' public/index.xml
grep -q '<title>fish are friends</title>' public/index.html
grep -q 'class="brand" href="/">fish are friends' public/index.html
grep -q 'href="/trips/">trips' public/trips/squamish-river/index.html
grep -q 'href="/trips/sample-trip/">sample trip' public/index.html
grep -q 'body { text-transform: lowercase }' public/css/site.*.css
grep -q '>walk and wade</a></h2>' public/trips/index.html
grep -q 'href="/categories/fish/">all fish' public/index.html
grep -q '<details><summary>rivers</summary><ul class="plain nest"><li><a href="/categories/rivers/">all rivers</a></li><li data-sub="0" data-l="58"><a href="/categories/atnarko-river/">Atnarko River</a>' public/index.html
grep -q '<summary>lakes</summary><ul class="plain nest"><li><a href="/categories/lakes/">all lakes</a></li><li data-sub="0" data-l="58"><a href="/categories/boot-lake/">Boot Lake</a>' public/index.html
! grep -q '<summary>places</summary>' public/index.html
grep -q '<summary>estuaries</summary><ul class="plain nest"><li><a href="/categories/estuaries/">all estuaries</a></li><li data-sub="0" data-l="58"><a href="/categories/toquaht-estuary/">Toquaht Estuary</a>' public/index.html
grep -q '<summary>oceans</summary><ul class="plain nest"><li><a href="/categories/oceans/">all oceans</a></li><li data-sub="0" data-l="58"><a href="/categories/ucluelet-harbour/">Ucluelet Harbour</a>' public/index.html
grep -q '<summary>archive</summary><ul class="plain nest"><li><a href="/archive/">all archive</a></li><li data-sub="0" data-l="62"><a href="/posts/2026-09-september-2026/">september 2026</a></li>' public/index.html
test $(grep -n 'figure class="card map" data-tags="rivers atnarko-river"' public/posts/2022-08-august-2022/index.html | head -1 | cut -d: -f1) -lt $(grep -n 'number 1' public/posts/2022-08-august-2022/index.html | head -1 | cut -d: -f1)
test $(grep -n 'number 1' public/posts/2022-08-august-2022/index.html | head -1 | cut -d: -f1) -lt $(grep -n 'figure class="card map" data-tags="rivers dean-river"' public/posts/2022-08-august-2022/index.html | head -1 | cut -d: -f1)
! grep -q 'spey fishing\|fly tying' public/index.html
grep -q 'data-tags="lakes kennedy-lake"' public/posts/2020-07-july-2020/index.html
grep -q 'data-tags="rivers dean-river"' public/categories/dean-river/index.html
test $(grep -c 'data-tags="rivers dean-river"' public/categories/dean-river/index.html) -eq 1
test $(grep -n 'figure class="card map"' public/categories/dean-river/index.html | head -1 | cut -d: -f1) -lt $(grep -n 'figure class="card" ' public/categories/dean-river/index.html | head -1 | cut -d: -f1)
grep -q 'data-tags="rivers bitteroot-river"' public/categories/bitteroot-river/index.html
grep -q 'href="/posts/2026-09-september-2026/">september 2026' public/index.html
grep -q 'critty (at) fisharefriends.org' public/index.html
grep -q 'href="/index.xml">rss' public/index.html
grep -q 'symbol id="fishpals"' public/index.html
grep -q 'filter id="wobble"' public/index.html
grep -q -- '--paper: #fff' public/css/site.*.css
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
grep -q '<figcaption><a class="ftitle" href="/categories/fish/">Ruby</a><p>Ruby fish from the Morice on Sunday and the first fish I caught in nearly two weeks of being up here. She nearly took my arm off. Her name is Ruby and she is beautiful.</p><p class="tags">' public/posts/2026-09-september-2026/index.html
grep -q '<a class="ftitle" href="/posts/2026-09-september-2026/">Ruby</a>' public/categories/fish/index.html
! grep -q 'card video\|card map\|<article' public/categories/fish/index.html
grep -q '<a class="ftitle" href="/posts/2026-09-september-2026/">Morice River</a>' public/categories/rivers/index.html
grep -q '<a class="ftitle" href="/posts/2026-09-september-2026/">Banquet by Bloc Party</a>' public/categories/music/index.html
! grep -q '<figure class="card"><a' public/categories/music/index.html
grep -q 'youtube.com/embed/P-i0jw61niE' public/posts/2026-09-september-2026/index.html
grep -q '<figure class="card video" data-tags="music"><div class="frame"><iframe src="https://www.youtube.com/embed/P-i0jw61niE"' public/posts/2026-09-september-2026/index.html
grep -q '<a class="ftitle" href="/categories/music/">Banquet by Bloc Party</a>' public/posts/2026-09-september-2026/index.html
! grep -q 'ftitle" href="[^"]*">september 2026' public/posts/2026-09-september-2026/index.html
grep -q '<figure class="card" data-tags="fish morice-river rainbow-trout"><a href="/posts/2026-09-september-2026/ruby.jpg"><img src="/posts/2026-09-september-2026/ruby_hu' public/posts/2026-09-september-2026/index.html
grep -q '<a class="ftitle" href="/categories/rivers/">Morice River</a></figcaption>' public/posts/2026-09-september-2026/index.html
grep -q 'preserveAspectRatio="xMinYMin meet"' public/posts/2026-09-september-2026/index.html
test -f public/posts/2026-09-september-2026/ruby.jpg
! grep -q 'squamish-river/">squamish river</a></h2>' public/index.html
! grep -q '<footer class="wrap"><svg' public/index.html
grep -q 'viewBox="0 0 640 360"' public/posts/2026-09-september-2026/index.html
test $(grep -n 'figure class="card map"' public/posts/2026-09-september-2026/index.html | head -1 | cut -d: -f1) -lt $(grep -n 'youtube.com/embed' public/posts/2026-09-september-2026/index.html | head -1 | cut -d: -f1)
grep -q "v.src += '?autoplay=1&playsinline=1'" public/posts/2026-09-september-2026/index.html
! grep -q 'autoplay=1' public/categories/music/index.html
! grep -q 'autoplay=1' public/posts/index.html
test $(grep -c 'data-tags="rivers morice-river"' public/posts/2026-09-september-2026/index.html) -eq 1
test $(grep -n 'data-tags="rivers morice-river"' public/posts/2026-09-september-2026/index.html | head -1 | cut -d: -f1) -lt $(grep -n '>Ruby</a>' public/posts/2026-09-september-2026/index.html | head -1 | cut -d: -f1)
grep -q '<div class="water">' public/posts/2022-08-august-2022/index.html
grep -q '<p class="tags"><a href="/categories/fish/">fish</a><a href="/categories/dean-river/">Dean River</a><a href="/categories/rainbow-trout/">Rainbow Trout</a></p>' public/posts/2022-08-august-2022/index.html
! grep -qi 'gab and gob\|mack the bulltrout' public/categories/fish/index.html
grep -q 'data-signup="https://script.google.com/macros/s/AKfycbx4_QPAM9AQnIfD8QtnuWdZJgYkNLEla_AJtjgrlUJJ_Pu4q_gHgVZ0Ey3dX426zPyGSw/exec"' public/trips/squamish-river/index.html
grep -q 'come upon my lie' public/index.html
grep -q 'href="/posts/">stories, photos, and observations</a>' public/index.html
grep -q 'href="/trips/squamish-river/">sign up to join me on a trip</a>' public/index.html
grep -q 'href="/posts/">all' public/index.html
grep -q 'id="random" href="/posts/">go fish <svg class="doodle blue" aria-hidden="true"><use href="#fish"/></svg></a>' public/index.html
grep -q '"/posts/2026-09-september-2026/"' public/index.html
grep -q '<a class="ftitle" href="/posts/2022-08-august-2022/">Josh</a>' public/categories/fish/index.html
grep -q '<a class="ftitle" href="/posts/2022-08-august-2022/">Christian in action</a>' public/categories/friends/index.html
! grep -q 'Christian in action' public/categories/fish/index.html
grep -q 'data-tags="rivers morice-river"' public/categories/morice-river/index.html
! grep -q 'squamish-river' public/archive/index.html
! grep -q 'href="/archive/#september-2026">september 2026' public/trips/index.html || true
! grep -q '<article' public/index.html
grep -q '<p class="date">September 1, 2026</p>' public/posts/2026-09-september-2026/index.html
grep -q 'href="/posts/2026-09-september-2026/">september 2026' public/posts/index.html
grep -q '# by critty | 2026-09-01 12:00 | <a href="/categories/morice-river/">Morice River</a> | <a href="/categories/rainbow-trout/">Rainbow Trout</a> | <a href="/categories/fish/">fish</a> | <a href="/categories/music/">music</a> | <a href="/categories/rivers/">rivers</a> | <a href="/categories/water/">water</a>' public/posts/index.html
grep -q 'class="doodle sep"' public/posts/index.html
grep -q '<title>september 2026 | fish are friends</title>' public/posts/2026-09-september-2026/index.html
grep -q '<dt>when</dt><dd>Saturday, June 6, 2099</dd>' public/trips/sample-trip/index.html
grep -q 'data-to="critty@fisharefriends.org" data-subject="fish are friends: count me in: sample trip"' public/trips/sample-trip/index.html
grep -q '0 of 3 taken' public/trips/index.html
grep -q '<h2 class="sub">upcoming</h2>' public/trips/index.html
grep -q 'href="/trips/sample-trip/">sample trip' public/trips/index.html
grep -q 'id="september-2026">september 2026' public/archive/index.html
grep -q 'href="/posts/2026-09-september-2026/">september 2026' public/archive/index.html
grep -q '<dt>what</dt><dd>raft fishing</dd>' public/trips/sample-trip/index.html
grep -q '<option>M</option>' public/trips/sample-trip/index.html
grep -q 'name="gear"' public/trips/sample-trip/index.html
grep -q 'src="/js/signup\.[0-9a-f]*\.js"' public/index.html
grep -q '<dt>licence</dt><dd><a href="https://www2.gov.bc.ca/gov/content/sports-culture/recreation/fishing-hunting/fishing/recreational-freshwater-fishing-licence">bc freshwater fishing licence</a>' public/trips/sample-trip/index.html
grep -q '<dt>what</dt><dd>walk and wade to learn the basics</dd>' public/trips/squamish-river/index.html
grep -q '<dt>when</dt><dd>Saturday, October 17, 2026</dd>' public/trips/squamish-river/index.html
grep -q '<dt>bring</dt><dd>a pair of runners, rain jacket' public/trips/squamish-river/index.html
grep -q 'I need gear (waders, rod)' public/trips/squamish-river/index.html
grep -q 'class="doodle blue mark" aria-hidden="true"><use href="#fishpals"/>' public/index.html
grep -q '<figure class="card map" data-tags="rivers squamish-river"><div class="doodle" aria-hidden="true"><svg' public/trips/squamish-river/index.html
grep -q '<a class="ftitle" href="/categories/rivers/">Squamish River</a></figcaption>' public/trips/squamish-river/index.html
hugo build -d public --quiet --cleanDestinationDir
test ! -e public/trips/sample-trip
grep -q 'href="/trips/squamish-river/">walk and wade' public/trips/index.html
grep -q '<summary>fish <span class="mute">4</span></summary><ul class="plain nest"><li><a href="/categories/fish/">all fish</a></li><li data-sub="0" data-l="62"><a href="/categories/coastal-cutthroat-trout/">Coastal Cutthroat Trout</a>' public/index.html
grep -q '<p class="latin">Oncorhynchus mykiss</p>' public/categories/rainbow-trout/index.html
grep -q 'href="/posts/2026-09-september-2026/">Ruby</a>' public/categories/rainbow-trout/index.html
grep -q 'href="/posts/2020-06-june-2020/">Ben</a>' public/categories/coastal-cutthroat-trout/index.html
grep -q 'Westslope Cutthroat Trout' public/posts/2021-03-march-2021/index.html
grep -q 'id="stem"' public/index.html
test $(grep -o 'class="petal' public/index.html | wc -l) -eq $(grep -o '<li data-tab=' public/index.html | wc -l)
grep -q 'class="petal lit" data-tab="1"' public/categories/rainbow-trout/index.html
grep -q '<li data-tab="1" style="--hue: 275" class="on"><details open>' public/categories/rainbow-trout/index.html
grep -q '<li data-sub="1" data-l="54" class="on"><a href="/categories/rainbow-trout/">' public/categories/rainbow-trout/index.html
! grep -q 'class="petal lit"' public/index.html
grep -q 'src="/js/garden\.[0-9a-f]*\.js"' public/index.html
grep -q '<summary>water</summary><ul class="plain nest"><li><a href="/categories/water/">all water</a></li><li data-sub="0" data-l="62"><details><summary>rivers</summary>' public/index.html
grep -q 'data-tags="rivers morice-river"' public/categories/water/index.html
grep -q 'data-tags="lakes boot-lake"' public/categories/water/index.html
grep -q '<summary>water</summary>' public/categories/dean-river/index.html && grep -q 'data-sub="0" data-l="62" class="on"><details open><summary>rivers</summary>' public/categories/dean-river/index.html
test $(grep -o '<li data-tab=' public/index.html | wc -l) -eq 7
grep -q '<summary>trips</summary><ul class="plain nest"><li><a href="/trips/">all trips</a></li><li data-sub="0" data-l="62"><a href="/trips/squamish-river/">walk and wade</a> <span class="mute">2026-10-17</span></li>' public/index.html
grep -q '<summary>contact</summary><ul class="plain nest"><li data-sub="0" data-l="62"><span>critty (at) fisharefriends.org</span></li><li data-sub="1" data-l="54"><a href="/index.xml">rss</a></li>' public/index.html
grep -q '<li data-tab="0" style="--hue: 130" class="on"><details open>' public/trips/squamish-river/index.html
grep -q 'data-l="62" class="on"><a href="/trips/squamish-river/">walk and wade</a>' public/trips/squamish-river/index.html
grep -q '<li data-tab="5" style="--hue: 48" class="on"><details open>' public/posts/2026-09-september-2026/index.html
grep -q 'style="--hue: 215"' public/index.html && grep -q 'style="--hue: 30"' public/index.html
! grep -q '>boat<\|>non-fish<\|>not-fly-fishing<' public/index.html
grep -q '<a class="centre" href="/posts/">' public/index.html
grep -q '<main class="themed" style="--tab: 275">' public/categories/rainbow-trout/index.html
grep -q '<main class="themed" style="--tab: 215">' public/categories/dean-river/index.html
grep -q '<main class="themed" style="--tab: 48">' public/archive/index.html
! grep -q 'class="themed"' public/posts/2026-09-september-2026/index.html
! grep -q 'class="themed"' public/index.html
grep -q '<p class="tags from"><a href="/posts/2026-09-september-2026/">september 2026</a></p></figcaption>' public/categories/rainbow-trout/index.html
grep -q '<p class="tags from"><a href="/posts/2026-09-september-2026/">september 2026</a></p></figcaption>' public/categories/morice-river/index.html
