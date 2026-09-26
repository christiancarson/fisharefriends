library(sf)
library(jsonlite)
args <- commandArgs(TRUE)
name <- args[1]
alias <- if (length(args) > 1) args[2] else name
grp <- if (length(args) > 2 && nzchar(args[3])) sprintf(" AND WATERSHED_GROUP_CODE='%s'", args[3]) else ""
pt <- if (length(args) > 4 && nzchar(args[4])) st_transform(st_sfc(st_point(c(as.numeric(args[5]), as.numeric(args[4]))), crs = 4326), 3005) else NULL
wfs <- function(layer, cql) {
  q <- c(service = "WFS", version = "2.0.0", request = "GetFeature", typeName = layer, outputFormat = "json", srsName = "EPSG:3005", count = "10000", CQL_FILTER = cql)
  st_read(paste0("https://openmaps.gov.bc.ca/geo/pub/wfs?", paste0(names(q), "=", URLencode(q, reserved = TRUE), collapse = "&")), quiet = TRUE)
}
tol <- 60
eps <- c("https://overpass-api.de/api/interpreter", "https://overpass.kumi.systems/api/interpreter")
got <- function(f, tag) file.exists(f) && file.size(f) > 0 && any(grepl(tag, readLines(f, n = 20, warn = FALSE), fixed = TRUE)) && !any(grepl("runtime error", readLines(f, n = 20, warn = FALSE), fixed = TRUE))
eps <- c("https://overpass-api.de/api/interpreter", "https://overpass.kumi.systems/api/interpreter")
got <- function(f, tag) file.exists(f) && file.size(f) > 0 && any(grepl(tag, readLines(f, n = 20, warn = FALSE), fixed = TRUE)) && !any(grepl("runtime error", readLines(f, n = 20, warn = FALSE), fixed = TRUE))
s <- wfs("WHSE_BASEMAPPING.FWA_STREAM_NETWORKS_SP", sprintf("GNIS_NAME='%s'%s", name, grp))
if (nrow(s) && !is.null(pt) && !nzchar(grp)) {
  near <- s$WATERSHED_GROUP_CODE[which.min(st_distance(s, pt))]
  message(name, ": nearest to the photos is in ", near, " (", round(min(st_distance(s, pt)) / 1000, 1), " km)")
  s <- s[s$WATERSHED_GROUP_CODE == near, ]
}
g <- st_geometry(s)
if (!nrow(s)) {
  l <- wfs("WHSE_BASEMAPPING.FWA_LAKES_POLY", sprintf("GNIS_NAME_1='%s'%s", name, grp))
  if (nrow(l) && !is.null(pt)) message(name, ": nearest lake to the photos is in ", l$WATERSHED_GROUP_CODE[which.min(st_distance(l, pt))], " (", round(min(st_distance(l, pt)) / 1000, 1), " km)")
  if (nrow(l)) g <- st_cast(st_geometry(l[if (!is.null(pt)) which.min(st_distance(l, pt)) else which.max(l$AREA_HA), ]), "MULTILINESTRING")
  tol <- 15
}
kind <- tolower(sub(".* ", "", name))
far <- !is.null(pt) && kind %in% c("lake", "pond", "river", "creek") && (!length(g) || as.numeric(min(st_distance(g, pt))) > 15000)
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
    s <- wfs("WHSE_BASEMAPPING.FWA_STREAM_NETWORKS_SP", paste0(box, " AND GNIS_NAME IS NOT NULL"))
    if (nrow(s)) {
      k <- s$GNIS_NAME[which.min(st_distance(s, pt))]
      message(name, ": named match is far from the photos, drawing the stream at the photos instead: ", k)
      g <- st_geometry(s[s$GNIS_NAME == k, ])
    }
  }
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
sea <- kind %in% c("bay", "harbour", "sound", "inlet", "ocean", "strait", "channel", "passage", "cove")
bc <- 'area["ISO3166-2"="CA-BC"]->.bc;'
if (!length(g) && !sea) {
  osm <- tempfile(fileext = ".osm")
  q <- function(a, b) sprintf('data=[out:xml][timeout:120];%s(way["waterway"~"river|stream"]["name"="%s"]%s;relation["waterway"~"river|stream"]["name"="%s"]%s;way["natural"="water"]["name"="%s"]%s;relation["natural"="water"]["name"="%s"]%s;);(._;>;);out body;', a, name, b, name, b, name, b, name, b)
  if (ask(c(q(bc, "(area.bc)"), q("", "")), osm, "<osm", function(f) length(lines(f)) > 0)) g <- st_transform(lines(osm), 3005)
}
if (!length(g)) {
  if (!is.null(pt)) {
    ll <- st_coordinates(st_transform(pt, 4326))
    lat <- ll[1, 2]
    lon <- ll[1, 1]
    message(name, ": drawing the shore around the photos")
  } else {
    ctr <- tempfile(fileext = ".json")
    q <- function(a, b) sprintf('data=[out:json][timeout:120];%s(node["name"="%s"]%s;way["name"="%s"]%s;relation["name"="%s"]%s;);out center 1;', a, name, b, name, b, name, b)
    stopifnot(ask(c(q(bc, "(area.bc)"), q("", "")), ctr, "elements", function(f) length(fromJSON(f)$elements) > 0))
    e <- fromJSON(ctr)$elements
    lat <- if (!is.null(e$lat)) e$lat[1] else e$center$lat[1]
    lon <- if (!is.null(e$lon)) e$lon[1] else e$center$lon[1]
  }
  osm <- tempfile(fileext = ".osm")
  dlat <- 4000 / 111320
  dlon <- 4000 / (111320 * cos(lat * pi / 180))
  q <- sprintf('data=[out:xml][timeout:120][bbox:%f,%f,%f,%f];(way["natural"="coastline"];way["waterway"~"river|stream"];);(._;>;);out body;', lat - dlat, lon - dlon, lat + dlat, lon + dlon)
  if (ask(q, osm, "<osm", function(f) length(lines(f)) > 0)) g <- st_transform(lines(osm), 3005)
}
stopifnot(length(g) > 0)
g <- st_zm(st_simplify(st_cast(st_cast(g, "MULTILINESTRING"), "LINESTRING"), dTolerance = tol))
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
old <- if (file.exists("data/rivers.toml")) readLines("data/rivers.toml") else character()
title <- alias
if (!any(old == sprintf('["%s"]', slug))) writeLines(c(old, sprintf('["%s"]', slug), sprintf('title = "%s"', title), 'about = ""', ""), "data/rivers.toml")
