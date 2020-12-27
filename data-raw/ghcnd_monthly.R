library(tidyverse)
library(HTSoutliers)


ppt <- HTSoutliers::PRISM_climate_norms[,c(1:12, 37)]  # 1:12 corresponds to PPT variables
names(ppt) <- c(1:12, "ID")
ppt <- ppt %>% tidyr::gather(MONTH, PRISM_PPT, 1:12)
ppt$MONTH <- as.double(ppt$MONTH)

tmin <- HTSoutliers::PRISM_climate_norms[,c(13:24, 37)]  # 13:24 corresponds to TMIN variables
names(tmin) <- c(1:12, "ID")
tmin <- tmin %>% tidyr::gather(MONTH, PRISM_TMIN, 1:12)
tmin$MONTH <- as.double(tmin$MONTH)

tmax <- HTSoutliers::PRISM_climate_norms[,c(25:36, 37)]  # 25:36 corresponds to TMAX variables
names(tmax) <- c(1:12, "ID")
tmax <- tmax %>% tidyr::gather(MONTH, PRISM_TMAX, 1:12)
tmax$MONTH <- as.double(tmax$MONTH)



ghcnd_monthly <- NULL

for (state in state.abb) {
  if (is.element(state, c("AK", "HI"))) {
    next
  }
  print(state)

  data <- snowload2::get_state_data(state, "D:/Data/ghcnd_all/")
  data <- data %>%
    dplyr::filter(ELEMENT == "SNWD") %>%
    dplyr::mutate(YEAR = lubridate::year(DATE),
                  MONTH = lubridate::month(DATE)) %>%
    dplyr::group_by(ID, YEAR, MONTH, .add = TRUE) %>%
    dplyr::mutate(MEAN = mean(VALUE),
                  MEDIAN = median(VALUE),
                  SD = ifelse(is.na(sd(VALUE)), -1, sd(VALUE)),
                  MAX = max(VALUE),
                  MIN = min(VALUE),
                  RANGE = MAX - MIN,
                  Q1 = quantile(VALUE, .25),
                  Q3 = quantile(VALUE, .75),
                  N = dplyr::n(),
                  DIFF = c(NA, diff(VALUE)),
                  MAXDIFF = max(DIFF, na.rm = TRUE),
                  MINDIFF = min(DIFF, na.rm = TRUE)
                  ) %>%
    dplyr::filter(N >= 5) %>%
    dplyr::select(-c(DATE, ELEMENT, VALUE, MFLAG, QFLAG, SFLAG, DIFF)) %>%
    dplyr::distinct()

  data <- data %>%
    dplyr::left_join(ppt, by=c("ID", "MONTH")) %>%
    dplyr::left_join(tmin, by=c("ID", "MONTH")) %>%
    dplyr::left_join(tmax, by=c("ID", "MONTH"))


  if (is.null(ghcnd_monthly)) {
    ghcnd_monthly <- data
  }
  else {
    ghcnd_monthly <- ghcnd_monthly %>%
      dplyr::bind_rows(data) %>%
      dplyr::distinct()
  }
  temp <- ghcnd_monthly
  gc()
}



usethis::use_data(ghcnd_monthly, overwrite = TRUE)
