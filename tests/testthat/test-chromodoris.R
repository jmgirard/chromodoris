# Oracle: none. This file tests plot structure and input errors; the band
# numbers are covered in test-stat_chromodoris.R.

library(ggplot2)

sim <- sim_raters()

test_that("chromodoris() returns a ggplot with a ribbon and a line layer", {
  p <- chromodoris(sim, id, time, value)
  expect_s3_class(p, "ggplot")
  expect_length(p$layers, 2)
  expect_s3_class(p$layers[[1]]$stat, "StatChromodoris")
  expect_s3_class(p$layers[[1]]$geom, "GeomRibbon")
  expect_s3_class(p$layers[[2]]$stat, "StatChromodoris")
  expect_s3_class(p$layers[[2]]$geom, "GeomLine")
  expect_equal(p$layers[[2]]$stat_params$.width, 0.9)
})

test_that("the fill scale is discrete viridis with labels 90%, 70%, 50%", {
  p <- chromodoris(sim, id, time, value)
  b <- ggplot_build(p)
  fill_scale <- b$plot$scales$get_scales("fill")
  expect_true(inherits(fill_scale, "ScaleDiscrete"))
  expect_equal(fill_scale$name, "Band")
  expect_equal(fill_scale$get_labels(), c("90%", "70%", "50%"))
  expect_equal(fill_scale$get_breaks(), c("90%", "70%", "50%"),
               ignore_attr = TRUE)
  expect_equal(unname(fill_scale$map(c("90%", "70%", "50%"))),
               scale_fill_viridis_d()$palette(3))
  ld <- layer_data(p, 1)
  expect_equal(nrow(ld), 60 * 3)
})

test_that("quoted column names work and axis labels use the column names", {
  p <- chromodoris(sim, "id", "time", "value")
  expect_equal(p$labels$x, "time")
  expect_equal(p$labels$y, "value")
  expect_length(p$layers, 2)
})

test_that("input errors carry class chromodoris_error_input", {
  expect_error(chromodoris(sim, rater, time, value),
               class = "chromodoris_error_input")
  expect_error(chromodoris(sim, id, clock, value),
               class = "chromodoris_error_input")
  expect_error(chromodoris(sim, id, time, rating),
               class = "chromodoris_error_input")
  bad <- sim
  bad$time <- as.character(bad$time)
  expect_error(chromodoris(bad, id, time, value),
               class = "chromodoris_error_input")
  bad <- sim
  bad$value <- factor(bad$value)
  expect_error(chromodoris(bad, id, time, value),
               class = "chromodoris_error_input")
  expect_error(chromodoris(as.list(sim), id, time, value),
               class = "chromodoris_error_input")
})

test_that("input error messages name the offending column", {
  expect_error(chromodoris(sim, rater, time, value), "rater")
  bad <- sim
  bad$value <- as.character(bad$value)
  expect_error(chromodoris(bad, id, time, value), "numeric")
})

test_that("R edge cases: NA values, a single rater, an empty frame", {
  na_sim <- sim
  na_sim$value[1:5] <- NA
  # One warning per layer: the ribbon and the line both drop the rows.
  w <- capture_warnings(ggplot_build(chromodoris(na_sim, id, time, value)))
  expect_length(w, 2)
  expect_match(w, "Removed 5 rows")
  one <- sim[sim$id == "r01", ]
  ld <- layer_data(chromodoris(one, id, time, value), 1)
  expect_equal(ld$ymin, ld$ymax)
  expect_equal(ld$center, ld$ymin)
  empty <- sim[0, ]
  expect_s3_class(chromodoris(empty, id, time, value), "ggplot")
})
