library(sf)
dir <- path.expand("~/Library/Caches/fisharefriends/ne")
dir.create(dir, recursive = TRUE, showWarnings = FALSE)
crs <- "+proj=eqearth +R=6378137"
get <- function(n, url) {
  f <- file.path(dir, paste0(n, ".geojson"))
  if (!file.exists(f)) download.file(url, f, quiet = TRUE)
  st_transform(st_geometry(st_read(f, quiet = TRUE)), crs)
}
ne <- function(n) get(n, paste0("https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/", n, ".geojson"))
strands <- function(g, tol) st_zm(st_simplify(st_cast(st_cast(g, "MULTILINESTRING"), "LINESTRING"), dTolerance = tol))
coast <- ne("ne_110m_coastline")
b <- st_bbox(coast)
s <- min(608 / (b$xmax - b$xmin), 328 / (b$ymax - b$ymin))
cx <- 320 - s * (b$xmin + b$xmax) / 2
cy <- 180 + s * (b$ymin + b$ymax) / 2
px <- function(g) vapply(g, function(p) paste("M", paste(round(cx + s * p[, 1], 1), round(cy - s * p[, 2], 1), collapse = " L ")), "")
fine <- function(g) vapply(g, function(p) { v <- round(cbind(cx + s * p[, 1], cy - s * p[, 2]) * 1000); v <- v[c(TRUE, rowSums(abs(diff(v))) > 0), , drop = FALSE]; if (nrow(v) < 2) "" else paste0("M", v[1, 1], " ", v[1, 2], "l", paste(diff(v[, 1]), diff(v[, 2]), collapse = " ")) }, "")
world <- strands(coast, 20000)
rivers <- if (file.exists("data/rivers.toml")) readLines("data/rivers.toml") else character()
lat <- as.numeric(sub("lat = ", "", grep("^lat = ", rivers, value = TRUE)))
lon <- as.numeric(sub("lon = ", "", grep("^lon = ", rivers, value = TRUE)))
here <- if (length(lat)) st_union(st_buffer(st_transform(st_sfc(st_multipoint(cbind(lon, lat)), crs = 4326), crs), 250000)) else st_sfc(crs = crs)
near <- function(g, tol, clip) { g <- g[lengths(st_intersects(g, here)) > 0]; if (!length(g)) return(st_sfc(crs = crs)); if (clip) g <- st_intersection(st_make_valid(g), here); strands(g, tol) }
detail <- if (length(here)) near(ne("ne_10m_coastline"), 100, TRUE) else st_sfc(crs = crs)
far <- if (length(here)) strands(st_difference(world, here), 20000) else world
slugs <- sort(sub(".json$", "", list.files("data/waters", pattern = "\\.json$")))
path <- function(d) sprintf('<path d="%s"/>', d[nzchar(d)])
svg <- c('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 360" preserveAspectRatio="xMinYMin meet" fill="none" stroke="#111" stroke-linecap="round" stroke-linejoin="round">',
  sprintf('<g id="land" data-fit="%.6g %.6g %.8g">', cx, cy, s), path(px(world)), "</g>",
  '<g id="landx">', path(px(far)), "</g>",
  sprintf('<g id="detail" transform="scale(.001)" data-waters="%s">', paste(slugs, collapse = " ")), path(fine(detail)), "</g>", "</svg>")
writeLines(svg, "assets/maps/world.svg")
