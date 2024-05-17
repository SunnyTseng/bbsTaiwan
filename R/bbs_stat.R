#' Basic stats of BBS Taiwan occurrence data
#'
#' Summarizing basic statistics for BBS data, highlighting the trend of specific species.
#'
#' @param data a list object derived from the bbs_fetch() function
#'
#' @return a tibble containing basic stats
#' @export
#'
#' @examples
#' bbs_stat(data =
#' bbs_fetch(target_species =
#' c("Psilopogon nuchalis", "Pycnonotus taivanus")))
#'
bbs_stat <- function(data) {

  statistics <- data$occurrence |>
    dplyr::group_by(vernacularName, scientificName) |>
    dplyr::summarise(n_site = dplyr::n_distinct(site),
              total_count = base::sum(individualCount),
              mean_elev = base::mean(elev, na.rm = TRUE)) |>
    dplyr::ungroup()

  return(statistics)
}
