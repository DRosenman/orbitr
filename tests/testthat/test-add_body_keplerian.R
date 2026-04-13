test_that("circular orbit produces correct distance and speed", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_body_keplerian(
      "Earth", mass = mass_earth,
      a = distance_earth_sun, e = 0,
      parent = "Sun"
    )

  earth <- sys$bodies[sys$bodies$id == "Earth", ]

  # For a circular orbit (e = 0, nu = 0), distance should equal the semi-major axis

  r <- sqrt(earth$x^2 + earth$y^2 + earth$z^2)
  expect_equal(r, distance_earth_sun, tolerance = 1e-6)

  # Speed should match the circular orbital velocity: v = sqrt(G * M / a)
  v <- sqrt(earth$vx^2 + earth$vy^2 + earth$vz^2)
  v_expected <- sqrt(gravitational_constant * mass_sun / distance_earth_sun)
  expect_equal(v, v_expected, tolerance = 1e-6)
})

test_that("periapsis placement is correct (nu = 0)", {

  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_body_keplerian(
      "test", mass = 1,
      a = 1e11, e = 0.5, i = 0, lan = 0, arg_pe = 0, nu = 0,
      parent = "Sun"
    )

  body <- sys$bodies[sys$bodies$id == "test", ]
  r <- sqrt(body$x^2 + body$y^2 + body$z^2)

  # At periapsis, r = a * (1 - e)
  expect_equal(r, 1e11 * (1 - 0.5), tolerance = 1e-6)
})

test_that("apoapsis placement is correct (nu = 180)", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_body_keplerian(
      "test", mass = 1,
      a = 1e11, e = 0.5, i = 0, lan = 0, arg_pe = 0, nu = 180,
      parent = "Sun"
    )

  body <- sys$bodies[sys$bodies$id == "test", ]
  r <- sqrt(body$x^2 + body$y^2 + body$z^2)

  # At apoapsis, r = a * (1 + e)
  expect_equal(r, 1e11 * (1 + 0.5), tolerance = 1e-6)
})

test_that("inclination tilts orbit out of XY plane", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_body_keplerian(
      "tilted", mass = 1,
      a = 1e11, e = 0, i = 90, lan = 0, arg_pe = 0, nu = 90,
      parent = "Sun"
    )

  body <- sys$bodies[sys$bodies$id == "tilted", ]

  # With i = 90 and nu = 90, the body should have significant z displacement
  expect_true(abs(body$z) > 1e10)
})

test_that("zero inclination stays in XY plane", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_body_keplerian(
      "flat", mass = 1,
      a = 1e11, e = 0.1, i = 0, lan = 0, arg_pe = 45, nu = 90,
      parent = "Sun"
    )

  body <- sys$bodies[sys$bodies$id == "flat", ]
  expect_equal(body$z, 0, tolerance = 1e-3)
  expect_equal(body$vz, 0, tolerance = 1e-3)
})

test_that("parent position and velocity are added", {
  sys <- create_system() |>
    add_body("Star", mass = mass_sun, x = 1e12, vy = 5000) |>
    add_body_keplerian(
      "Planet", mass = mass_earth,
      a = 1e11, e = 0, parent = "Star"
    )

  planet <- sys$bodies[sys$bodies$id == "Planet", ]

  # Planet's position should be offset by the star's position
  expect_true(planet$x > 1e12)
  # Planet's velocity should include the star's velocity
  expect_true(planet$vy > 5000)
})

test_that("add_body_keplerian rejects missing parent", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun)

  expect_error(
    add_body_keplerian(sys, "test", mass = 1, a = 1e11),
    "parent"
  )
})

test_that("add_body_keplerian rejects nonexistent parent", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun)

  expect_error(
    add_body_keplerian(sys, "test", mass = 1, a = 1e11, parent = "Jupiter"),
    "not found"
  )
})

test_that("add_body_keplerian rejects invalid eccentricity", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun)

  expect_error(
    add_body_keplerian(sys, "test", mass = 1, a = 1e11, e = 1.0, parent = "Sun"),
    "eccentricity"
  )
  expect_error(
    add_body_keplerian(sys, "test", mass = 1, a = 1e11, e = -0.1, parent = "Sun"),
    "eccentricity"
  )
})

test_that("add_body_keplerian rejects invalid semi-major axis", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun)

  expect_error(
    add_body_keplerian(sys, "test", mass = 1, a = -100, parent = "Sun"),
    "semi-major"
  )
})

test_that("add_body_keplerian preserves orbit_system class", {
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_body_keplerian("Earth", mass = mass_earth,
                        a = distance_earth_sun, e = 0.0167, parent = "Sun")

  expect_s3_class(sys, "orbit_system")
})

test_that("energy is approximately conserved for Keplerian setup", {
  # A body set up with Keplerian elements and simulated with Verlet
  # should conserve energy well — this validates the conversion is correct
  sys <- create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_body_keplerian(
      "Earth", mass = mass_earth,
      a = distance_earth_sun, e = 0.0167,
      parent = "Sun"
    )

  result <- simulate_system(sys,
    time_step = seconds_per_hour,
    duration  = seconds_per_year,
    method    = "verlet"
  )

  # Compute specific orbital energy at first and last time step
  G <- gravitational_constant

  first <- result[result$time == min(result$time) & result$id == "Earth", ]
  last  <- result[result$time == max(result$time) & result$id == "Earth", ]

  sun_first <- result[result$time == min(result$time) & result$id == "Sun", ]
  sun_last  <- result[result$time == max(result$time) & result$id == "Sun", ]

  ke_first <- 0.5 * (first$vx^2 + first$vy^2 + first$vz^2)
  r_first  <- sqrt((first$x - sun_first$x)^2 + (first$y - sun_first$y)^2 +
                    (first$z - sun_first$z)^2)
  pe_first <- -G * mass_sun / r_first
  E_first  <- ke_first + pe_first

  ke_last <- 0.5 * (last$vx^2 + last$vy^2 + last$vz^2)
  r_last  <- sqrt((last$x - sun_last$x)^2 + (last$y - sun_last$y)^2 +
                   (last$z - sun_last$z)^2)
  pe_last <- -G * mass_sun / r_last
  E_last  <- ke_last + pe_last

  # Energy should be conserved to within 0.1%
  expect_equal(E_last, E_first, tolerance = 0.001)
})
