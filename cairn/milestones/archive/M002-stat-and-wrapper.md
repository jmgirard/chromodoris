# M002: First stat and wrapper

**Status:** done (2026-09-15, PR #2 https://github.com/jmgirard/chromodoris/pull/2)

**Goal:** Export `stat_chromodoris()` and `chromodoris()` so aligned multi-rater data becomes the nested-ribbon plot with one call.

**Outcome:** R/summarise_bands.R computes band edges with `stats::quantile()` and a mean
or median center in base R. R/stat-chromodoris.R exports `StatChromodoris` and
`stat_chromodoris()`. The stat pools every series per x and returns long rows
(x, level, ymin, ymax, center, y = center), level a factor widest first, with
non-positional aesthetics declared dropped. R/chromodoris.R exports `chromodoris()`
with ensym column capture, `check_input()`, `check_width()`, and `check_type()`
raising `chromodoris_error_input`, a ribbon and a line layer on the stat, viridis
fill with legend "Band", and `theme_minimal()`. Tests: seeded `sim_raters()` helper,
oracles `stats::quantile()` types 7 and 8 and `ggdist::mean_qi()`, a vdiffr snapshot.
pkgdown rows, NEWS, README figure, and the pkgdown url set ahead of the site.

**Decisions:** D-001 (vdiffr and ggdist in Suggests).

**Review:** three-lens fan-out. Diff lens returned nine findings. Four fixed on the
branch: colliding .width labels, `type` validated at call time, `dropped_aes`
declared, the y-equals-center doc line. Three deferred to candidate rows: all-missing
time points, single-series zero-height bands, duplicate (id, time) rows. Two
rejected: unreachable all-NA `summarise_bands()`, unvalidated center off the
documented path. History and prior-review lenses found nothing. Nothing retired.
