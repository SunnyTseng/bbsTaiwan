tw_region <- sf::st_read(here::here("data-raw", "tw_region")) |>
  sf::st_transform(crs = "epsg:4326") |>
  dplyr::mutate(region = c("West", "East", "North")) |>
  dplyr::select(region)

usethis::use_data(tw_region, overwrite = TRUE)
