#' Shift the coordinate reference frame of the simulation
#'
#' Recalculates the positions and velocities of all bodies relative to a specific
#' target body, or to the system's center of mass. This effectively "anchors the
#' camera" to the chosen point, placing it at the origin (0, 0, 0) for all time
#' steps.
#'
#' @param sim_data A tidy `tibble` containing the output from `simulate_system()`.
#' @param center_id The character string ID of the body to use as the new origin,
#'   or `"barycenter"` to use the system's center of mass (the mass-weighted mean
#'   position and velocity of all bodies at each time step).
#' @param keep_center Logical. Should the central body remain in the dataset
#'   (it will have 0 for all coordinates) or be removed? Default is `TRUE`.
#'   Ignored when `center_id = "barycenter"`.
#'
#' @details
#' The shift is a Galilean transformation: at every time step the chosen
#' point's position and velocity are subtracted from every body. No physics
#' changes; the same forces and accelerations produced the data, and you are
#' only choosing where to stand when you look at it.
#'
#' The barycentric frame is the natural one for binary stars and any other
#' system where no single body dominates. In it the total momentum is zero and
#' the center of mass sits at the origin for the whole run, which removes the
#' slow drift you get when a system is built with one body at rest but nonzero
#' total momentum (for example, a planet given an orbital velocity around a
#' star that was not given the balancing recoil).
#'
#' If a body in the system is itself named `"barycenter"`, that body is used as
#' the center rather than the center of mass.
#'
#' @return A tidy `tibble` with updated `x`, `y`, `z`, `vx`, `vy`, and `vz` columns.
#' @export
#'
#' @examples
#' \donttest{
#' # Simulate Sun-Earth-Moon
#' orbit_data <- create_system() |>
#'   add_sun() |>
#'   add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
#'   add_body("Moon", mass = mass_moon, x = distance_earth_sun + distance_earth_moon,
#'            vy = speed_earth + speed_moon) |>
#'   simulate_system(time_step = seconds_per_hour, duration = seconds_per_year)
#'
#' # Shift view to Earth and plot
#' orbit_data |>
#'   shift_reference_frame(center_id = "Earth") |>
#'   plot_orbits()
#'
#' # The Sun started at rest with Jupiter in orbit: the pair's center of mass
#' # drifts, because the total momentum is not zero. The barycentric frame
#' # removes the drift and shows the Sun's own small orbit.
#' sun_jupiter <- create_system() |>
#'   add_sun() |>
#'   add_planet("Jupiter", parent = "Sun") |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_year * 12)
#'
#' sun_jupiter |>
#'   shift_reference_frame("barycenter") |>
#'   plot_orbits(three_d = FALSE)
#' }
shift_reference_frame <- function(sim_data, center_id, keep_center = TRUE) {

  if (identical(center_id, "barycenter") && !("barycenter" %in% sim_data$id)) {
    return(shift_to_barycenter(sim_data))
  }

  if (!center_id %in% sim_data$id) {
    stop(sprintf("Body '%s' not found in the simulation data.", center_id))
  }

  shifted_data <- sim_data |>
    dplyr::group_by(time) |>
    # Capture the exact position and velocity of the target body at this millisecond
    dplyr::mutate(
      ref_x = x[id == center_id],
      ref_y = y[id == center_id],
      ref_z = z[id == center_id],
      ref_vx = vx[id == center_id],
      ref_vy = vy[id == center_id],
      ref_vz = vz[id == center_id]
    ) |>
    dplyr::ungroup() |>
    # Subtract those reference values from every single body
    dplyr::mutate(
      x = x - ref_x,
      y = y - ref_y,
      z = z - ref_z,
      vx = vx - ref_vx,
      vy = vy - ref_vy,
      vz = vz - ref_vz
    ) |>
    # Clean up the temporary columns
    dplyr::select(-ref_x, -ref_y, -ref_z, -ref_vx, -ref_vy, -ref_vz)

  # Remove the central body if requested
  if (!keep_center) {
    shifted_data <- dplyr::filter(shifted_data, id != center_id)
  }

  return(shifted_data)
}

# Internal: subtract the mass-weighted mean position and velocity at every
# time step, so the center of mass sits at the origin at rest.
shift_to_barycenter <- function(sim_data) {
  sim_data |>
    dplyr::group_by(time) |>
    dplyr::mutate(
      ref_x  = sum(mass * x)  / sum(mass),
      ref_y  = sum(mass * y)  / sum(mass),
      ref_z  = sum(mass * z)  / sum(mass),
      ref_vx = sum(mass * vx) / sum(mass),
      ref_vy = sum(mass * vy) / sum(mass),
      ref_vz = sum(mass * vz) / sum(mass)
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      x = x - ref_x,
      y = y - ref_y,
      z = z - ref_z,
      vx = vx - ref_vx,
      vy = vy - ref_vy,
      vz = vz - ref_vz
    ) |>
    dplyr::select(-ref_x, -ref_y, -ref_z, -ref_vx, -ref_vy, -ref_vz)
}
