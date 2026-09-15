# Extracted from test-chromodoris.R:70

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "chromodoris", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
library(ggplot2)
sim <- sim_raters()

# test -------------------------------------------------------------------------
na_sim <- sim
na_sim$value[1:5] <- NA
expect_warning(ggplot_build(chromodoris(na_sim, id, time, value)),
                 "missing values")
