#' Elevation raster of Taiwan
#'
#' A raster in dataframe xyz format, representing the elevation of Taiwan in
#' 1m by 1m grids. The data were reprojected to WGS84 (EPSG:4326).
#'
#' @format
#' A data frame with 38,575 rows and 3 columns:
#' \describe{
#'   \item{x}{scientific name}
#'   \item{y}{all possible Chinese that were used for the species}
#'   \item{G1km_TWD97-121_DTM_ELE}{english name from Taiwan Wild Bird Federation}
#'   ...
#' }
#' @source <https://github.com/WanJyunChen/Taiwan_environmental_dataset>
"tw_elev"
