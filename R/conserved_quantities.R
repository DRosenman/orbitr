#' Total energy of a simulated system
#'
#' Computes the total kinetic energy, total gravitational potential energy,
#' and their sum at every time step of a simulation. In exact Newtonian
#' gravity the total is constant; with a numerical integrator it is not, and
#' how far it wanders is a direct measure of integration error (see
#' [conserved_quantities()] for the error itself).
#'
#' @param sim_data A tibble output from [simulate_system()].
#' @param G The gravitational constant the simulation was run with. Defaults
#'   to the value recorded by [simulate_system()] in the `"G"` attribute of
#'   `sim_data`, or to [gravitational_constant] if that attribute is absent.
#' @param softening The softening length (in meters) the simulation was run
#'   with. The potential energy is computed with the same softened distance,
#'   `sqrt(r^2 + softening^2)`, that the force used; if the two do not match,
#'   the energy will appear to drift when it has not. Defaults to the value
#'   recorded by [simulate_system()], or 0.
#'
#' @details
#' At each time step,
#' `kinetic` is \eqn{\sum_j \tfrac{1}{2} m_j v_j^2},
#' `potential` is \eqn{-\sum_{j<k} G m_j m_k / \sqrt{r_{jk}^2 + \varepsilon^2}}
#' summed over every unordered pair of bodies, and `energy` is their sum.
#' Potential energy is a property of pairs, not of individual bodies, which
#' is why the function reports system totals only.
#'
#' @return A tibble with one row per time step and columns `time`,
#'   `kinetic`, `potential`, and `energy`, all in joules.
#' @export
#'
#' @examples
#' \donttest{
#' sim <- create_system() |>
#'   add_body("Star", mass = 1e30) |>
#'   add_body("Planet", mass = 1e24, x = 1e11, vy = 30000) |>
#'   simulate_system(time_step = seconds_per_hour * 6,
#'                   duration = seconds_per_year)
#'
#' energy <- get_energy(sim)
#' energy
#'
#' # Kinetic and potential trade off along the orbit; the total barely moves
#' plot(energy$time / seconds_per_day, energy$kinetic, type = "l",
#'      xlab = "Day", ylab = "Kinetic energy (J)")
#' }
get_energy <- function(sim_data, G = NULL, softening = NULL) {
  check_sim_data(sim_data)
  G <- run_setting(sim_data, "G", G, gravitational_constant)
  softening <- run_setting(sim_data, "softening", softening, 0)

  sim_data |>
    dplyr::group_by(time) |>
    dplyr::summarise(
      kinetic   = sum(0.5 * mass * (vx^2 + vy^2 + vz^2)),
      potential = pair_potential(x, y, z, mass, G, softening),
      .groups = "drop"
    ) |>
    dplyr::arrange(time) |>
    dplyr::mutate(energy = kinetic + potential)
}

#' Total linear and angular momentum of a simulated system
#'
#' `get_momentum()` computes the total linear momentum
#' \eqn{\mathbf{P} = \sum_j m_j \mathbf{v}_j} and `get_angular_momentum()`
#' the total angular momentum about the origin,
#' \eqn{\mathbf{L} = \sum_j m_j \mathbf{r}_j \times \mathbf{v}_j}, at every
#' time step of a simulation.
#'
#' Both are conserved exactly by Newtonian gravity, because every force comes
#' in an equal and opposite pair directed along the line between the two
#' bodies. The Velocity Verlet and Euler-Cromer integrators also conserve
#' both to floating-point rounding, at any time step, so a drift in either
#' points to a problem in the setup rather than the step size. A system whose
#' total momentum is not zero has a center of mass that drifts at a constant
#' velocity; see `shift_reference_frame(sim_data, "barycenter")`.
#'
#' @param sim_data A tibble output from [simulate_system()].
#'
#' @return A tibble with one row per time step: `time, px, py, pz`
#'   (kg m/s) for `get_momentum()`, and `time, Lx, Ly, Lz` (kg m^2/s) for
#'   `get_angular_momentum()`.
#' @export
#'
#' @examples
#' \donttest{
#' # A binary built with zero total momentum
#' sim <- create_system() |>
#'   add_body("A", mass = 2e30, x = 5e10, vy = 15000) |>
#'   add_body("B", mass = 1e30, x = -1e11, vy = -30000) |>
#'   simulate_system(time_step = seconds_per_hour, duration = seconds_per_year)
#'
#' get_momentum(sim)          # px, py, pz all zero to rounding
#' get_angular_momentum(sim)  # Lz constant to rounding
#' }
get_momentum <- function(sim_data) {
  check_sim_data(sim_data)
  sim_data |>
    dplyr::group_by(time) |>
    dplyr::summarise(px = sum(mass * vx),
                     py = sum(mass * vy),
                     pz = sum(mass * vz),
                     .groups = "drop") |>
    dplyr::arrange(time)
}

#' @rdname get_momentum
#' @export
get_angular_momentum <- function(sim_data) {
  check_sim_data(sim_data)
  sim_data |>
    dplyr::group_by(time) |>
    dplyr::summarise(Lx = sum(mass * (y * vz - z * vy)),
                     Ly = sum(mass * (z * vx - x * vz)),
                     Lz = sum(mass * (x * vy - y * vx)),
                     .groups = "drop") |>
    dplyr::arrange(time)
}

#' Conserved quantities and how well a simulation conserved them
#'
#' Joins [get_energy()], [get_momentum()], and [get_angular_momentum()] into
#' one tibble and adds the relative error of each quantity against its value
#' at the first time step. In exact Newtonian gravity all three are
#' constant, so the errors measure the integrator, and their shape tells you
#' what is wrong when something is.
#'
#' @inheritParams get_energy
#'
#' @details
#' `energy_error` is \eqn{(E - E_0)/|E_0|}. `momentum_error` is
#' \eqn{|\mathbf{P} - \mathbf{P}_0|} divided by \eqn{\sum_j m_j |\mathbf{v}_j|}
#' at the first step (total momentum is often exactly zero, so it cannot be
#' its own scale). `angular_momentum_error` is
#' \eqn{|\mathbf{L} - \mathbf{L}_0| / |\mathbf{L}_0|}. An error is `NA` when
#' its scale is zero.
#'
#' @section What to expect:
#' The Velocity Verlet and Euler-Cromer integrators are built from "kicks"
#' and "drifts" that conserve linear and angular momentum exactly, so for
#' `method = "verlet"` or `"euler_cromer"` those two errors should stay at
#' the level of floating-point rounding (around 1e-15) for any time step.
#' Energy is conserved only approximately: with Verlet its error oscillates
#' once per orbit within a band whose width scales as the square of the time
#' step, and does not grow. A steady drift in energy means the time step is
#' too large for the fastest or most eccentric orbit in the system, or that
#' `method = "euler"` was used. A sudden jump marks a close encounter the
#' step could not resolve. A drift in momentum or angular momentum under
#' Verlet points to a problem in the setup rather than the integrator.
#'
#' @return A tibble with one row per time step and columns `time`,
#'   `kinetic`, `potential`, `energy`, `px`, `py`, `pz`, `Lx`, `Ly`, `Lz`,
#'   `energy_error`, `momentum_error`, and `angular_momentum_error`.
#' @export
#'
#' @examples
#' \donttest{
#' sim <- create_system() |>
#'   add_body("Star", mass = 1e30) |>
#'   add_body("Planet", mass = 1e24, x = 1e11, vy = 30000) |>
#'   simulate_system(time_step = seconds_per_hour * 6,
#'                   duration = seconds_per_year * 2)
#'
#' cq <- conserved_quantities(sim)
#'
#' # Verlet: bounded energy error, momenta at rounding level
#' range(cq$energy_error)
#' max(cq$angular_momentum_error)
#'
#' plot(cq$time / seconds_per_day, cq$energy_error, type = "l",
#'      xlab = "Day", ylab = "Relative energy error")
#' }
conserved_quantities <- function(sim_data, G = NULL, softening = NULL) {
  check_sim_data(sim_data)

  energy  <- get_energy(sim_data, G = G, softening = softening)
  linear  <- get_momentum(sim_data)
  angular <- get_angular_momentum(sim_data)

  p_scale0 <- sim_data |>
    dplyr::filter(time == min(time)) |>
    dplyr::summarise(s = sum(mass * sqrt(vx^2 + vy^2 + vz^2))) |>
    dplyr::pull(s)

  out <- energy |>
    dplyr::inner_join(linear, by = "time") |>
    dplyr::inner_join(angular, by = "time")

  E0 <- out$energy[1]
  P0 <- c(out$px[1], out$py[1], out$pz[1])
  L0 <- c(out$Lx[1], out$Ly[1], out$Lz[1])
  L_scale0 <- sqrt(sum(L0^2))

  safe_divide <- function(numerator, scale) {
    if (!is.finite(scale) || scale == 0) return(rep(NA_real_, length(numerator)))
    numerator / scale
  }

  out |>
    dplyr::mutate(
      energy_error = safe_divide(energy - E0, abs(E0)),
      momentum_error = safe_divide(
        sqrt((px - P0[1])^2 + (py - P0[2])^2 + (pz - P0[3])^2), p_scale0),
      angular_momentum_error = safe_divide(
        sqrt((Lx - L0[1])^2 + (Ly - L0[2])^2 + (Lz - L0[3])^2), L_scale0)
    )
}

# Internal: potential energy of one snapshot, summed over unordered pairs,
# using the same softened distance as the force calculation.
pair_potential <- function(x, y, z, mass, G, softening) {
  n <- length(x)
  if (n < 2 || G == 0) return(0)
  dx <- outer(x, x, "-")
  dy <- outer(y, y, "-")
  dz <- outer(z, z, "-")
  r  <- sqrt(dx^2 + dy^2 + dz^2 + softening^2)
  mm <- outer(mass, mass)
  -G * sum((mm / r)[upper.tri(r)])
}

# Internal: a run setting, taken from the argument if given, else from the
# attribute simulate_system() recorded, else a default.
run_setting <- function(sim_data, name, value, default) {
  if (!is.null(value)) return(value)
  recorded <- attr(sim_data, name)
  if (!is.null(recorded)) recorded else default
}

# Internal: validate a simulation tibble.
check_sim_data <- function(sim_data) {
  needed <- c("id", "mass", "x", "y", "z", "vx", "vy", "vz", "time")
  if (!is.data.frame(sim_data) || !all(needed %in% names(sim_data))) {
    stop("`sim_data` must be the output of `simulate_system()` ",
         "(a tibble with columns id, mass, x, y, z, vx, vy, vz, time).")
  }
  invisible(TRUE)
}
