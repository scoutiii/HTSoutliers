library(tidyverse)
load_all()

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
                  DIFF = c(NA, diff(VALUE)) / c(NA, diff(DATE)),  # Recent change to divide by N
                  MAXDIFFSCALED = max(hablar::s(DIFF)),
                  MINDIFFSCALED = min(hablar::s(DIFF)),
                  DIFFRAW = c(NA, diff(VALUE)),
                  MAXDIFFRAW = max(hablar::s(DIFFRAW)),
                  MINDIFFRAW = min(hablar::s(DIFFRAW))
                  ) %>%
    dplyr::filter(N >= 5) %>%
    dplyr::select(-c(DATE, ELEMENT, VALUE, MFLAG, QFLAG, SFLAG, DIFF, DIFFRAW)) %>%
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
      dplyr::bind_rows(data)
  }
  temp <- ghcnd_monthly
  gc()
}
ghcnd_monthly$ID <- as.factor(ghcnd_monthly$ID)

outliers <- outliers_ghcnd %>%
  dplyr::filter(ELEMENT == "SNWD") %>%
  dplyr::mutate(YEAR = lubridate::year(DATE),
                MONTH = lubridate::month(DATE)) %>%
  dplyr::group_by(ID, YEAR, MONTH, .add = TRUE) %>%
  dplyr::mutate(NOUT = dplyr::n(),
                TYPEOUT = ifelse(length(unique(TYPE)) == 2,
                                 "BOTH",
                                 as.character(unique(TYPE)))) %>%
  dplyr::select(ID, YEAR, MONTH, NOUT, TYPEOUT) %>%
  dplyr::distinct()

ghcnd_monthly <- ghcnd_monthly %>%
  dplyr::left_join(outliers) %>%
  dplyr::mutate(NOUT = ifelse(is.na(NOUT), 0, NOUT),
                TYPEOUT = ifelse(is.na(TYPEOUT), "NONE", TYPEOUT))
ghcnd_monthly$TYPEOUT <- as.factor(ghcnd_monthly$TYPEOUT)

ghcnd_monthly <- ghcnd_monthly %>%
  dplyr::filter(!is.na(PRISM_PPT),
                !is.na(PRISM_TMIN),
                !is.na(PRISM_TMAX))

ghcnd_monthly <- ghcnd_monthly %>%
  dplyr::filter(MIN >= 0,
                MEDIAN >= 0,
                MEAN >= 0)

usethis::use_data(ghcnd_monthly, overwrite = TRUE)
