tw_region <- sf::st_read(here::here("data-raw", "tw_region"), ) |>
  sf::st_transform(crs = "epsg:4326") |>
  dplyr::select(ZONE41)

usethis::use_data(tw_region, overwrite = TRUE)
