# chromodoris (development version)

* New `interpolate_series()` evaluates each series at the times in `grid`, so
  series sampled at different times share time points. `grid` is a numeric
  vector of finite times; the function sorts it and drops duplicates, so any
  order is fine. With `method = "linear"`, a grid point takes the value on
  the straight line between the observations on either side of it; with
  `"constant"`, it takes the last observation at or before it. Nothing is
  extrapolated: a grid point outside a series' observed time range, or one
  computed from a missing value, gives no row for that series. Within a
  series, rows with a missing time are dropped and rows that repeat a time
  are averaged first. `stat_chromodoris()` and `chromodoris()` gain `grid`
  and `interpolate` arguments (`interpolate` takes the same `"linear"` or
  `"constant"` values as `method`) that apply the same rule to each series
  before the bands are computed. With `grid` set, the stat needs a group for
  each series (map `group` to the series id, or map a discrete aesthetic such
  as `colour` to it). Rows with a missing `x` are dropped, and a missing `y`
  leaves that series out of the bands at the grid points it affects; neither
  gives ggplot2's warning about removed rows. A grid point where no series
  has a value gets no bands; between two grid points that have bands, the
  ribbons and center line are drawn straight across it. `grid` is not
  transformed with `x`, so it is not supported with a transformed x scale
  such as `scale_x_log10()` or `scale_x_reverse()`. Setting both
  `bin` and `grid`, an invalid `grid`, a `grid` with no point inside the
  range of `x` in the plot functions, a layer with `grid` set but no groups,
  or an infinite time or value in `interpolate_series()` signals
  `chromodoris_error_input`.
* New vignette, `vignette("chromodoris")`, shows how to plot continuous
  ratings from many raters: binning, faceting clips, choosing `.width` and
  `center`, building from `stat_chromodoris()`, and what the bands miss.
* With `bin` set, `stat_chromodoris()` warns (`chromodoris_warning_input`)
  when a group has several rows at one raw `x` in a panel, as when series
  sampled at the same times share a `group` (a constant, or a condition) or a
  series repeats a time. Each group is averaged into one series before the
  bands are computed, so the bands show the spread of group means, not of
  series; map `group` to the series id. Series in a group that share a bin
  but no `x` are still averaged together, without a warning.
* New `bin_series()` averages each series within fixed-width time bins
  (bin `k` covers `[k * width, (k + 1) * width)`, rows sit at bin midpoints).
  `stat_chromodoris()` and `chromodoris()` gain a `bin` argument that applies
  the same rule before the bands are computed; with `bin` set, the stat
  needs `group` mapped to the series id. An invalid `bin` or `width` signals
  `chromodoris_error_input`.
* New `chromodoris()` draws the Chromodoris plot from long data in one call:
  nested quantile ribbons (default 50%, 70%, 90%) around a mean or median
  center line, with a viridis fill scale and `theme_minimal()`. Errors about
  `data`, its columns, `.width`, or `type` signal a condition of class
  `chromodoris_error_input`.
* New `stat_chromodoris()` computes the bands and center inside any ggplot2
  pipeline. Arguments `.width`, `center`, and `type` are shared with the
  wrapper.
* Package skeleton.
