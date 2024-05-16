### a function to visualize the statistics of the fetched data

bbs_stat <- function(data) {
  test <- data$occurrence

  test_1 <- test %>%
    group_by(vernacularName, scientificName) %>%
    summarise(n_site = n_distinct(site))


}
