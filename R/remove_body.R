#' Remove one or more bodies from the system
#'
#' Drops bodies by name from an `orbit_system`. This is the counterpart to
#' [add_body()] — use it to strip out bodies you no longer need before
#' simulating, or to prune a system built with [load_solar_system()].
#'
#' ```
#' load_solar_system() |>
#'   remove_body(c("Pluto", "Moon")) |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_year)
#' ```
#'
#' @param system An `orbit_system` object.
#' @param id A character vector of body names to remove. All names must exist
#'   in the system.
#'
#' @return The updated `orbit_system` with the specified bodies removed.
#' @export
#'
#' @examples
#' # Remove a single body
#' create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun") |>
#'   add_planet("Mars",  parent = "Sun") |>
#'   remove_body("Mars")
#'
#' \donttest{
#' # Remove multiple bodies from the full solar system
#' load_solar_system() |>
#'   remove_body(c("Pluto", "Moon")) |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_year) |>
#'   plot_orbits()
#' }
remove_body <- function(system, id) {
  if (!inherits(system, "orbit_system")) stop("Input must be an `orbit_system`.")
  if (!is.character(id) || length(id) == 0) {
    stop("`id` must be a non-empty character vector of body names.")
  }

  missing <- id[!id %in% system$bodies$id]
  if (length(missing) > 0) {
    stop(sprintf(
      "Body %s not found in system. Present: %s.",
      paste0("'", missing, "'", collapse = ", "),
      paste(system$bodies$id, collapse = ", ")
    ))
  }

  system$bodies <- system$bodies[!system$bodies$id %in% id, , drop = FALSE]
  system
}
