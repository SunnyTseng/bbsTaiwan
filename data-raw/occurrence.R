occurrence <- readr::read_tsv(here::here("data-raw", "dwca-bbstaiwan_dataset-v1.9", "occurrence.txt"), lazy = TRUE)

usethis::use_data(occurrence, overwrite = TRUE)
