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


    new_data <- dplyr::select(data, .data$ID, .data$DATE) %>%
        dplyr::distinct() %>%
        dplyr::left_join(.data$WESD, by = c("ID", "DATE")) %>%
        dplyr::left_join(.data$PRCP, by = c("ID", "DATE")) %>%
        dplyr::left_join(.data$SNOW, by = c("ID", "DATE")) %>%
        dplyr::left_join(.data$TMAX, by = c("ID", "DATE")) %>%
        dplyr::left_join(.data$TMIN, by = c("ID", "DATE")) %>%
        dplyr::left_join(.data$SNWD, by = c("ID", "DATE")) %>%
        dplyr::select(.data$ID, .data$DATE, .data$OUTLIER_FINAL, .data$SNWD, .data$WESD, .data$PRCP, .data$SNOW, .data$TMAX, .data$TMIN) %>%
        dplyr::filter(!base::is.na(.data$SNWD))

    if (complete) {
        new_data <- dplyr::filter(new_data, stats::complete.cases(new_data))
    }

    return(new_data)

}
