#' Visualize Species Distribution Across All BBS Sites
#'
#' This function visualizes the sites surveyed for breeding birds in Taiwan,
#' highlighting the presence and absence of specific species. It is designed
#' to be used with the \link{bbs_fetch} function as the input argument.
#'
#' @param data An occurrence dataset derived from the \link{bbs_fetch} function.
#'
#' @return A `ggplot` object showing the distribution map.
#' @export
#'
#' @examples
#' plot <- c("Psilopogon nuchalis", "Pycnonotus taivanus") |>
#'   bbs_fetch() |>
#'   bbs_plotmap()
bbs_plotmap <- function(data) {

  # argument check ----------------------------------------------------------
  checkmate::assert_data_frame(
    data,
    min.rows = 1,
    null.ok = FALSE
  )



  # sites with target species -----------------------------------------------
  bird_site <- data |>
    dplyr::slice_max(individualCount, by = c(site, scientificName), with_ties = FALSE) |>
    dplyr::mutate(type = dplyr::if_else(individualCount == 0, "absence", "presence")) |>
    dplyr::group_by(type) |>
    dplyr::group_map(~ terra::vect(.x, geom = c("decimalLongitude", "decimalLatitude"), crs = "epsg:4326"))



  # prepare taiwan map and elevation ----------------------------------------
  tw_elev_terra <- tw_elev |>
    terra::rast(crs = "epsg:4326", type = "xyz") |>
    terra::classify(c(0, 100, 1000, 2500, Inf), include.lowest = FALSE, brackets = TRUE)

  tw_map_sf <- tw_map


  # create map --------------------------------------------------------------
  distribution_map <- ggplot2::ggplot() +

    # basemap and elevation
    tidyterra::geom_spatraster(data = tw_elev_terra, alpha = 0.5) +
    tidyterra::geom_spatvector(data = tw_map_sf, fill = NA, colour = "gray65") +
    ggplot2::scale_fill_manual(values = c("white", "gray90", "gray78", "gray65"), na.value = NA) +

    # sites with and without detection
    tidyterra::geom_spatvector(data = bird_site[[1]] |> dplyr::filter(!site %in% bird_site[[2]]$site),
                               colour = "lightblue4",
                               alpha = 0.5,
                               size = 1.8,
                               shape = 1) +
    tidyterra::geom_spatvector(data = bird_site[[2]],
                               ggplot2::aes(colour = scientificName),
                               alpha = 0.5,
                               size = 1.8,
                               stroke = NA) +
    ggplot2::scale_colour_brewer(palette = "Set2") +

    # plot fine tunes
    ggplot2::theme_bw() +
    ggplot2::guides(fill = ggplot2::guide_none(),
                    colour = ggplot2::guide_legend(title = NULL,
                                                   override.aes = list(size = 3))) +
    ggplot2::theme(legend.position = "top",
                   legend.text = ggplot2::element_text(size = 10),
                   plot.title = ggplot2::element_text(hjust = 0.5)) +
    ggplot2::ggtitle(paste("Taiwan BBS from",
                           data$year |> min(na.rm = TRUE),
                           "to",
                           data$year |> max(na.rm = TRUE),
                           sep = " "))

  distribution_map

  return(distribution_map)
}
