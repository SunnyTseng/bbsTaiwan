#' Fetch BBS Occurrence Data by Species
#'
#' This function fetches occurrence data for specified target species,
#' utilizing both the event and occurrence tables from GBIF. The fetched dataset
#' undergoes the following processing steps:
#' 1. **Join**: Combines the [event], [occurrence], and [measurementorfacts] datasheets
#' from GBIF into a single cohesive dataset.
#' 2. **Filter**: Retains only the observations for specified species using the
#' `target_species` argument. The entered Chinese common name was linked to
#' scientific name by [bbs_translate].
#' 3. **Zero Fill**: Converts implicit missing values into explicit ones by
#' filling in zeros for trips where the target species was not observed.
#' Specifically, if a plot was visited during a particular year or trip
#' but the target species was not observed, the species count will show a value of 0 for that row.
#'
#' @param target_species Character string specifying the Chinese common name of
#' the species of interest. It can accept a single character string, such as
#' `target_species = "紅嘴黑鵯"`, or a vector, such as
#' `target_species = c("紅嘴黑鵯", "白耳畫眉")`.Use `"全部"` to return all species.
#'
#' @return A `tibble` containing the species occurrence data.
#' @export
#'
#' @examples
#' # For single species data fetch
#' bbs_fetch(target_species = "紅嘴黑鵯")
#'
#' # For multiple species data fetch
#' bbs_fetch(target_species = c("紅嘴黑鵯", "白耳畫眉"))
#'
#' # To return data for all species
#' bbs_fetch(target_species = "全部")
#'
#' # The function will return NULL if the target species is not found in the
#' # BBS species list
#' bbs_fetch(target_species = "隨機鳥")
bbs_fetch <- function(target_species) {

  # argument check ----------------------------------------------------------
  if (checkmate::test_null(target_species)) {
    return(NULL)

  } else if (any(target_species %in% c("all", "All", "所有", "全部"))){
    target_species <- bird_info |> dplyr::pull(scientificName)

  } else if (checkmate::test_null(bbs_translate(target_species))){
    return(NULL)

  } else {
    checkmate::assert_character(
      target_species,
      min.len = 1)

    target_species <- target_species |> bbs_translate()
  }


  # clean data --------------------------------------------------------------

  # get event covariates associated with each point count event
  #! first two lines to retain only event related measurement, like weather
  event_info <- measurementorfacts |>
    dplyr::mutate(type = stringr::str_length(id)) |>
    dplyr::filter(type == 23) |>
    dplyr::select(id, measurementDeterminedDate, measurementType, measurementValue) |>
    dplyr::distinct(id, measurementType, .keep_all = TRUE) |>
    tidyr::pivot_wider(names_from = measurementType,
                       values_from = measurementValue) |>
    dplyr::mutate(year = measurementDeterminedDate |> stringr::str_split_i(pattern = "-", i = 1) |> as.numeric(),
                  month = measurementDeterminedDate |> stringr::str_split_i(pattern = "-", i = 2) |> as.numeric(),
                  day = measurementDeterminedDate |> stringr::str_split_i(pattern = "-", i = 3) |> as.numeric()) |>
    dplyr::rename(date = measurementDeterminedDate,
                  weather = 3,
                  wind = 4,
                  habitat = 5)

  # get occurrence covariates associated with each observation within a point count
  #! first two lines to retain occurrence related measurement
  occurrence_info <- extendedmeasurementorfact |>
    dplyr::mutate(type = stringr::str_length(id)) |>
    dplyr::filter(type == 30) |>
    dplyr::select(id, measurementType, measurementValue) |>
    dplyr::distinct(id, measurementType, .keep_all = TRUE) |>
    tidyr::pivot_wider(names_from = measurementType,
                       values_from = measurementValue) |>
    dplyr::rename(time_slot = 2, distance = 3, flock = 4)


  # site_info for adding coordinate
  site_info <- event |>
    dplyr::mutate(site = stringr::str_split_i(id, pattern = "_", i = 3)) |>
    tidyr::drop_na(site, locationID, decimalLatitude, decimalLongitude) |>
    dplyr::distinct(locationID, .keep_all = TRUE)


  # filter occurrence to a given species and year ---------------------------
  occurrence_filter <- occurrence |>
    dplyr::filter(scientificName %in% target_species) |>
    dplyr::mutate(locationID =
                    paste0(stringr::str_split_i(id, pattern = "_", i = 3)
                           ,"_",
                           stringr::str_split_i(id, pattern = "_", i = 4)))


  # zero control for all the point counts sites & species observation -------

  if (base::length(target_species) <= 40){

    occurrence_zero <- occurrence_filter |>
      # add zero for each point count and each target species
      dplyr::right_join(tidyr::expand_grid(id = event_info$id, scientificName = target_species),
                        by = dplyr::join_by(id == id, scientificName == scientificName)) |>
      dplyr::mutate(individualCount = dplyr::if_else(is.na(individualCount), 0, individualCount)) |>
      # remove sites that never detected the species
      # dplyr::mutate(site = stringr::str_split_i(id, pattern = "_", i = 3)) |>
      # dplyr::group_by(site, scientificName) |>
      # dplyr::filter(base::sum(individualCount) != 0) |>
      # dplyr::ungroup() |>
      # add necessary column to the zero rows for the join purpose
      dplyr::mutate(locationID = dplyr::if_else(is.na(locationID),
                                                base::paste0(stringr::str_split_i(id, pattern = "_", i = 3)
                                                             ,"_",
                                                             stringr::str_split_i(id, pattern = "_", i = 4)),
                                                locationID))
  } else {
    occurrence_zero <- occurrence_filter
  }




  # link event info, occurrence info, bird info, and site info --------------
  occurrence_add_var <- occurrence_zero |>
    dplyr::left_join(event_info, by = dplyr::join_by(id == id)) |>
    dplyr::left_join(occurrence_info, by = dplyr::join_by(occurrenceID == id)) |>
    dplyr::left_join(site_info, by = dplyr::join_by(locationID == locationID)) |>
    dplyr::select(year, month, day, site, locationID, decimalLatitude, decimalLongitude,
                  weather, wind, habitat,
                  scientificName, vernacularName, individualCount,
                  time_slot, distance, flock)

  return(occurrence_add_var)
}
