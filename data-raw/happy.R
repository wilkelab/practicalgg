data(happy, package = "productplots")

library(tibble)

happy <- as_tibble(happy)

usethis::use_data(happy, overwrite = TRUE)
