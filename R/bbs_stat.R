#' Basic stats of BBS Taiwan occurrence data
#'
#' Summarizing basic statistics for BBS data, highlighting the trend of specific species.
#'
#' @param data a list object derived from the bbs_fetch() function
#'
#' @return a tibble containing basic stats for fetched data
#' @export
#'
#' @examples
#' bbs_stat(data =
#' bbs_fetch(target_species =
#' c("Psilopogon nuchalis", "Pycnonotus taivanus")))
#'
bbs_stat <- function(data) {

  # calculate sites in each region ------------------------------------------
  sites_zone <- data$site_info |>
    dplyr::distinct(site, .keep_all = TRUE) |>
    dplyr::pull(zone) |>
    base::table()

  # calculate statistics ----------------------------------------------------
  statistics <- data$occurrence |>
    dplyr::filter(individualCount != 0) |>
    dplyr::left_join(data$site_info, by = dplyr::join_by(locationID == locationID)) |>
    dplyr::group_by(vernacularName, scientificName, zone) |>
    dplyr::summarise(site_n = dplyr::n_distinct(site)) |>
    tidyr::drop_na(zone) |>
    tidyr::pivot_wider(names_from = zone, values_from = site_n, values_fill = 0) |>
    dplyr::mutate(Total = (sum(East, Mountain, West, North)/sum(sites_zone)) |> round(2),
                  North = (North/sites_zone["North"]) |> round(2),
                  West = (West/sites_zone["West"]) |> round(2),
                  East = (East/sites_zone["East"]) |> round(2),
                  Mountain = (Mountain/sites_zone["Mountain"]) |> round(2))

  return(statistics)
}
