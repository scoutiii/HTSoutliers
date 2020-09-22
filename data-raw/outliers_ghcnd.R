## code to prepare `outliers_ghcnd` dataset goes here

outliers_ghcnd <- snowload2::outlier_combined %>%
    dplyr::filter(OUTLIER != 0) %>%
    dplyr::mutate(DATE = lubridate::as_date(DATE),
                  VALUE = ifelse(ELEMENT == "WESD", VALUE/10, VALUE))

usethis::use_data(outliers_ghcnd, overwrite = TRUE)
