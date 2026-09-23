# fish are friends

The site behind fisharefriends.org. Hugo builds it, GitHub Pages serves it, a push to main publishes it.

new post: `hugo new content posts/<slug>/index.md`, set `categories` to one or more of spey fishing, single hand, music, floats, fly tying, film, art, write under the front matter. Photos sit beside index.md and go in as `![](photo.jpg)`. Add `river: "Morice River"` to the front matter and the post shows that river map (see maps.R). Music: `{{< youtube ID >}}` or paste an embed iframe.

new trip: `hugo new content trips/<slug>/index.md`, set `kind` to raft (three spots) or wade (four spots), fill in trip_date, where (the place, with the river in brackets), river (names the map file), meet, crew, donate and donate_url (the group that gets the donations), bring. Every card links the BC freshwater licence page from `licence` in hugo.toml, and shows the river map `assets/maps/<river>.svg` when one exists: `Rscript maps.R "Squamish River"` draws it from the BC Freshwater Atlas (needs R with sf). Keep `crew: []` until someone signs up. Friends sign themselves in on the card. With `signup` in hugo.toml set to the Apps Script web app URL, names live in the Google Sheet and the card shows them live (crew in the front matter is ignored); with `signup` empty, the form falls back to an email to `email` and you keep crew by hand. The script is signup.gs: new Google Sheet, Extensions, Apps Script, paste it, Deploy as web app executing as you with access for anyone, copy the /exec URL into hugo.toml.

preview: `hugo server -D`, then open http://localhost:1313/

publish: `git add -A && git commit -m "..." && git push`

check: `./test.sh`

Hold a post back with `draft: true`. Profile photo: assets/img/profile.jpg. Email: hugo.toml. Categories: the folders under content/categories, ordered by weight. Spots per kind: the `[params.trips]` tables in hugo.toml. Links: replace `links = []` in hugo.toml with `links = [{ name = 'a name', url = 'https://example.org' }]`. content/trips/sample-trip is the draft that test.sh builds against; leave it. Trips move from upcoming to past on the nightly rebuild; if nothing has been pushed for two months GitHub pauses that schedule, so push or run the workflow by hand from the Actions tab.
