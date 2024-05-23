#' Fetch BBS Taiwan data from GBIF
#'
#' Filter and clean BBS Taiwan data given certain year range and target species
#'
#' @param target_species  a character vector for species of interest, return all species if NULL
#'
#' @return a list containing 1. species occurrence and 2. site information
#' @export
#'
#' @examples
#' bbs_fetch(target_species = c("Pycnonotus taivanus", "Pycnonotus sinensis"))
bbs_fetch <- function(target_species = NULL) {

  # argument check ----------------------------------------------------------

  if (is.null(target_species)) {
    target_species <- bird_info |> dplyr::pull(scientificName)
  } else {
    checkmate::assert_character(
      target_species,
      min.len = 1
    )
  }

  # clean data --------------------------------------------------------------

  # get event covariates associated with each point count event
  event_info <- measurementorfacts |>
    dplyr::mutate(type = stringr::str_length(id)) |> # two lines to retain only event related measurement, like weather
    dplyr::filter(type == 23) |>
    dplyr::select(id, measurementDeterminedDate, measurementType, measurementValue) |>
    dplyr::distinct(id, measurementType, .keep_all = TRUE) |>
    tidyr::pivot_wider(names_from = measurementType,
                       values_from = measurementValue) |>
    dplyr::mutate(year = measurementDeterminedDate |> stringr::str_split_i(pattern = "-", i = 1) |> as.numeric(),
                  month = measurementDeterminedDate |> stringr::str_split_i(pattern = "-", i = 2) |> as.numeric(),
                  day = measurementDeterminedDate |> stringr::str_split_i(pattern = "-", i = 3) |> as.numeric()) |>
    dplyr::rename(date = measurementDeterminedDate,
                  weather = "天氣代號",
                  wind = "風速代號",
                  habitat = "棲地代號")

  # get occurrence covariates associated with each observation within a point count
  occurrence_info <- extendedmeasurementorfact |>
    dplyr::mutate(type = stringr::str_length(id)) |> # two lines to retain occurrence related measurement
    dplyr::filter(type == 30) |>
    dplyr::select(id, measurementType, measurementValue) |>
    dplyr::distinct(id, measurementType, .keep_all = TRUE) |>
    tidyr::pivot_wider(names_from = measurementType,
                       values_from = measurementValue) |>
    dplyr::rename(time_slot = "時段", distance = "距離", flock = "結群")

  site_info <- event |>
    dplyr::mutate(site = stringr::str_split_i(id, pattern = "_", i = 3)) |>
    dplyr::mutate(plot = stringr::str_split_i(id, pattern = "_", i = 4)) |>
    dplyr::select(site, plot, locationID, locality, decimalLatitude, decimalLongitude) |>
    tidyr::drop_na() |>
    dplyr::distinct(site, plot, locationID, .keep_all = TRUE)

  site_zone <- site_info |>
    terra::vect(geom=c("decimalLongitude", "decimalLatitude"), crs = "epsg:4326") |>
    terra::extract(x = tw_elev |> terra::rast(crs = "epsg:4326", type = "xyz"), bind = TRUE) |>
    terra::intersect(x = tw_region |> terra::vect()) |>
    dplyr::as_tibble() |>
    dplyr::rename(elev = `G1km_TWD97-121_DTM_ELE`) |>
    dplyr::select(locationID, elev, region) |>
    dplyr::mutate(zone = dplyr::if_else(elev >= 1000, "Mountain", region))


  # filter occurrence to a given species and year ---------------------------

  occurrence_filter <- occurrence |>
    dplyr::filter(scientificName %in% target_species) |>
    dplyr::mutate(locationID =
                    paste0(stringr::str_split_i(id, pattern = "_", i = 3)
                           ,"_",
                           stringr::str_split_i(id, pattern = "_", i = 4)))


  # zero control for all the point counts sites & species observation -------

  occurrence_zero <- occurrence_filter |>
    # add zero for each point count and each target species
    dplyr::right_join(tidyr::expand_grid(id = event_info$id, scientificName = target_species),
                      by = dplyr::join_by(id == id, scientificName == scientificName)) |>
    dplyr::mutate(individualCount = dplyr::if_else(is.na(individualCount), 0, individualCount)) |>
    # remove sites that never detected the species
    dplyr::mutate(site_1 = stringr::str_split_i(id, pattern = "_", i = 3)) |>
    dplyr::group_by(site_1, scientificName) |>
    dplyr::filter(base::sum(individualCount) != 0) |>
    dplyr::ungroup() |>
    # add necessary column to the zero rows for the join purpose
    dplyr::mutate(locationID = dplyr::if_else(is.na(locationID),
                                              base::paste0(stringr::str_split_i(id, pattern = "_", i = 3)
                                                           ,"_",
                                                           stringr::str_split_i(id, pattern = "_", i = 4)),
                                              locationID))

  # link event info, occurrence info, bird info, and site info --------------

  occurrence_add_var <- occurrence_zero |>
    dplyr::left_join(event_info, by = dplyr::join_by(id == id)) |>
    dplyr::left_join(occurrence_info, by = dplyr::join_by(occurrenceID == id)) |>
    dplyr::select(year, month, day, locationID, eventID, weather, wind, habitat,
                  occurrenceID, scientificName, vernacularName, individualCount,
                  time_slot, distance, flock)

  site_add_var <- site_info |>
    dplyr::left_join(site_zone) |>
    dplyr::select(site, plot, locationID, locality, decimalLatitude, decimalLongitude, elev, region, zone)


  return(list(occurrence = occurrence_add_var,
              site_info = site_add_var))
}
