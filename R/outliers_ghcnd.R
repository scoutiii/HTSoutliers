#'
#' A data set which is formated for use in the create_flagged_Dataset function
#'
#' It is a modified version of snowload2::outliers_combined
#'
#'
#' @format A data frame with 671352 rows and 9 variables:
#' \describe{
#'   \item{ID}{The weather station ID}
#'   \item{DATE}{Date of the flagged outlier}
#'   \item{ELEMENT}{The element type of the outlier, i.e. SNWD or WESD}
#'   \item{VALUE}{The value in mm (WESD will be in 10ths of mm, divide by 10 to get mm)}
#'   \item{OUTLIER}{Always 1 indicating it is an outlier}
#'   \item{TYPE}{MANUAL if I manually verified it to be an outlier, QFLAG if the GHCN_D qflag was not empty (indicating it is an invalid observation)}
#' }
#' @source snowload2::outliers_combined modified by Brennan Bean to add the name
"outliers_ghcnd"
