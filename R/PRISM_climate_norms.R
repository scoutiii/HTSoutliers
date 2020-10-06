#'
#' This rasterbrick has precipitation, min temp, and max temp for all 12 months.
#' Its primary use is in the create_model_variables() function
#'
#' The first 12 layers are for precipitation, where 1st layer is january, 12th layer is decemeber,
#' The next 12 layers (13-24) are for minimum temperature
#' The final 12 layers (25-36) are for maximum temperature
#'
#' @format A raster brick with 36 layers, 12 for each month, with precipitation, min temp, and max temp
#'
#' @source \url{https://prism.oregonstate.edu/normals/}
"PRISM_climate_norms"
