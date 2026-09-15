# Oracle O1 (live): stats::quantile() types 7 and 8, mean(), median().
# Oracle O2 (closed-form): hand-computed edges on a fixed vector, arithmetic
# in comments below.
# Oracle O3 (live, ggdist): tests/testthat/test-stat_chromodoris.R.

sb <- chromodoris:::summarise_bands

test_that("edges match stats::quantile for types 7 and 8 and each width", {
  set.seed(1)
  v <- stats::rnorm(41)
  for (t in c(7, 8)) {
    out <- sb(v, .width = c(0.5, 0.7, 0.9), type = t)
    expect_equal(out$.width, c(0.5, 0.7, 0.9))
    expect_equal(out$ymin[1], stats::quantile(v, 0.25, type = t, names = FALSE))
    expect_equal(out$ymax[1], stats::quantile(v, 0.75, type = t, names = FALSE))
    expect_equal(out$ymin[2], stats::quantile(v, 0.15, type = t, names = FALSE))
    expect_equal(out$ymax[2], stats::quantile(v, 0.85, type = t, names = FALSE))
    expect_equal(out$ymin[3], stats::quantile(v, 0.05, type = t, names = FALSE))
    expect_equal(out$ymax[3], stats::quantile(v, 0.95, type = t, names = FALSE))
  }
  # Types 7 and 8 differ on this vector, so the type argument is live.
  expect_false(sb(v, type = 7)$ymin[3] == sb(v, type = 8)$ymin[3])
})

test_that("center is the mean by default and the median on request", {
  v <- c(1, 2, 3, 10)
  expect_equal(unique(sb(v)$center), 4)          # (1+2+3+10)/4
  expect_equal(unique(sb(v, center = "median")$center), 2.5)  # (2+3)/2
  expect_equal(unique(sb(v, center = "mean")$center), mean(v))
})

test_that("hand-computed type-7 edges on 1:10", {
  # type 7: Q(p) = x[1 + (n-1)p] with linear interpolation, n = 10.
  # p = .25 -> index 3.25 -> 3.25; p = .75 -> index 7.75 -> 7.75
  # p = .05 -> index 1.45 -> 1.45; p = .95 -> index 9.55 -> 9.55
  out <- sb(1:10, .width = c(0.5, 0.9), type = 7)
  expect_equal(out$ymin, c(3.25, 1.45))
  expect_equal(out$ymax, c(7.75, 9.55))
  expect_equal(out$center, c(5.5, 5.5))
})

test_that("missing values are dropped and a single width works", {
  out <- sb(c(1, NA, 3, 5), .width = 0.5)
  expect_equal(nrow(out), 1)
  expect_equal(out$center, 3)
  expect_equal(out$ymin, stats::quantile(c(1, 3, 5), 0.25, names = FALSE))
})

test_that("an unknown center is rejected", {
  expect_error(sb(1:5, center = "mode"), "should be one of")
})
