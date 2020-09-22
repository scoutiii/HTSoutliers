test_that("checks no args returns null", {
    expect_equal(get_weather_data(c()), NULL)
})
