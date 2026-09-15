# Design

## Purpose & Scope

<!-- Elicited by /design-interview on 2026-09-15 (Phase 1). -->

chromodoris is a ggplot2 extension for one plot type, the Chromodoris plot:
many time series (one per participant or unit) summarized moment by moment
as nested quantile ribbons (for example inner 90%, 70%, 50%) around a center
line. It replaces the spaghetti plot of overlaid series with a distributional
summary that reads at a glance.

- **Audience.** R users broadly, not only the author's group.
- **Contract boundary.** Layered. A low-level `Stat` computes the bands from
  long data inside a ggplot pipeline; a high-level wrapper draws the whole
  plot with opinionated scales and theme. Users can drop to the stat.
- **What earns a place.** Every capability must serve the Chromodoris plot.
  General time-series tools and sibling plot types live elsewhere.
- **Niche beside ggdist.** ggdist's `stat_lineribbon` draws nested bands
  already. chromodoris earns its place through defaults for dense time
  series: a fixed band set, a sequential fill scale, and alignment of
  ragged, unaligned timestamps onto a common grid.
- **Distribution.** GitHub-only for now (2026-09-15). CRAN is not ruled out.
- **Stability.** Free to break until 1.0; NEWS.md records every break.

## Function Families

_Planned, not built:_

- **Alignment.** Put many series with different timestamps and lengths onto
  a common time grid (binning or interpolation, user-settable).
- **Summary.** Per-grid-point quantile bands and a center line (mean or
  median).
- **Layer.** A ggplot2 `Stat` that feeds `geom_ribbon`, plus the wrapper.

## Conventions

- **Input contract.** Long data with columns for series id, time, and value.
  Any timestamps; the package aligns them.
- **Numeric work is oracle-verified.** Band edges and the center line are
  tested against an independent reference (base `quantile()`, ggdist) at
  the ≥2-types bar (D-024/D-025 doctrine). Supersedes the init-time
  "no numeric work" line.
- **Dependencies.** Imports: ggplot2, rlang, cli. Alignment and quantiles
  in base R. No ggdist, distributional, dplyr, or tidyr in Imports.
- **Pure R.** No compiled code (reversible default, 2026-09-15).
- Toolchain conventions (testthat 3e, roxygen, cli conditions, NEWS.md)
  live in `cairn/PROFILE.md`.

## Design Principles

<!-- IP<n> = Inviolable (hard constraint) first, then GP<n> = Guiding
     (tradeable with justification). Numbers are never reused. -->

### Inviolable

_None adopted yet. Phase 2 was deferred on 2026-09-15 until the package
exists (see ROADMAP candidate). The ledger below stays banked._

### Guiding

_None adopted yet._

### Banked candidates (Phase 1 ledger, consumed by Phase 2)

- One plot type: every capability serves the Chromodoris plot.
- Composable: the stat works in any ggplot pipeline; the wrapper is sugar.
- Light dependencies: base R for the math, ggplot2/rlang/cli only.
- Summaries are honest: never smooth or otherwise alter the quantiles; the
  bands show the data, jagged where the data is stepped.
- Bands declare their support: where fewer series contribute (ragged ends)
  or values sit on a scale bound, the plot must show it, not hide it.
- Alignment is explicit: the grid and method are visible parameters, never
  a silent default that changes the picture.
- Numeric results are oracle-verified.

## Architecture

_Nothing built yet._

## Known issues

_Known fragilities, recorded at design time, not yet observed in code:_

- Ragged ends: tail bands come from fewer series and look narrower for the
  wrong reason.
- Scale-bound clipping: when values hit a floor or ceiling (the example
  rests on -4), the outer band lies flat on the bound and misleads.
- Step data: ratings that move in steps give jagged bands; smoothing would
  change the summary.
- Alignment sensitivity: bin width and interpolation method change the
  picture, and there is no obvious default.
