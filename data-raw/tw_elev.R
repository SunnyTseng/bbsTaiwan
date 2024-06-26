tw_elev <- terra::rast(here::here("data-raw", "G1km_TWD97-121_DTM_ELE.tif")) |>
  terra::project(y = "epsg:4326") |>
  terra::crop(y = terra::ext(119.1, 122.1, 21.75, 25.35)) |>
  terra::as.data.frame(xy = TRUE)

usethis::use_data(tw_elev, overwrite = TRUE)
