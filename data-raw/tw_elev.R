## code to prepare `tw_elev` dataset goes here

# From: https://github.com/WanJyunChen/Taiwan_environmental_dataset

tw_elev <- raster::raster(here::here("data-raw", "G1km_TWD97-121_DTM_ELE.tif")) |>
  raster::projectRaster(crs = "epsg:4326") |>
  raster::crop(c(xmin = 119.1, xmax = 122.1,
                 ymin = 21.75, ymax = 25.35))


usethis::use_data(tw_elev, overwrite = TRUE)
