extendedmeasurementorfact <- readr::read_tsv(here::here("data-raw", "dwca-bbstaiwan_dataset-v1.9", "extendedmeasurementorfact.txt"), lazy = TRUE)

usethis::use_data(extendedmeasurementorfact, overwrite = TRUE)
