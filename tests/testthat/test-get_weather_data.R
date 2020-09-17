test_that("get_weather_data gets some weather data", {
  expect_equal(get_weather_data("BF1BI000001"),
               snowload2::get_station_data("BF1BI000001",
                                           "ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/all/"))
})
