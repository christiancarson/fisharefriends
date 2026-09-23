#!/bin/sh
set -e
hugo build -D -d public --quiet --cleanDestinationDir
grep -q '<title>first morice steelhead</title>' public/index.xml
grep -q '<title>fish are friends</title>' public/index.html
grep -q 'class="brand" href="/">fish are friends' public/index.html
grep -q 'href="/trips/">trips' public/trips/squamish-river/index.html
grep -q 'href="/trips/sample-trip/">sample trip' public/index.html
grep -q 'href="/categories/spey-fishing/">spey fishing' public/index.html
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
grep -q 'width="484" height="272"' public/index.html
grep -q '<figcaption><a class="ftitle" href="/categories/spey-fishing/">first morice steelhead</a><p>ruby fish from the Morice on Sunday and the first fish I caught in nearly two weeks of being up here. It nearly took my arm off.</p></figcaption>' public/index.html
grep -q 'youtube.com/embed/P-i0jw61niE' public/posts/first-morice-steelhead/index.html
grep -q 'href="https://www.youtube.com/watch?v=P-i0jw61niE">watch on youtube' public/posts/first-morice-steelhead/index.html
grep -q '<figure><a href="/posts/first-morice-steelhead/first-morice-steelhead.jpg"><img src="/posts/first-morice-steelhead/first-morice-steelhead_hu' public/index.html
grep -q '>morice river</text>' public/posts/first-morice-steelhead/index.html
grep -q 'preserveAspectRatio="xMinYMin meet"' public/posts/first-morice-steelhead/index.html
test -f public/posts/first-morice-steelhead/first-morice-steelhead.jpg
! grep -q 'squamish-river/">squamish river</a></h2>' public/index.html
grep -q 'come upon my lie' public/index.html
grep -q 'href="/posts/">all' public/index.html
grep -q 'href="/posts/first-morice-steelhead/">first morice steelhead</a></h2>' public/index.html
grep -q '<p class="date">September 20, 2026</p>' public/index.html
grep -q 'href="/posts/first-morice-steelhead/">first morice steelhead' public/posts/index.html
grep -q '# by critty | 2026-09-20 18:00 | <a href="/categories/spey-fishing/">spey fishing</a>' public/posts/index.html
grep -q 'class="doodle sep"' public/posts/index.html
grep -q '<title>first morice steelhead | fish are friends</title>' public/posts/first-morice-steelhead/index.html
test -f public/categories/art/index.html
grep -q '<dt>when</dt><dd>Saturday, June 6, 2099</dd>' public/trips/sample-trip/index.html
grep -q 'data-to="critty@fisharefriends.org" data-subject="fish are friends: count me in: sample trip"' public/trips/sample-trip/index.html
grep -q '0 of 3 taken' public/trips/index.html
grep -q '<h2 class="sub">upcoming</h2>' public/trips/index.html
grep -q 'href="/trips/sample-trip/">sample trip' public/trips/index.html
grep -q 'id="september-2026">September 2026' public/archive/index.html
grep -q 'href="/posts/first-morice-steelhead/">first morice steelhead' public/archive/index.html
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
grep -q '<div class="map doodle" aria-hidden="true"><svg' public/trips/squamish-river/index.html
grep -q '>squamish river</text>' public/trips/squamish-river/index.html
hugo build -d public --quiet --cleanDestinationDir
test ! -e public/trips/sample-trip
grep -q 'href="/trips/squamish-river/">squamish river' public/trips/index.html
