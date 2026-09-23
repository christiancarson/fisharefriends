# fish are friends

The site behind fisharefriends.org. Hugo builds it, GitHub Pages serves it, a push to main publishes it.

new post: `hugo new content posts/<slug>/index.md`, set `categories` to one of fishing, music, life, write under the front matter. Photos sit beside index.md and go in as `![](photo.jpg)`. Music: `{{< youtube ID >}}` or paste an embed iframe.

new trip: `hugo new content trips/<slug>/index.md`, fill in trip_date, where, meet, spots, crew, bring. Friends press "count me in", which opens an email with the trip in the subject; add their name to crew.

preview: `hugo server -D`, then open http://localhost:1313/

publish: `git add -A && git commit -m "..." && git push`

check: `./test.sh`

Hold a post back with `draft: true`. Profile photo: assets/img/profile.jpg. Bio, email and links: hugo.toml. Delete content/trips/sample-trip once a real trip exists.
