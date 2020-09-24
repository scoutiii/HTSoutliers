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

    # Separates each element type into its own frame
    WESD <- dplyr::filter(data, .data$ELEMENT == "WESD", .data$OUTLIER_FINAL == 0) %>%
        dplyr::rename(WESD = .data$VALUE) %>%
        dplyr::select(.data$ID, .data$DATE, .data$WESD)

    SNWD <- dplyr::filter(data, .data$ELEMENT == "SNWD") %>%
        dplyr::rename(SNWD = .data$VALUE) %>%
        dplyr::select(.data$ID, .data$DATE, .data$SNWD, .data$OUTLIER_FINAL)

    PRCP <- dplyr::filter(data, .data$ELEMENT == "PRCP") %>%
        dplyr::rename(PRCP = .data$VALUE) %>%
        dplyr::select(.data$ID, .data$DATE, .data$PRCP)

    SNOW <- dplyr::filter(data, .data$ELEMENT == "SNOW") %>%
        dplyr::rename(SNOW = .data$VALUE) %>%
        dplyr::select(.data$ID, .data$DATE, .data$SNOW)

    TMAX <- dplyr::filter(data, .data$ELEMENT == "TMAX") %>%
        dplyr::rename(TMAX = .data$VALUE) %>%
        dplyr::select(.data$ID, .data$DATE, .data$TMAX)

    TMIN <- dplyr::filter(data, .data$ELEMENT == "TMIN") %>%
        dplyr::rename(TMIN = .data$VALUE) %>%
        dplyr::select(.data$ID, .data$DATE, .data$TMIN)

    # Adds WESD, PRCP, SNOW, TMAX, TMIN, SNWD as separate variables
    new_data <- dplyr::select(data, .data$ID, .data$DATE) %>%
        dplyr::distinct() %>%
        dplyr::left_join(WESD, by = c("ID", "DATE")) %>%
        dplyr::left_join(PRCP, by = c("ID", "DATE")) %>%
        dplyr::left_join(SNOW, by = c("ID", "DATE")) %>%
        dplyr::left_join(TMAX, by = c("ID", "DATE")) %>%
        dplyr::left_join(TMIN, by = c("ID", "DATE")) %>%
        dplyr::left_join(SNWD, by = c("ID", "DATE")) %>%
        dplyr::select(.data$ID, .data$DATE, .data$OUTLIER_FINAL, .data$SNWD, .data$WESD, .data$PRCP, .data$SNOW, .data$TMAX, .data$TMIN) %>%
        dplyr::filter(!base::is.na(.data$SNWD))

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
                      MONTH_RANGE = .data$MONTH_MAX - .data$MONTH_MIN
                      ) %>%
        dplyr::group_by(.data$ID, .data$YEAR, .data$WEEK) %>%
        dplyr::mutate(WEEK_AVG = base::mean(.data$SNWD),
                      WEEK_SD = base::ifelse(base::is.na(stats::sd(.data$SNWD)),
                                             -1,
                                             stats::sd(.data$SNWD)),
                      WEEK_MAX = base::max(.data$SNWD),
                      WEEK_MIN = base::min(.data$SNWD),
                      WEEK_RANGE = .data$WEEK_MAX - .data$WEEK_MIN
                      )


    if (complete) {
        new_data <- dplyr::filter(new_data, stats::complete.cases(new_data))
    }

    return(new_data)

}
