#' Takes a flagged dataset created by create_flagged_dataset()
#'
#' Removes marked WESD values (as they are the only other variable we checked for)
#' OUTLIER_FINAL is if the SNWD was an outlier
#' Adds WESD, SNWD, PRCP, SNOW, TMIN, TMAX variables
#'
#' @param data a flagged dataset
#' @param complete if true, uses complete.cases
#'
#' @return dataset with extra variables
#' @export
#'
#' @importFrom dplyr .data
#'
#' @examples
#' # UT <- create_flagged_dataset(get_weather_data("UT"))
#' # UT_model_variables <- create_model_variables(UT)
create_model_variables <- function(data,
                                   complete = FALSE) {

    snow <- data %>% dplyr::filter(.data$ELEMENT == "SNWD") %>%
        dplyr::select(.data$ID, .data$DATE, .data$OUTLIER_FINAL)
    data <- data %>% dplyr::filter(!(.data$ELEMENT == "WESD" & .data$OUTLIER_FINAL == 1)) %>%
        dplyr::select(-.data$OUTLIER_FINAL)


    new_data <- data %>% tidyr::pivot_wider(names_from = .data$ELEMENT,
                                            values_from = .data$VALUE) %>%
        dplyr::left_join(snow, by=c("ID", "DATE"))


    # Creates various date variables
    new_data <- new_data %>%
        dplyr::mutate(MONTH = lubridate::month(.data$DATE),
                      YEAR = lubridate::year(.data$DATE),
                      WEEK = lubridate::week(.data$DATE))

    # Uses date variables and groups by them to get avg and stuff
    new_data <- new_data %>%
        dplyr::group_by(.data$ID) %>%
        dplyr::mutate(STATION_AVG = base::mean(.data$SNWD),
                      STATION_SD = base::ifelse(base::is.na(stats::sd(.data$SNWD)),
                                                -1,
                                                stats::sd(.data$SNWD)),
                      STATION_MAX = base::max(.data$SNWD),
                      STATION_MIN = base::min(.data$SNWD),
                      STATION_RANGE = .data$STATION_MAX - .data$STATION_MIN
                      ) %>%
        dplyr::group_by(.data$YEAR, .add=TRUE) %>%
        dplyr::mutate(YEAR_AVG = base::mean(.data$SNWD),
                      YEAR_SD = base::ifelse(base::is.na(stats::sd(.data$SNWD)),
                                             -1,
                                             stats::sd(.data$SNWD)),
                      YEAR_MAX = base::max(.data$SNWD),
                      YEAR_MIN = base::min(.data$SNWD),
                      YEAR_RANGE = .data$YEAR_MAX - .data$YEAR_MIN
                      ) %>%
        dplyr::group_by(.data$MONTH, .add=TRUE) %>%
        dplyr::mutate(MONTH_AVG = base::mean(.data$SNWD),
                      MONTH_SD = base::ifelse(base::is.na(stats::sd(.data$SNWD)),
                                              -1,
                                              stats::sd(.data$SNWD)),
                      MONTH_MAX = base::max(.data$SNWD),
                      MONTH_MIN = base::min(.data$SNWD),
                      MONTH_RANGE = .data$MONTH_MAX - .data$MONTH_MIN,
                      MONTH_DENSITY = dplyr::n() / lubridate::days_in_month(.data$MONTH)
                      ) %>%
        dplyr::group_by(.data$ID, .data$YEAR, .data$WEEK) %>%
        dplyr::mutate(WEEK_AVG = base::mean(.data$SNWD),
                      # WEEK_SD = base::ifelse(base::is.na(stats::sd(.data$SNWD)),
                      #                        -1,
                      #                        stats::sd(.data$SNWD)),
                      WEEK_MAX = base::max(.data$SNWD),
                      WEEK_MIN = base::min(.data$SNWD),
                      WEEK_RANGE = .data$WEEK_MAX - .data$WEEK_MIN
                      ) %>%
        dplyr::filter(.data$MONTH_SD >= 0)

    # snowload2::ghcnd_stations


    if (complete) {
        new_data <- dplyr::filter(new_data, stats::complete.cases(new_data))
    }

    return(new_data)

}


# temp <- snowload2::ghcnd_stations
#
# sp::coordinates(temp) <- c("LONGITUDE", "LATITUDE")
#
# sp::proj4string(temp) <- sp::proj4string(PRISM_climate_norms)
#
# # Create teh matrix of PRISM climate values (n (of GHCND_STATIONS) x 36)
# tvalues <- raster::extract(PRISM_climate_norms, temp, method = "bilinear")
#
# # TODO: Figure out how to assign climate variables based on ID and month.
