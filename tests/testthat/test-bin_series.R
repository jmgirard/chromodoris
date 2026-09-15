# Oracle O4 (closed-form): hand-computed bins for three short series, the
# arithmetic in comments below.
# Oracle O5 (live, independent implementation): floor(time / width) with
# tapply() means over a seeded data set.

test_that("bins match the hand-computed fixture", {
  d <- data.frame(
    id = c("a", "a", "a", "a", "b", "b", "b", "c", "c"),
    time = c(0, 0.25, 0.5, 1.25, 0.5, 0.75, -0.25, 0, 0.125),
    value = c(1, 3, 5, 7, 2, NA, 4, NA, NA),
    stringsAsFactors = FALSE
  )
  # width 0.5: a -> k = 0, 0, 1, 2: means 2, 5, 7 at 0.25, 0.75, 1.25.
  # b -> k = 1, 1, -1: bin 1 holds 2 and NA -> 2 at 0.75; bin -1 -> 4 at -0.25.
  # c -> both values NA -> no rows.
  out <- bin_series(d, id, time, value, width = 0.5)
  expect_equal(names(out), c("id", "time", "value"))
  expect_equal(out$id, c("a", "a", "a", "b", "b"))
  expect_equal(out$time, c(0.25, 0.75, 1.25, -0.25, 0.75))
  expect_equal(out$value, c(2, 5, 7, 4, 2))
  expect_equal(rownames(out), as.character(1:5))
})

test_that("column names are kept and may be quoted", {
  d <- data.frame(rater = "r1", t = c(0, 1), score = c(1, 2))
  out <- bin_series(d, "rater", "t", "score", width = 4)
  expect_equal(names(out), c("rater", "t", "score"))
  expect_equal(out$t, 2)
  expect_equal(out$score, 1.5)
})

test_that("bins match an independent tapply() computation", {
  set.seed(20260915)
  width <- 0.5
  # Times are multiples of 1/8, so floor(time / width) is exact. Series
  # have different lengths and unsorted rows; times run negative, land on
  # boundaries, and are not all multiples of width. Series s3 has NA values,
  # one bin with only NA, and (as every series) bins with no rows.
  lens <- c(s1 = 30, s2 = 45, s3 = 20)
  d <- do.call(rbind, lapply(names(lens), function(s) {
    time <- sample(seq(-2, 6, by = 1 / 8), lens[[s]])
    data.frame(id = s, time = time, value = stats::rnorm(lens[[s]]),
               stringsAsFactors = FALSE)
  }))
  d$value[d$id == "s3"][1:5] <- NA
  d$value[d$id == "s3" & floor(d$time / width) == 3] <- NA
  expect_true(any(d$time %% width == 0))
  expect_true(any(d$time %% width != 0))
  expect_true(any(d$time < 0))

  k <- floor(d$time / width)
  m <- tapply(d$value, list(d$id, k), mean, na.rm = TRUE)
  idx <- which(is.finite(m), arr.ind = TRUE)
  expected <- data.frame(
    id = rownames(m)[idx[, "row"]],
    time = (as.numeric(colnames(m)[idx[, "col"]]) + 0.5) * width,
    value = m[idx],
    stringsAsFactors = FALSE
  )
  expected <- expected[order(expected$id, expected$time), ]
  rownames(expected) <- NULL

  out <- bin_series(d, id, time, value, width = width)
  expect_equal(out, expected)
  expect_false(any(out$id == "s3" & out$time == 3.5))
})

test_that("invalid width signals chromodoris_error_input", {
  d <- data.frame(id = "a", time = 0, value = 1)
  for (w in list(NA, Inf, 0, -1, c(1, 2), "1", list(1), NULL)) {
    expect_error(bin_series(d, id, time, value, width = w),
                 class = "chromodoris_error_input")
  }
})

test_that("input errors reuse check_input()", {
  expect_error(bin_series(list(), id, time, value, width = 1),
               class = "chromodoris_error_input")
  d <- data.frame(id = "a", time = "0", value = 1)
  expect_error(bin_series(d, id, time, value, width = 1),
               class = "chromodoris_error_input")
})
