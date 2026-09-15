# chromodoris (development version)

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
