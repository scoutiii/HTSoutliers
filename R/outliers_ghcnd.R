#'
#' A data set which is formated for use in the create_flagged_Dataset function
#'
#' It is a modified version of snowload2::outliers_combined
#'
#'
#' @format A data frame with 763323 rows and 8 variables:
#' \describe{
#'   \item{ID}{the weather station ID}
#'   \item{DATE}{date of the flagged outlier}
#'   \item{ELEMENT}{the element type of the outlier, i.e. SNWD or WESD}
#'   \item{VALUE}{the value in mm (WESD was converted from 10ths mm to mm)}
#'   \item{FLAGGED}{the method used to flag the outlier}
#'   \item{OUTLIER}{will always be 1 since this contains all outliers}
#'   \item{TYPE}{further describes how the observation was flagged}
#'   \item{YEAR}{the year of the outlier}
#' }
#' @source snowload2::outliers_combined
"outliers_ghcnd"
