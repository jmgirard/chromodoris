# Extracted from test-chromodoris.R:26

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
fill_scale <- b$plot$scales$get_scales("fill")
expect_true(inherits(fill_scale, "ScaleDiscrete"))
expect_equal(fill_scale$name, "Band")
expect_equal(fill_scale$get_labels(), c("90%", "70%", "50%"))
expect_equal(fill_scale$get_breaks(), c("90%", "70%", "50%"))
