#' Visualize Species Distribution Across All BBS Sites
#'
#' This function visualizes the sites surveyed for breeding birds in Taiwan,
#' highlighting the presence and absence of specific species. It is designed
#' upon the function [bbs_fetch].
#'
#' @param target_species Character string specifying the scientific name of
#' the species of interest. It can accept a single character string, such as
#' `target_species = "Hypsipetes leucocephalus"`, or a vector, such as
#' `target_species = c("Hypsipetes leucocephalus", "Heterophasia auricularis")`.
#' Leave undefined or use `NULL` to return no species. Use the [bbs_translate]
#' function to help find the species' scientific names.
#'
#' @return A `ggplot` object showing the distribution map.
#' @export
#'
#' @examples
#' bbs_plotmap(target_species = c("Pycnonotus taivanus", "Pycnonotus sinensis"))
bbs_plotmap <- function(target_species) {

  # prepare taiwan map and elevation ----------------------------------------
  tw_elev_terra <- tw_elev |>
    terra::rast(crs = "epsg:4326", type = "xyz") |>
    terra::classify(c(0, 100, 1000, 2500, Inf), include.lowest = FALSE, brackets = TRUE)

  tw_map_sf <- tw_map


  # different plots based on argument value ---------------------------------
  if (checkmate::test_null(target_species)) {

    # data preparation ------------------------------------------------------
    bird_site <- bbs_sites() |>
      dplyr::distinct(site, .keep_all = TRUE) |>
      terra::vect(geom = c("decimalLongitude", "decimalLatitude"), crs = "epsg:4326")

    # create map ------------------------------------------------------------
    distribution_map <- ggplot2::ggplot() +

      # basemap and elevation
      tidyterra::geom_spatraster(data = tw_elev_terra, alpha = 0.6) +
      tidyterra::geom_spatvector(data = tw_map_sf, fill = NA, colour = "gray65") +
      ggplot2::scale_fill_manual(values = c("white", "gray90", "gray78", "gray65"), na.value = NA) +

      # sites with and without detection
      tidyterra::geom_spatvector(data = bird_site,
                                 colour = "lightblue4",
                                 alpha = 1,
                                 size = 1.8,
                                 shape = 16) +

      # plot fine tunes
      ggplot2::theme_bw() +
      ggplot2::guides(fill = ggplot2::guide_none(),
                      colour = ggplot2::guide_legend(title = NULL,
                                                     override.aes = list(size = 3))) +
      ggplot2::theme(legend.position = "top",
                     legend.text = ggplot2::element_text(size = 10),
                     plot.title = ggplot2::element_text(hjust = 0.5)) +
      ggplot2::ggtitle(paste("Taiwan BBS All Sites"))

  } else if (checkmate::test_null(bbs_translate(target_species))) {
    distribution_map <- NULL

  } else {
    checkmate::assert_character(
      target_species,
      min.len = 1,
      max.len = 10
    )

    # data preparation ------------------------------------------------------
    data <- target_species |>
      bbs_fetch()

    # sites with and without target species
    bird_site <- data |>
      dplyr::slice_max(individualCount, by = c(site, scientificName), with_ties = FALSE) |>
      dplyr::mutate(type = dplyr::if_else(individualCount == 0, "absence", "presence")) |>
      dplyr::group_by(type) |>
      dplyr::group_map(~ terra::vect(.x, geom = c("decimalLongitude", "decimalLatitude"), crs = "epsg:4326"))

    # create map ------------------------------------------------------------
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
  }

  return(distribution_map)
}
