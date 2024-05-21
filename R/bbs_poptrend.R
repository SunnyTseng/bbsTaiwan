#' Calculate the population trend based on BBS data
#'
#' @return some info here
#' @export
#'
#' @examples
bbs_poptrend <- function() {

  bird_data <- bbs_fetch(bbs_translate("金背鳩"))

  ## Fit a smooth trend with fixed site effects, random time effects,
  ## and automatic selection of degrees of freedom
  test_model <- ptrend(formula = individualCount ~ trend(year, tempRE = TRUE, type = "smooth", k = 7) +
                         locationID,
                       data = bird_data$occurrence)

  #checkFit(test_model)

  plot(test_model,
       plotGrid = FALSE)

  change(test_model, min(bird_data$occurrence$year, na.rm = TRUE), max(bird_data$occurrence$year, na.rm = TRUE))

  return(test_model)
  }
