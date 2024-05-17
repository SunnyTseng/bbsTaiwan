tw_map <- sf::st_read(here::here("data-raw", "taiwan")) |>
  sf::st_crop(c(xmin = 119.1, xmax = 122.1, ymin = 21.75, ymax = 25.35)) |>
  dplyr::select()

usethis::use_data(tw_map, overwrite = TRUE)
