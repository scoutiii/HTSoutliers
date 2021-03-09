


loess_model <- function(data, ...) {

  # Makes sure that the data only has SNWD
  data <- data %>% dplyr::mutate(DOY_RAW = lubridate::yday(.data$DATE),
                                 DOY = base::ifelse(DOY_RAW >= 182,  # 182 is July 1st
                                                    DOY_RAW - 366,
                                                    DOY_RAW)) %>%
    dplyr::select(-.data$DOY_RAW)

  # Loops through all the stations
  stations <- base::unique(data$ID)
  results <- NULL;
  i <- 0;
  for (station in stations) {
    print(station)
    i <- i + 1
    print(i)

    new_data <- dplyr::filter(data, .data$ID == station)

    base::tryCatch({
      # train loes model
      model_full <- msir::loess.sd(new_data$DOY, new_data$SNWD,
                                   span = .1, nsigma = 3.5, ...)
      # find prediction upper limit
      prediction <- base::data.frame(DOY = model_full$x,
                                     loess_upper = model_full$upper) %>%
        dplyr::distinct(.keep_all = TRUE)
      # create the outlier flag
      new_data <- dplyr::left_join(new_data, prediction, by = "DOY") %>%
        dplyr::mutate(loess_outlier = .data$SNWD > loess_upper)
    },
    error = function(c) {
      base::simpleWarning("Could not fit loess, defaulting loess_outlier to all TRUE")
      new_data <- dplyr::mutate(new_data,
                                loess_upper = NA,
                                loess_outlier = TRUE)
    }
    # warning = function(c) {
    #   base::simpleWarning("Could not fit loess, defaulting loess_outlier to all TRUE")
    #   new_data <- dplyr::mutate(new_data,
    #                             loess_upper = NA,
    #                             loess_outlier = TRUE)
    # }
  )

    if (!base::is.null(results)) {
      results <- dplyr::bind_rows(results, new_data)
    }
    else {
      results <- new_data
    }
  }

  results$loess_outlier <- results$loess_outlier * 1
  results <- results %>% dplyr::mutate(loess_outlier = base::ifelse(base::is.na(loess_outlier),
                                                                    1,
                                                                    loess_outlier),
                                       loess_outlier = base::as.factor(loess_outlier))
  return(results)
}
