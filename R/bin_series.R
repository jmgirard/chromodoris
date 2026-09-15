#' Bin every series onto a common time grid
#'
#' `bin_series()` averages each series within fixed-width time bins, so
#' series sampled faster than they vary become one value per bin. A time
#' `t` belongs to bin `k = floor(t / width)`, which covers
#' `[k * width, (k + 1) * width)`. The binned row carries the bin midpoint
#' `(k + 0.5) * width` as its time and the arithmetic mean of the series'
#' non-missing values in the bin as its value. A bin with no non-missing
#' value for a series yields no row for that series.
#'
#' [stat_chromodoris()] and [chromodoris()] apply the same rule through
#' their `bin` argument.
#'
#' @inheritParams chromodoris
#' @param width A single positive number: the bin width in the units of
#'   `time`. Ratings sampled in seconds and binned to 2 Hz use
#'   `width = 0.5`.
#' @return A data frame with the `id`, `time`, and `value` columns of
#'   `data` (same names), one row per series and non-empty bin, sorted by
#'   series then time.
#' @examples
#' d <- data.frame(id = rep(c("a", "b"), each = 4),
#'                 time = rep(c(0, 0.25, 0.5, 0.75), 2),
#'                 value = 1:8)
#' bin_series(d, id, time, value, width = 0.5)
#' @export
bin_series <- function(data, id, time, value, width) {
  id <- rlang::as_name(rlang::ensym(id))
  time <- rlang::as_name(rlang::ensym(time))
  value <- rlang::as_name(rlang::ensym(value))
  check_input(data, id, time, value)
  check_bin(width)
  out <- bin_core(data[[id]], data[[time]], data[[value]], width)
  names(out) <- c(id, time, value)
  out
}

# Shared by bin_series() and StatChromodoris: returns a data frame with
# columns id, time, value, sorted by id then time.
bin_core <- function(id, time, value, width) {
  keep <- !is.na(value)
  id <- id[keep]
  k <- floor(time[keep] / width)
  value <- value[keep]
  if (length(value) == 0) {
    return(data.frame(id = id, time = numeric(0), value = numeric(0)))
  }
  out <- stats::aggregate(value, by = list(id = id, k = k), FUN = mean)
  out <- out[order(out$id, out$k), ]
  out <- data.frame(id = out$id, time = (out$k + 0.5) * width,
                    value = out$x, stringsAsFactors = FALSE)
  rownames(out) <- NULL
  out
}

check_bin <- function(bin, allow_null = FALSE, arg = "width") {
  if (is.null(bin) && allow_null) {
    return(invisible(bin))
  }
  if (!is.numeric(bin) || length(bin) != 1 || !is.finite(bin) || bin <= 0) {
    cli_abort("{.arg {arg}} must be a single positive number.",
              class = "chromodoris_error_input")
  }
  invisible(bin)
}
