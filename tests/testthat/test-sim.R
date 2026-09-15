test_that("sim_raters() is seeded and has the promised shape", {
  d <- sim_raters()
  expect_equal(length(unique(d$id)), 24)
  expect_equal(length(unique(d$time)), 60)
  expect_equal(nrow(d), 24 * 60)
  expect_equal(d, sim_raters())
  expect_false(isTRUE(all.equal(d$value, sim_raters(seed = 1)$value)))
})
