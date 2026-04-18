#' Add a physical body to the system
#'
#' This function introduces a new celestial or physical body into your `orbit_system`.
#' You must provide a unique identifier and its mass. By default, the body will be
#' placed at the origin (0, 0, 0) with zero initial velocity unless specified.
#'
#' @param system An `orbit_system` object created by `create_system()`.
#' @param id A unique character string to identify the body (e.g., "Earth", "Apollo").
#' @param mass The mass of the object in kilograms.
#' @param x Initial X-axis position in meters (default 0).
#' @param y Initial Y-axis position in meters (default 0).
#' @param z Initial Z-axis position in meters (default 0).
#' @param vx Initial velocity along the X-axis in meters per second (default 0).
#' @param vy Initial velocity along the Y-axis in meters per second (default 0).
#' @param vz Initial velocity along the Z-axis in meters per second (default 0).
#'
#' @return The updated `orbit_system` object containing the newly added body.
#' @export
#'
#' @examples
#' \donttest{
#' my_universe <- create_system() |>
#'   add_body(id = "Earth", mass = 5.97e24) |>
#'   add_body(id = "Moon", mass = 7.34e22, x = 3.84e8, vy = 1022)
#' }
add_body <- function(system, id, mass, x = 0, y = 0, z = 0, vx = 0, vy = 0, vz = 0) {
  if (!inherits(system, "orbit_system")) stop("Input must be an `orbit_system`.")
  if (id %in% system$bodies$id) stop(sprintf("Body '%s' already exists.", id))
  if (!is.numeric(mass) || length(mass) != 1 || is.na(mass)) {
    stop("`mass` must be a single numeric value.")
  }
  if (mass < 0) stop("`mass` must be non-negative.")

  new_body <- tibble::tibble(
    id = id, mass = mass, x = x, y = y, z = z, vx = vx, vy = vy, vz = vz
  )

  system$bodies <- dplyr::bind_rows(system$bodies, new_body)
  return(system)
}
