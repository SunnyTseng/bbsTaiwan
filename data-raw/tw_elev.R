## code to prepare `tw_elev` dataset goes here

# From: https://github.com/WanJyunChen/Taiwan_environmental_dataset

tw_elev <- raster::raster(here::here("data-raw", "G1km_TWD97-121_DTM_ELE.tif"))

usethis::use_data(tw_elev, overwrite = TRUE)
