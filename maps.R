library(sf)
river <- commandArgs(TRUE)[1]
q <- c(service = "WFS", version = "2.0.0", request = "GetFeature", typeName = "WHSE_BASEMAPPING.FWA_STREAM_NETWORKS_SP", outputFormat = "json", srsName = "EPSG:3005", count = "10000", CQL_FILTER = sprintf("GNIS_NAME='%s'", river))
main <- st_read(paste0("https://openmaps.gov.bc.ca/geo/pub/wfs?", paste0(names(q), "=", URLencode(q, reserved = TRUE), collapse = "&")), quiet = TRUE)
stopifnot(nrow(main) < 10000)
g <- st_zm(st_simplify(st_cast(st_geometry(main), "LINESTRING"), dTolerance = 60))
b <- st_bbox(g)
x0 <- 8
y0 <- 8
w <- 624
h <- 344
cx <- (b$xmin + b$xmax) / 2
cy <- (b$ymin + b$ymax) / 2
W <- max(b$xmax - b$xmin, (b$ymax - b$ymin) * w / h)
H <- W * h / w
s <- w / W
d <- vapply(g, function(p) paste("M", paste(round((p[, 1] - (cx - W / 2)) * s + x0, 1), round(((cy + H / 2) - p[, 2]) * s + y0, 1), collapse = " L ")), "")
svg <- c('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 360" preserveAspectRatio="xMinYMin meet" fill="none" stroke="#111" stroke-linecap="round" stroke-linejoin="round">', sprintf('<path d="%s" stroke-width="5"/>', d), "</svg>")
writeLines(svg, sprintf("assets/maps/%s.svg", gsub(" ", "-", tolower(river))))
