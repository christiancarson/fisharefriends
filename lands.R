suppressMessages(library(sf))
library(jsonlite)
slug <- commandArgs(TRUE)[1]
crs <- "+proj=eqearth +R=6378137"
f <- path.expand("~/Library/Caches/fisharefriends/ne/territories.geojson")
dir.create(dirname(f), recursive = TRUE, showWarnings = FALSE)
if (!file.exists(f)) download.file("https://native-land.ca/api/polygons/geojson/territories", f, quiet = TRUE)
t <- st_transform(st_make_valid(st_read(f, quiet = TRUE)), crs)
lines <- fromJSON(sprintf("data/waters/%s.json", slug), simplifyVector = FALSE)$lines
g <- st_transform(st_sfc(lapply(lines, function(v) st_linestring(apply(matrix(unlist(v), ncol = 2, byrow = TRUE), 2, cumsum) / 1e4)), crs = 4326), crs)
names <- sort(unique(stringi::stri_trans_nfc(trimws(t$Name[lengths(st_intersects(t, g)) > 0]))))
old <- readLines("data/rivers.toml")
at <- which(old == sprintf('["%s"]', slug))
stopifnot(length(at) == 1)
end <- at + min(c(grep("^\\[", old[-(1:at)]), length(old) - at)) - 1
line <- sprintf("lands = %s", toJSON(names))
had <- at + grep("^lands = ", old[(at + 1):end]) - 1 + 1
old <- if (length(had)) replace(old, had[1], line) else append(old, line, at)
writeLines(old, "data/rivers.toml")
message(slug, ": ", if (length(names)) paste(names, collapse = ", ") else "no territory found")
