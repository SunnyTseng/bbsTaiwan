#' Find species' scientific name
#'
#' @param target_species a single character or a vector of characters including species' name in Chinese
#'
#' @return a vector of bird species' scientific name
#' @export
#'
#' @examples
#' # For single species
#' bbs_translate("白頭翁")
#'
#' # For multiple species
#' bbs_translate(c("烏頭翁", "白頭翁"))
bbs_translate <- function(target_species) {

  # sub function ----------------------------------------------------------
  decision <- function(target_species) {
    if(!target_species %in% (bird_info$chineseName |> unlist())) {
      return("The bird is not in the BBS list")
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
    purrr::map_chr(decision)

  return(bird_name)
}
