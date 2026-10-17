library(sf)
library(jsonlite)
args <- commandArgs(TRUE)
name <- args[1]
alias <- if (length(args) > 1) args[2] else name
grp <- if (length(args) > 2 && nzchar(args[3])) sprintf(" AND WATERSHED_GROUP_CODE='%s'", args[3]) else ""
pt <- if (length(args) > 4 && nzchar(args[4])) st_transform(st_sfc(st_point(c(as.numeric(args[5]), as.numeric(args[4]))), crs = 4326), 3005) else NULL
lit <- function(v) gsub("'", "''", v)
wfs <- function(layer, cql) {
  q <- c(service = "WFS", version = "2.0.0", request = "GetFeature", typeName = layer, outputFormat = "json", srsName = "EPSG:3005", count = "10000", CQL_FILTER = cql)
  u <- paste0("https://openmaps.gov.bc.ca/geo/pub/wfs?", paste0(names(q), "=", URLencode(q, reserved = TRUE), collapse = "&"))
  for (i in 1:4) { r <- tryCatch(suppressWarnings(st_read(u, quiet = TRUE)), error = function(e) NULL); if (!is.null(r)) return(r); Sys.sleep(5 * i) }
  stop(name, ": the BC map server is not answering")
}
streams <- "WHSE_BASEMAPPING.FWA_STREAM_NETWORKS_SP"
eps <- c("https://overpass-api.de/api/interpreter", "https://overpass.kumi.systems/api/interpreter")
got <- function(f, tag) file.exists(f) && file.size(f) > 0 && any(grepl(tag, readLines(f, n = 20, warn = FALSE), fixed = TRUE)) && !any(grepl("runtime error", readLines(f, n = 20, warn = FALSE), fixed = TRUE))
kind <- tolower(sub(".* ", "", name))
base <- sub(" [^ ]+$", "", name)
sea <- kind %in% c("bay", "harbour", "sound", "inlet", "ocean", "strait", "channel", "passage", "cove")
tries <- switch(kind, river = c(name, paste(base, "Creek")), creek = c(name, paste(base, "River")), estuary = if (grepl(" (River|Creek)$", base)) base else paste(base, c("River", "Creek")), name)
tol <- if (sea || kind == "estuary") 15 else 60
km <- function(a, b) as.numeric(min(st_distance(a, b))) / 1000
strands <- function(o) { o <- o[st_dimension(o) %in% 1]; if (any(st_is(o, "GEOMETRYCOLLECTION"))) o <- st_collection_extract(o, "LINESTRING"); st_zm(o) }
shore <- function(p, r, reach = 8000) {
  xy <- st_coordinates(p)
  c <- wfs("WHSE_BASEMAPPING.FWA_COASTLINES_SP", sprintf("BBOX(GEOMETRY,%f,%f,%f,%f)", xy[1] - r - reach, xy[2] - r - reach, xy[1] + r + reach, xy[2] + r + reach))
  if (!nrow(c)) return(st_sfc(crs = 3005))
  d <- as.numeric(min(st_distance(st_geometry(c), p)))
  if (d > reach) return(st_sfc(crs = 3005))
  strands(st_intersection(st_geometry(c), st_buffer(p, r + d)))
}
foot <- function(s) st_sfc(st_point(st_coordinates(st_zm(st_geometry(s[which.min(s$DOWNSTREAM_ROUTE_MEASURE), ])))[1, 1:2]), crs = 3005)
reach <- function(s, to) { g <- st_zm(st_geometry(s)); for (i in seq_len(nrow(s))) if (s$DOWNSTREAM_ROUTE_MEASURE[i] + s$LENGTH_METRE[i] > to) g[i] <- lwgeom::st_linesubstring(g[i], 0, (to - s$DOWNSTREAM_ROUTE_MEASURE[i]) / s$LENGTH_METRE[i]); g }
mouth <- function(nm) {
  s <- wfs(streams, sprintf("GNIS_NAME='%s' AND DOWNSTREAM_ROUTE_MEASURE < 3000%s", lit(nm), grp))
  if (!nrow(s)) return(st_sfc(crs = 3005))
  keys <- unique(s$BLUE_LINE_KEY)
  near <- function(k) km(s[s$BLUE_LINE_KEY == k, ], pt)
  if (!is.null(pt)) { k <- keys[which.min(sapply(keys, near))]; if (near(k) > 15) { message(name, ": the nearest mouth of ", nm, " is ", round(near(k)), " km from the photos"); return(st_sfc(crs = 3005)) } }
  else if (length(keys) == 1) k <- keys
  else { k <- keys[sapply(keys, function(k) length(shore(foot(s[s$BLUE_LINE_KEY == k, ]), 2000, 2000)) > 0)]; if (length(k) != 1) stop(name, ": ", length(keys), " rivers are named ", nm, " and ", length(k), " of them meet the sea, add lat and lon for it in data/rivers.toml") }
  s <- s[s$BLUE_LINE_KEY == k, ]
  g <- reach(s, 3000)
  for (i in 1:3) {
    sh <- shore(foot(s), 2000, 2000)
    if (length(sh) || i == 3) break
    b <- strsplit(s$FWA_WATERSHED_CODE[1], "-")[[1]]
    b[max(which(b != "000000"))] <- "000000"
    p <- wfs(streams, sprintf("FWA_WATERSHED_CODE='%s'", paste(b, collapse = "-")))
    if (!nrow(p)) break
    p <- p[p$DOWNSTREAM_ROUTE_MEASURE <= p$DOWNSTREAM_ROUTE_MEASURE[which.min(st_distance(p, foot(s)))], ]
    message(name, ": ", s$GNIS_NAME[1], " meets ", p$GNIS_NAME[1], ", following it to the sea")
    s <- p
    g <- c(g, st_zm(st_geometry(p)))
  }
  if (!length(sh)) message(name, ": no sea within 2 km of the mouth of ", nm)
  c(g, sh)
}
g <- st_sfc(crs = 3005)
if (kind == "estuary") {
  for (nm in tries) { g <- mouth(nm); if (length(g)) { message(name, ": drawn as the mouth of ", nm); break } }
} else if (!sea) {
  for (nm in tries) { s <- wfs(streams, sprintf("GNIS_NAME='%s'%s", lit(nm), grp)); if (nrow(s)) { if (nm != name) message(name, ": drawn from ", nm); break } }
  if (nrow(s) && !is.null(pt) && !nzchar(grp)) {
    near <- s$WATERSHED_GROUP_CODE[which.min(st_distance(s, pt))]
    message(name, ": nearest to the photos is in ", near, " (", round(km(s, pt), 1), " km)")
    repeat { more <- unique(s$WATERSHED_GROUP_CODE[lengths(st_intersects(s, s[s$WATERSHED_GROUP_CODE %in% near, ])) > 0]); if (all(more %in% near)) break; near <- union(near, more) }
    s <- s[s$WATERSHED_GROUP_CODE %in% near, ]
  }
  g <- st_geometry(s)
  if (!nrow(s)) {
    l <- wfs("WHSE_BASEMAPPING.FWA_LAKES_POLY", sprintf("GNIS_NAME_1='%s'%s", lit(name), grp))
    if (nrow(l) && !is.null(pt)) message(name, ": nearest lake to the photos is in ", l$WATERSHED_GROUP_CODE[which.min(st_distance(l, pt))], " (", round(km(l, pt), 1), " km)")
    if (nrow(l)) g <- st_cast(st_geometry(l[if (!is.null(pt)) which.min(st_distance(l, pt)) else which.max(l$AREA_HA), ]), "MULTILINESTRING")
    tol <- 15
  }
}
far <- !is.null(pt) && kind %in% c("lake", "pond", "river", "creek", "estuary") && (!length(g) || km(g, pt) > 15)
if (far) {
  xy <- st_coordinates(pt)
  box <- sprintf("BBOX(GEOMETRY,%f,%f,%f,%f)", xy[1] - 2500, xy[2] - 2500, xy[1] + 2500, xy[2] + 2500)
  if (kind %in% c("lake", "pond")) {
    l <- wfs("WHSE_BASEMAPPING.FWA_LAKES_POLY", box)
    if (nrow(l)) {
      k <- which.min(st_distance(l, pt))
      message(name, ": named match is far from the photos, drawing the lake at the photos instead: ", l$GNIS_NAME_1[k], " (", round(as.numeric(st_distance(l, pt))[k] / 1000, 1), " km)")
      g <- st_cast(st_geometry(l[k, ]), "MULTILINESTRING")
      tol <- 15
    }
  } else {
    s <- wfs(streams, paste0(box, " AND GNIS_NAME IS NOT NULL"))
    if (nrow(s)) {
      k <- s$GNIS_NAME[which.min(st_distance(s, pt))]
      message(name, ": named match is far from the photos, drawing the ", if (kind == "estuary") "mouth of the " else "", "stream at the photos instead: ", k)
      g <- if (kind == "estuary") mouth(k) else st_geometry(s[s$GNIS_NAME == k, ])
    }
  }
  if (length(g) && km(g, pt) > 15) g <- st_sfc(crs = 3005)
}
ask <- function(qs, out, tag, has) {
  for (q in qs) for (i in 1:3) {
    system2("curl", c("-s", "-m", "150", "-A", shQuote("fisharefriends.org maps"), "-X", "POST", eps[(i - 1) %% 2 + 1], "--data-urlencode", shQuote(q), "-o", out))
    if (got(out, tag)) {
      if (isTRUE(tryCatch(has(out), error = function(e) FALSE))) return(TRUE)
      break
    }
    Sys.sleep(20)
  }
  FALSE
}
lines <- function(f) st_geometry(suppressWarnings(st_read(f, "lines", quiet = TRUE)))
bc <- 'area["ISO3166-2"="CA-BC"]->.bc;'
if (!length(g) && !sea && kind != "estuary") {
  osm <- tempfile(fileext = ".osm")
  q <- function(a, b) sprintf('data=[out:xml][timeout:120];%s(way["waterway"~"river|stream"]["name"="%s"]%s;relation["waterway"~"river|stream"]["name"="%s"]%s;way["natural"="water"]["name"="%s"]%s;relation["natural"="water"]["name"="%s"]%s;);(._;>;);out body;', a, name, b, name, b, name, b, name, b)
  if (ask(c(q(bc, "(area.bc)"), q("", "")), osm, "<osm", function(f) length(lines(f)) > 0)) g <- st_transform(lines(osm), 3005)
  if (length(g) > 1) {
    cl <- cutree(hclust(as.dist(matrix(as.numeric(st_distance(g)), length(g))), method = "single"), h = 2000)
    big <- if (is.null(pt)) as.integer(names(which.max(tapply(as.numeric(st_length(g)), cl, sum)))) else cl[which.min(as.numeric(st_distance(g, pt)))]
    if (any(cl != big)) message(name, ": ", length(unique(cl)), " places share this name, drawing the ", if (is.null(pt)) "longest" else "one nearest the photos")
    g <- g[cl == big]
  }
  if (length(g) && !is.null(pt) && km(g, pt) > 15) {
    message(name, ": nothing by that name near the photos, drawing the water around them instead")
    g <- st_sfc(crs = 3005)
  }
}
if (!length(g) && sea) {
  n <- wfs("WHSE_BASEMAPPING.GNS_GEOGRAPHICAL_NAMES_SP", sprintf("GEOGRAPHICAL_NAME ILIKE '%s %%' AND FEATURE_CLASS='Water Features' AND FEATURE_CATEGORY IN ('Shoreline Water Features','Standing Water Connecting Two or More Bodies of Water')", lit(base)))
  if (nrow(n)) {
    same <- tolower(n$GEOGRAPHICAL_NAME) == tolower(name)
    if (any(same)) n <- n[same, ]
    if (!is.null(pt)) k <- which.min(st_distance(n, pt)) else if (nrow(n) == 1) k <- 1 else stop(name, ": ", nrow(n), if (any(same)) " places share this name" else " sea waters start with this name", ", add lat and lon for it in data/rivers.toml")
    sh <- shore(st_geometry(n[k, ]), 2000)
    if (length(sh) && (is.null(pt) || km(sh, pt) <= 15)) { g <- sh; message(name, ": drawn as the shore of ", n$GEOGRAPHICAL_NAME[k], " (", n$FEATURE_TYPE[k], ")") }
    else message(name, ": ", n$GEOGRAPHICAL_NAME[k], if (length(sh)) paste0(" is ", round(km(sh, pt)), " km from the photos") else " has no shore within 8 km of its named point")
  }
}
if (!length(g)) {
  if (!is.null(pt)) {
    ll <- st_coordinates(st_transform(pt, 4326))
    lat <- ll[1, 2]
    lon <- ll[1, 1]
    message(name, ": drawing the water around the photos")
  } else {
    ctr <- tempfile(fileext = ".json")
    q <- function(a, b) sprintf('data=[out:json][timeout:120];%s(node["name"="%s"]%s;way["name"="%s"]%s;relation["name"="%s"]%s;);out center 1;', a, name, b, name, b, name, b)
    stopifnot(ask(c(q(bc, "(area.bc)"), q("", "")), ctr, "elements", function(f) length(fromJSON(f)$elements) > 0))
    e <- fromJSON(ctr)$elements
    lat <- if (!is.null(e$lat)) e$lat[1] else e$center$lat[1]
    lon <- if (!is.null(e$lon)) e$lon[1] else e$center$lon[1]
  }
  if (is.null(pt)) pt <- st_transform(st_sfc(st_point(c(lon, lat)), crs = 4326), 3005)
  span <- function(r) sprintf("[bbox:%f,%f,%f,%f]", lat - r / 111320, lon - r / (111320 * cos(lat * pi / 180)), lat + r / 111320, lon + r / (111320 * cos(lat * pi / 180)))
  if (sea || kind == "estuary") {
    g <- shore(pt, 1500)
    for (r in c(1500, 4000)) if (!length(g)) { osm <- tempfile(fileext = ".osm"); if (ask(sprintf('data=[out:xml][timeout:120]%s;(way["natural"="coastline"];);(._;>;);out body;', span(r)), osm, "<osm", function(f) length(lines(f)) > 0)) g <- strands(st_intersection(st_transform(lines(osm), 3005), st_buffer(pt, r))) }
  } else {
    osm <- tempfile(fileext = ".osm")
    if (ask(sprintf('data=[out:xml][timeout:120]%s;(way["waterway"~"river|stream"]["name"];);(._;>;);out body;', span(8000)), osm, "<osm", function(f) length(lines(f)) > 0)) { w <- st_transform(suppressWarnings(st_read(osm, "lines", quiet = TRUE)), 3005); k <- w$name[which.min(st_distance(w, pt))]; message(name, ": drawing the nearest named stream, ", k); g <- st_geometry(w[!is.na(w$name) & w$name == k, ]) }
  }
}
stopifnot(length(g) > 0)
g <- st_zm(st_simplify(st_cast(st_cast(g, "MULTILINESTRING"), "LINESTRING"), dTolerance = tol))
b <- st_bbox(g)
g <- g[as.numeric(st_length(g)) > max(b$xmax - b$xmin, b$ymax - b$ymin) / 608]
b <- st_bbox(g)
x0 <- 16
y0 <- 16
w <- 608
h <- 328
sx <- w / (b$xmax - b$xmin)
sy <- h / (b$ymax - b$ymin)
d <- vapply(g, function(p) paste("M", paste(round((p[, 1] - b$xmin) * sx + x0, 1), round((b$ymax - p[, 2]) * sy + y0, 1), collapse = " L ")), "")
svg <- c('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 360" preserveAspectRatio="xMinYMin meet" fill="none" stroke="#111" stroke-linecap="round" stroke-linejoin="round">', sprintf('<path d="%s" stroke-width="5"/>', d), "</svg>")
slug <- gsub(" ", "-", tolower(alias))
writeLines(svg, sprintf("assets/maps/%s.svg", slug))
dir.create("data/waters", showWarnings = FALSE)
lines <- Filter(Negate(is.null), lapply(st_transform(st_simplify(g, dTolerance = 100), 4326), function(p) { v <- round(p[, 1:2] * 1e4); v <- v[c(TRUE, rowSums(abs(diff(v))) > 0), , drop = FALSE]; if (nrow(v) < 2) NULL else c(v[1, ], as.vector(t(diff(v)))) }))
writeLines(toJSON(list(lines = lines)), sprintf("data/waters/%s.json", slug))
old <- if (file.exists("data/rivers.toml")) readLines("data/rivers.toml") else character()
title <- alias
ll <- st_coordinates(st_transform(st_centroid(st_union(g)), 4326))
at <- which(old == sprintf('["%s"]', slug))
where <- c(sprintf("lat = %.1f", ll[2]), sprintf("lon = %.1f", ll[1]))
blk <- if (length(at)) old[at:length(old)] else character()
nxt <- grep("^\\[", blk[-1])
blk <- blk[seq_len(if (length(nxt)) nxt[1] else length(blk))]
if (!length(at)) old <- c(old, sprintf('["%s"]', slug), sprintf('title = "%s"', title), 'about = ""', where, "") else if (!any(grepl("^lat = ", blk))) old <- append(old, where, at)
writeLines(old, "data/rivers.toml")
