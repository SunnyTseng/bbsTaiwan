#' Return the Coordinates of All BBS Sites
#'
#' This function returns the coordinates of all BBS sites that were surveyed.
#' No arguments are needed. The coordinates are reported using the WGS84
#' projection system.
#' Use `terra::vect(geom = c("decimalLatitude", "decimalLongitude"), crs = "epsg:4326")`
#' to transform the table to spatial object.
#'
#' The source data comes from the event table in the GBIF dataset.
#'
#' @return A tibble including the coordinates of all BBS survey sites, in WGS84.
#' @export
#'
#' @examples
#' # Get the full list of BBS sites in a tibble
#' bbs_sites()
#'
#' # Transform BBS sites into a spatial object using terra package
#' bbs_sites() |>
#' terra::vect(geom = c("decimalLatitude", "decimalLongitude"), crs = "epsg:4326")
bbs_sites <- function() {

  year_location_trip <- event |>
    dplyr::mutate(site = stringr::str_split_i(id, pattern = "_", i = 3),
                  plot = stringr::str_split_i(id, pattern = "_", i = 4)) |>
    tidyr::drop_na(site, plot, locationID, decimalLatitude, decimalLongitude) |>
    dplyr::distinct(locationID, .keep_all = TRUE) |>
    dplyr::select(site, plot, locationID, locality, decimalLatitude, decimalLongitude)

  return(year_location_trip)
}
