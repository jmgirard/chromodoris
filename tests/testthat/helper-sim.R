# Provenance: simulated multi-rater data for the chromodoris test suite.
# Source: none (synthetic). Generator: this file, sim_raters(). Seed: the
# `seed` argument (default 20260915). Regenerate by calling sim_raters()
# with the same arguments. Values follow a shared smooth signal plus a
# per-rater offset and per-observation noise, on a common time grid.
sim_raters <- function(n_raters = 24, n_time = 60, seed = 20260915) {
  set.seed(seed)
  time <- seq(0, 30, length.out = n_time)
  signal <- 2 * sin(time / 4)
  offset <- stats::rnorm(n_raters, sd = 0.8)
  data.frame(
    id = rep(sprintf("r%02d", seq_len(n_raters)), each = n_time),
    time = rep(time, times = n_raters),
    value = rep(signal, times = n_raters) +
      rep(offset, each = n_time) +
      stats::rnorm(n_raters * n_time, sd = 0.5),
    stringsAsFactors = FALSE
  )
}
