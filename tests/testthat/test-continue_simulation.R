base_run <- function() {
  create_system() |>
    add_body("Star", mass = 1e30) |>
    add_body("Planet", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400 * 10)
}

test_that("continue_simulation appends rows with time running on", {
  sim  <- base_run()
  more <- continue_simulation(sim, time_step = 3600, duration = 86400 * 5)

  expect_equal(nrow(more), nrow(sim) + 2 * 24 * 5)
  expect_equal(max(more$time), 86400 * 15)
  expect_equal(min(more$time), 0)

  # time strictly increasing within each body, no duplicated handoff row
  planet <- more[more$id == "Planet", ]
  expect_true(all(diff(planet$time) > 0))
  expect_equal(sum(planet$time == 86400 * 10), 1)
})

test_that("a continued run matches an uninterrupted run with the same step", {
  sim  <- base_run()
  more <- continue_simulation(sim, time_step = 3600, duration = 86400 * 10)

  straight <- create_system() |>
    add_body("Star", mass = 1e30) |>
    add_body("Planet", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400 * 20)

  a <- more[more$id == "Planet", ]
  b <- straight[straight$id == "Planet", ]
  expect_equal(a$time, b$time)
  expect_equal(a$x, b$x, tolerance = 1e-10)
  expect_equal(a$vy, b$vy, tolerance = 1e-10)
})

test_that("the time step can change between segments", {
  sim  <- base_run()
  more <- continue_simulation(sim, time_step = 600, duration = 3600)

  planet <- more[more$id == "Planet", ]
  expect_equal(max(planet$time), 86400 * 10 + 3600)
  expect_equal(sum(planet$time > 86400 * 10), 6)
  expect_equal(attr(more, "time_step"), 600)
})

test_that("method, softening and G carry over from the previous segment", {
  sim <- create_system(G = 2 * gravitational_constant) |>
    add_body("Star", mass = 1e30) |>
    add_body("Planet", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400, method = "euler_cromer",
                    softening = 1e4)

  more <- continue_simulation(sim, time_step = 3600, duration = 86400)

  expect_equal(attr(more, "G"), 2 * gravitational_constant)
  expect_equal(attr(more, "method"), "euler_cromer")
  expect_equal(attr(more, "softening"), 1e4)
})

test_that("segmenting a comet's perihelion passage beats a uniform coarse step", {
  comet <- create_system() |>
    add_sun() |>
    add_body_keplerian("Comet", mass = 1e14, parent = "Sun",
                       a = 2 * distance_earth_sun, e = 0.9, nu = 180)
  period <- 2 * pi * sqrt((2 * distance_earth_sun)^3 /
                            (gravitational_constant * mass_sun))

  uniform <- simulate_system(comet, time_step = 86400 * 2, duration = period)
  segmented <- comet |>
    simulate_system(time_step = 86400 * 2, duration = period * 0.4) |>
    continue_simulation(time_step = 3600, duration = period * 0.2) |>
    continue_simulation(time_step = 86400 * 2, duration = period * 0.4)

  err_uniform   <- max(abs(conserved_quantities(uniform)$energy_error))
  err_segmented <- max(abs(conserved_quantities(segmented)$energy_error))

  expect_lt(err_segmented, err_uniform)
  expect_lt(err_segmented, 1e-3)
})

test_that("system_from_simulation rebuilds the last state by default", {
  sim <- base_run()
  sys <- system_from_simulation(sim)

  expect_s3_class(sys, "orbit_system")
  last <- sim[sim$time == max(sim$time), ]
  expect_equal(sys$bodies$id, last$id)
  expect_equal(sys$bodies$x, last$x)
  expect_equal(sys$bodies$vy, last$vy)
  expect_equal(sys$forces$gravity$G, gravitational_constant)
})

test_that("system_from_simulation snaps to the nearest time", {
  sim <- base_run()
  sys <- system_from_simulation(sim, time = 86400 * 3 + 100)

  at3 <- sim[sim$time == 86400 * 3, ]
  expect_equal(sys$bodies$x, at3$x)
})

test_that("continue_simulation rejects non-simulation input", {
  expect_error(continue_simulation(data.frame(a = 1), 1, 1), "simulate_system")
})
