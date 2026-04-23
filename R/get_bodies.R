#' Extract the body table from a system
#'
#' Returns the bodies in an `orbit_system` as a standalone tibble. Useful
#' when you want to inspect, filter, or save the body states without
#' dealing with the full system object.
#'
#' @param system An `orbit_system` object.
#'
#' @return A tibble with columns `id`, `mass`, `x`, `y`, `z`, `vx`, `vy`,
#'   `vz`.
#' @export
#'
#' @examples
#' sys <- create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun") |>
#'   add_planet("Mars",  parent = "Sun")
#'
#' # Get the tibble
#' get_bodies(sys)
#'
#' # Use with dplyr
#' \donttest{
#' get_bodies(sys) |>
#'   dplyr::filter(mass > 1e24)
#' }
get_bodies <- function(system) {
  if (!inherits(system, "orbit_system")) stop("Input must be an `orbit_system`.")
  system$bodies
}
