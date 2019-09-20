#' Data related to happiness from the general social survey
#'
#' This dataset provides a small sample of variables related to happiness from the general social survey (GSS).
#' It is a reexport of the [`productplots::happy`] dataset, converted into a tibble.
#'
#' @examples
#' library(tidyverse)
#'
#' happy %>%
#'   na.omit() %>%
#'   mutate(health = fct_rev(health)) %>%
#'   ggplot(aes(x = age, y = stat(count))) +
#'   geom_density(fill = "lightblue") +
#'   facet_wrap(~health)
"happy"
