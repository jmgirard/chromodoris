#' Summarise one time point's values into nested bands and a center
#'
#' Internal helper. For a numeric vector of values observed at one time
#' point, computes the lower and upper edge of each central band named by
#' `.width` and one center value.
#'
#' @param values Numeric vector. Missing values are dropped.
#' @param .width Numeric vector of central band widths in (0, 1). A width
#'   of 0.9 spans the 0.05 and 0.95 quantiles.
#' @param center One of `"mean"` or `"median"`.
#' @param type Quantile algorithm passed to [stats::quantile()].
#' @return A data frame with one row per band, in the order of `.width`,
#'   and columns `.width`, `ymin`, `ymax`, `center`.
#' @noRd
summarise_bands <- function(values, .width = c(0.5, 0.7, 0.9),
                            center = c("mean", "median"), type = 7) {
  center <- match.arg(center)
  values <- values[!is.na(values)]
  lower <- (1 - .width) / 2
  upper <- 1 - lower
  ymin <- stats::quantile(values, probs = lower, type = type, names = FALSE)
  ymax <- stats::quantile(values, probs = upper, type = type, names = FALSE)
  ctr <- if (center == "mean") mean(values) else stats::median(values)
  data.frame(
    .width = .width,
    ymin = ymin,
    ymax = ymax,
    center = rep(ctr, length(.width))
  )
}
