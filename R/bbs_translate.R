#' Translate Bird Species' Chinese Common Name to Scientific Name
#'
#' This function is intended for use with the [bbs_fetch] function, which
#' requires the `target_species` argument to be in scientific names. This function
#' helps users find the scientific names of birds from their Chinese common names
#' for species found in Taiwan.
#'
#' @param target_species A single character string or a vector of character strings
#' representing species' names in Chinese.
#'
#' @return A vector of bird species' scientific names. If the input species name is not
#' included in the bird list of Taiwan, `"The bird is not in the BBS list"` will be returned.
#' Please check for any typos.
#'
#' @export
#'
#' @examples
#' # For a single species
#' bbs_translate("白頭翁")
#'
#' # For multiple species
#' bbs_translate(target_species = c("烏頭翁", "白頭翁"))
bbs_translate <- function(target_species) {

  # sub function ----------------------------------------------------------
  decision <- function(target_species) {
    if(!target_species %in% (bird_info$chineseName |> unlist())) {
      cli::cli_alert_warning("The bird is not in the BBS species list")
      cli::cli_alert_warning("查無鳥名")
      return(NA)
    }

    bird_name <- bird_info |>
      dplyr::mutate(in_out = purrr::map_lgl(.x = chineseName, .f =~ target_species %in% .x)) |>
      dplyr::filter(in_out) |>
      dplyr::pull(scientificName)
    return(bird_name)
  }


  # argument check --------------------------------------------------------
  checkmate::assert_character(
    target_species,
    min.len = 1,
    unique = TRUE
  )


  # main function body ----------------------------------------------------
  bird_name <- target_species |>
    purrr::map(decision) |>
    base::unlist() |>
    (\(x) if (anyNA(x)) NULL else x)()

  return(bird_name)
}
