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


  # argument check ----------------------------------------------------------
  checkmate::assert_data_frame(
    data$occurrence,
    min.rows = 1,
    null.ok = FALSE
  )

  checkmate::assert_list(
    data,
    len = 2,
    unique = FALSE,
    null.ok = FALSE
  )

  # calculate sites in each region ------------------------------------------
  sites_zone <- data$site_info |>
    dplyr::distinct(site, .keep_all = TRUE) |>
    dplyr::pull(zone) |>
    base::table()

  # calculate statistics ----------------------------------------------------
  all_zones <- dplyr::tibble(zone = c("North", "West", "East", "Mountain"))

  statistics <- data$occurrence |>
    dplyr::filter(individualCount != 0) |>
    dplyr::left_join(data$site_info, by = dplyr::join_by(locationID == locationID)) |>
    # wrangling to get the # of sites each zone
    dplyr::group_by(vernacularName, scientificName, zone) |>
    dplyr::summarise(site_n = dplyr::n_distinct(site)) |>
    tidyr::drop_na(zone) |>
    # fill in the zone that the species has zero detection
    dplyr::right_join(all_zones, by = dplyr::join_by(zone == zone)) |>
    tidyr::pivot_wider(names_from = zone, values_from = site_n, values_fill = 0) |>
    tidyr::drop_na() |>
    # divide the total number of sites
    dplyr::mutate(Total = (sum(East, Mountain, West, North)/sum(sites_zone)) |> round(2),
                  North = (North/sites_zone["North"]) |> round(2),
                  West = (West/sites_zone["West"]) |> round(2),
                  East = (East/sites_zone["East"]) |> round(2),
                  Mountain = (Mountain/sites_zone["Mountain"]) |> round(2))

  return(statistics)
}
