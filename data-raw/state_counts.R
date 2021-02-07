load("D:/RCode/URCO/Packages/state_counts.rdata")

# results <- data.frame(name=names(results),
#                       value=unlist(results))
results <- unlist(results)

new_results <- data.frame(STATE=character(),
                          NWESD=integer(),
                          QWESD=integer(),
                          NSNWD=integer(),
                          QSNWD=integer())

for (state in state.abb) {
  try({
    vals <- results[startsWith(names(results), state)]
    nwesd <- vals[endsWith(names(vals), "nwesd")]
    qwesd <- vals[endsWith(names(vals), "qwesd")]
    nsnwd <- vals[endsWith(names(vals), "nsnwd")]
    qsnwd <- vals[endsWith(names(vals), "qsnwd")]
    temp <- data.frame(STATE=as.character(state),
                       NWESD=as.integer(nwesd),
                       QWESD=as.integer(qwesd),
                       NSNWD=as.integer(nsnwd),
                       QSNWD=as.integer(qsnwd))
    new_results <- dplyr::bind_rows(new_results, temp)
  })
}

state_counts <- new_results

# save(state_counts, file = "D:/RCode/URCO/Packages/state_counts2.rda")

usethis::use_data(state_counts, overwrite = TRUE)

