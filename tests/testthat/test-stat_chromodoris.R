# Oracle O1 (live): stats::quantile() types 7 and 8, mean(), median(),
# recomputed per time point.
# Oracle O3 (live): ggdist::mean_qi() at .width = c(.5, .7, .9).

library(ggplot2)

sim <- sim_raters()
stat_data <- function(...) {
  p <- ggplot(sim, aes(time, value, group = id)) + stat_chromodoris(...)
  layer_data(p, 1)
}

test_that("one row per (x, level) with the promised columns", {
  ld <- stat_data()
  expect_true(all(c("x", "level", "ymin", "ymax", "center") %in% names(ld)))
  # The ribbon geom overwrites y with ymin, so check y on a line layer.
  line_ld <- stat_data(geom = "line")
  expect_equal(line_ld$y, line_ld$center)
  expect_equal(nrow(ld), 60 * 3)
  expect_equal(anyDuplicated(ld[c("x", "level")]), 0)
  expect_equal(levels(ld$level), c("90%", "70%", "50%"))
  expect_equal(unique(ld$group), 1:3)
})

test_that("edges and center match stats::quantile per x, types 7 and 8", {
  probs <- list("50%" = c(.25, .75), "70%" = c(.15, .85), "90%" = c(.05, .95))
  for (t in c(7, 8)) {
    ld <- stat_data(type = t)
    for (lvl in names(probs)) {
      sub <- ld[ld$level == lvl, ]
      for (i in seq_len(nrow(sub))) {
        v <- sim$value[sim$time == sub$x[i]]
        expect_equal(sub$ymin[i], stats::quantile(v, probs[[lvl]][1], type = t, names = FALSE))
        expect_equal(sub$ymax[i], stats::quantile(v, probs[[lvl]][2], type = t, names = FALSE))
        expect_equal(sub$center[i], mean(v))
      }
    }
  }
})

test_that("type changes the result and center = 'median' uses the median", {
  ld7 <- stat_data(type = 7)
  ld8 <- stat_data(type = 8)
  expect_false(isTRUE(all.equal(ld7$ymin, ld8$ymin)))
  ldm <- stat_data(center = "median")
  for (i in seq_len(nrow(ldm))) {
    expect_equal(ldm$center[i], stats::median(sim$value[sim$time == ldm$x[i]]))
  }
})

test_that("type-7 result agrees with ggdist::mean_qi()", {
  skip_if_not_installed("ggdist")
  ld <- stat_data(type = 7)
  xs <- sort(unique(sim$time))
  ref <- do.call(rbind, lapply(xs, function(t) {
    r <- as.data.frame(ggdist::mean_qi(sim$value[sim$time == t],
                                       .width = c(.5, .7, .9)))
    r$x <- t
    r
  }))
  ref$level <- band_labels(ref$.width)
  m <- match(paste(ref$x, ref$level), paste(ld$x, ld$level))
  expect_false(anyNA(m))
  expect_equal(nrow(ref), nrow(ld))
  expect_equal(ld$ymin[m], ref$ymin)
  expect_equal(ld$ymax[m], ref$ymax)
  expect_equal(ld$center[m], ref$y)
})

test_that("a custom .width is sorted widest first and labelled", {
  ld <- stat_data(.width = c(0.2, 0.8))
  expect_equal(levels(ld$level), c("80%", "20%"))
  expect_equal(nrow(ld), 60 * 2)
})

test_that("bad .width aborts", {
  p <- ggplot(sim, aes(time, value)) + stat_chromodoris(.width = 1.5)
  expect_error(layer_data(p), "must be numeric")
})
