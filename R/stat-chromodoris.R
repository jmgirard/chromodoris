#' Nested quantile bands across many series at each time point
#'
#' `stat_chromodoris()` pools every series in a panel at each `x` and
#' returns, for each central band width in `.width`, the band's lower and
#' upper edge plus one center value. The default geom is a ribbon. Map
#' `fill = after_stat(level)` to shade the bands, or use the
#' [chromodoris()] wrapper, which does this for you.
#'
#' @section Aesthetics:
#' `stat_chromodoris()` requires `x` (time) and `y` (value). Without `bin`,
#' mapping `group` to a series id is allowed but not needed, because every
#' series in a panel is pooled at each `x`. With `bin` set, `group` must
#' identify the series, because each series is binned on its own before
#' the pooling; a layer with no `group` mapping then signals an error when
#' the plot is built.
#'
#' @section Computed variables:
#' The stat returns one row per (`x`, `level`):
#' - `level`: a factor labelling the band, for example `"90%"`, with the
#'   widest band first.
#' - `.width`: the band width as a number.
#' - `ymin`, `ymax`: the band's lower and upper edge.
#' - `center`: the mean (default) or median of the pooled values. The stat
#'   also sets `y` to the center, so `geom = "line"` draws the center line.
#'   A ribbon geom replaces `y` with `ymin` when it draws.
#'
#' Other aesthetics mapped to the input, such as `colour`, are dropped,
#' because every series is pooled.
#'
#' @inheritParams ggplot2::stat_identity
#' @param .width Numeric vector of central band widths in (0, 1).
#'   Default `c(0.5, 0.7, 0.9)`.
#' @param center One of `"mean"` (default) or `"median"`.
#' @param type Quantile algorithm passed to [stats::quantile()]. Default 7.
#' @param na.rm If `FALSE` (default), missing values are removed with a
#'   warning. If `TRUE`, they are removed silently.
#' @param bin `NULL` (default) to summarise at each observed `x`, or a
#'   single positive number: the bin width in `x` units. Each series is
#'   first averaged within bins of that width, exactly as [bin_series()]
#'   does: bin `k` covers `[k * bin, (k + 1) * bin)`, and the bands are
#'   computed at the bin midpoints `(k + 0.5) * bin`.
#' @return A ggplot2 layer.
#' @examples
#' # 20 raters sampled 10 times per second for 40 seconds (401 points each).
#' set.seed(1)
#' d <- expand.grid(time = seq(0, 40, by = 0.1), id = 1:20)
#' d$value <- sin(d$time / 6) + rnorm(20, sd = 0.3)[d$id] +
#'   ave(rnorm(nrow(d), sd = 0.06), d$id,
#'       FUN = function(e) stats::filter(e, 0.985, method = "recursive"))
#' library(ggplot2)
#' ggplot(d, aes(time, value)) +
#'   stat_chromodoris(aes(fill = after_stat(level)), alpha = 0.8) +
#'   stat_chromodoris(geom = "line", .width = 0.9)
#' # Bin each rater to 0.5-second bins (2 Hz): 81 bins, the last holding
#' # only the sample at 40 s.
#' # With bin set, group must identify the series.
#' ggplot(d, aes(time, value, group = id)) +
#'   stat_chromodoris(aes(fill = after_stat(level)), bin = 0.5) +
#'   stat_chromodoris(geom = "line", .width = 0.9, bin = 0.5)
#' @export
stat_chromodoris <- function(mapping = NULL, data = NULL, geom = "ribbon",
                             position = "identity", ...,
                             .width = c(0.5, 0.7, 0.9),
                             center = c("mean", "median"), type = 7,
                             bin = NULL, na.rm = FALSE, show.legend = NA,
                             inherit.aes = TRUE) {
  center <- match.arg(center)
  layer(
    stat = StatChromodoris, data = data, mapping = mapping, geom = geom,
    position = position, show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(.width = .width, center = center, type = type,
                  bin = bin, na.rm = na.rm, ...)
  )
}

#' @rdname stat_chromodoris
#' @format NULL
#' @usage NULL
#' @export
StatChromodoris <- ggproto(
  "StatChromodoris", Stat,
  required_aes = c("x", "y"),
  dropped_aes = c("colour", "fill", "alpha", "linetype", "linewidth",
                  "size", "shape", "weight"),

  setup_params = function(data, params) {
    check_width(params$.width)
    check_type(params$type)
    check_bin(params$bin, allow_null = TRUE, arg = "bin")
    if (!is.null(params$bin) && all(data$group == -1)) {
      cli_abort(c(
        "{.arg bin} needs {.field group} mapped to the series id.",
        i = "Every series is binned on its own before the bands are computed."
      ), class = "chromodoris_error_input")
    }
    params$.width <- sort(unique(params$.width), decreasing = TRUE)
    params
  },

  compute_panel = function(data, scales, .width = c(0.5, 0.7, 0.9),
                           center = "mean", type = 7, bin = NULL,
                           na.rm = FALSE) {
    labels <- band_labels(.width)
    if (!is.null(bin)) {
      binned <- bin_core(data$group, data$x, data$y, bin)
      data <- data.frame(x = binned$time, y = binned$value,
                         group = binned$id, PANEL = data$PANEL[1])
    }
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
