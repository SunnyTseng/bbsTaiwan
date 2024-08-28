#' Examine the Number of BBS Sites Surveyed Each Year
#'
#' This function returns the number of sites surveyed each year in the BBS
#' Taiwan project. Sites were mapped into five regions: East, West, South,
#' North, and Mountain (elevation higher than 1,000 m).
#'
#' @param type Character string specifying the output format: either `"table"`
#' or `"plot"`. Default value `type = "plot"`
#'
#' @return A `tibble` or a `ggplot` showing the number of sites surveyed each
#' year across regions.
#' @export
#'
#' @examples
#' # Return the number of sites in a table
#' bbs_history(type = "table")
#'
#' # Return the number of sites in a bar chart
#' bbs_history(type = "plot")
bbs_history <- function(type = "plot") {

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
    dplyr::rename(elev = 7) |>
    dplyr::select(year, trip, locationID, elev, region) |>
    dplyr::mutate(zone = dplyr::if_else(elev >= 1000, "Mountain", region))

  time_location <- year_location_trip |>
    dplyr::left_join(year_location_trip_zone, dplyr::join_by(year == year,
                                                             trip == trip,
                                                             locationID == locationID))

  #! There are 22 site, 105 plots (399 observations) can't be mapped into zones. Check the shape file or the coordinates.
  #! site_info[!site_info$locationID %in% site_zone$locationID, ] %>% distinct(locality, .keep_all = TRUE)

  # try to fix the issue that one site with multiple zone matched
  site_zone_standard <- time_location |>
    dplyr::count(site, zone) |>
    dplyr::slice_max(n, by = site)

  time_location_1 <- time_location |>
    dplyr::left_join(site_zone_standard,
                     dplyr::join_by(site == site),
                     multiple = "last",
                     suffix = c("_raw", "")) |>
    dplyr::select(year, trip, site, plot, locationID, zone)


  # information for sites each year -----------------------------------------

  year_site <- time_location_1 |>
    split(time_location$year) |>
    purrr::map_df(\(df) df |>
                    dplyr::group_by(zone) |>
                    dplyr::summarize(n_sites = dplyr::n_distinct(site)), .id = "year") |>
    dplyr::mutate(zone = tidyr::replace_na(zone, "Others"))

  year_site_vis <- year_site |>
    dplyr::mutate(zone = factor(zone, levels = c("Others", "North", "West", "East", "Mountain"))) |>
    ggplot2::ggplot(ggplot2::aes(x = year, y = n_sites, fill = zone, label = n_sites)) +
    ggplot2::geom_bar(position = "stack", stat = "identity") +
    ggplot2::geom_text(size = 3, position = ggplot2::position_stack(vjust = 0.5)) +
    ggplot2::scale_fill_brewer(palette = "Set2") +
    ggplot2::labs(x = "Year",
                  y = "# of sites",
                  fill = "Region") +
    ggplot2::theme_bw() +
    ggplot2::guides(fill = ggplot2::guide_legend(title = NULL,
                                                 override.aes = list(size = 3))) +
    ggplot2::theme(legend.position = "top",
                   legend.text = ggplot2::element_text(size = 10),
                   plot.title = ggplot2::element_text(hjust = 0.5))

  year_site_table <- year_site |>
    tidyr::pivot_wider(names_from = zone,
                       values_from = n_sites,
                       values_fill = 0)

  if (type == "plot"){
    return(year_site_vis)
  } else {
    return(year_site_table)
  }
}
