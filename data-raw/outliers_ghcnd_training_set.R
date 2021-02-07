library(tidyverse)
load_all()

train_data_outliers <- NULL
outlier_ids <- unique(outliers_ghcnd$ID)
i <- 0
for (id in outlier_ids) {
  try({
    i <- i + 1
    print(100*i/length(outlier_ids))
    data <- snowload2::get_station_data(id, "D:/Data/ghcnd_all/")
    data <- create_flagged_dataset(data)
    data <- create_model_variables(data)
    data <- data %>%
      dplyr::filter(OUTLIER_FINAL == 1)
    if (nrow(data) > 0) {
      if (is.null(train_data_outliers)) {
        train_data_outliers <- data
      }
      else {
        train_data_outliers <- dplyr::bind_rows(train_data_outliers, data)
      }
    }
  })
}
save(train_data_outliers, file = "D:/RCode/URCO/Packages/train_outliers.rda")



train_data_non_outliers <- NULL
set.seed(42069)
non_outlier_ids <- snowload2::ghcnd_stations %>%
  dplyr::sample_n(30000) %>%
  dplyr::select(ID)
i <- 0
for (id in non_outlier_ids$ID) {
  try({
    i <- i + 1
    print(100*i/nrow(non_outlier_ids))
    data <- snowload2::get_station_data(id, "D:/Data/ghcnd_all/")
    if (is.null(data)) {
      next
    }
    data <- create_flagged_dataset(data)
    data <- create_model_variables(data)
    set.seed(42069)
    data <- data %>%
      dplyr::filter(OUTLIER_FINAL != 1,
                    SNWD >= 0) %>%
      dplyr::sample_n(20)
    if (nrow(data) > 0) {
      if (is.null(train_data_non_outliers)) {
        train_data_non_outliers <- data
      }
      else {
        train_data_non_outliers <- dplyr::bind_rows(train_data_non_outliers, data)
      }
    }
  })
}
save(train_data_non_outliers, file = "D:/RCode/URCO/Packages/train_non_outliers.rda")

outliers_ghcnd_training_set <- dplyr::bind_rows(train_data_outliers,
                                                train_data_non_outliers)
