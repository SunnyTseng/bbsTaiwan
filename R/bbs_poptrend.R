#' Calculate the population trend based on BBS data
#'
#' @return some info here
#' @export
#'
#' @examples
#' bbs_poptrend(data = bbs_fetch(bbs_translate("金背鳩")))
bbs_poptrend <- function(data, zone = NULL) {

  ## Fit a smooth trend with fixed site effects, random time effects,
  ## and automatic selection of degrees of freedom
  trend_model <- poptrend::ptrend(
    formula = individualCount ~ trend(var = year, tempRE = TRUE, type = "smooth", k = 7) + locationID,
    data = data$occurrence)

  #checkFit(trend_model)

  change <- poptrend::change(trend_model,
                             min(data$occurrence$year, na.rm = TRUE),
                             max(data$occurrence$year, na.rm = TRUE))

  trend_plot <- plot(trend_model,
                     plotGrid = FALSE,
                     main = paste0("Change = ",
                                   change$percentChange |> round(2), "% (",
                                   change$CI[1] |> round(2), "%, ",
                                   change$CI[2] |> round(2), "%",
                                   ")"))
  return(trend_plot)
}
