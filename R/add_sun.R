#' Add the Sun to the system
#'
#' A convenience function that adds the Sun as the central body of a
#' simulation. By default it is placed at the origin with zero velocity,
#' which is the natural choice for a heliocentric reference frame. Position
#' and velocity can be overridden for advanced use cases such as
#' barycentric coordinates.
#'
#' This pairs naturally with [add_planet()]:
#'
#' ```
#' create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun") |>
#'   add_planet("Mars",  parent = "Sun")
#' ```
#'
#' @param system An `orbit_system` object created by [create_system()].
#' @param mass Mass of the Sun in kilograms. Defaults to [mass_sun]
#'   (1.989 x 10^30 kg).
#' @param x Initial X-axis position in meters (default 0).
#' @param y Initial Y-axis position in meters (default 0).
#' @param z Initial Z-axis position in meters (default 0).
#' @param vx Initial velocity along the X-axis in m/s (default 0).
#' @param vy Initial velocity along the Y-axis in m/s (default 0).
#' @param vz Initial velocity along the Z-axis in m/s (default 0).
#'
#' @return The updated `orbit_system` with the Sun added.
#' @export
#'
#' @examples
#' # Typical usage — Sun at the origin
#' create_system() |>
#'   add_sun()
#'
#' \donttest{
#' # Full solar system in three lines
#' create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun") |>
#'   add_planet("Mars",  parent = "Sun") |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_year) |>
#'   plot_orbits()
#' }
add_sun <- function(system, mass = mass_sun,
                    x = 0, y = 0, z = 0,
                    vx = 0, vy = 0, vz = 0) {
  add_body(system, id = "Sun", mass = mass,
           x = x, y = y, z = z,
           vx = vx, vy = vy, vz = vz)
}
