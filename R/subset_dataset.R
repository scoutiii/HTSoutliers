
#' Subset_dataset
#'
#' After creating a flagged dataset, and creating the model variables,
#' use this function to create training datasets.
#'
#' Since there are significantly more non-outliers to outliers (zeros to ones),
#' it is nessicary to under-sample the zeros while training models.
#'
#' The default is zeros_to_one=3, meaning there are 3 '0' observations for every
#' '1' observation. Every '1' observation is kept, and the '0's are randomly
#' sampled. The results are also shuffled.
#'
#' @param data from create_model_variables
#' @param zeros_to_one number of 0's to 1's, default is 3 0's to 1 1
#' @param seed number to set seed so randomization is consistent
#'
#' @return dataframe
#' @export
#'
#' @examples
#' # UT <- get_weather_data("UT", "D:/Data/ghcnd_all/")
#' # data <- create_flagged_dataset(UT)
#' # data_1 <- create_model_variables(data)
#'
#' # subset <- subset_dataset(data_1)
#'
#' # trainSize <- .5
#' # train <- subset[1:(trainSize*nrow(subset)), ]
#' # test <- subset[(trainSize*nrow(subset)):nrow(subset), ]
#'
subset_dataset <- function(data,
                           zeros_to_one = 3,
                           seed = 42069) {
  base::set.seed(seed)

  ones <- dplyr::filter(data, .data$OUTLIER_FINAL == 1)
  zeros <- dplyr::filter(data, .data$OUTLIER_FINAL == 0)

  if(zeros_to_one * base::nrow(ones) > base::nrow(zeros)) {
    base::stop("Zeros_to_one too large.")
  }

  zeros <- zeros[base::sample(1:base::nrow(zeros),
                              zeros_to_one * base::nrow(ones)), ]

  new_data <- dplyr::bind_rows(ones, zeros)
  new_data <- new_data[base::sample(1:base::nrow(new_data),
                                    base::nrow(new_data)), ]
}
