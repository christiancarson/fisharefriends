# how to tag

Drop a photo in a month folder, give it Finder tags, and the site sorts it. This is the whole rule set.

## the shape of a tag set

    [tab tag]  [names that belong to that tab]  [water name]  [species]

- **tab tags:** `friends`, `fish`, `music`, `works`. A tab tag tells the site what the other names on the photo are.
- **names:** anything that is not a tab tag, a water or a species. Beside `friends` it is a person, beside `fish` it is a fish's name, beside `works` a project. On a song file it is a genre.
- **water:** any name ending in river, creek, lake, pond, slough, estuary, lagoon, bay, harbour, inlet, sound, strait, channel, passage, cove or ocean. It gets a map and the photo nests under it.
- **species:** rainbow trout, bull trout, coho, steelhead and about 200 others, or any two-word name ending in trout, salmon, char, rockfish, snapper and so on. Filed under fish with the Latin name.

Case never matters. Periods are dropped (`Sam A.` is `Sam A`). Group words like water, rivers, lakes, estuary or ocean are ignored, so add them or not.

## the file name is the card title

- underscores become spaces: `all_hands_on_deck.jpeg` shows as "all hands on deck"
- a water or species word in the name is stripped: `Josh_Dean_River` tagged Dean River shows as "Josh"
- a trailing on, at, in, from, of, the, and, with is dropped: `standing_on` shows as "standing"
- `Screenshot ...`, `IMG_...`, `DSC_...` publish with no title, so rename the file to give it one
- emoji work in file names
- `Name.txt` beside the photo is its caption

## sequences

**a friend, no fish**
`friends`, `Sam A`, `Kennedy Lake`
Sam A nests under friends, the photo under Kennedy Lake.

**a fish you caught, no people**
file `Ruby.jpg`, tags `fish`, `Rainbow Trout`, `Morice River`
Ruby is the title. To give Ruby her own page, add the tag `Ruby` too.

**a friend holding a fish**
file `Trevor.jpg`, tags `friends`, `Sam A`, `fish`, `Rainbow Trout`, `Trevor`
The tag that matches the file name is the fish, so Trevor goes under fish and Sam A under friends. Name the file after the fish.

**someone's first fish**
add `first fish` to the set above. It is pinned under fish.

**a place, nobody in it**
`Lost Lake`
That is enough. No tab tag needed.

**a work day**
`works`, `restoration`, `Kennedy River`
Add `friends` and names if people are the point of the photo. Restoration is pinned under works.

**a song**
file `Banquet_by_Bloc_Party__P-i0jw61niE.video` (the YouTube id after the double underscore), tags `indie`
Genres nest under music. `Banquet_by_Bloc_Party.txt` beside it is the caption.

**a screenshot or a saved image**
Rename it, then tag everything, including the water. It has no GPS and no useful name.

**a month with one water**
an empty `Morice_River.river` file in the folder puts every untagged photo of that month under the Morice.

**a note about a water**
`Kennedy_River.txt` in any month folder becomes that water's description on every page it appears.

## how the map is chosen

- the map is drawn once, the first time a water name appears
- if the photos carry GPS, the water of that name nearest to where you stood is drawn, so two Lost Lakes never get mixed up
- if the nearest water of that name is more than 15 km away, the lake or stream at your feet is drawn instead, and the log names it (your "lost lake" is Rolf Lake to the province, your "onion lake" has no official name)
- GPS is used only for that choice; published photos carry no location
- if no map can be drawn, the photo still publishes, just without one

## the first time a name appears

- a name filed under a tab stays there for good, even if later photos tag it differently
- a new name that sits beside two tab tags on the same photo goes to friends first. To start a new project, tag it on a works-only photo first, or ask for it to be pinned.
- a new name with no tab tag beside it becomes a tab of its own with a petal. Right for a new facet, wrong for a typo, and you will see it in the sidebar at once.
- once a name is known, the name alone is enough; the tab tag is added for you

## fixing mistakes

- retag or rename in Finder and the site follows within a couple of minutes
- a name in the wrong tab: change its `parent` in `data/tags.toml` in the repo, or ask
- a name that must always land somewhere: `[params.nest]` in `hugo.toml` (`'first fish' = 'fish'`, `restoration = 'works'`)
- a species without a Latin name: add it to `data/latin.toml`
- move a photo to `_trash` to take it off the site
- the sync log is `~/Library/Logs/fisharefriends-sync.log`; map choices and skipped folders are written there
