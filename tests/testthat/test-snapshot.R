# Oracle: none. A vdiffr snapshot pins the drawn plot; the band numbers are
# oracle-tested in test-stat_chromodoris.R.

test_that("chromodoris() draws the expected plot on the simulated data", {
  skip_if_not_installed("vdiffr")
  p <- chromodoris(sim_raters(), id, time, value)
  vdiffr::expect_doppelganger("chromodoris-default", p)
})
