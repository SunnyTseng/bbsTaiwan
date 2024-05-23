

test <- event |>
  dplyr::mutate(site = stringr::str_split_i(id, pattern = "_", i = 3),
                plot = stringr::str_split_i(id, pattern = "_", i = 4)) |>
  dplyr::select(site, plot, locationID, locality, decimalLatitude, decimalLongitude) |>
  tidyr::drop_na()


  dplyr::mutate(plot = stringr::str_split_i(id, pattern = "_", i = 4)) |>


|>
  dplyr::select(site, plot, locationID, locality, decimalLatitude, decimalLongitude) |>
  tidyr::drop_na() |>
  dplyr::distinct(site, plot, locationID, .keep_all = TRUE)
