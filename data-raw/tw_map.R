## code to prepare `tw_map` dataset goes here

# From: https://geodata.mit.edu/catalog/stanford-dz142zj5454
# CRS: lon/lat WGS 84 (EPSG:4326)

tw_map <- sf::st_read(here::here("data-raw", "taiwan")) |>
  sf::st_crop(c(xmin = 119.1, xmax = 122.1,
                ymin = 21.75, ymax = 25.35))

usethis::use_data(tw_map, overwrite = TRUE)
