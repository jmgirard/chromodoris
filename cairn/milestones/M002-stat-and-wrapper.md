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

- [ ] T1: Simulated dataset generator (seeded; `data-raw/` script or test helper) with provenance header.
- [ ] T2: Internal `summarise_bands(values, .width, center, type)` in base R; oracle tests against `stats::quantile` types 7 and 8 and `stats::median` (RB tripwire: no-oracle if a summary beyond quantiles is added).
- [ ] T3: `StatChromodoris` ggproto + `stat_chromodoris()` returning long (x, level, ymin, ymax, center); `layer_data()` tests and the ggdist Suggests test.
- [ ] T4: `chromodoris()` wrapper: tidy-eval column selection, cli input errors of class `chromodoris_error_input`, ribbon + line layers, viridis fill, legend labels and order, theme.
- [ ] T5: vdiffr snapshot test; vdiffr and ggdist to Suggests.
- [ ] T6: Argument-passing tests for `.width`, `center`, `type` on both functions.
- [ ] T7: Roxygen with examples, `_pkgdown.yml` rows, NEWS entry, `document()`/`test()`/`check()`/`check_pkgdown()`.

## Work log

- 2026-09-15: created by /milestone-plan; absorbs ROADMAP candidate "wrap ggdist or reimplement".
- 2026-09-15: criteria audit ran in full mode (shared run with M001; see M001 work log).
- 2026-09-15: plan gate chose base-R reimplementation over wrapping ggdist because Imports stay ggplot2/rlang/cli (DESIGN Conventions); falsified by the base-R summary diverging from the oracle or exceeding ~100 lines.
- 2026-09-15: plan chose a long (x, level) stat output drawn by one ribbon layer over one stat call per width because it mirrors ggplot2 grouping and keeps the wrapper to two layers; falsified by legend or draw-order problems in vdiffr.

## Decisions

## Review
