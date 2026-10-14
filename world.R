library(sf)
library(jsonlite)
dir <- path.expand("~/Library/Caches/fisharefriends/ne")
dir.create(dir, recursive = TRUE, showWarnings = FALSE)
crs <- "+proj=eqearth +R=6378137"
get <- function(n, url) {
  f <- file.path(dir, paste0(n, ".geojson"))
  if (!file.exists(f)) download.file(url, f, quiet = TRUE)
  st_transform(st_geometry(st_read(f, quiet = TRUE)), crs)
}
ne <- function(n) get(n, paste0("https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/", n, ".geojson"))
wfs <- function(layer, cql) {
  q <- c(service = "WFS", version = "2.0.0", request = "GetFeature", typeName = layer, outputFormat = "json", srsName = "EPSG:3005", count = "10000", CQL_FILTER = cql)
  st_read(paste0("https://openmaps.gov.bc.ca/geo/pub/wfs?", paste0(names(q), "=", URLencode(q, reserved = TRUE), collapse = "&")), quiet = TRUE)
}
strands <- function(g, tol) st_zm(st_simplify(st_cast(st_cast(g, "MULTILINESTRING"), "LINESTRING"), dTolerance = tol))
coast <- ne("ne_110m_coastline")
enc <- function(g) Filter(Negate(is.null), lapply(st_transform(g, 4326), function(p) { v <- round(p[, 1:2] * 1e4); v <- v[c(TRUE, rowSums(abs(diff(v))) > 0), , drop = FALSE]; if (nrow(v) < 2) NULL else c(v[1, ], as.vector(t(diff(v)))) }))
world <- strands(coast, 20000)
rivers <- if (file.exists("data/rivers.toml")) readLines("data/rivers.toml") else character()
lat <- as.numeric(sub("lat = ", "", grep("^lat = ", rivers, value = TRUE)))
lon <- as.numeric(sub("lon = ", "", grep("^lon = ", rivers, value = TRUE)))
pts <- if (length(lat)) st_transform(st_sfc(st_multipoint(cbind(lon, lat)), crs = 4326), crs) else st_sfc(crs = crs)
here <- if (length(lat)) st_union(st_buffer(pts, 250000)) else st_sfc(crs = crs)
close <- if (length(lat)) st_union(st_buffer(pts, 25000)) else st_sfc(crs = crs)
near <- function(g, tol) { g <- g[lengths(st_intersects(g, here)) > 0]; if (!length(g)) return(st_sfc(crs = crs)); strands(st_difference(st_intersection(st_make_valid(g), here), close), tol) }
region <- if (length(here)) near(ne("ne_10m_coastline"), 100) else st_sfc(crs = crs)
far <- if (length(here)) strands(st_difference(world, here), 20000) else world
shore <- function(poly) { xy <- st_bbox(st_transform(poly, 3005)); g <- tryCatch(st_geometry(wfs("WHSE_BASEMAPPING.FWA_COASTLINES_SP", sprintf("BBOX(GEOMETRY,%f,%f,%f,%f)", xy$xmin, xy$ymin, xy$xmax, xy$ymax))), error = function(e) st_sfc(crs = 3005)); if (!length(g)) return(st_sfc(crs = crs)); st_intersection(st_transform(g, crs), poly) }
local <- if (length(close)) do.call(c, lapply(seq_along(st_cast(close, "POLYGON")), function(i) shore(st_cast(close, "POLYGON")[i]))) else st_sfc(crs = crs)
local <- if (length(local)) strands(local, 60) else st_sfc(crs = crs)
slugs <- sort(sub(".json$", "", list.files("data/waters", pattern = "\\.json$")))
out <- list(waters = paste(slugs, collapse = " "), world = enc(world), landx = enc(far), region = enc(region), local = enc(local))
writeLines(toJSON(out, auto_unbox = TRUE, digits = NA), "assets/maps/world.json")
message("world.json: ", paste(sapply(out[c("world", "landx", "region", "local")], function(l) sum(lengths(l)) / 2), collapse = ", "), " points")
