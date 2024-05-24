#
#
#
#
# site_info <- event |>
#   dplyr::mutate(site = stringr::str_split_i(id, pattern = "_", i = 3)) |>
#   dplyr::mutate(plot = stringr::str_split_i(id, pattern = "_", i = 4)) |>
#   dplyr::select(site, plot, locationID, locality, decimalLatitude, decimalLongitude) |>
#   tidyr::drop_na() |>
#   dplyr::distinct(site, plot, locationID, .keep_all = TRUE)
#
# site_zone <- site_info |>
#   terra::vect(geom=c("decimalLongitude", "decimalLatitude"), crs = "epsg:4326") |>
#   terra::extract(x = tw_elev |> terra::rast(crs = "epsg:4326", type = "xyz"), bind = TRUE) |>
#   terra::intersect(x = tw_region |> terra::vect()) |>
#   dplyr::as_tibble() |>
#   dplyr::rename(elev = `G1km_TWD97-121_DTM_ELE`) |>
#   dplyr::select(locationID, elev, region) |>
#   dplyr::mutate(zone = dplyr::if_else(elev >= 1000, "Mountain", region))
#
# # data wrangling to see the site and plot that were surveyed in each year
#
# site_plot <- event |>
#   dplyr::mutate(site = stringr::str_split_i(id, pattern = "_", i = 3),
#                 plot = stringr::str_split_i(id, pattern = "_", i = 4),
#                 year = stringr::str_split_i(id, pattern = "_", i = 2) |> as.numeric()) |>
#   tidyr::drop_na(site, plot, year) |>
#   dplyr::left_join(site_zone, dplyr::join_by(locationID == locationID)) |>
#   dplyr::select(year, site, plot, locationID, zone)
#
# # calculate the sites in each year
#
# year_site <- site_plot %>%
#   split(.$year) %>%
#   purrr::map_df(\(df) df |>
#                   dplyr::group_by(zone) |>
#                   dplyr::summarize(n_sites = n_distinct(site)), .id = "id")
#
# # visualization and the output table
# year_site_vis <- ggplot2::ggplot(data = year_site,
#                                  aes(x = id, y = n_sites, fill = zone)) +
#   ggplot2::geom_bar(position = "stack", stat = "identity") +
#   ggplot2::scale_fill_brewer(palette = "Set2") +
#   ggplot2::labs(title = "Taiwan BBS surveyed sites",
#                 x = "Year",
#                 y = "# of sites",
#                 fill = "Region") +
#   # plot fine tunes
#   ggplot2::theme_bw() +
#   ggplot2::guides(fill = ggplot2::guide_legend(title = NULL,
#                                                override.aes = list(size = 3))) +
#   ggplot2::theme(legend.position = "top",
#                  legend.text = ggplot2::element_text(size = 10),
#                  plot.title = ggplot2::element_text(hjust = 0.5))
#
# year_site_table <- year_site %>%
#   tidyr::pivot_wider(names_from = zone,
#                      values_from = n_sites,
#                      values_fill = 0)
#
#
#
#
#
