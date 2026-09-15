# Extracted from test-stat_chromodoris.R:16

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "chromodoris", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
library(ggplot2)
sim <- sim_raters()
stat_data <- function(...) {
  p <- ggplot(sim, aes(time, value, group = id)) + stat_chromodoris(...)
  layer_data(p, 1)
}

# test -------------------------------------------------------------------------
ld <- stat_data()
expect_true(all(c("x", "level", "ymin", "ymax", "center") %in% names(ld)))
expect_equal(ld$y, ld$center)
