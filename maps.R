library(sf)
args <- commandArgs(TRUE)
name <- args[1]
alias <- if (length(args) > 1) args[2] else name
wfs <- function(layer, cql) {
  q <- c(service = "WFS", version = "2.0.0", request = "GetFeature", typeName = layer, outputFormat = "json", srsName = "EPSG:3005", count = "10000", CQL_FILTER = cql)
  st_read(paste0("https://openmaps.gov.bc.ca/geo/pub/wfs?", paste0(names(q), "=", URLencode(q, reserved = TRUE), collapse = "&")), quiet = TRUE)
}
tol <- 60
s <- wfs("WHSE_BASEMAPPING.FWA_STREAM_NETWORKS_SP", sprintf("GNIS_NAME='%s'", name))
g <- st_geometry(s)
if (!nrow(s)) {
  l <- wfs("WHSE_BASEMAPPING.FWA_LAKES_POLY", sprintf("GNIS_NAME_1='%s'", name))
  if (nrow(l)) g <- st_cast(st_geometry(l[which.max(l$AREA_HA), ]), "MULTILINESTRING")
  tol <- 15
}
if (!length(g)) {
  osm <- tempfile(fileext = ".osm")
  system2("curl", c("-s", "-m", "150", "-A", shQuote("fisharefriends.org maps"), "-X", "POST", "https://overpass-api.de/api/interpreter", "--data-urlencode", shQuote(sprintf('data=[out:xml][timeout:120];(way["waterway"~"river|stream"]["name"="%s"];relation["waterway"~"river|stream"]["name"="%s"];way["natural"="water"]["name"="%s"];relation["natural"="water"]["name"="%s"];);(._;>;);out body;', name, name, name, name)), "-o", osm))
  g <- st_transform(st_geometry(suppressWarnings(st_read(osm, "lines", quiet = TRUE))), 3005)
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
title <- if (grepl(" (River|Creek)$", alias)) paste("The", alias) else alias
if (!any(old == sprintf('["%s"]', slug))) writeLines(c(old, sprintf('["%s"]', slug), sprintf('title = "%s"', title), 'about = ""', ""), "data/rivers.toml")
