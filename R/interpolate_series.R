#' Interpolate every series onto a common time grid
#'
#' `interpolate_series()` evaluates each series at the times in `grid`, so
#' series sampled at different times share time points. Within a series,
#' rows with a missing time are dropped, and rows that repeat a time are
#' first averaged over their non-missing values. Each grid point is then
#' computed from the series' observations around it:
#'
#' - `"linear"` (default) joins the two observations on either side of the
#'   grid point with a straight line. A grid point that equals an observed
#'   time takes that observation's value.
#' - `"constant"` carries the last observation at or before the grid point
#'   forward.
#'
#' A grid point outside a series' observed time range yields no row for
#' that series, so nothing is extrapolated. A grid point computed from a
#' missing value also yields no row, so gaps in a series stay gaps. An
#' infinite time or value is an error.
#'
#' [stat_chromodoris()] and [chromodoris()] apply the same rule through
#' their `grid` and `interpolate` arguments.
#'
#' @inheritParams chromodoris
#' @param grid A numeric vector of finite times, in the units of `time`,
#'   at which to evaluate every series. It is sorted and duplicate values
#'   are dropped. Ratings sampled at irregular times and put on a 10 Hz
#'   grid over 60 seconds use `grid = seq(0, 60, by = 0.1)`.
#' @param method One of `"linear"` (default) or `"constant"`.
#' @return A data frame with the `id`, `time`, and `value` columns of
#'   `data` (same names), one row per series and grid point that has a
#'   value, sorted by series then time.
#' @examples
#' d <- data.frame(id = rep(c("a", "b"), each = 3),
#'                 time = c(0, 0.4, 1, 0.1, 0.5, 0.9),
#'                 value = c(1, 2, 4, 3, 5, 7))
#' interpolate_series(d, id, time, value, grid = seq(0, 1, by = 0.25))
#' interpolate_series(d, id, time, value, grid = seq(0, 1, by = 0.25),
#'                    method = "constant")
#' @export
interpolate_series <- function(data, id, time, value, grid,
                               method = c("linear", "constant")) {
  method <- match.arg(method)
  id <- rlang::as_name(rlang::ensym(id))
  time <- rlang::as_name(rlang::ensym(time))
  value <- rlang::as_name(rlang::ensym(value))
  check_input(data, id, time, value)
  check_grid(grid)
  for (col in c(time, value)) {
    if (any(is.infinite(data[[col]]))) {
      cli_abort("Column {.val {col}} must not hold infinite values.",
                class = "chromodoris_error_input")
    }
  }
  out <- interp_core(data[[id]], data[[time]], data[[value]], grid, method)
  names(out) <- c(id, time, value)
  out
}

# Shared by interpolate_series() and StatChromodoris: returns a data frame
# with columns id, time, value, sorted by id then time.
interp_core <- function(id, time, value, grid, method) {
  grid <- sort(unique(grid))
  keep <- !is.na(time)
  id <- id[keep]
  time <- time[keep]
  value <- value[keep]
  rows <- split(seq_along(id), id, drop = TRUE)
  pieces <- lapply(rows, function(i) {
    s <- interp_one(time[i], value[i], grid, method)
    list(id = rep(id[i[1]], length(s$time)), time = s$time, value = s$value)
  })
  out <- data.frame(
    id = do.call(c, c(list(id[0]), lapply(pieces, `[[`, "id"))),
    time = as.numeric(unlist(lapply(pieces, `[[`, "time"))),
    value = as.numeric(unlist(lapply(pieces, `[[`, "value"))),
    stringsAsFactors = FALSE
  )
  rownames(out) <- NULL
  out
}

# One series: times may be unsorted and repeated, values may be NA.
interp_one <- function(time, value, grid, method) {
  tt <- sort(unique(time))
  vv <- vapply(split(value, match(time, tt)), function(v) {
    if (all(is.na(v))) NA_real_ else mean(v, na.rm = TRUE)
  }, numeric(1))
  g <- grid[grid >= tt[1] & grid <= tt[length(tt)]]
  i <- findInterval(g, tt)
  out <- vv[i]
  if (method == "linear") {
    j <- which(g != tt[i])
    k <- i[j]
    out[j] <- vv[k] + (vv[k + 1] - vv[k]) * (g[j] - tt[k]) / (tt[k + 1] - tt[k])
  }
  keep <- !is.na(out)
  list(time = g[keep], value = unname(out[keep]))
}

check_grid <- function(grid, allow_null = FALSE) {
  if (is.null(grid) && allow_null) {
    return(invisible(grid))
  }
  if (!is.numeric(grid) || !is.null(dim(grid)) || length(grid) == 0 ||
      !all(is.finite(grid))) {
    cli_abort("{.arg grid} must be a numeric vector of finite times.",
              class = "chromodoris_error_input")
  }
  invisible(grid)
}
