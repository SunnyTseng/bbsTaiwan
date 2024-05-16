#' Visualization of BBS Taiwan detection sites
#'
#' Visualizes sites surveyed for breeding birds in Taiwan, highlighting presence and absence of specific species.
#'
#' @param data a list object derived from the bbs_fetch() function
#'
#' @return a distribution map
#' @export
#'
#' @examples
#' bbs_plotmap(data =
#' bbs_fetch(target_species =
#' c("Psilopogon nuchalis", "Pycnonotus taivanus")))
bbs_plotmap <- function(data) {

  ## transform the data into spatial info
  all_site <- data$site_info |>
    terra::vect(geom=c("decimalLongitude", "decimalLatitude"), crs = "epsg:4326")

  bird_site <- data$occurrence |>
    dplyr::select(site, scientificName, decimalLatitude, decimalLongitude) |>
    dplyr::distinct(.keep_all = TRUE) |>
    tidyr::drop_na() |>
    terra::vect(geom=c("decimalLongitude", "decimalLatitude"), crs = "epsg:4326")

  ## prepare the elevation for plotting

  tw_elev_terra <- tw_elev |>
    terra::rast(crs = "epsg:4326", type = "xyz") |>
    terra::crop(y = terra::ext(119.1, 122.1, 21.75, 25.35)) |>
    terra::classify(c(0, 100, 1000, 2500, Inf), include.lowest = FALSE, brackets = TRUE)


  tw_map_sf <- tw_map

  ## create map
  distribution_map <- ggplot2::ggplot() +

    # basemap and elevation
    tidyterra::geom_spatraster(data = tw_elev_terra) +
    tidyterra::geom_spatvector(data = tw_map_sf, fill = NA, colour = "gray65") +
    ggplot2::scale_fill_manual(values = c("white", "gray90", "gray78", "gray65"), na.value = NA) +

    # sites with and without detection
    tidyterra::geom_spatvector(data = all_site,
                               colour = "lightblue4",
                               alpha = 0.1) +
    tidyterra::geom_spatvector(data = bird_site,
                               ggplot2::aes(colour = scientificName),
                               alpha = 0.5) +
    ggplot2::scale_colour_brewer(palette = "Set2") +

    # plot fine tunes
    ggplot2::theme_bw() +
    ggplot2::guides(fill = ggplot2::guide_none(),
                    colour = ggplot2::guide_legend(title = NULL,
                                                   override.aes = list(size = 3))) +
    ggplot2::theme(legend.position = "top",
                   legend.text = ggplot2::element_text(size = 10)) +
    ggplot2::ggtitle(paste("BBS Taiwan detection sites between",
                           data$occurrence$year |> min(),
                           "to",
                           data$occurrence$year |> max(),
                           sep = " "))
  distribution_map

  return(distribution_map)
}
