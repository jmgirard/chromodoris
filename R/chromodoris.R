#' Draw a Chromodoris plot of many time series
#'
#' Summarises many series (one per rater or unit) moment by moment as
#' nested quantile ribbons around a center line, with a viridis fill
#' scale, a band legend, and [ggplot2::theme_minimal()]. Add further
#' ggplot2 layers, scales, or themes to the result to customise it.
#'
#' @param data A data frame in long form: one row per series and time.
#' @param id,time,value Column names in `data`, bare or quoted, holding
#'   the series id, the time, and the value. `time` and `value` must be
#'   numeric.
#' @inheritParams stat_chromodoris
#' @return A ggplot object with two layers: a ribbon layer built on
#'   [stat_chromodoris()] and a line layer for the center.
#' @examples
#' set.seed(1)
#' d <- expand.grid(id = 1:20, time = 1:40)
#' d$value <- sin(d$time / 6) + rnorm(nrow(d), sd = 0.5)
#' chromodoris(d, id, time, value)
#' chromodoris(d, "id", "time", "value", .width = c(0.5, 0.95),
#'             center = "median")
#' @export
chromodoris <- function(data, id, time, value,
                        .width = c(0.5, 0.7, 0.9),
                        center = c("mean", "median"), type = 7) {
  center <- match.arg(center)
  id <- rlang::as_name(rlang::ensym(id))
  time <- rlang::as_name(rlang::ensym(time))
  value <- rlang::as_name(rlang::ensym(value))
  check_input(data, id, time, value)
  check_width(.width)
  check_type(type)

  ggplot(data, aes(x = .data[[time]], y = .data[[value]],
                   group = .data[[id]])) +
    stat_chromodoris(aes(fill = after_stat(level)),
                     .width = .width, center = center, type = type) +
    stat_chromodoris(geom = "line", .width = max(.width), center = center,
                     type = type, show.legend = FALSE) +
    scale_fill_viridis_d(name = "Band") +
    labs(x = time, y = value) +
    theme_minimal()
}

check_input <- function(data, id, time, value) {
  if (!is.data.frame(data)) {
    cli_abort("{.arg data} must be a data frame.",
              class = "chromodoris_error_input")
  }
  for (col in c(id, time, value)) {
    if (!col %in% names(data)) {
      cli_abort("Column {.val {col}} is not in {.arg data}.",
                class = "chromodoris_error_input")
    }
  }
  for (col in c(time, value)) {
    if (!is.numeric(data[[col]])) {
      cli_abort("Column {.val {col}} must be numeric, not {.cls {class(data[[col]])}}.",
                class = "chromodoris_error_input")
    }
  }
  invisible(data)
}

check_width <- function(.width) {
  if (!is.numeric(.width) || length(.width) == 0 ||
      anyNA(.width) || any(.width <= 0 | .width >= 1)) {
    cli_abort("{.arg .width} must be numeric with every value in (0, 1).",
              class = "chromodoris_error_input")
  }
  if (anyDuplicated(band_labels(unique(.width)))) {
    cli_abort("{.arg .width} values must not round to the same percent.",
              class = "chromodoris_error_input")
  }
  invisible(.width)
}

check_type <- function(type) {
  if (!is.numeric(type) || length(type) != 1 || is.na(type) ||
      type != round(type) || type < 1 || type > 9) {
    cli_abort("{.arg type} must be a single integer from 1 to 9.",
              class = "chromodoris_error_input")
  }
  invisible(type)
}
