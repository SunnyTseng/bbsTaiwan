#' Calculate the population trend based on BBS data
#'
#' @param data a list object derived from the bbs_fetch() function
#' @param prop the proportion of observations to fit the population trend model.
#' The lower value can reduce the
#'
#' @return some info here
#' @export
#'
#' @examples
#' bbs_poptrend()
bbs_poptrend <- function(data = NULL, prop = 1) {


  # # adding weight info into the dataset -------------------------------------
  # data_weight <- data$occurrence |>
  #   dplyr::left_join(data$site_info, by = dplyr::join_by(locationID == locationID)) |>
  #   dplyr::group_by(year, zone) |>
  #   dplyr::mutate(zone_sites = dplyr::n_distinct(site)) |>
  #   dplyr::ungroup()


  # Fit a smooth trend with fixed site effects, random time effects,
  # and automatic selection of degrees of freedom

  trend_model <- data |>
    utils::head(1000) |>
    dplyr::slice_sample(prop = prop) |>
    poptrend::ptrend(formula = individualCount ~ trend(var = year,
                                                       tempRE = TRUE,
                                                       type = "smooth",
                                                       k = 8) + site)

  change <- poptrend::change(trend_model,
                             min(data$occurrence$year, na.rm = TRUE),
                             max(data$occurrence$year, na.rm = TRUE))

  trend_plot <- plot(trend_model,
                     plotGrid = FALSE,
                     main = paste0("Change = ",
                                   change$percentChange |> round(2), "% (",
                                   change$CI[1] |> round(2), "%, ",
                                   change$CI[2] |> round(2), "%",
                                   ")"),
                     xlab = "Year",
                     ylab = "Abundance index")

  return(NULL)
}
