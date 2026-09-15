# chromodoris (development version)

* New `chromodoris()` draws the Chromodoris plot from long data in one call:
  nested quantile ribbons (default 50%, 70%, 90%) around a mean or median
  center line, with a viridis fill scale and `theme_minimal()`. Errors about
  `data`, its columns, or `.width` signal a condition of class
  `chromodoris_error_input`.
* New `stat_chromodoris()` computes the bands and center inside any ggplot2
  pipeline. Arguments `.width`, `center`, and `type` are shared with the
  wrapper.
* Package skeleton.
