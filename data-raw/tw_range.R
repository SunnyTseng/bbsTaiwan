tw_elev <- terra::rast(here::here("data-raw", "G1km_TWD97-121_DTM_ELE.tif")) |>
  terra::project(y = "epsg:4326") |>
  terra::as.data.frame(xy = TRUE)

usethis::use_data(tw_range, overwrite = TRUE)
