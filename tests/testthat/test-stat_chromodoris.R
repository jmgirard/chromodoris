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
  expect_error(layer_data(p), class = "chromodoris_error_input")
  # The wrapper checks at call time, so tryCatch() sees the class directly.
  caught <- tryCatch(chromodoris(sim, id, time, value, .width = c(0.5, 0)),
                     chromodoris_error_input = function(e) "caught")
  expect_equal(caught, "caught")
  expect_error(chromodoris(sim, id, time, value, .width = NA_real_),
               class = "chromodoris_error_input")
})

test_that(".width values that round to the same percent abort", {
  expect_error(chromodoris(sim, id, time, value, .width = c(0.9, 0.904)),
               class = "chromodoris_error_input")
  expect_error(chromodoris(sim, id, time, value, .width = c(0.9, 0.904)),
               "same percent")
  p <- ggplot(sim, aes(time, value)) + stat_chromodoris(.width = c(0.9, 0.904))
  expect_error(layer_data(p), class = "chromodoris_error_input")
  # Distinct percents still pass.
  ld <- stat_data(.width = c(0.9, 0.91))
  expect_equal(levels(ld$level), c("91%", "90%"))
})

test_that("bad type aborts at call time from both functions", {
  for (bad in list(99, 0, 7.5, NA_real_, c(7, 8), "7")) {
    expect_error(chromodoris(sim, id, time, value, type = bad),
                 class = "chromodoris_error_input")
    p <- ggplot(sim, aes(time, value)) + stat_chromodoris(type = bad)
    expect_error(layer_data(p), class = "chromodoris_error_input")
  }
  expect_error(chromodoris(sim, id, time, value, type = 99), "1 to 9")
})

test_that("extra aesthetics are dropped without a warning", {
  p <- ggplot(sim, aes(time, value, colour = id)) + stat_chromodoris()
  expect_no_warning(ld <- layer_data(p, 1))
  # The ribbon geom adds its default colour (NA) after the stat, so the
  # mapped rater colours are gone when every value is NA.
  expect_true(all(is.na(ld$colour)))
  expect_equal(nrow(ld), 60 * 3)
})

# --- bin (M003) -------------------------------------------------------------
# Oracle for `bin`: bin_series() (test-bin_series.R oracles O4, O5), the
# stat drawn on its output.

line_data <- function(data, ...) {
  p <- ggplot(data, aes(time, value, group = id)) +
    stat_chromodoris(geom = "line", ...)
  layer_data(p, 1)
}
band_cols <- c("x", "ymin", "ymax", "center", "y", "level")

test_that("bin = w equals the stat drawn on bin_series() output", {
  # 0.7 does not divide the grid step 30 / 59; 100 exceeds the time range.
  for (w in c(0.7, 100)) {
    got <- line_data(sim, bin = w)
    want <- line_data(bin_series(sim, id, time, value, width = w))
    expect_equal(got[band_cols], want[band_cols])
    expect_equal(nrow(got), 3 * length(unique(want$x)))
  }
  expect_equal(nrow(line_data(sim, bin = 100)), 3)
})

test_that("the default path equals the fixture recorded at 48e2e88", {
  want <- readRDS(test_path("fixtures", "stat-default-48e2e88.rds"))
  expect_equal(line_data(sim), want)
  expect_equal(line_data(sim, bin = NULL), want)
})

test_that("invalid bin signals chromodoris_error_input at build", {
  for (w in list(NA, Inf, 0, -1, c(1, 2), "1", list(1))) {
    p <- ggplot(sim, aes(time, value, group = id)) + stat_chromodoris(bin = w)
    expect_error(ggplot_build(p), class = "chromodoris_error_input")
  }
})

test_that("bin without a group mapping errors; one grouped series bins", {
  p <- ggplot(sim, aes(time, value)) + stat_chromodoris(bin = 1)
  expect_error(ggplot_build(p), class = "chromodoris_error_input")
  one <- sim[sim$id == "r01", ]
  expect_equal(unique(one$id), "r01")
  out <- line_data(one, bin = 1)
  expect_equal(nrow(out), 3 * nrow(bin_series(one, id, time, value, width = 1)))
})

test_that("bin with a group coarser than the series warns", {
  p <- ggplot(sim, aes(time, value, group = 1)) + stat_chromodoris(bin = 1)
  expect_warning(ggplot_build(p), class = "chromodoris_warning_input")
  two <- sim
  two$cond <- ifelse(two$id <= "r12", "a", "b")
  p <- ggplot(two, aes(time, value, group = cond)) + stat_chromodoris(bin = 1)
  expect_warning(ggplot_build(p), class = "chromodoris_warning_input")
})

test_that("bin with group = id, or no bin, does not warn", {
  expect_no_warning(line_data(sim, bin = 1))
  expect_no_warning(line_data(sim[sim$id == "r01", ], bin = 1))
  faceted <- rbind(transform(sim, panel = "a"), transform(sim, panel = "b"))
  p <- ggplot(faceted, aes(time, value, group = id)) +
    stat_chromodoris(bin = 1) + facet_wrap(~panel)
  expect_no_warning(ggplot_build(p))
  p <- ggplot(sim, aes(time, value, group = 1)) + stat_chromodoris()
  expect_no_warning(ggplot_build(p))
})

# --- grid --------------------------------------------------------------------
# Oracle for `grid`: summarise_bands() (test-summarise_bands.R) applied at
# each grid point to the output of interpolate_series() (oracles O6, O7).

# sim with irregular, per-rater times and an NA gap (plus an Inf) in r01.
grid_sim <- function() {
  set.seed(20261127)
  d <- sim
  d$time <- d$time + stats::runif(nrow(d), -0.2, 0.2)
  r01 <- which(d$id == "r01")
  d$value[r01[20:25]] <- NA
  d$value[r01[40]] <- Inf
  d
}
grid_pts <- seq(-1, 31, by = 0.25)

bands_from <- function(interp, .width = c(0.5, 0.7, 0.9)) {
  out <- do.call(rbind, lapply(split(interp, interp$time), function(d) {
    b <- summarise_bands(d$value, .width = .width)
    b$x <- d$time[1]
    b
  }))
  out$level <- band_labels(out$.width)
  out[order(-out$.width, out$x), ]
}

test_that("grid equals summarise_bands() over interpolate_series() output", {
  d <- grid_sim()
  for (m in c("linear", "constant")) {
    d_na <- d
    d_na$value[!is.finite(d_na$value)] <- NA
    want <- bands_from(interpolate_series(d_na, id, time, value,
                                          grid = grid_pts, method = m))
    got <- list(
      stat = layer_data(ggplot(d, aes(time, value, group = id)) +
                          stat_chromodoris(grid = grid_pts, interpolate = m), 1),
      wrap = layer_data(chromodoris(d, id, time, value, grid = grid_pts,
                                    interpolate = m), 1)
    )
    for (ld in got) {
      expect_equal(nrow(ld), nrow(want))
      expect_equal(ld$x, want$x)
      expect_equal(as.character(ld$level), want$level)
      expect_equal(ld$ymin, want$ymin)
      expect_equal(ld$ymax, want$ymax)
      expect_equal(ld$center, want$center)
    }
  }
})

test_that("with grid, a missing y is a gap, not bridged or warned about", {
  d <- grid_sim()
  r01 <- d[d$id == "r01", ]
  p <- ggplot(r01, aes(time, value, group = id)) +
    stat_chromodoris(geom = "line", grid = grid_pts)
  expect_no_warning(ld <- layer_data(p, 1))
  gap <- range(r01$time[20:25])
  expect_false(any(ld$x > gap[1] - 0.1 & ld$x < gap[2] + 0.1))
  # The wrapper draws the line at max(.width) only.
  line <- layer_data(chromodoris(d, id, time, value, grid = grid_pts,
                                 interpolate = "constant"), 2)
  expect_equal(unique(line$.width), 0.9)
})

test_that("invalid grid signals chromodoris_error_input from the stat and wrapper", {
  for (g in list(NA_real_, c(0, NA), c(0, Inf), numeric(0), "1", list(1),
                 matrix(c(0, 1)))) {
    p <- ggplot(sim, aes(time, value, group = id)) + stat_chromodoris(grid = g)
    expect_error(ggplot_build(p), class = "chromodoris_error_input")
    expect_error(chromodoris(sim, id, time, value, grid = g),
                 class = "chromodoris_error_input")
  }
  expect_error(stat_chromodoris(grid = 0, interpolate = "spline"),
               "should be one of")
  expect_error(chromodoris(sim, id, time, value, grid = 0,
                           interpolate = "spline"),
               "should be one of")
})

test_that("bin and grid together, or grid without groups, are errors", {
  p <- ggplot(sim, aes(time, value, group = id)) +
    stat_chromodoris(bin = 1, grid = 0:30)
  expect_error(ggplot_build(p), class = "chromodoris_error_input")
  expect_error(ggplot_build(p), "not both")
  expect_error(chromodoris(sim, id, time, value, bin = 1, grid = 0:30),
               class = "chromodoris_error_input")
  p <- ggplot(sim, aes(time, value)) + stat_chromodoris(grid = 0:30)
  expect_error(ggplot_build(p), class = "chromodoris_error_input")
  expect_error(ggplot_build(p), "grid")
})

test_that("a grid outside the data, or an unknown interpolate, is an error", {
  p <- ggplot(sim, aes(time, value, group = id)) +
    stat_chromodoris(grid = 100:110)
  expect_error(ggplot_build(p), class = "chromodoris_error_input")
  expect_error(ggplot_build(chromodoris(sim, id, time, value, grid = -5:-1)),
               class = "chromodoris_error_input")
  p <- ggplot(sim, aes(time, value, group = id)) +
    geom_ribbon(stat = "chromodoris", grid = 0:30, interpolate = "cubic")
  expect_error(ggplot_build(p), class = "chromodoris_error_input")
})

test_that("grid with a group coarser than the series warns", {
  p <- ggplot(sim, aes(time, value, group = 1)) + stat_chromodoris(grid = 0:30)
  expect_warning(ggplot_build(p), class = "chromodoris_warning_input")
  expect_no_warning(line_data(sim, grid = 0:30))
})

test_that("missing times do not set off the duplicate-x warning", {
  d <- data.frame(id = "a", time = c(0, 1, NA, NA), value = 1:4)
  expect_no_warning(ggplot_build(chromodoris(d, id, time, value, grid = 0:1)))
  p <- ggplot(d, aes(time, value, group = id)) +
    stat_chromodoris(bin = 1, na.rm = TRUE)
  expect_no_warning(ggplot_build(p))
})

test_that("grid accepts groups from a discrete aesthetic", {
  p <- ggplot(sim, aes(time, value, colour = id)) +
    stat_chromodoris(geom = "line", .width = 0.9, grid = 0:30)
  expect_equal(layer_data(p)$x, 0:30)
})

test_that("grid interpolates within each facet panel", {
  faceted <- rbind(transform(sim, panel = "a"),
                   transform(sim, panel = "b", value = value + 1))
  p <- ggplot(faceted, aes(time, value, group = id)) +
    stat_chromodoris(geom = "line", .width = 0.9, grid = 0:30) +
    facet_wrap(~panel)
  ld <- layer_data(p, 1)
  a <- ld[ld$PANEL == 1, ]
  b <- ld[ld$PANEL == 2, ]
  expect_equal(a$x, 0:30)
  expect_equal(b$center, a$center + 1)
})
