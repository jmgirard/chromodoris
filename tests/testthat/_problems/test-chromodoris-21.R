# Extracted from test-chromodoris.R:21

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "chromodoris", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
library(ggplot2)
sim <- sim_raters()

# test -------------------------------------------------------------------------
p <- chromodoris(sim, id, time, value)
b <- ggplot_build(p)
