library(sf)
river <- commandArgs(TRUE)[1]
q <- c(service = "WFS", version = "2.0.0", request = "GetFeature", typeName = "WHSE_BASEMAPPING.FWA_STREAM_NETWORKS_SP", outputFormat = "json", srsName = "EPSG:3005", count = "10000", CQL_FILTER = sprintf("GNIS_NAME='%s'", river))
main <- st_read(paste0("https://openmaps.gov.bc.ca/geo/pub/wfs?", paste0(names(q), "=", URLencode(q, reserved = TRUE), collapse = "&")), quiet = TRUE)
stopifnot(nrow(main) < 10000)
g <- st_zm(st_simplify(st_cast(st_geometry(main), "LINESTRING"), dTolerance = 60))
b <- st_bbox(g)
x0 <- 16
y0 <- 16
w <- 608
h <- 328
sx <- w / (b$xmax - b$xmin)
sy <- h / (b$ymax - b$ymin)
d <- vapply(g, function(p) paste("M", paste(round((p[, 1] - b$xmin) * sx + x0, 1), round((b$ymax - p[, 2]) * sy + y0, 1), collapse = " L ")), "")
svg <- c('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 360" preserveAspectRatio="xMinYMin meet" fill="none" stroke="#111" stroke-linecap="round" stroke-linejoin="round">', sprintf('<path d="%s" stroke-width="5"/>', d), "</svg>")
slug <- gsub(" ", "-", tolower(river))
writeLines(svg, sprintf("assets/maps/%s.svg", slug))
old <- if (file.exists("data/rivers.toml")) readLines("data/rivers.toml") else character()
if (!any(old == sprintf('["%s"]', slug))) writeLines(c(old, sprintf('["%s"]', slug), 'about = ""', ""), "data/rivers.toml")
