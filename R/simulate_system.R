#' Simulate kinematics for an orbitr system
#'
#' Propagates the physical state of an `orbit_system` through time using numerical integration.
#' This engine supports multiple mathematical methods, defaulting to the energy-conserving
#' Velocity Verlet algorithm to ensure highly stable orbital trajectories.
#'
#' @param system An `orbit_system` object created by `create_system()`.
#' @param time_step The time increment per frame in seconds (default 60s).
#' @param duration Total simulation time in seconds (default 86400s / 1 day).
#' @param method The numerical integration method: "verlet" (default), "euler_cromer", or "euler".
#' @param softening A small distance (in meters) added to prevent numerical singularities
#'   when bodies pass very close to each other. The gravitational distance is computed as
#'   `sqrt(r^2 + softening^2)` instead of `r`. Default is 0 (no softening). A value like
#'   1e4 (10 km) is reasonable for planetary simulations.
#' @param use_cpp Logical. If `TRUE` (default), uses the compiled C++ acceleration engine
#'   for better performance. Falls back to vectorized R if the C++ code is not available.
#'
#' @return A tidy `tibble` containing the physical state (time, id, mass, x, y, z, vx, vy, vz)
#'   of every body at every time step.
#' @export
#'
#' @examples
#' \dontrun{
#' my_universe <- create_system() |>
#'   add_body("Earth", mass = 5.97e24) |>
#'   add_body("Moon", mass = 7.34e22, x = 3.84e8, vy = 1022) |>
#'   simulate_system(time_step = 3600, duration = 86400 * 28)
#' }
simulate_system <- function(system, time_step = 60, duration = 86400, method = "verlet",
                     softening = 0, use_cpp = TRUE) {

  if (!inherits(system, "orbit_system")) stop("Input must be an `orbit_system`.")
  if (!method %in% c("verlet", "euler_cromer", "euler")) {
    stop("Method must be 'verlet', 'euler_cromer', or 'euler'.")
  }

  state <- system$bodies
  n_bodies <- nrow(state)

  # Extract G from the forces list
  G <- system$forces$gravity$G
  if (is.null(G)) G <- 0

  # Check if the C++ engine is available
  cpp_available <- use_cpp && requireNamespace("Rcpp", quietly = TRUE) &&
    tryCatch({ calc_acceleration_cpp; TRUE }, error = function(e) FALSE)

  # --- INTERNAL HELPER: C++ Accelerated N-Body Acceleration ---
  calc_acceleration_cpp_wrapper <- function(current_state) {
    calc_acceleration_cpp(
      current_state$x, current_state$y, current_state$z,
      current_state$mass, G, softening
    )
  }

  # --- INTERNAL HELPER: Vectorized R N-Body Acceleration ---
  # Uses matrix operations for an efficient pure-R fallback.
  calc_acceleration_r <- function(current_state) {
    if (G == 0 || n_bodies <= 1) {
      return(list(ax = numeric(n_bodies), ay = numeric(n_bodies), az = numeric(n_bodies)))
    }

    # Create matrices of coordinate differences.
    # outer(a, b, "-") produces mat[i,j] = a[i] - b[j], so for row i (the body
    # being accelerated) and column j (the source body), we need x[j] - x[i].
    # Multiplying by -1 flips outer's native (a[i] - b[j]) to (b[j] - a[i]),
    # giving us the direction vector pointing FROM body i TOWARD body j.
    dx_mat <- outer(current_state$x, current_state$x, "-") * -1
    dy_mat <- outer(current_state$y, current_state$y, "-") * -1
    dz_mat <- outer(current_state$z, current_state$z, "-") * -1

    # Distance matrix with optional softening to prevent 1/r^2 singularity
    r_mat <- sqrt(dx_mat^2 + dy_mat^2 + dz_mat^2 + softening^2)

    # A body doesn't pull on itself — set self-distance to Inf
    diag(r_mat) <- Inf

    # Mass matrix: column j holds mass[j] (the mass of the pulling body)
    mass_mat <- matrix(current_state$mass, nrow = n_bodies, ncol = n_bodies, byrow = TRUE)

    # Scalar acceleration matrix: a = G * M / r^2
    a_mat <- G * mass_mat / (r_mat^2)

    # Decompose into directional components and sum across all sources
    ax <- rowSums(a_mat * (dx_mat / r_mat))
    ay <- rowSums(a_mat * (dy_mat / r_mat))
    az <- rowSums(a_mat * (dz_mat / r_mat))

    return(list(ax = ax, ay = ay, az = az))
  }

  # Select the acceleration engine
  calc_acceleration <- if (cpp_available) {
    calc_acceleration_cpp_wrapper
  } else {
    calc_acceleration_r
  }

  steps <- seq(0, duration, by = time_step)

  # Pre-allocating a list is much faster than binding rows in a loop
  results <- vector("list", length(steps))

  for (i in seq_along(steps)) {
    state$time <- steps[i]
    results[[i]] <- state

    # Skip integration on the final recorded step (no next step to advance to)
    if (i == length(steps)) break

    accels <- calc_acceleration(state)

    if (method == "euler") {
      state$x <- state$x + (state$vx * time_step)
      state$y <- state$y + (state$vy * time_step)
      state$z <- state$z + (state$vz * time_step)

      state$vx <- state$vx + (accels$ax * time_step)
      state$vy <- state$vy + (accels$ay * time_step)
      state$vz <- state$vz + (accels$az * time_step)

    } else if (method == "euler_cromer") {
      state$vx <- state$vx + (accels$ax * time_step)
      state$vy <- state$vy + (accels$ay * time_step)
      state$vz <- state$vz + (accels$az * time_step)

      state$x <- state$x + (state$vx * time_step)
      state$y <- state$y + (state$vy * time_step)
      state$z <- state$z + (state$vz * time_step)

    } else if (method == "verlet") {
      state$x <- state$x + (state$vx * time_step) + (0.5 * accels$ax * time_step^2)
      state$y <- state$y + (state$vy * time_step) + (0.5 * accels$ay * time_step^2)
      state$z <- state$z + (state$vz * time_step) + (0.5 * accels$az * time_step^2)

      new_accels <- calc_acceleration(state)

      state$vx <- state$vx + (0.5 * (accels$ax + new_accels$ax) * time_step)
      state$vy <- state$vy + (0.5 * (accels$ay + new_accels$ay) * time_step)
      state$vz <- state$vz + (0.5 * (accels$az + new_accels$az) * time_step)
    }
  }

  dplyr::bind_rows(results)
}
