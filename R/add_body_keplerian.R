#' Add a body using Keplerian orbital elements
#'
#' A convenience wrapper around [add_body()] that lets you specify an orbit
#' using classical Keplerian elements instead of raw Cartesian state vectors.
#' The elements are converted to position and velocity in the reference frame
#' of the parent body, which must already exist in the system.
#'
#' @section Keplerian Elements:
#' Six numbers fully describe a Keplerian orbit:
#'
#' \describe{
#'   \item{`a` (semi-major axis)}{The size of the orbit — half the longest
#'     diameter of the ellipse, in meters.}
#'   \item{`e` (eccentricity)}{The shape of the orbit. 0 is a perfect circle;
#'     values between 0 and 1 are ellipses.}
#'   \item{`i` (inclination)}{The tilt of the orbital plane relative to the
#'     reference plane, in degrees.}
#'   \item{`lan` (longitude of ascending node)}{The angle from the reference
#'     direction to where the orbit crosses the reference plane going "upward,"
#'     in degrees. Sometimes written as \eqn{\Omega}.}
#'   \item{`arg_pe` (argument of periapsis)}{The angle within the orbital
#'     plane from the ascending node to the closest-approach point, in degrees.
#'     Sometimes written as \eqn{\omega}.}
#'   \item{`nu` (true anomaly)}{Where the body currently sits along its orbit,
#'     measured as an angle from periapsis in degrees. 0 = at periapsis
#'     (closest), 180 = at apoapsis (farthest).}
#' }
#'
#' @param system An `orbit_system` object created by [create_system()].
#' @param id A unique character string to identify the body.
#' @param mass The mass of the body in kilograms.
#' @param a Semi-major axis in meters.
#' @param e Eccentricity (0 = circle, 0 < e < 1 = ellipse). Default 0.
#' @param i Inclination in degrees. Default 0.
#' @param lan Longitude of ascending node in degrees. Default 0.
#' @param arg_pe Argument of periapsis in degrees. Default 0.
#' @param nu True anomaly in degrees. Default 0 (body starts at periapsis).
#' @param parent Character id of the parent body (must already exist in
#'   `system`). The orbital elements are defined relative to this body.
#'
#' @return The updated `orbit_system` with the new body added.
#' @export
#'
#' @examples
#' \donttest{
#' # Earth orbiting the Sun with real orbital elements
#' system <- create_system() |>
#'   add_sun() |>
#'   add_body_keplerian(
#'     "Earth", mass = mass_earth,
#'     a = distance_earth_sun, e = 0.0167, i = 0.00005,
#'     parent = "Sun"
#'   )
#'
#' # Mars with its notable eccentricity
#' system <- system |>
#'   add_body_keplerian(
#'     "Mars", mass = mass_mars,
#'     a = distance_mars_sun, e = 0.0934, i = 1.85,
#'     lan = 49.6, arg_pe = 286.5, nu = 0,
#'     parent = "Sun"
#'   )
#' }
add_body_keplerian <- function(system, id, mass, a, e = 0, i = 0,
                                lan = 0, arg_pe = 0, nu = 0, parent) {
  if (!inherits(system, "orbit_system")) stop("Input must be an `orbit_system`.")
  if (missing(parent)) stop("`parent` must be specified.")
  if (!(parent %in% system$bodies$id)) {
    stop(sprintf("Parent body '%s' not found in system.", parent))
  }
  if (!is.numeric(a) || length(a) != 1 || a <= 0) {
    stop("`a` (semi-major axis) must be a positive number.")
  }
  if (!is.numeric(e) || length(e) != 1 || e < 0 || e >= 1) {
    stop("`e` (eccentricity) must be >= 0 and < 1.")
  }

  # Gravitational parameter of parent
  parent_row <- system$bodies[system$bodies$id == parent, ]
  mu <- system$forces$gravity$G * parent_row$mass

  # Convert angles from degrees to radians
  i_rad      <- i * pi / 180
  lan_rad    <- lan * pi / 180
  arg_pe_rad <- arg_pe * pi / 180
  nu_rad     <- nu * pi / 180


  # --- Position and velocity in the orbital plane ---

  # Distance from parent at the current true anomaly
  r <- a * (1 - e^2) / (1 + e * cos(nu_rad))

  # Position in the perifocal frame (orbital plane, x toward periapsis)
  x_pf <- r * cos(nu_rad)
  y_pf <- r * sin(nu_rad)

  # Specific angular momentum

  h <- sqrt(mu * a * (1 - e^2))

  # Velocity in the perifocal frame
  vx_pf <- -(mu / h) * sin(nu_rad)
  vy_pf <-  (mu / h) * (e + cos(nu_rad))


  # --- Rotate from perifocal frame to inertial frame ---
  # Rotation matrix: R = Rz(-lan) * Rx(-i) * Rz(-arg_pe)

  cos_lan <- cos(lan_rad);  sin_lan <- sin(lan_rad)
  cos_i   <- cos(i_rad);    sin_i   <- sin(i_rad)
  cos_w   <- cos(arg_pe_rad); sin_w <- sin(arg_pe_rad)

  # First column of the rotation matrix
  r11 <-  cos_lan * cos_w - sin_lan * sin_w * cos_i
  r21 <-  sin_lan * cos_w + cos_lan * sin_w * cos_i
  r31 <-  sin_w * sin_i

  # Second column
  r12 <- -cos_lan * sin_w - sin_lan * cos_w * cos_i
  r22 <- -sin_lan * sin_w + cos_lan * cos_w * cos_i
  r32 <-  cos_w * sin_i

  # Transform position
  x_rel  <- r11 * x_pf + r12 * y_pf
  y_rel  <- r21 * x_pf + r22 * y_pf
  z_rel  <- r31 * x_pf + r32 * y_pf

  # Transform velocity
  vx_rel <- r11 * vx_pf + r12 * vy_pf
  vy_rel <- r21 * vx_pf + r22 * vy_pf
  vz_rel <- r31 * vx_pf + r32 * vy_pf


  # --- Shift to parent's position and velocity ---

  x_abs  <- x_rel  + parent_row$x
  y_abs  <- y_rel  + parent_row$y
  z_abs  <- z_rel  + parent_row$z
  vx_abs <- vx_rel + parent_row$vx
  vy_abs <- vy_rel + parent_row$vy
  vz_abs <- vz_rel + parent_row$vz

  add_body(system, id = id, mass = mass,
           x = x_abs, y = y_abs, z = z_abs,
           vx = vx_abs, vy = vy_abs, vz = vz_abs)
}
