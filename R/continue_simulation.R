#' Rebuild an orbit_system from a simulation snapshot
#'
#' Takes the state of every body at one time step of a simulation and returns
#' a new `orbit_system` with those positions and velocities as its initial
#' conditions. This is the bridge from a finished run back to a system you can
#' modify (add a body, remove one, change a velocity) and simulate again.
#'
#' @param sim_data A tibble output from [simulate_system()].
#' @param time The simulation time (in seconds) of the snapshot to use.
#'   Defaults to the last time step. Snaps to the closest available time.
#' @param G The gravitational constant for the new system. Defaults to the
#'   value recorded by [simulate_system()] in the `"G"` attribute of
#'   `sim_data`, or to [gravitational_constant] if that is absent.
#'
#' @return An `orbit_system` whose bodies have the snapshot's positions and
#'   velocities.
#' @export
#'
#' @examples
#' \donttest{
#' sim <- create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun") |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_day * 100)
#'
#' # Where everything was on day 100, as a system ready to simulate again
#' later <- system_from_simulation(sim)
#' later
#' }
system_from_simulation <- function(sim_data, time = NULL, G = NULL) {
  check_sim_data(sim_data)

  if (is.null(G)) {
    G <- attr(sim_data, "G")
    if (is.null(G)) G <- gravitational_constant
  }

  times <- unique(sim_data$time)
  if (is.null(time)) {
    t_use <- max(times)
  } else {
    t_use <- times[which.min(abs(times - time))]
  }
  snapshot <- sim_data[sim_data$time == t_use, ]

  system <- create_system(G = G)
  for (i in seq_len(nrow(snapshot))) {
    system <- add_body(
      system, id = snapshot$id[i], mass = snapshot$mass[i],
      x  = snapshot$x[i],  y  = snapshot$y[i],  z  = snapshot$z[i],
      vx = snapshot$vx[i], vy = snapshot$vy[i], vz = snapshot$vz[i]
    )
  }
  system
}

#' Continue a simulation from its last state
#'
#' Rebuilds the system from the final time step of a simulation, runs it
#' forward, and appends the new rows with `time` continuing from where the
#' previous run ended. Use it to extend a run without starting over, to change
#' the time step partway through (small steps through a close approach, large
#' ones elsewhere), or to apply a change between segments, such as a velocity
#' kick or an added body, by editing the tibble before continuing.
#'
#' @param sim_data A tibble output from [simulate_system()] or from a previous
#'   call to `continue_simulation()`.
#' @param time_step The time increment per step in seconds for the new
#'   segment. Need not match the previous segment's.
#' @param duration Total time in seconds to simulate in the new segment.
#' @param G The gravitational constant. Defaults to the value recorded by
#'   [simulate_system()], or to [gravitational_constant].
#' @param ... Further arguments passed to [simulate_system()]: `method`,
#'   `softening`, and `use_cpp`. When not supplied, `method` and `softening`
#'   default to the values recorded from the previous segment.
#'
#' @details
#' The last row of each body in `sim_data` is a complete state, so the
#' restart is exact: the new segment begins from precisely where the old one
#' stopped. The new segment's first step duplicates the old segment's last
#' and is dropped, so `time` is strictly increasing in the result.
#'
#' Each segment is integrated independently with a fixed step. Changing the
#' step between segments disturbs the integration by about one step's worth
#' of error at the switch, which is usually far smaller than the error saved
#' by using a small step only where it is needed. A comet's perihelion
#' passage is the typical use: run with a step of days out to a few AU, a
#' step of hours through perihelion, and days again on the way out.
#'
#' @return A tibble with the same columns as `sim_data` and the new time
#'   steps appended.
#' @export
#'
#' @examples
#' \donttest{
#' # A comet on a highly eccentric orbit, started at aphelion
#' comet <- create_system() |>
#'   add_sun() |>
#'   add_body_keplerian("Comet", mass = 1e14, parent = "Sun",
#'                      a = 5 * distance_earth_sun, e = 0.9, nu = 180)
#'
#' # Coarse steps on the way in, fine steps through perihelion, coarse again
#' sim <- comet |>
#'   simulate_system(time_step = seconds_per_day * 5,
#'                   duration = seconds_per_year * 5) |>
#'   continue_simulation(time_step = seconds_per_hour * 2,
#'                       duration = seconds_per_year * 1.2) |>
#'   continue_simulation(time_step = seconds_per_day * 5,
#'                       duration = seconds_per_year * 5)
#'
#' range(sim$time) / seconds_per_year
#' }
continue_simulation <- function(sim_data, time_step, duration, G = NULL, ...) {
  check_sim_data(sim_data)

  dots <- list(...)
  if (is.null(G)) {
    G <- attr(sim_data, "G")
    if (is.null(G)) G <- gravitational_constant
  }
  if (is.null(dots$method) && !is.null(attr(sim_data, "method"))) {
    dots$method <- attr(sim_data, "method")
  }
  if (is.null(dots$softening) && !is.null(attr(sim_data, "softening"))) {
    dots$softening <- attr(sim_data, "softening")
  }

  t0 <- max(sim_data$time)
  system <- system_from_simulation(sim_data, time = t0, G = G)

  more <- do.call(simulate_system, c(
    list(system = system, time_step = time_step, duration = duration), dots
  ))
  seg_method    <- attr(more, "method")
  seg_softening <- attr(more, "softening")

  more$time <- more$time + t0
  more <- more[more$time > t0, ]          # drop the duplicated starting state

  out <- dplyr::bind_rows(sim_data, more)
  attr(out, "G")         <- G
  attr(out, "method")    <- seg_method
  attr(out, "softening") <- seg_softening
  attr(out, "time_step") <- time_step
  out
}
