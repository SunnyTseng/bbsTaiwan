event <- readr::read_tsv(here::here("data-raw", "dwca-bbstaiwan_dataset-v1.10", "event.txt"),
                         col_types = cols(decimalLatitude = "d", decimalLongitude = "d"),
                         lazy = TRUE)

usethis::use_data(event, overwrite = TRUE)
