#' Shift the coordinate reference frame of the simulation
#'
#' Recalculates the positions and velocities of all bodies relative to a specific
#' target body. This effectively "anchors the camera" to the chosen body, placing
#' it at the origin (0, 0, 0) for all time steps.
#'
#' @param sim_data A tidy `tibble` containing the output from `simulate_system()`.
#' @param center_id The character string ID of the body to use as the new origin.
#' @param keep_center Logical. Should the central body remain in the dataset
#'   (it will have 0 for all coordinates) or be removed? Default is `TRUE`.
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
#' }
shift_reference_frame <- function(sim_data, center_id, keep_center = TRUE) {

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
