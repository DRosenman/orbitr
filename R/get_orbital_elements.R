#' Osculating orbital elements of a body relative to a parent
#'
#' The inverse of [add_body_keplerian()]: computes the classical Keplerian
#' elements of `body`'s orbit about `parent` at every time step of a
#' simulation, from their relative position and velocity. In a two-body
#' system the elements are constant (up to integration error). With more
#' bodies present they drift as the orbit is perturbed, and the value at each
#' instant is the *osculating* orbit: the ellipse the body would follow from
#' that moment on if every other perturbation were switched off.
#'
#' @param sim_data A tibble output from [simulate_system()].
#' @param body Character id of the orbiting body.
#' @param parent Character id of the body the orbit is measured about.
#' @param mu Gravitational parameter in m^3/s^2. The default, `NULL`, uses
#'   \eqn{G M_{parent}}, the same convention as [add_body_keplerian()], so that
#'   elements round-trip exactly. Pass `G * (parent mass + body mass)` for the
#'   exact two-body relative orbit, which matters when the body's mass is not
#'   negligible (the Moon's is 1.2\% of Earth's).
#' @param G The gravitational constant, used only when `mu` is `NULL`.
#'   Defaults to the value recorded by [simulate_system()], or to
#'   [gravitational_constant].
#'
#' @details
#' The computation follows the standard textbook route. The specific angular
#' momentum \eqn{\mathbf{h} = \mathbf{r} \times \mathbf{v}} gives the
#' inclination (\eqn{\cos i = h_z / h}) and, through the node vector
#' \eqn{\hat{\mathbf{z}} \times \mathbf{h}}, the longitude of the ascending
#' node. The eccentricity vector
#' \eqn{\mathbf{e} = (\mathbf{v} \times \mathbf{h})/\mu - \mathbf{r}/r}
#' points to periapsis and gives the eccentricity, the argument of periapsis
#' (the angle from the node to \eqn{\mathbf{e}}), and the true anomaly (the
#' angle from \eqn{\mathbf{e}} to \eqn{\mathbf{r}}). The semi-major axis comes
#' from the vis-viva equation, \eqn{a = 1 / (2/r - v^2/\mu)}.
#'
#' Two cases are degenerate and need a convention. For an orbit in the
#' reference plane (\eqn{i = 0}) the ascending node is undefined: `lan` is
#' reported as 0 and `arg_pe` is measured from the x axis. For a circular
#' orbit (\eqn{e = 0}) periapsis is undefined: `arg_pe` is reported as 0 and
#' `nu` is measured from the ascending node (or the x axis).
#'
#' For an unbound orbit (\eqn{e \ge 1}) `a` is negative and `period` is `NA`.
#'
#' @return A tibble with one row per time step and columns `time`, `a`
#'   (meters), `e`, `i`, `lan`, `arg_pe`, `nu` (degrees; angles other than
#'   `i` are in \eqn{[0, 360)}), and `period` (seconds).
#' @export
#'
#' @examples
#' \donttest{
#' # Round trip: the elements that went in come back out at t = 0
#' sim <- create_system() |>
#'   add_sun() |>
#'   add_body_keplerian("Mars", mass = mass_mars, parent = "Sun",
#'                      a = distance_mars_sun, e = 0.0934, i = 1.85,
#'                      lan = 49.6, arg_pe = 286.5, nu = 120) |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_day * 687)
#'
#' elements <- get_orbital_elements(sim, "Mars", "Sun")
#' elements[1, ]
#'
#' # Two bodies: a and e are constant to integration error
#' range(elements$e)
#'
#' # Earth's eccentricity drifting under Jupiter's pull
#' perturbed <- create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun") |>
#'   add_planet("Jupiter", parent = "Sun", nu = 90) |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_year * 12)
#'
#' earth <- get_orbital_elements(perturbed, "Earth", "Sun")
#' plot(earth$time / seconds_per_year, earth$e, type = "l",
#'      xlab = "Years", ylab = "Osculating eccentricity")
#' }
get_orbital_elements <- function(sim_data, body, parent, mu = NULL, G = NULL) {
  check_sim_data(sim_data)
  for (nm in c(body, parent)) {
    if (!nm %in% sim_data$id) {
      stop(sprintf("Body '%s' not found in the simulation data.", nm))
    }
  }
  if (identical(body, parent)) stop("`body` and `parent` must be different bodies.")

  if (is.null(G)) {
    G <- attr(sim_data, "G")
    if (is.null(G)) G <- gravitational_constant
  }

  b <- sim_data[sim_data$id == body, c("time", "x", "y", "z", "vx", "vy", "vz")]
  p <- sim_data[sim_data$id == parent, c("time", "mass", "x", "y", "z", "vx", "vy", "vz")]
  names(p) <- c("time", "p_mass", "p_x", "p_y", "p_z", "p_vx", "p_vy", "p_vz")
  d <- dplyr::inner_join(b, p, by = "time")
  d <- d[order(d$time), ]

  if (is.null(mu)) mu <- G * d$p_mass[1]

  # Relative position and velocity
  rx <- d$x - d$p_x;   ry <- d$y - d$p_y;   rz <- d$z - d$p_z
  ux <- d$vx - d$p_vx; uy <- d$vy - d$p_vy; uz <- d$vz - d$p_vz
  r  <- sqrt(rx^2 + ry^2 + rz^2)
  v2 <- ux^2 + uy^2 + uz^2

  # Specific angular momentum h = r x u
  hx <- ry * uz - rz * uy
  hy <- rz * ux - rx * uz
  hz <- rx * uy - ry * ux
  h  <- sqrt(hx^2 + hy^2 + hz^2)
  hhx <- hx / h; hhy <- hy / h; hhz <- hz / h

  # Node vector n = z_hat x h = (-hy, hx, 0); undefined for a flat orbit
  nx <- -hy; ny <- hx
  n  <- sqrt(nx^2 + ny^2)
  flat <- n < 1e-12 * h
  nx[flat] <- 1; ny[flat] <- 0; n[flat] <- 1
  nx <- nx / n; ny <- ny / n

  # Eccentricity vector e = (u x h) / mu - r / r
  ex <- (uy * hz - uz * hy) / mu - rx / r
  ey <- (uz * hx - ux * hz) / mu - ry / r
  ez <- (ux * hy - uy * hx) / mu - rz / r
  e  <- sqrt(ex^2 + ey^2 + ez^2)
  circular <- e < 1e-12
  edx <- ifelse(circular, nx, ex / e)
  edy <- ifelse(circular, ny, ey / e)
  edz <- ifelse(circular, 0,  ez / e)

  a <- 1 / (2 / r - v2 / mu)
  i <- acos(pmin(pmax(hz / h, -1), 1))

  # Longitude of ascending node: direction of n in the reference plane
  lan <- atan2(ny, nx)

  # Argument of periapsis: angle from n to e_dir, signed about h
  arg_pe <- atan2(
    (ny * edz) * hhx + (-nx * edz) * hhy + (nx * edy - ny * edx) * hhz,
    nx * edx + ny * edy
  )
  arg_pe[circular] <- 0

  # True anomaly: angle from e_dir to r, signed about h
  nu <- atan2(
    (edy * rz - edz * ry) * hhx + (edz * rx - edx * rz) * hhy +
      (edx * ry - edy * rx) * hhz,
    edx * rx + edy * ry + edz * rz
  )

  to_deg <- function(theta) (theta * 180 / pi) %% 360

  tibble::tibble(
    time   = d$time,
    a      = a,
    e      = e,
    i      = i * 180 / pi,
    lan    = to_deg(lan),
    arg_pe = to_deg(arg_pe),
    nu     = to_deg(nu),
    period = ifelse(e < 1 & a > 0, 2 * pi * sqrt(abs(a)^3 / mu), NA_real_)
  )
}
