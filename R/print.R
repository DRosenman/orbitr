#' Print an orbit_system
#'
#' Displays a compact, human-readable summary of an `orbit_system` showing
#' the gravitational constant and a tibble of body states.
#'
#' @param x An `orbit_system` object.
#' @param ... Additional arguments (ignored).
#'
#' @return `x`, invisibly.
#' @export
#'
#' @examples
#' create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun") |>
#'   add_planet("Mars",  parent = "Sun")
print.orbit_system <- function(x, ...) {
  n <- nrow(x$bodies)
  G <- x$forces$gravity$G

  g_label <- if (G == gravitational_constant) {
    "6.6743e-11 (standard)"
  } else if (G == 0) {
    "0 (no gravity)"
  } else {
    sprintf("%g", G)
  }

  cat(cli_line(), "\n")
  cat(sprintf("G: %s\n", g_label))

  if (n == 0) {
    cat("Bodies: (none)\n")
  } else {
    cat(sprintf("Bodies: %d\n\n", n))
    print(x$bodies)
  }

  invisible(x)
}


# Build a header line like: ── orbit_system ──
cli_line <- function(width = getOption("width", 80)) {
  label <- " orbit_system "
  side <- max(1, (width - nchar(label)) %/% 2)
  paste0(strrep("\u2500", side), label, strrep("\u2500", width - side - nchar(label)))
}
