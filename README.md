# fish are friends

The site behind fisharefriends.org. Hugo builds it, GitHub Pages serves it, a push to main publishes it.

new post: `hugo new content posts/<slug>/index.md`, set `categories` to one of fishing, music, life, write under the front matter. Photos sit beside index.md and go in as `![](photo.jpg)`. Music: `{{< youtube ID >}}` or paste an embed iframe.

new trip: `hugo new content trips/<slug>/index.md`, set `kind` to raft (three spots) or wade (four spots), fill in trip_date, where, meet, crew, bring. Every card links the BC freshwater licence page from `licence` in hugo.toml, and shows the river map `assets/maps/<where>.svg` when one exists: `Rscript maps.R "Squamish River"` draws it from the BC Freshwater Atlas (needs R with sf). Keep `crew: []` until someone signs up. Friends fill in the sign-up form, which opens an email with their name, whether they need gear, and their wader size; add their name to crew.

preview: `hugo server -D`, then open http://localhost:1313/

publish: `git add -A && git commit -m "..." && git push`

check: `./test.sh`

Hold a post back with `draft: true`. Profile photo: assets/img/profile.jpg. Bio and email: hugo.toml. Spots per kind: the `[params.trips]` tables in hugo.toml. Links: replace `links = []` in hugo.toml with `links = [{ name = 'a name', url = 'https://example.org' }]`. content/trips/sample-trip is the draft that test.sh builds against; leave it. Trips move from upcoming to past on the nightly rebuild; if nothing has been pushed for two months GitHub pauses that schedule, so push or run the workflow by hand from the Actions tab.
