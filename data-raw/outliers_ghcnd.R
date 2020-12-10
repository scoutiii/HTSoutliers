## code to prepare `outliers_ghcnd` dataset goes here

library(tidyverse)

# This is the code to produce the original (doesn't have name column)
### VERSION 1
outliers_ghcnd <- snowload2::outlier_combined %>%
    dplyr::filter(OUTLIER != 0) %>%
    dplyr::mutate(DATE = lubridate::as_date(DATE)) %>%
    dplyr::distinct()

# New code which adds a name column to the dataset
### VERSION 2
load("C://Users/scout/Box/URCO_2020_Scout_Jarman/data/outliers_with_names_scout.RData")
outliers_ghcnd <- outlier_combined %>%
  dplyr::filter(OUTLIER != 0) %>%
  dplyr::mutate(DATE = lubridate::as_date(DATE)) %>%
  dplyr::distinct() %>%
  dplyr::mutate(name = ifelse(is.na(name), "", name))


# Reflagged based on my manual search of the others outliers
### VERSION 3
temp <- read.csv("C://Users/scout/Box/URCO_2020_Scout_Jarman/data/scout_outlier_check_combined.csv")
outliers_ghcnd <- temp %>%
  dplyr::mutate(DATE = lubridate::as_date(DATE)) %>%
  dplyr::distinct()
outliers_ghcnd$TYPE = "MANUAL"

canada <- c("AB", "BC", "MB", "NB", "NS", "ON", "PE", "QC", "SK", "YT")
states <- c(canada, state.abb)

for (state in states) {
  if (is.element(state, c("AK", "HI"))) {
    next
  }
  data <- snowload2::get_state_data(state, "D:/Data/ghcnd_all/")
  data <- data %>%
    dplyr::filter(QFLAG != " ") %>%
    dplyr::select(ID, DATE, ELEMENT, VALUE) %>%
    dplyr::mutate(DATE = lubridate::as_date(DATE))
  data$OUTLIER = 1
  data$TYPE = "QFLAG"
  outliers_ghcnd <- outliers_ghcnd %>%
    dplyr::bind_rows(data) %>%
    dplyr::distinct()
  temp <- outliers_ghcnd
}


outliers_ghcnd <- outliers_ghcnd %>%
  dplyr::filter(VALUE > 0,
                OUTLIER != -1)
out_tally <- outliers_ghcnd %>%
  dplyr::group_by(ID) %>%
  tally(.) %>%
  dplyr::filter(n < 10)

outliers_ghcnd <- outliers_ghcnd %>%
  dplyr::filter(ID %in% out_tally$ID)


usethis::use_data(outliers_ghcnd, overwrite = TRUE)
