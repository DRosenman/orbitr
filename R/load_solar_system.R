#' Load a pre-built solar system
#'
#' A convenience function that creates a complete solar system with the Sun and
#' all eight planets (plus optionally the Moon and Pluto) using real orbital
#' data. Bodies are placed using Keplerian orbital elements from the JPL DE440
#' ephemeris (J2000 epoch), giving realistic eccentricities, inclinations, and
#' orbital orientations out of the box.
#'
#' This is a quick way to get a physically accurate starting point without
#' typing out a dozen [add_body()] calls. The returned system is a normal
#' `orbit_system` that you can modify further — add bodies, change parameters,
#' or pipe straight into [simulate_system()].
#'
#' @param moon Logical. If `TRUE` (the default), include the Moon in orbit
#'   around Earth.
#' @param pluto Logical. If `TRUE` (the default), include Pluto.
#'
#' @return An `orbit_system` object containing the Sun and planets, ready for
#'   simulation.
#' @export
#'
#' @examples
#' \dontrun{
#' # Simulate the full solar system for one year
#' solar <- load_solar_system() |>
#'   simulate_system(
#'     time_step = seconds_per_day,
#'     duration  = seconds_per_year
#'   )
#'
#' plot_orbits(solar)
#'
#' # Just the Sun and planets, no Moon or Pluto
#' load_solar_system(moon = FALSE, pluto = FALSE)
#' }
load_solar_system <- function(moon = TRUE, pluto = TRUE) {

  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Mercury", parent = "Sun") |>
    add_planet("Venus",   parent = "Sun") |>
    add_planet("Earth",   parent = "Sun") |>
    add_planet("Mars",    parent = "Sun") |>
    add_planet("Jupiter", parent = "Sun") |>
    add_planet("Saturn",  parent = "Sun") |>
    add_planet("Uranus",  parent = "Sun") |>
    add_planet("Neptune", parent = "Sun")

  if (moon)  sys <- add_planet(sys, "Moon",  parent = "Earth")
  if (pluto) sys <- add_planet(sys, "Pluto", parent = "Sun")

  sys
}
