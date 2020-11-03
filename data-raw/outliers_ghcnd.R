## code to prepare `outliers_ghcnd` dataset goes here

# This is the code to produce the original (doesn't have name column)
outliers_ghcnd <- snowload2::outlier_combined %>%
    dplyr::filter(OUTLIER != 0) %>%
    dplyr::mutate(DATE = lubridate::as_date(DATE)) %>%
    dplyr::distinct()

# New code which adds a name column to the dataset
load("C://Users/scout/Box/URCO_2020_Scout_Jarman/data/outliers_with_names_scout.RData")
outliers_ghcnd <- outlier_combined %>%
  dplyr::filter(OUTLIER != 0) %>%
  dplyr::mutate(DATE = lubridate::as_date(DATE)) %>%
  dplyr::distinct() %>%
  dplyr::mutate(name = ifelse(is.na(name), "", name))

usethis::use_data(outliers_ghcnd, overwrite = TRUE)
