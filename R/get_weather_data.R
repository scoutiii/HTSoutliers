#' Get Weather Data From the GHCN-D
#'
#' This is a wrapper function for the 3 main get_x_data functions in snowload2
#'
#' You can enter in a list containing states, station IDS, and eco regions
#' all at once, and get the weather data from all of them in one data frame.
#'
#' NOTE: ECO REGIONS NOT SUPPORTED YET
#'
#'
#' @param locations character
#' @param path character
#' @param elem vector of which elements to be retrieved
#' @param ... other arguments
#'
#' @return data.frame
#' @export
#'
#' @examples
#' # data <- get_weather_data(C("UT", "BF1BI000001", "8.2.4"), "D:/Data/ghcnd_all/")
get_weather_data <- function(locations,
                             path = "ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/all/",
                             elem = c("SNWD", "WESD", "PRCP", "TMIN", "TMAX", "SNOW"),
                             ...) {

    final_data <- NULL

    for (location in locations) {
        print(location)
        new_data <- NULL
        if (base::toupper(location) %in% datasets::state.abb) {
            new_data <- snowload2::get_state_data(location, path, elem, ...)
        }
        else if (location %in% snowload2::ghcnd_stations$ID) {
            new_data <- snowload2::get_station_data(location, path, elem, ...)
        }

        if (base::is.null(final_data)) {
            final_data <- new_data
        }
        else {
            if (!base::is.null(new_data)) {
                final_data <- dplyr::union(final_data, new_data)
            }
        }
    }

    return(final_data)
}
