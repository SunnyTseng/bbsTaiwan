## code to prepare `bird_info` dataset goes here

# BBS species list form Jerome Ko

bird_full_list <- readr::read_csv(here::here("data-raw", "taiwan_species_list_2023.csv")) |>
  dplyr::rename(chinese_name_t = "中文名", english_name_t = "英文名", scientific_name_t = "學名")

bird_info <- readr::read_csv(here::here("data-raw", "bbs_species_list_v0.csv")) |>
  dplyr::mutate(vernacularName_2023 = vernacularName) |>
  dplyr::mutate(vernacularName_2023 = stringr::str_replace_all(vernacularName_2023,
                                                               c("台" = "臺",
                                                                 "臺灣/大陸畫眉" = "臺灣畫眉",
                                                                 "白氏/虎斑地鶇" = "虎鶇",
                                                                 "小虎鶇" = "虎斑地鶇",
                                                                 "銹胸藍姬鶲" = "鏽胸藍姬鶲"))) |>
  dplyr::left_join(bird_full_list, by = dplyr::join_by(vernacularName_2023 == chinese_name_t)) |>
  dplyr::group_nest(scientificName) |>
  dplyr::mutate(chineseName = purrr::map(.x = data, .f =~ c(.x |> dplyr::pull(species_ori),
                                                            .x |> dplyr::pull(vernacularName),
                                                            .x |> dplyr::pull(vernacularName_2023)) |>
                                           unique() |>
                                           stats::na.omit())) |>
  dplyr::mutate(englishName = purrr::map_chr(.x = data, .f =~ .x |>
                                               dplyr::pull(english_name_t) |>
                                               unique())) |>
  dplyr::mutate(scientificName_t = purrr::map_chr(.x = data, .f =~ .x |>
                                                    dplyr::pull(scientific_name_t) |>
                                                    unique())) |>
  dplyr::select(scientificName, chineseName, englishName, scientificName_t)


usethis::use_data(bird_info, overwrite = TRUE)
