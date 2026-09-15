# Extracted from test-snapshot.R:7

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "chromodoris", path = "..")
attach(test_env, warn.conflicts = FALSE)

# test -------------------------------------------------------------------------
skip_if_not_installed("vdiffr")
p <- chromodoris(sim_raters(), id, time, value, .width = c(.5, .9))
vdiffr::expect_doppelganger("chromodoris-default", p)
