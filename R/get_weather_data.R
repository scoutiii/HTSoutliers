#' Get Weather Data From the GHCN-D
#'
#' This is a wrapper function for the 3 main get_x_data functions in snowload2
#'
#' You can enter in a list containing states, station IDS, and eco regions
#' all at once, and get the weather data from all of them in one data frame.
#'
#'
#' @param locations character
#' @param path character
#' @param ... other arguments
#'
#' @return data.frame
#' @export
#'
#' @examples
#' # data <- get_weather_data(C("UT", "BF1BI000001", "8.2.4"), "D:/Data/ghcnd_all/")
get_weather_data <- function(locations,
                             path = "ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/all/",
                             ...) {
    # Now I have changed something
    #
    snowload2::get_station_data(locations, path, ...)
}
