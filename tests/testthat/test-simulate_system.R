test_that("simulate_system returns a tibble", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1, x = 1e8, vy = 1000) |>
    simulate_system(time_step = 60, duration = 600)

  expect_true(tibble::is_tibble(sim))
})

test_that("simulate_system output has correct columns", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1, x = 1e8, vy = 1000) |>
    simulate_system(time_step = 60, duration = 600)

  expected_cols <- c("id", "mass", "x", "y", "z", "vx", "vy", "vz", "time")
  expect_true(all(expected_cols %in% names(sim)))
})

test_that("simulate_system produces correct number of rows", {
  sys <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1, x = 1e8)

  sim <- simulate_system(sys, time_step = 100, duration = 1000)

  n_steps <- length(seq(0, 1000, by = 100))  # 11 steps (0, 100, ..., 1000)
  n_bodies <- 2
  expect_equal(nrow(sim), n_steps * n_bodies)
})

test_that("simulate_system starts at time 0", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1, x = 1e8) |>
    simulate_system(time_step = 100, duration = 1000)

  expect_equal(min(sim$time), 0)
})

test_that("simulate_system ends at correct duration", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1, x = 1e8) |>
    simulate_system(time_step = 100, duration = 1000)

  expect_equal(max(sim$time), 1000)
})

test_that("simulate_system preserves initial conditions at t=0", {
  sim <- create_system() |>
    add_body("Star", mass = 1e30) |>
    add_body("Planet", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 3600)

  t0 <- sim[sim$time == 0, ]
  planet_t0 <- t0[t0$id == "Planet", ]

  expect_equal(planet_t0$x, 1e11)
  expect_equal(planet_t0$y, 0)
  expect_equal(planet_t0$vx, 0)
  expect_equal(planet_t0$vy, 30000)
})

test_that("simulate_system uses default time_step and duration", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1, x = 1e11, vy = 30000) |>
    simulate_system()

  # Default: time_step = seconds_per_hour, duration = seconds_per_year
  expect_equal(max(sim$time), seconds_per_year)
  times <- unique(sim$time)
  expect_equal(times[2] - times[1], seconds_per_hour)
})

test_that("all three integrators run without error", {
  sys <- create_system() |>
    add_body("Star", mass = 1e30) |>
    add_body("Planet", mass = 1e24, x = 1e11, vy = 30000)

  expect_no_error(simulate_system(sys, time_step = 3600, duration = 86400, method = "verlet"))
  expect_no_error(simulate_system(sys, time_step = 3600, duration = 86400, method = "euler_cromer"))
  expect_no_error(simulate_system(sys, time_step = 3600, duration = 86400, method = "euler"))
})

test_that("invalid method produces an error", {
  sys <- create_system() |>
    add_body("A", mass = 1)

  expect_error(simulate_system(sys, method = "rk4"), "must be")
})

test_that("simulate_system rejects non-orbit_system input", {
  expect_error(simulate_system(data.frame()), "orbit_system")
})

test_that("zero-gravity simulation produces straight-line motion", {
  sim <- create_system(G = 0) |>
    add_body("A", mass = 1, vx = 100) |>
    simulate_system(time_step = 1, duration = 10)

  body <- sim[sim$id == "A", ]

  # With G=0 and constant velocity, x should increase linearly
  expect_equal(body$x, body$time * 100)
  expect_equal(body$y, rep(0, nrow(body)))
  expect_equal(body$vx, rep(100, nrow(body)))
})

test_that("verlet conserves energy better than euler", {
  sys <- create_system() |>
    add_body("Star", mass = 1e30) |>
    add_body("Planet", mass = 1e24, x = 1e11, vy = 30000)

  calc_energy <- function(sim_data) {
    G <- gravitational_constant
    planet <- sim_data[sim_data$id == "Planet", ]
    star <- sim_data[sim_data$id == "Star", ]

    # Kinetic energy of planet at each time step
    ke <- 0.5 * planet$mass * (planet$vx^2 + planet$vy^2 + planet$vz^2)

    # Potential energy
    r <- sqrt((planet$x - star$x)^2 + (planet$y - star$y)^2 + (planet$z - star$z)^2)
    pe <- -G * planet$mass * star$mass / r

    ke + pe
  }

  verlet <- simulate_system(sys, time_step = 3600, duration = 86400 * 365, method = "verlet")
  euler <- simulate_system(sys, time_step = 3600, duration = 86400 * 365, method = "euler")

  e_verlet <- calc_energy(verlet)
  e_euler <- calc_energy(euler)

  # Verlet energy drift should be much smaller than Euler
  verlet_drift <- abs(e_verlet[length(e_verlet)] - e_verlet[1]) / abs(e_verlet[1])
  euler_drift <- abs(e_euler[length(e_euler)] - e_euler[1]) / abs(e_euler[1])

  expect_true(verlet_drift < euler_drift)
  # Verlet should conserve energy to within 0.1% over a year
  expect_true(verlet_drift < 0.001)
})

test_that("softening prevents singularity at close approach", {
  # Two bodies headed straight at each other
  sim <- create_system() |>
    add_body("A", mass = 1e30, x = 1e8) |>
    add_body("B", mass = 1e30, x = -1e8) |>
    simulate_system(time_step = 1, duration = 100, softening = 1e6)

  # Should complete without NaN/Inf
  expect_false(any(is.nan(sim$x)))
  expect_false(any(is.infinite(sim$x)))
})

test_that("R and C++ engines produce similar results", {
  sys <- create_system() |>
    add_body("Star", mass = 1e30) |>
    add_body("Planet", mass = 1e24, x = 1e11, vy = 30000)

  sim_cpp <- simulate_system(sys, time_step = 3600, duration = 86400 * 30, use_cpp = TRUE)
  sim_r <- simulate_system(sys, time_step = 3600, duration = 86400 * 30, use_cpp = FALSE)

  # Final positions should match to high precision
  planet_cpp <- sim_cpp[sim_cpp$id == "Planet" & sim_cpp$time == max(sim_cpp$time), ]
  planet_r <- sim_r[sim_r$id == "Planet" & sim_r$time == max(sim_r$time), ]

  expect_equal(planet_cpp$x, planet_r$x, tolerance = 1)
  expect_equal(planet_cpp$y, planet_r$y, tolerance = 1)
})
