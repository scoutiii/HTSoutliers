
#' Title
#'
#' @param data full data frame with at least SNWD, OUTLIER_FINAL, ID, DATE, OUTLIER_PRED
#' @param id the id for the station you want to plot
#' @param ...
#'
#' @return plotly plot
#' @export
#'
#' @examples
plot_outliers <- function(data, id, ...) {
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
                                              "Predicted :", OUTLIER_PRED)
                          )
  plot <- plot %>% plotly::layout(title = paste(state, name, id, sep = " : "),
                                  font = list(size = 10))
  return(plot)
}
