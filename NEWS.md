# chromodoris (development version)

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
