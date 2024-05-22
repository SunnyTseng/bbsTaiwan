#' Fetch BBS Taiwan data from GBIF
#'
#' Filter and clean BBS Taiwan data given certain year range and target species
#'
#' @param y_min a numeric value indicating the start year of the year range, by default 2009, the start year of Taiwan BBS data
#' @param y_max a numeric value indicating the end year of the year range, by default 2029. Note that GBIF only updates BBS data until 2016
#' @param target_species  a character vector for species of interest, return all species if NULL
#'
#' @return a list containing 1. species occurrence and 2. site information
#' @export
#'
#' @examples
#' bbs_fetch(y_min = 2009, y_max = 2016,
#' target_species = c("Pycnonotus taivanus", "Pycnonotus sinensis"))
bbs_fetch <- function(target_species = NULL, y_min = 2009, y_max = 2029) {

  # argument check ----------------------------------------------------------

  checkmate::assert_number(
    y_min,
    na.ok = FALSE,
    lower = 2009,
    upper = 2029
  )

  checkmate::assert_number(
    y_max,
    na.ok = FALSE,
    lower = 2009,
    upper = 2029
  )

  if (is.null(target_species)) {
    target_species <- bird_info |> dplyr::pull(scientificName)
  } else {
    checkmate::assert_character(
      target_species,
      min.len = 1
    )
  }

  # clean data --------------------------------------------------------------

  ## I guess there was a mixed up with both sheets. These codes needs to be updated once new data is up on GBIF
  event_info <- measurementorfacts |>
    dplyr::mutate(type = stringr::str_length(id)) |> # two lines to retain only event related measurement, like weather
    dplyr::filter(type == 23) |>
    dplyr::select(id, measurementType, measurementValue) |>
    dplyr::distinct(id, measurementType, .keep_all = TRUE) |>
    tidyr::pivot_wider(names_from = measurementType,
                       values_from = measurementValue) |>
    dplyr::rename(weather = "天氣代號", wind = "風速代號", habitat = "棲地代號")

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
    dplyr::select(site, plot, locationID, locality, decimalLatitude, decimalLongitude,
                  eventDate, eventTime) |>
    tidyr::drop_na() |>
    dplyr::distinct(site, plot, locationID, .keep_all = TRUE)

  site_zone <- site_info |>
    terra::vect(geom=c("decimalLongitude", "decimalLatitude"), crs = "epsg:4326") |>
    terra::extract(x = tw_elev |> terra::rast(crs = "epsg:4326", type = "xyz"), bind = TRUE) |>
    terra::intersect(x = tw_region |> terra::vect() |> terra::buffer(1500)) |>
    dplyr::as_tibble() |>
    dplyr::rename(elev = `G1km_TWD97-121_DTM_ELE`) |>
    dplyr::select(locationID, elev, region) |>
    dplyr::mutate(zone = dplyr::if_else(elev >= 1000, "Mountain", region))


  # filter occurrence to a given species and year ---------------------------

  occurrence_filter <- occurrence |>
    dplyr::mutate(year = stringr::str_split_i(id, pattern = "_", i = 2) |> as.numeric()) |>
    dplyr::filter(year %in% seq(y_min, y_max)) |>
    dplyr::filter(scientificName %in% target_species) |>
    dplyr::mutate(locationID =
                    paste0(stringr::str_split_i(id, pattern = "_", i = 3)
                           ,"_",
                           stringr::str_split_i(id, pattern = "_", i = 4)))


  # link event info, occurrence info, bird info, and site info --------------

  occurrence_add_var <- occurrence_filter |>
    dplyr::left_join(event_info, by = dplyr::join_by(id == id)) |>
    dplyr::left_join(occurrence_info, by = dplyr::join_by(occurrenceID == id)) |>
    dplyr::left_join(site_info, by = dplyr::join_by(locationID == locationID)) |>
    dplyr::left_join(site_zone, by = dplyr::join_by(locationID == locationID)) |>
    dplyr::select(year, eventID, occurrenceID, scientificName, vernacularName, individualCount,
                  eventDate, eventTime, weather, wind, habitat, time_slot, distance, flock,
                  site, plot, locationID, locality, decimalLatitude, decimalLongitude,
                  elev, region, zone)

  site_add_var <- site_info |>
    dplyr::left_join(site_zone) |>
    dplyr::select(site, plot, locationID, locality, decimalLatitude, decimalLongitude, elev, region, zone)


  return(list(occurrence = occurrence_add_var,
              site_info = site_add_var))
}
