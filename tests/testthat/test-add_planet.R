test_that("add_planet adds a known body", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Earth", parent = "Sun")

  expect_equal(nrow(sys$bodies), 2)
  expect_true("Earth" %in% sys$bodies$id)
})

test_that("add_planet matches add_body_keplerian output", {
  sys_planet <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Mars", parent = "Sun")

  sys_manual <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_body_keplerian(
      "Mars", mass = mass_mars, parent = "Sun",
      a = distance_mars_sun, e = 0.0934,
      i = 1.85, lan = 49.58, arg_pe = 286.50, nu = 0
    )

  mars_p <- sys_planet$bodies[sys_planet$bodies$id == "Mars", ]
  mars_m <- sys_manual$bodies[sys_manual$bodies$id == "Mars", ]

  expect_equal(mars_p$x, mars_m$x)
  expect_equal(mars_p$y, mars_m$y)
  expect_equal(mars_p$z, mars_m$z)
  expect_equal(mars_p$vx, mars_m$vx)
  expect_equal(mars_p$vy, mars_m$vy)
  expect_equal(mars_p$vz, mars_m$vz)
})

test_that("add_planet works for Moon with Earth as parent", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Earth", parent = "Sun") |>
    add_planet("Moon", parent = "Earth")

  expect_equal(nrow(sys$bodies), 3)
  expect_true("Moon" %in% sys$bodies$id)
})

test_that("add_planet chains all planets", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Mercury", parent = "Sun") |>
    add_planet("Venus",   parent = "Sun") |>
    add_planet("Earth",   parent = "Sun") |>
    add_planet("Mars",    parent = "Sun") |>
    add_planet("Jupiter", parent = "Sun") |>
    add_planet("Saturn",  parent = "Sun") |>
    add_planet("Uranus",  parent = "Sun") |>
    add_planet("Neptune", parent = "Sun") |>
    add_planet("Pluto",   parent = "Sun")

  expect_equal(nrow(sys$bodies), 10)
})

test_that("add_planet allows overriding eccentricity", {
  sys_default <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Mars", parent = "Sun")

  sys_circular <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Mars", parent = "Sun", e = 0)

  mars_d <- sys_default$bodies[sys_default$bodies$id == "Mars", ]
  mars_c <- sys_circular$bodies[sys_circular$bodies$id == "Mars", ]

  # Both should be at the same distance (nu = 0 for both, but e differs)
  r_d <- sqrt(mars_d$x^2 + mars_d$y^2 + mars_d$z^2)
  r_c <- sqrt(mars_c$x^2 + mars_c$y^2 + mars_c$z^2)

  # Circular orbit at periapsis: r = a. Eccentric orbit at periapsis: r = a(1-e).
  expect_true(r_c > r_d)
})

test_that("add_planet allows overriding mass", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Jupiter", parent = "Sun", mass = mass_jupiter * 2)

  jup <- sys$bodies[sys$bodies$id == "Jupiter", ]
  expect_equal(jup$mass, mass_jupiter * 2)
})

test_that("add_planet allows overriding true anomaly", {
  sys_0 <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Earth", parent = "Sun", nu = 0)

  sys_90 <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Earth", parent = "Sun", nu = 90)

  earth_0  <- sys_0$bodies[sys_0$bodies$id == "Earth", ]
  earth_90 <- sys_90$bodies[sys_90$bodies$id == "Earth", ]

  # Different nu should give different positions
  expect_false(earth_0$x == earth_90$x)
  expect_false(earth_0$y == earth_90$y)
})

test_that("add_planet rejects unknown body", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun)

  expect_error(add_planet(sys, "Vulcan", parent = "Sun"), "not a recognized")
})

test_that("add_planet rejects missing parent", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun)

  expect_error(add_planet(sys, "Earth"), "parent")
})

test_that("add_planet preserves orbit_system class", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Earth", parent = "Sun")

  expect_s3_class(sys, "orbit_system")
})
