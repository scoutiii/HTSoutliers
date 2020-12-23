#' Plot outliers
#'
#' Once you have flagged outliers using any model (randomForest for example),
#' you can plot the outliers that have already been flagged vs the one you have flagged
#'
#' This will show known outliers as triangles, and points you predict
#' to be outliers as blue. So a blue triangle is a point you marked as an outlier
#' that we also found to be an outlier. A green triangle is a point we found to be
#' and outlier and you did not. A blue circle is a point you flagged as an outlier
#' that we did not. And a green circle is a point neither you nor we flagged.
#'
#' Note that you must have at least SNWD, OUTLIER_FINAL, ID, DATE, and OUTLIER_PRED
#' in order to use this function. You will need to manually create the
#' OUTLIER_PRED variable
#'
#' @param data full data frame with at least SNWD, OUTLIER_FINAL, ID, DATE, OUTLIER_PRED
#' @param id the id for the station you want to plot
#'
#' @return plotly plot
#' @export
#'
#' @examples
plot_outliers <- function(data, id) {
  data <- data %>% dplyr::filter(.data$ID == id)
  stations_info <- dplyr::filter(snowload2::ghcnd_stations, .data$ID == id)
  state <- usdata::abbr2state(stations_info$STATE)
  if(base::is.na(state)) {
    state <- stations_info$STATE
  }
  name <- stations_info$NAME

  data$size <- base::as.numeric(base::ifelse(data$OUTLIER_FINAL == "1" |
                                             data$OUTLIER_PRED == "1",
                                             3, 1))

  plot <- plotly::plot_ly(data, x=~DATE, y=~SNWD,
                          type = "scatter", mode = "markers",
                          symbol = ~OUTLIER_FINAL,
                          size = ~size,
                          color = ~OUTLIER_PRED,
                          text = ~base::paste("Actual :", OUTLIER_FINAL,
                                              "\nPredicted :", OUTLIER_PRED,
                                              "\nTYPE : ", TYPE)
                          )
  plot <- plot %>% plotly::layout(title = paste(state, name, id, sep = " : "),
                                  font = list(size = 10))
  return(plot)
}
