library(sf)
river <- commandArgs(TRUE)[1]
wfs <- function(cql) {
  q <- c(service = "WFS", version = "2.0.0", request = "GetFeature", typeName = "WHSE_BASEMAPPING.FWA_STREAM_NETWORKS_SP", outputFormat = "json", srsName = "EPSG:3005", count = "10000", CQL_FILTER = cql)
  x <- st_read(paste0("https://openmaps.gov.bc.ca/geo/pub/wfs?", paste0(names(q), "=", URLencode(q, reserved = TRUE), collapse = "&")), quiet = TRUE)
  stopifnot(nrow(x) < 10000)
  x
}
main <- wfs(sprintf("GNIS_NAME='%s'", river))
code <- strsplit(main$FWA_WATERSHED_CODE[1], "-")[[1]]
prefix <- paste(code[seq_len(match("000000", code) - 1)], collapse = "-")
net <- wfs(sprintf("FWA_WATERSHED_CODE LIKE '%s-%%' AND STREAM_ORDER>=%d", prefix, max(main$STREAM_ORDER) - 2))
thick <- ifelse(net$GNIS_NAME %in% river, 5, 2)
g <- st_zm(st_simplify(st_cast(st_geometry(net), "LINESTRING"), dTolerance = 60))
b <- st_bbox(g)
s <- 600 / (b$xmax - b$xmin)
h <- ceiling((b$ymax - b$ymin) * s)
d <- vapply(g, function(p) paste("M", paste(round((p[, 1] - b$xmin) * s + 20, 1), round((b$ymax - p[, 2]) * s + 20, 1), collapse = " L ")), "")
f <- round(h / 14)
svg <- c(sprintf('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 %d" fill="none" stroke="#111" stroke-linecap="round" stroke-linejoin="round">', h + f + 50), sprintf('<path d="%s" stroke-width="%d"/>', d, thick), sprintf('<text x="20" y="%d" font-size="%d" fill="#111" stroke="none">%s</text>', h + f + 30, f, tolower(river)), "</svg>")
writeLines(svg, sprintf("assets/maps/%s.svg", gsub(" ", "-", tolower(river))))
