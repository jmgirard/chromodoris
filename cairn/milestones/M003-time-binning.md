# M003: Time binning

- **Status:** review
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

- [x] AC1: `bin_series(data, id, time, value, width)` is exported. It returns a data frame with the input's `id`, `time`, and `value` column names holding one row per (series, bin) that has at least one non-missing value in that bin, where a row belongs to bin `k = floor(time / width)` as R computes it, `time` is the midpoint `(k + 0.5) * width`, and `value` is the arithmetic mean of that series' non-missing values in the bin. Tests verify this against two oracle types: a hand-computed fixture of three short series whose expected rows are written out in the test, and an independent base-R computation (`tapply()` over the same `k`) on a seeded data set whose series have different lengths and unsorted rows, include NA values, include a bin with no rows and a bin holding only NA for at least one series, and include negative times, a time exactly on a bin boundary, and times that are not multiples of `width` (times are multiples of 1/8 so `k` is exact).
- [x] AC2: When `bin` is a width, `stat_chromodoris()` identifies a series by the `group` aesthetic and bins before summarising: on the seeded `sim_raters()` data, `layer_data()` of a line-geom `stat_chromodoris(bin = w)` layer with `group = id` equals `layer_data()` of the same layer without `bin` drawn on `bin_series()` output at width w, in columns x, ymin, ymax, center, y, and level, for a width that does not divide the grid step and for a width larger than the whole time range (one bin); and `layer_data(chromodoris(d, id, time, value, bin = w), i)` for layers i = 1, 2 equals the corresponding `stat_chromodoris(bin = w)` layer data.
- [x] AC3: The default path is unchanged: `layer_data()` of a line-geom `stat_chromodoris()` layer with `group = id`, and of the same layer with `bin = NULL`, on the seeded `sim_raters()` data equals the fixture `tests/testthat/fixtures/stat-default-48e2e88.rds`, which the committed script `data-raw/stat-default-fixture.R` regenerates from the `R/` tree at commit 48e2e88.
- [x] AC4: A `width` or `bin` other than `NULL` that is not a single finite number greater than zero signals a condition of class `chromodoris_error_input` from `bin_series()`, from `chromodoris()` at call time, and from `stat_chromodoris()` when the plot is built; the probes `NA`, `Inf`, `0`, `-1`, `c(1, 2)`, `"1"`, and `list(1)` are each tested at each of the three entry points. `stat_chromodoris(bin = w)` on a layer whose `group` is ggplot2's no-group sentinel (every row `group == -1`, no discrete aesthetic mapped) signals `chromodoris_error_input` when the plot is built, and a one-series data set with `group` mapped to its id bins without error.
- [x] AC5: The roxygen for `bin_series()`, `stat_chromodoris()`, and `chromodoris()` states the bin rule of AC1 in words; the stat's Aesthetics section says `group` must identify the series when `bin` is set; the README example and both plot functions' `@examples` call `bin = w` with the surrounding sentence giving the width in the data's time units and the resulting number of bins; NEWS.md has an entry for the new function and argument; `bin_series` appears in a `_pkgdown.yml` reference section and `pkgdown::check_pkgdown()` passes.
- [x] AC6: `devtools::document()` produces no diff; `devtools::test()` reports 0 failures and 0 warnings, with skips only for ggdist or vdiffr absent (D-001); `devtools::check()` reports 0 errors, 0 warnings, and no NOTE beyond those present at commit 48e2e88.

## Coverage

- AC1 → T1
- AC2 → T2, T3
- AC3 → T2, T5
- AC4 → T1, T2, T3
- AC5 → T4
- AC6 → T4

## Tasks

- [x] T1: Tests first in `tests/testthat/test-bin_series.R` (oracle header naming the hand-computed and independent-implementation oracles; AC1 probes; AC4 width probes). Implement `R/bin_series.R` with `bin_series()` and `check_bin()` reused by the plot functions; export.
- [x] T2: Record the AC3 fixture from 48e2e88 first. In `R/stat-chromodoris.R` add `bin = NULL` to `stat_chromodoris()` and the params; validate in `setup_params` (lesson: ggplot2 wraps a Stat's `cli_abort`, `expect_error(class =)` still sees it); in `compute_panel` bin per `group` via the AC1 rule before the split-by-x path, aborting on the no-group sentinel; AC2, AC3, AC4 stat tests on line layers (lesson: ribbons overwrite `y`). Check note: `git diff --numstat 48e2e88 -- tests/testthat` shows 0 deletions on the three `.R` files (pre-existing tests appended to, none removed).
- [x] T3: In `R/chromodoris.R` add `bin = NULL`, validate at call time, pass to both layers; AC2 wrapper equality and AC4 call-time tests in `test-chromodoris.R`.
- [x] T4: Docs: roxygen text and examples per AC5, README example at a stated width then `devtools::build_readme()` (lesson: the pre-commit hook refuses stale README.md), NEWS entry, `_pkgdown.yml` row, DESIGN.md Function Families and Architecture updated for the built binning method; `document()`, `test()`, `check()` per AC6.
- [x] T5: Write `data-raw/stat-default-fixture.R`, which extracts the `R/` tree, `DESCRIPTION`, and `NAMESPACE` at commit 48e2e88 with `git archive`, loads that package copy, and writes the line-geom `layer_data()` of the seeded `sim_raters()` data to `tests/testthat/fixtures/stat-default-48e2e88.rds`. Run it and confirm the regenerated file equals the committed fixture. `.Rbuildignore` covers `data-raw`.

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

- 2026-09-15: T4 done: roxygen bin rule and Aesthetics note, examples and README at `bin = 0.5` (81 bins, corrected from a first draft saying 80), README rebuilt, NEWS entry, pkgdown "Preparing data" section, DESIGN Function Families and Architecture updated. `document()` no diff, `test()` 1439 pass 0 fail 0 warn 0 skip, `check()` 0 errors 0 warnings 1 NOTE (the NEWS heading NOTE present at 48e2e88, LESSONS M001).

- 2026-09-15: claim audit: 21 claims read, 2 corrected — README.Rmd, R/stat-chromodoris.R (the "two raters" gloss and the `@param bin` bin rule; both re-read VERIFIED, 0 wrong).
- 2026-09-15: all tasks done; `document()` no diff, `test()` 1439 pass 0 fail, `check()` 0 errors 0 warnings 1 NOTE (NEWS heading, LESSONS M001); status set to review.
- 2026-09-15: review: AC1, AC2, AC4, AC5, AC6 verified with fresh evidence (Review section). amendment return: AC3 — "and `git diff 48e2e88 -- tests/testthat` adds files or adds lines to existing files only, with no deleted lines (0 lines starting with `-` in that diff)". The proposed clause replaces "touches only files this milestone adds", which T2 and T3 contradict by adding tests to test-chromodoris.R and test-stat_chromodoris.R. Status set to in-progress for the amendment alone (amendment-return count 1, defect-return count 0).
- 2026-09-15: mini gate accepted replacing the AC3 diff clause with a no-deleted-lines clause. re-audit: AC3 (full) — unsound "remains unchanged" inference, unbounded "every test", instrument property, unverified fixture provenance, brittle `-` rule, no wrapper fixture. Fixed the first, second, and fifth (numstat wording) before re-entry.
- 2026-09-15: re-audit: AC3 (full) — the criterion names the default ribbon geom, whose `layer_data()` does not equal the line-geom fixture, numstat prints `-` for the binary fixture, instrument property, fixture provenance unverified (PROFILE test-doctrine fixture rule), no wrapper fixture. Second re-audit line, so further AC3 wording went to the user.
- 2026-09-15: user gate: amendment return: AC3 — "`layer_data()` of a line-geom `stat_chromodoris()` layer with `group = id`, and of the same layer with `bin = NULL`, on the seeded `sim_raters()` data equals the fixture `tests/testthat/fixtures/stat-default-48e2e88.rds`, which the committed script `data-raw/stat-default-fixture.R` regenerates from the `R/` tree at commit 48e2e88". The diff check moved to a T2 note. T5 added (generator script) and Coverage AC3 → T2, T5. Wrapper default-path fixture rejected: the wrapper's two layers are tested equal to the stat's layers in test-chromodoris.R, so a regression surfaces there.
- 2026-09-15: T5 done: `data-raw/stat-default-fixture.R` regenerates the fixture from a `git archive` of 48e2e88 (R/, DESCRIPTION, NAMESPACE). The regenerated file is byte-identical to the committed fixture (`identical()` TRUE, `git status` clean on the .rds). `^data-raw$` added to `.Rbuildignore`. `test()` 1439 pass 0 fail 0 warn 0 skip. Claim audit not re-run (one-pass stopping rule). The script header's claims are written from this run's output and the commands above. Status set to review.

## Decisions

## Review

Evidence gathered 2026-09-15 on m003-time-binning at b085a6c, in sync with origin/main (0 behind, 0 ahead).

- AC1: `bin_series` exported (NAMESPACE, `_pkgdown.yml` line 12). test-bin_series.R holds the hand-computed three-series fixture (times include 0.125, -0.25, boundary 0 and 0.5, an all-NA series) and the seeded `tapply()` oracle over `floor(time / width)` on times in multiples of 1/8 from -2 to 6 with unequal series lengths, sampled order, NA values, an all-NA bin, and empty bins. 23 tests pass. PASS.
- AC2: test-stat_chromodoris.R compares line-geom `layer_data()` with `bin = w` against the stat drawn on `bin_series()` output in columns x, ymin, ymax, center, y, level at w = 0.7 (does not divide the grid step 30/59) and w = 100 (one bin, 3 rows). test-chromodoris.R compares `layer_data(chromodoris(..., bin = w), i)` for i = 1, 2 against the matching stat layers. All pass. PASS.
- AC3: `layer_data()` of the default and `bin = NULL` stat equals fixtures/stat-default-48e2e88.rds (test passes). `git diff 48e2e88 -- tests/testthat` lists 4 files: 2 added (the fixture, test-bin_series.R) and 2 modified (test-chromodoris.R +23, test-stat_chromodoris.R +44, 0 deleted lines). The criterion's clause "touches only files this milestone adds" fails as written while T2 and T3 planned those additions. FAIL as written. Amendment return (work log).
- AC4: width probes NA, Inf, 0, -1, c(1, 2), "1", list(1) tested with `expect_error(class = "chromodoris_error_input")` at `bin_series()` (test-bin_series.R:70), `chromodoris()` call time (test-chromodoris.R:98), and `ggplot_build()` of the stat (test-stat_chromodoris.R:147). No-group sentinel layer errors at build and a one-series `group = id` layer bins (test-stat_chromodoris.R:154). PASS.
- AC5: roxygen for `bin_series()` (R/bin_series.R:3-8), `stat_chromodoris()` `@param bin` (R/stat-chromodoris.R:37-41), and `chromodoris()` state the floor/midpoint/mean rule. The stat's Aesthetics section says `group` must identify the series with `bin` set (R/stat-chromodoris.R:12-14). README.Rmd:61 and both `@examples` call `bin = 0.5` with "0.5-second bins (2 Hz), 81 bins". NEWS.md has the entry. `bin_series` is in `_pkgdown.yml`, and `pkgdown::check_pkgdown()` reports no problems. PASS.
- AC6: `devtools::document()` leaves a clean tree. `devtools::test()`: 1439 pass, 0 fail, 0 warn, 0 skip. `devtools::check()`: 0 errors, 0 warnings, 1 NOTE ("No news entries found"), the NOTE present at 48e2e88 (LESSONS M001). PASS.
- Driving RR: none, so projection-vs-outcome is a no-op.
- Consistency gate, pass 1 (partial, run before the stop): `cairn_validate.py` exit 0 with all checks passed, document() no diff, README.md knitted from README.Rmd, pkgdown check clean, NEWS entry present, check() clean. Independent review (step 5) not run, because the review stopped at the AC3 amendment return.

Pass 2, 2026-09-15, at 5be71a7 on the amended AC3, branch in sync with origin/main (0 behind, 0 ahead).

- AC1 (pass 2): re-run, 23 tests in test-bin_series.R pass, same probes as pass 1. PASS.
- AC2 (pass 2): re-run, the width 0.7 and 100 equality tests and the wrapper layer tests pass (39 tests in test-chromodoris.R). PASS.
- AC3 (pass 2, amended wording): test "the default path equals the fixture recorded at 48e2e88" (test-stat_chromodoris.R:141) compares the line-geom `group = id` layer, bare and with `bin = NULL`, to fixtures/stat-default-48e2e88.rds and passes. Running `data-raw/stat-default-fixture.R` regenerated the fixture from a `git archive` of 48e2e88 (180 rows), and `identical()` against the committed file is TRUE, with `git status` clean on the .rds. PASS.
- AC4 (pass 2): re-run, the width and bin probes and the sentinel tests pass at all three entry points. PASS.
- AC5 (pass 2): roxygen, README, NEWS, and `_pkgdown.yml` unchanged since pass 1, `pkgdown::check_pkgdown()` reports no problems. PASS.
- AC6 (pass 2): `document()` 0 changed files, `test()` 1439 pass 0 fail 0 warn 0 skip, `check()` 0 errors 0 warnings 1 NOTE (the NEWS heading NOTE present at 48e2e88, LESSONS M001). PASS.
- Consistency gate, pass 2: `cairn_validate.py` exit 0 with all checks passed, no DESIGN principle changed so `cairn_impact` is skipped, document() no diff, generated files untouched by hand (NAMESPACE and man/ regenerate clean), README.md knitted from README.Rmd, pkgdown check clean, NEWS entry present with no milestone numbers, `^data-raw$` in `.Rbuildignore`, check() clean with the one justified NOTE. PASS.
