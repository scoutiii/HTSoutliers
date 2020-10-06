#'
#' This rasterbrick has precipitation, min temp, and max temp for all 12 months.
#' Its primary use is in the create_model_variables() function
#'
#'
#'
#' @format A data frame with 36 layers, 12 for each month, with precipitation, min temp, and max temp,
#'         and a final variable with the stations IDs
#'
#' @source \url{https://prism.oregonstate.edu/normals/}
"PRISM_climate_norms"
