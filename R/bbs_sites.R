#' All BBS site's coordinate
#'
#' @return a tibble including the coordinates of all the BBS survey sites
#' @export
#'
#' @examples
#' bbs_sites()
bbs_sites <- function() {

  year_location_trip <- event |>
    dplyr::mutate(site = stringr::str_split_i(id, pattern = "_", i = 3),
                  plot = stringr::str_split_i(id, pattern = "_", i = 4)) |>
    dplyr::select(site, plot, locationID, decimalLatitude, decimalLongitude) |>
    tidyr::drop_na() |>
    dplyr::distinct(locationID, .keep_all = TRUE)

  return(year_location_trip)
}
