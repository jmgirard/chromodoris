# M003: Time binning

- **Status:** in-progress
- **Priority:** high
- **Depends on:** —
- **Driving RR:** —
- **Principles touched:** —
- **Resolves:** —
- **Surface tier:** user-facing — exports `bin_series()` and a `bin` argument on both plot functions
- **Branch/PR:** m003-time-binning

## Goal

Let users bin every series onto a common time grid of a stated width before the bands are computed, so continuous ratings sampled faster than they vary plot as readable ribbons.

## Scope

**In:** an exported `bin_series(data, id, time, value, width)` that averages each series within fixed-width time bins; a `bin` argument on `stat_chromodoris()` and `chromodoris()` that applies the same rule before summarising; input validation; docs, examples, README figure at a stated width; NEWS; pkgdown reference.

**Out:** interpolation onto a grid → ROADMAP candidate row (narrowed from the absorbed alignment row). Smoothing of band edges → rejected at the 2026-09-15 plan gate (work log). Other in-bin summaries than the mean → not planned. Ragged-end marking, bound clipping, duplicate (id, time) check → their own candidate rows.

## Acceptance criteria

- [ ] AC1: `bin_series(data, id, time, value, width)` is exported. It returns a data frame with the input's `id`, `time`, and `value` column names holding one row per (series, bin) that has at least one non-missing value in that bin, where a row belongs to bin `k = floor(time / width)` as R computes it, `time` is the midpoint `(k + 0.5) * width`, and `value` is the arithmetic mean of that series' non-missing values in the bin. Tests verify this against two oracle types: a hand-computed fixture of three short series whose expected rows are written out in the test, and an independent base-R computation (`tapply()` over the same `k`) on a seeded data set whose series have different lengths and unsorted rows, include NA values, include a bin with no rows and a bin holding only NA for at least one series, and include negative times, a time exactly on a bin boundary, and times that are not multiples of `width` (times are multiples of 1/8 so `k` is exact).
- [ ] AC2: When `bin` is a width, `stat_chromodoris()` identifies a series by the `group` aesthetic and bins before summarising: on the seeded `sim_raters()` data, `layer_data()` of a line-geom `stat_chromodoris(bin = w)` layer with `group = id` equals `layer_data()` of the same layer without `bin` drawn on `bin_series()` output at width w, in columns x, ymin, ymax, center, y, and level, for a width that does not divide the grid step and for a width larger than the whole time range (one bin); and `layer_data(chromodoris(d, id, time, value, bin = w), i)` for layers i = 1, 2 equals the corresponding `stat_chromodoris(bin = w)` layer data.
- [ ] AC3: The default path is unchanged: `layer_data()` of `stat_chromodoris()` and of `stat_chromodoris(bin = NULL)` on the seeded `sim_raters()` data equals a fixture recorded from commit 48e2e88 and stored under `tests/testthat`, and `git diff 48e2e88 -- tests/testthat` touches only files this milestone adds.
- [ ] AC4: A `width` or `bin` other than `NULL` that is not a single finite number greater than zero signals a condition of class `chromodoris_error_input` from `bin_series()`, from `chromodoris()` at call time, and from `stat_chromodoris()` when the plot is built; the probes `NA`, `Inf`, `0`, `-1`, `c(1, 2)`, `"1"`, and `list(1)` are each tested at each of the three entry points. `stat_chromodoris(bin = w)` on a layer whose `group` is ggplot2's no-group sentinel (every row `group == -1`, no discrete aesthetic mapped) signals `chromodoris_error_input` when the plot is built, and a one-series data set with `group` mapped to its id bins without error.
- [ ] AC5: The roxygen for `bin_series()`, `stat_chromodoris()`, and `chromodoris()` states the bin rule of AC1 in words; the stat's Aesthetics section says `group` must identify the series when `bin` is set; the README example and both plot functions' `@examples` call `bin = w` with the surrounding sentence giving the width in the data's time units and the resulting number of bins; NEWS.md has an entry for the new function and argument; `bin_series` appears in a `_pkgdown.yml` reference section and `pkgdown::check_pkgdown()` passes.
- [ ] AC6: `devtools::document()` produces no diff; `devtools::test()` reports 0 failures and 0 warnings, with skips only for ggdist or vdiffr absent (D-001); `devtools::check()` reports 0 errors, 0 warnings, and no NOTE beyond those present at commit 48e2e88.

## Coverage

- AC1 → T1
- AC2 → T2, T3
- AC3 → T2
- AC4 → T1, T2, T3
- AC5 → T4
- AC6 → T4

## Tasks

- [x] T1: Tests first in `tests/testthat/test-bin_series.R` (oracle header naming the hand-computed and independent-implementation oracles; AC1 probes; AC4 width probes). Implement `R/bin_series.R` with `bin_series()` and `check_bin()` reused by the plot functions; export.
- [x] T2: Record the AC3 fixture from 48e2e88 first. In `R/stat-chromodoris.R` add `bin = NULL` to `stat_chromodoris()` and the params; validate in `setup_params` (lesson: ggplot2 wraps a Stat's `cli_abort`, `expect_error(class =)` still sees it); in `compute_panel` bin per `group` via the AC1 rule before the split-by-x path, aborting on the no-group sentinel; AC2, AC3, AC4 stat tests on line layers (lesson: ribbons overwrite `y`).
- [x] T3: In `R/chromodoris.R` add `bin = NULL`, validate at call time, pass to both layers; AC2 wrapper equality and AC4 call-time tests in `test-chromodoris.R`.
- [ ] T4: Docs: roxygen text and examples per AC5, README example at a stated width then `devtools::build_readme()` (lesson: the pre-commit hook refuses stale README.md), NEWS entry, `_pkgdown.yml` row, DESIGN.md Function Families and Architecture updated for the built binning method; `document()`, `test()`, `check()` per AC6.

## Work log

- 2026-09-15: created by /milestone-plan from the user's request to reduce README jaggedness; the user's own practice bins ratings to 2 Hz.
- 2026-09-15: criteria audit ran in full mode (user-facing tier) by a fresh reader; returned findings on AC1–AC6 (float-exact bin index, probe variety, group aesthetic, AC3 tautology, NULL exemption, sentinel group, instrument-bound AC6); each fixed in the wording above.
- 2026-09-15: plan gate chose per-series binning to a stated width over smoothing the computed band edges because the banked principle "summaries are honest" forbids altering quantiles and the user's practice is binning; falsified by a use case where bins at any width still hide the signal users need.
- 2026-09-15: plan gate chose an exported `bin_series()` plus a `bin` argument over an argument-only or function-only home because the function makes the rule oracle-testable and the argument keeps the one-call wrapper; falsified by users never calling `bin_series()` directly.
- 2026-09-15: plan gate chose bin midpoints for binned rows over bin starts because the ribbon then spans the interval it summarises; the user asked for edges visible on the axis, which default breaks give whenever the width divides the break spacing; falsified by a README figure whose breaks fall inside bins.
- 2026-09-15: plan gate chose width in time units over a rate in Hz because the package cannot check the time unit; falsified by users repeatedly converting Hz by hand.
- 2026-09-15: absorbed the ROADMAP candidate row "Alignment of unshared timestamps onto a grid (binning/interpolation), optional layer"; its interpolation half stays as a narrowed candidate row.

- 2026-09-15: T1 done: `bin_series()`, `bin_core()`, `check_bin()` in R/bin_series.R; tests against the hand-computed and tapply() oracles pass. AC3 fixture recorded from the R/ tree at 48e2e88 (verified equal by `git diff --quiet 48e2e88 -- R/`) into tests/testthat/fixtures/stat-default-48e2e88.rds.

- 2026-09-15: T2 done: `bin` on `stat_chromodoris()`, validated in `setup_params` with the no-group sentinel check; `compute_panel` bins per group via `bin_core()`. AC2 equality at widths 0.7 and 100, AC3 fixture equality, AC4 build-time probes pass.

- 2026-09-15: T3 done: `bin = NULL` on `chromodoris()`, validated at call time, passed to both layers; wrapper equality and call-time probe tests pass.

## Decisions

## Review
