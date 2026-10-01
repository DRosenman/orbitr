two_body <- function(method = "verlet", time_step = 3600 * 6,
                     duration = 86400 * 400) {
  create_system() |>
    add_body("Star", mass = 1e30) |>
    add_body("Planet", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = time_step, duration = duration, method = method)
}

test_that("get_energy matches a hand calculation at t = 0", {
  en <- get_energy(two_body(duration = 3600 * 6))

  expect_true(tibble::is_tibble(en))
  expect_equal(names(en), c("time", "kinetic", "potential", "energy"))
  expect_equal(en$kinetic[1], 0.5 * 1e24 * 30000^2)
  expect_equal(en$potential[1], -gravitational_constant * 1e30 * 1e24 / 1e11)
  expect_equal(en$energy[1], en$kinetic[1] + en$potential[1])
})

test_that("get_momentum and get_angular_momentum match hand calculations", {
  sim <- two_body(duration = 3600 * 6)
  p <- get_momentum(sim)
  L <- get_angular_momentum(sim)

  expect_equal(names(p), c("time", "px", "py", "pz"))
  expect_equal(names(L), c("time", "Lx", "Ly", "Lz"))
  expect_equal(p$py[1], 1e24 * 30000)
  expect_equal(p$px[1], 0)
  expect_equal(L$Lz[1], 1e24 * 1e11 * 30000)
  expect_equal(L$Lx[1], 0)
  expect_equal(nrow(p), length(unique(sim$time)))
})

test_that("a balanced binary has zero momentum and constant angular momentum", {
  sim <- create_system() |>
    add_body("A", mass = 2e30, x = 5e10, vy = 15000) |>
    add_body("B", mass = 1e30, x = -1e11, vy = -30000) |>
    simulate_system(time_step = 3600, duration = 86400 * 30)

  p <- get_momentum(sim)
  L <- get_angular_momentum(sim)
  expect_lt(max(abs(c(p$px, p$py, p$pz))), 1e-6 * 2e30 * 15000)
  expect_lt((max(L$Lz) - min(L$Lz)) / abs(L$Lz[1]), 1e-12)
})

test_that("conserved_quantities returns one row per step with the right columns", {
  sim <- two_body(duration = 86400 * 10)
  cq <- conserved_quantities(sim)

  expect_equal(nrow(cq), length(unique(sim$time)))
  expect_true(all(c("time", "kinetic", "potential", "energy",
                    "px", "py", "pz", "Lx", "Ly", "Lz",
                    "energy_error", "momentum_error",
                    "angular_momentum_error") %in% names(cq)))
  expect_equal(cq$energy_error[1], 0)
  expect_equal(cq$momentum_error[1], 0)
  expect_equal(cq$angular_momentum_error[1], 0)
})

test_that("Verlet keeps energy bounded and momenta at rounding level", {
  cq <- conserved_quantities(two_body())

  expect_lt(max(abs(cq$energy_error)), 1e-4)
  expect_lt(max(cq$momentum_error), 1e-10)
  expect_lt(max(cq$angular_momentum_error), 1e-10)
})

test_that("Euler pumps energy into the orbit", {
  cq <- conserved_quantities(two_body(method = "euler"))

  expect_gt(cq$energy_error[nrow(cq)], 1e-3)
  expect_gt(cq$energy_error[nrow(cq)], cq$energy_error[nrow(cq) %/% 2])
})

test_that("energy error scales as the square of the time step for Verlet", {
  coarse <- conserved_quantities(two_body(time_step = 3600 * 12))
  fine   <- conserved_quantities(two_body(time_step = 3600 * 6))

  ratio <- max(abs(coarse$energy_error)) / max(abs(fine$energy_error))
  expect_gt(ratio, 2.5)
  expect_lt(ratio, 6)
})

test_that("softening is read from the run and matches the force law", {
  sys <- create_system() |>
    add_body("A", mass = 1e30, x = -1e10, vx = 5e4) |>
    add_body("B", mass = 1e30, x = 1e10, vx = -5e4, y = 2e9)
  sim <- simulate_system(sys, time_step = 600, duration = 86400 * 2,
                         softening = 3e9)

  with_soft <- conserved_quantities(sim)              # softening read from attribute
  without   <- conserved_quantities(sim, softening = 0)

  expect_equal(attr(sim, "softening"), 3e9)
  expect_lt(max(abs(with_soft$energy_error)), 0.05)
  expect_gt(max(abs(without$energy_error)), max(abs(with_soft$energy_error)))
})

test_that("G = 0 gives zero potential energy", {
  sim <- create_system(G = 0) |>
    add_body("A", mass = 1, x = 0, vx = 1) |>
    add_body("B", mass = 1, x = 10, vx = -1) |>
    simulate_system(time_step = 1, duration = 10)

  expect_true(all(get_energy(sim)$potential == 0))
  expect_true(all(conserved_quantities(sim)$energy_error == 0))
})

test_that("the energy functions reject non-simulation input", {
  expect_error(get_energy(data.frame(a = 1)), "simulate_system")
  expect_error(get_momentum(data.frame(a = 1)), "simulate_system")
  expect_error(conserved_quantities(data.frame(a = 1)), "simulate_system")
})
