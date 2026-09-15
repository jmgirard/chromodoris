# M002: First stat and wrapper

- **Status:** in-progress
- **Priority:** high
- **Depends on:** M001
- **Driving RR:** —
- **Principles touched:** —
- **Resolves:** —
- **Surface tier:** user-facing — the two exported functions are the package's API
- **Branch/PR:** m002-stat-and-wrapper

## Goal

Export `stat_chromodoris()` and `chromodoris()` so aligned multi-rater data becomes the nested-ribbon plot with one call.

## Scope

**In:** a ggplot2 Stat computing per-time quantile bands and a center in base
R; a wrapper applying the default fill scale, legend, and theme; input
errors via cli; oracle tests; pkgdown rows; NEWS entry.

**Out:** alignment of unshared timestamps, ragged-end support marking, and
bound-clipping display → candidate rows (DESIGN Known issues). Wrapping
ggdist → rejected at the M002 plan gate (work log); ggdist stays in
Suggests as a test oracle only. Vignette → candidate row.

## Acceptance criteria

- [ ] AC1: `stat_chromodoris()` with aesthetics x = time, y = value, group = rater id yields, via `layer_data()`, one row per (x, level) with `ymin`, `ymax`, and `center`; for every unique x in the simulated dataset (>= 20 raters, >= 50 time points, committed generator in `data-raw/` or a seeded helper in tests) `ymin`/`ymax` equal `stats::quantile(values_at_x, probs, type = t)` for probs (.05,.95), (.15,.85), (.25,.75) and t in c(7, 8) via a `type` argument, `center` equals `mean(values_at_x)` by default and `stats::median(values_at_x)` with `center = "median"`; a second test compares the type-7 result to `ggdist::mean_qi()` at `.width = c(.5, .7, .9)`.
- [ ] AC2: `chromodoris(data, id, time, value)` returns a ggplot object whose layers are one ribbon layer built on `stat_chromodoris()` and one line layer, with a discrete viridis fill scale whose legend reads `90%`, `70%`, `50%` top to bottom; a `vdiffr::expect_doppelganger()` snapshot on the simulated dataset is committed.
- [ ] AC3: `.width` (default `c(.5, .7, .9)`), `center = c("mean", "median")`, and `type` are arguments on both functions; `chromodoris()` raises a `cli::cli_abort()` condition of class `chromodoris_error_input` when `id`, `time`, or `value` is not a column of `data` or `time`/`value` is not numeric, tested with `expect_error(class = )`.
- [ ] AC4: `devtools::document()` produces no diff, `devtools::test()` passes, and `devtools::check()` reports 0 errors, 0 warnings, and no NOTE beyond those justified in M001.
- [ ] AC5: Both exported functions have `_pkgdown.yml` reference rows, `pkgdown::check_pkgdown()` passes, roxygen examples run under `devtools::run_examples()`, and NEWS.md has an entry describing them.

## Coverage

- AC1 → T1, T2, T3
- AC2 → T4, T5
- AC3 → T2, T4, T6
- AC4 → T7
- AC5 → T7

## Tasks

- [x] T1: Simulated dataset generator (seeded; `data-raw/` script or test helper) with provenance header.
- [x] T2: Internal `summarise_bands(values, .width, center, type)` in base R; oracle tests against `stats::quantile` types 7 and 8 and `stats::median` (RB tripwire: no-oracle if a summary beyond quantiles is added).
- [x] T3: `StatChromodoris` ggproto + `stat_chromodoris()` returning long (x, level, ymin, ymax, center); `layer_data()` tests and the ggdist Suggests test.
- [x] T4: `chromodoris()` wrapper: tidy-eval column selection, cli input errors of class `chromodoris_error_input`, ribbon + line layers, viridis fill, legend labels and order, theme.
- [x] T5: vdiffr snapshot test; vdiffr and ggdist to Suggests.
- [x] T6: Argument-passing tests for `.width`, `center`, `type` on both functions.
- [ ] T7: Roxygen with examples, `_pkgdown.yml` rows, NEWS entry, `document()`/`test()`/`check()`/`check_pkgdown()`.

## Work log

- 2026-09-15: created by /milestone-plan; absorbs ROADMAP candidate "wrap ggdist or reimplement".
- 2026-09-15: criteria audit ran in full mode (shared run with M001; see M001 work log).
- 2026-09-15: plan gate chose base-R reimplementation over wrapping ggdist because Imports stay ggplot2/rlang/cli (DESIGN Conventions); falsified by the base-R summary diverging from the oracle or exceeding ~100 lines.
- 2026-09-15: plan chose a long (x, level) stat output drawn by one ribbon layer over one stat call per width because it mirrors ggplot2 grouping and keeps the wrapper to two layers; falsified by legend or draw-order problems in vdiffr.

- 2026-09-15: implement started on branch m002-stat-and-wrapper. Question gate outcomes: vdiffr and ggdist go to Suggests (D-001). The line layer reuses the stat with the widest band only. The simulated dataset is a seeded test helper, and examples simulate inline. The wrapper theme is theme_minimal with legend title "Band".
- 2026-09-15: T1 done. tests/testthat/helper-sim.R adds sim_raters() (24 raters, 60 time points, seed 20260915) with a provenance header and a shape test.
- 2026-09-15: T2 done. R/summarise_bands.R (23 lines) with oracle tests against stats::quantile types 7 and 8 (live) and hand-computed type-7 edges on 1:10 (closed-form). No summary beyond quantiles, mean, and median was added, so the no-oracle tripwire did not fire. DESIGN Conventions now names where oracle records live (test file headers).
- 2026-09-15: T3 done. R/stat-chromodoris.R exports stat_chromodoris() and StatChromodoris. compute_panel pools all series per x, so a group aesthetic is allowed but not needed. Output is long (x, level, ymin, ymax, center) with level a factor widest first and group set to the level index. layer_data tests cover types 7 and 8, both centers, and a live ggdist::mean_qi() comparison per x.
- 2026-09-15: T4 done. R/chromodoris.R exports chromodoris() with ensym column capture, check_input() raising chromodoris_error_input, a ribbon layer and a line layer on the stat, scale_fill_viridis_d(name = "Band"), and theme_minimal(). Mapping y = after_stat(center) on the line layer removed the input y, so the stat now also returns y = center and the line layer maps nothing. Rendered plot checked by eye.
- 2026-09-15: T5 done. vdiffr and ggdist added to Suggests (D-001). tests/testthat/test-snapshot.R commits chromodoris-default.svg. The snapshot was shown to fail on a planted .width change before the real plot was pinned.
- 2026-09-15: T6 done. tests/testthat/test-arguments.R checks that .width, center, and type reach the computation from both functions and the wrapper's line layer, against stats::quantile, mean, and median at one time point.

## Decisions

## Review
