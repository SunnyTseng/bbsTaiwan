measurementorfacts <- readr::read_tsv(here::here("data-raw", "dwca-bbstaiwan_dataset-v1.9", "measurementorfacts.txt"), lazy = TRUE)

usethis::use_data(measurementorfacts, overwrite = TRUE)
