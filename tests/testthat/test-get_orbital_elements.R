mars_elements <- list(a = distance_mars_sun, e = 0.0934, i = 1.85,
                      lan = 49.6, arg_pe = 286.5, nu = 120)

mars_sim <- function(duration = 86400) {
  create_system() |>
    add_sun() |>
    add_body_keplerian("Mars", mass = mass_mars, parent = "Sun",
                       a = mars_elements$a, e = mars_elements$e,
                       i = mars_elements$i, lan = mars_elements$lan,
                       arg_pe = mars_elements$arg_pe, nu = mars_elements$nu) |>
    simulate_system(time_step = 86400, duration = duration)
}

test_that("elements round-trip through add_body_keplerian at t = 0", {
  el <- get_orbital_elements(mars_sim(), "Mars", "Sun")[1, ]

  expect_equal(el$a, mars_elements$a, tolerance = 1e-8)
  expect_equal(el$e, mars_elements$e, tolerance = 1e-8)
  expect_equal(el$i, mars_elements$i, tolerance = 1e-8)
  expect_equal(el$lan, mars_elements$lan, tolerance = 1e-8)
  expect_equal(el$arg_pe, mars_elements$arg_pe, tolerance = 1e-8)
  expect_equal(el$nu, mars_elements$nu, tolerance = 1e-8)
  expect_equal(el$period,
               2 * pi * sqrt(mars_elements$a^3 / (gravitational_constant * mass_sun)),
               tolerance = 1e-8)
})

test_that("elements are constant along a two-body orbit", {
  el <- get_orbital_elements(mars_sim(duration = 86400 * 687), "Mars", "Sun")

  expect_equal(nrow(el), 688)
  expect_lt(max(el$a) - min(el$a), 1e-3 * mars_elements$a)
  expect_lt(max(el$e) - min(el$e), 1e-3)
  expect_lt(max(el$i) - min(el$i), 1e-6)
  # true anomaly advances through a full turn
  expect_gt(max(el$nu) - min(el$nu), 350)
})

test_that("flat and circular orbits use the documented conventions", {
  sim <- create_system() |>
    add_sun() |>
    add_body_keplerian("Flat", mass = 1, parent = "Sun",
                       a = 1e11, e = 0.3, i = 0, lan = 0, arg_pe = 40, nu = 25) |>
    add_body_keplerian("Circle", mass = 1, parent = "Sun",
                       a = 1e11, e = 0, i = 30, lan = 70, arg_pe = 0, nu = 15) |>
    simulate_system(time_step = 3600, duration = 3600)

  flat <- get_orbital_elements(sim, "Flat", "Sun")[1, ]
  expect_equal(flat$i, 0, tolerance = 1e-8)
  expect_equal(flat$lan, 0)
  expect_equal(flat$arg_pe, 40, tolerance = 1e-8)   # measured from the x axis
  expect_equal(flat$nu, 25, tolerance = 1e-8)

  circle <- get_orbital_elements(sim, "Circle", "Sun")[1, ]
  expect_lt(circle$e, 1e-9)
  expect_equal(circle$i, 30, tolerance = 1e-8)
  expect_equal(circle$lan, 70, tolerance = 1e-8)
  expect_equal(circle$arg_pe, 0)
  expect_equal(circle$nu, 15, tolerance = 1e-6)      # measured from the node
})

test_that("a hyperbolic orbit keeps its elements and has no period", {
  q <- 0.3 * distance_earth_sun
  e <- 1.5
  sim <- create_system() |>
    add_sun() |>
    add_body_keplerian("Visitor", mass = 1e10, parent = "Sun",
                       a = -q / (e - 1), e = e, i = 20, nu = -100) |>
    simulate_system(time_step = 3600 * 3, duration = 86400 * 200)

  el <- get_orbital_elements(sim, "Visitor", "Sun")
  expect_true(all(el$a < 0))
  expect_true(all(is.na(el$period)))
  expect_lt(max(el$e) - min(el$e), 1e-3)
  expect_equal(el$e[1], e, tolerance = 1e-8)
  expect_equal(el$a[1], -q / (e - 1), tolerance = 1e-8)
})

test_that("mu can be overridden", {
  sim <- mars_sim()
  mu <- gravitational_constant * (mass_sun + mass_mars)
  el_default <- get_orbital_elements(sim, "Mars", "Sun")[1, ]
  el_full    <- get_orbital_elements(sim, "Mars", "Sun", mu = mu)[1, ]

  expect_false(isTRUE(all.equal(el_default$a, el_full$a, tolerance = 1e-12)))
  expect_equal(el_full$a, el_default$a, tolerance = 1e-5)   # tiny difference for Mars
})

test_that("get_orbital_elements validates its inputs", {
  sim <- mars_sim()
  expect_error(get_orbital_elements(sim, "Venus", "Sun"), "not found")
  expect_error(get_orbital_elements(sim, "Mars", "Mars"), "different")
  expect_error(get_orbital_elements(data.frame(a = 1), "A", "B"), "simulate_system")
})
