# Regenerates tests/testthat/fixtures/stat-default-48e2e88.rds.
#
# Source: the package as committed at 48e2e88, the commit the fixture is
# recorded from, loaded from a `git archive` export of that commit's R/,
# DESCRIPTION, and NAMESPACE. Data: sim_raters() from
# tests/testthat/helper-sim.R with its default seed (20260915).
# Output: layer_data() of a line-geom stat_chromodoris() layer with
# group = id, which the AC3 default-path test compares against.
#
# Run from the package root: Rscript data-raw/stat-default-fixture.R

commit <- "48e2e88"
out <- file.path("tests", "testthat", "fixtures", "stat-default-48e2e88.rds")

tmp <- tempfile("chromodoris-")
dir.create(tmp)
status <- system2(
  "sh", c("-c", shQuote(sprintf(
    "git archive %s R DESCRIPTION NAMESPACE | tar -x -C %s", commit, tmp
  )))
)
stopifnot(status == 0)

pkgload::load_all(tmp, quiet = TRUE)
source(file.path("tests", "testthat", "helper-sim.R"))
library(ggplot2)

sim <- sim_raters()
p <- ggplot(sim, aes(time, value, group = id)) +
  stat_chromodoris(geom = "line")
fixture <- layer_data(p, 1)

saveRDS(fixture, out, version = 2)
cat("wrote", out, "with", nrow(fixture), "rows\n")
