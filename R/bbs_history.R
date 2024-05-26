#' Number of sites surveyed each year
#'
#' @return A table showing number of sites surveyed each year in regions
#' @export
#'
#' @examples
#' bbs_history()
bbs_history <- function() {

  # get time (year, trip) and space (site, plot) info from event table ------

  year_location_trip <- event |>
    dplyr::mutate(year = stringr::str_split_i(id, pattern = "_", i = 2),
                  trip = stringr::str_split_i(id, pattern = "_|:", i = 5),
                  site = stringr::str_split_i(id, pattern = "_", i = 3),
                  plot = stringr::str_split_i(id, pattern = "_", i = 4)) |>
    dplyr::select(year, trip, site, plot, locationID, decimalLatitude, decimalLongitude) |>
    tidyr::drop_na() |>
    dplyr::distinct(year, trip, locationID, .keep_all = TRUE)

  year_location_trip_zone <- year_location_trip |>
    terra::vect(geom=c("decimalLongitude", "decimalLatitude"), crs = "epsg:4326") |>
    terra::extract(x = tw_elev |> terra::rast(crs = "epsg:4326", type = "xyz"), bind = TRUE) |>
    terra::intersect(x = tw_region |> terra::vect()) |>
    dplyr::as_tibble() |>
    dplyr::rename(elev = `G1km_TWD97-121_DTM_ELE`) |>
    dplyr::select(year, trip, locationID, elev, region) |>
    dplyr::mutate(zone = dplyr::if_else(elev >= 1000, "Mountain", region))

  time_location <- year_location_trip |>
    dplyr::left_join(year_location_trip_zone, dplyr::join_by(year == year,
                                                             trip == trip,
                                                             locationID == locationID)) |>
    dplyr::select(year, trip, site, plot, locationID, zone)


  # information for sites each year -----------------------------------------

  year_site <- time_location %>%
    split(.$year) %>%
    purrr::map_df(\(df) df |>
                    dplyr::group_by(zone) |>
                    dplyr::summarize(n_sites = n_distinct(site)), .id = "year") |>
    dplyr::mutate(zone = tidyr::replace_na(zone, "Others"))

  year_site_vis <- year_site |>
    dplyr::mutate(zone = factor(zone, levels = c("Others", "North", "West", "East", "Mountain"))) |>
    ggplot2::ggplot(aes(x = year, y = n_sites, fill = zone, label = n_sites)) +
    ggplot2::geom_bar(position = "stack", stat = "identity") +
    ggplot2::geom_text(size = 3, position = position_stack(vjust = 0.5)) +
    ggplot2::scale_fill_brewer(palette = "Set2") +
    ggplot2::labs(title = "Taiwan BBS surveyed sites",
                  x = "Year",
                  y = "# of sites",
                  fill = "Region") +
    ggplot2::theme_bw() +
    ggplot2::guides(fill = ggplot2::guide_legend(title = NULL,
                                                 override.aes = list(size = 3))) +
    ggplot2::theme(legend.position = "top",
                   legend.text = ggplot2::element_text(size = 10),
                   plot.title = ggplot2::element_text(hjust = 0.5))

  year_site_table <- year_site %>%
    tidyr::pivot_wider(names_from = zone,
                       values_from = n_sites,
                       values_fill = 0)

  plot(year_site_vis)

  return(year_site_table)
}
