#' Nested quantile bands across many series at each time point
#'
#' `stat_chromodoris()` pools every series in a panel at each `x` and
#' returns, for each central band width in `.width`, the band's lower and
#' upper edge plus one center value. The default geom is a ribbon. Map
#' `fill = after_stat(level)` to shade the bands, or use the
#' [chromodoris()] wrapper, which does this for you.
#'
#' @section Aesthetics:
#' `stat_chromodoris()` requires `x` (time) and `y` (value). Mapping
#' `group` to a series id is allowed but not needed, because every series
#' in a panel is pooled at each `x`.
#'
#' @section Computed variables:
#' The stat returns one row per (`x`, `level`):
#' - `level`: a factor labelling the band, for example `"90%"`, with the
#'   widest band first.
#' - `.width`: the band width as a number.
#' - `ymin`, `ymax`: the band's lower and upper edge.
#' - `center`: the mean (default) or median of the pooled values. It is
#'   also returned as `y`, so `geom = "line"` draws the center line.
#'
#' @inheritParams ggplot2::stat_identity
#' @param .width Numeric vector of central band widths in (0, 1).
#'   Default `c(0.5, 0.7, 0.9)`.
#' @param center One of `"mean"` (default) or `"median"`.
#' @param type Quantile algorithm passed to [stats::quantile()]. Default 7.
#' @param na.rm If `FALSE` (default), missing values are removed with a
#'   warning. If `TRUE`, they are removed silently.
#' @return A ggplot2 layer.
#' @examples
#' set.seed(1)
#' d <- expand.grid(id = 1:20, time = 1:40)
#' d$value <- sin(d$time / 6) + rnorm(nrow(d), sd = 0.5)
#' library(ggplot2)
#' ggplot(d, aes(time, value)) +
#'   stat_chromodoris(aes(fill = after_stat(level)), alpha = 0.8) +
#'   stat_chromodoris(geom = "line", .width = 0.9)
#' @export
stat_chromodoris <- function(mapping = NULL, data = NULL, geom = "ribbon",
                             position = "identity", ...,
                             .width = c(0.5, 0.7, 0.9),
                             center = c("mean", "median"), type = 7,
                             na.rm = FALSE, show.legend = NA,
                             inherit.aes = TRUE) {
  center <- match.arg(center)
  layer(
    stat = StatChromodoris, data = data, mapping = mapping, geom = geom,
    position = position, show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(.width = .width, center = center, type = type,
                  na.rm = na.rm, ...)
  )
}

#' @rdname stat_chromodoris
#' @format NULL
#' @usage NULL
#' @export
StatChromodoris <- ggproto(
  "StatChromodoris", Stat,
  required_aes = c("x", "y"),

  setup_params = function(data, params) {
    w <- params$.width
    if (!is.numeric(w) || length(w) == 0 || any(w <= 0 | w >= 1)) {
      cli_abort("{.arg .width} must be numeric with every value in (0, 1).")
    }
    params$.width <- sort(unique(w), decreasing = TRUE)
    params
  },

  compute_panel = function(data, scales, .width = c(0.5, 0.7, 0.9),
                           center = "mean", type = 7, na.rm = FALSE) {
    labels <- band_labels(.width)
    pieces <- lapply(split(data, data$x), function(d) {
      bands <- summarise_bands(d$y, .width = .width, center = center,
                               type = type)
      bands$x <- d$x[1]
      bands$PANEL <- d$PANEL[1]
      bands
    })
    out <- do.call(rbind, pieces)
    rownames(out) <- NULL
    out$level <- factor(labels[match(out$.width, .width)], levels = labels)
    out$group <- as.integer(out$level)
    out$y <- out$center
    out[order(out$group, out$x), ]
  }
)

band_labels <- function(.width) {
  paste0(round(100 * .width), "%")
}
