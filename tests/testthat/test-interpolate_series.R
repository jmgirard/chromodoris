# Oracle O6 (closed-form): hand-computed interpolation for three short
# series, the arithmetic in comments below.
# Oracle O7 (live, independent implementation): stats::approx() per series
# over a seeded data set with no missing values.

hand_data <- function() {
  data.frame(
    id = c("a", "a", "a", "a", "a", "a", "a", "b", "b", "c", "c"),
    time = c(2, 0, 1, 1, 4, 5, 4, 3, NA, 0, 2),
    value = c(NA, 0, 8, 12, 20, 30, NA, 7, 99, NA, NA),
    stringsAsFactors = FALSE
  )
}
# Unsorted, with 0.5 twice.
hand_grid <- c(5, -1, 0.5, 2, 1, 1.5, 3, 4.5, 6, 0.5)

# a, sorted, repeated times averaged over non-NA values:
#   t = 0, 1, 2, 4, 5 -> v = 0, 10, NA, 20, 30. Range [0, 5].
# b: the NA-time row is dropped, leaving t = 3, v = 7. Range [3, 3].
# c: every value NA -> no rows.
# Grid, sorted and deduplicated: -1, 0.5, 1, 1.5, 2, 3, 4.5, 5, 6.

test_that("linear interpolation matches the hand-computed fixture", {
  # a: -1 and 6 lie outside [0, 5]; 0.5 -> 0 + 10 * 0.5 = 5; 1 -> 10;
  #   1.5 and 3 sit next to the NA at t = 2, and 2 is that NA: no rows;
  #   4.5 -> 20 + 10 * 0.5 = 25; 5 -> 30.
  # b: only 3 lies in [3, 3] -> 7.
  out <- interpolate_series(hand_data(), id, time, value, grid = hand_grid)
  expect_equal(names(out), c("id", "time", "value"))
  expect_equal(out$id, c("a", "a", "a", "a", "b"))
  expect_equal(out$time, c(0.5, 1, 4.5, 5, 3))
  expect_equal(out$value, c(5, 10, 25, 30, 7))
  expect_equal(rownames(out), as.character(1:5))
})

test_that("constant interpolation matches the hand-computed fixture", {
  # The value at g is the value at the last time at or before g.
  # a: 0.5 -> 0; 1 -> 10; 1.5 -> 10; 2 and 3 take the NA at t = 2: no rows;
  #   4.5 -> 20; 5 -> 30.
  # b: 3 -> 7.
  out <- interpolate_series(hand_data(), id, time, value, grid = hand_grid,
                            method = "constant")
  expect_equal(out$id, c("a", "a", "a", "a", "a", "b"))
  expect_equal(out$time, c(0.5, 1, 1.5, 4.5, 5, 3))
  expect_equal(out$value, c(0, 10, 10, 20, 30, 7))
})

test_that("column names are kept and may be quoted", {
  d <- data.frame(rater = "r1", t = c(0, 2), score = c(1, 3))
  out <- interpolate_series(d, "rater", "t", "score", grid = 1)
  expect_equal(names(out), c("rater", "t", "score"))
  expect_equal(out$t, 1)
  expect_equal(out$score, 2)
})

test_that("a grid with no point inside any series gives zero rows", {
  d <- data.frame(id = "a", time = c(0, 1), value = c(1, 2))
  out <- interpolate_series(d, id, time, value, grid = c(-2, 3))
  expect_equal(nrow(out), 0)
  expect_equal(names(out), c("id", "time", "value"))
})

test_that("interpolation matches stats::approx() inside each series' range", {
  set.seed(20261127)
  # Series of different lengths, irregular times in unsorted rows, and a
  # grid that runs past both ends of every series.
  lens <- c(s1 = 25, s2 = 40, s3 = 12)
  d <- do.call(rbind, lapply(names(lens), function(s) {
    time <- sample(stats::runif(lens[[s]], -2, 8))
    data.frame(id = s, time = time, value = stats::rnorm(lens[[s]]),
               stringsAsFactors = FALSE)
  }))
  grid <- seq(-3, 9, by = 0.05)

  for (method in c("linear", "constant")) {
    expected <- do.call(rbind, lapply(split(d, d$id), function(s) {
      y <- stats::approx(s$time, s$value, xout = grid, method = method,
                         rule = 1, f = 0)$y
      keep <- !is.na(y)
      data.frame(id = s$id[1], time = grid[keep], value = y[keep],
                 stringsAsFactors = FALSE)
    }))
    rownames(expected) <- NULL
    out <- interpolate_series(d, id, time, value, grid = grid,
                              method = method)
    expect_equal(out, expected)
    # Every series stops short of the grid's ends.
    expect_true(all(tapply(out$time, out$id, min) > -3))
    expect_true(all(tapply(out$time, out$id, max) < 9))
  }
})

test_that("invalid grid signals chromodoris_error_input", {
  d <- data.frame(id = "a", time = 0, value = 1)
  for (g in list(NA_real_, c(0, NA), c(0, Inf), numeric(0), "1", list(1),
                 NULL, matrix(c(0, 1)))) {
    expect_error(interpolate_series(d, id, time, value, grid = g),
                 class = "chromodoris_error_input")
  }
})

test_that("an infinite time or value is an error", {
  for (d in list(data.frame(id = 1, time = c(0, 1, Inf), value = 1:3),
                 data.frame(id = 1, time = 0:2, value = c(1, -Inf, 3)))) {
    expect_error(interpolate_series(d, id, time, value, grid = 0:5),
                 class = "chromodoris_error_input")
  }
})

test_that("an unknown method is an error", {
  d <- data.frame(id = "a", time = 0, value = 1)
  expect_error(interpolate_series(d, id, time, value, grid = 0,
                                  method = "spline"),
               "should be one of")
})

test_that("input errors reuse check_input()", {
  expect_error(interpolate_series(list(), id, time, value, grid = 0),
               class = "chromodoris_error_input")
  d <- data.frame(id = "a", time = "0", value = 1)
  expect_error(interpolate_series(d, id, time, value, grid = 0),
               class = "chromodoris_error_input")
})
