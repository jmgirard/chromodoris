# Oracle O1 (live): stats::quantile(), mean(), median() recomputed per x.
# Confirms that .width, center, and type reach the computation from both
# exported functions.

library(ggplot2)

sim <- sim_raters()
one_x <- sim$value[sim$time == sim$time[1]]
x1 <- sim$time[1]

stat_rows <- function(...) {
  p <- ggplot(sim, aes(time, value)) + stat_chromodoris(...)
  ld <- layer_data(p, 1)
  ld[ld$x == x1, ]
}
wrap_rows <- function(...) {
  ld <- layer_data(chromodoris(sim, id, time, value, ...), 1)
  ld[ld$x == x1, ]
}

test_that("both functions accept the same .width, center, and type defaults", {
  expect_equal(formals(stat_chromodoris)$.width, formals(chromodoris)$.width)
  expect_equal(formals(stat_chromodoris)$center, formals(chromodoris)$center)
  expect_equal(formals(stat_chromodoris)$type, formals(chromodoris)$type)
  expect_equal(eval(formals(chromodoris)$.width), c(0.5, 0.7, 0.9))
  expect_equal(eval(formals(chromodoris)$type), 7)
})

test_that(".width reaches the bands from both functions", {
  for (rows in list(stat_rows(.width = 0.6), wrap_rows(.width = 0.6))) {
    expect_equal(nrow(rows), 1)
    expect_equal(as.character(rows$level), "60%")
    expect_equal(rows$ymin, stats::quantile(one_x, 0.2, names = FALSE))
    expect_equal(rows$ymax, stats::quantile(one_x, 0.8, names = FALSE))
  }
})

test_that("center reaches the center from both functions", {
  for (rows in list(stat_rows(center = "median"), wrap_rows(center = "median"))) {
    expect_equal(unique(rows$center), stats::median(one_x))
  }
  for (rows in list(stat_rows(), wrap_rows())) {
    expect_equal(unique(rows$center), mean(one_x))
  }
  expect_error(chromodoris(sim, id, time, value, center = "mode"),
               "should be one of")
  expect_error(stat_chromodoris(center = "mode"), "should be one of")
})

test_that("type reaches stats::quantile from both functions", {
  for (rows in list(stat_rows(type = 8), wrap_rows(type = 8))) {
    w <- rows[rows$level == "90%", ]
    expect_equal(w$ymin, stats::quantile(one_x, 0.05, type = 8, names = FALSE))
    expect_false(w$ymin == stats::quantile(one_x, 0.05, type = 7, names = FALSE))
  }
})

test_that("the wrapper's line layer follows .width, center, and type", {
  p <- chromodoris(sim, id, time, value, .width = c(0.3, 0.8),
                   center = "median", type = 8)
  line <- layer_data(p, 2)
  expect_equal(nrow(line), 60)
  expect_equal(p$layers[[2]]$stat_params$.width, 0.8)
  expect_equal(p$layers[[2]]$stat_params$type, 8)
  expect_equal(line$y[line$x == x1], stats::median(one_x))
})
