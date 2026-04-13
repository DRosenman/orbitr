test_that("load_solar_system returns an orbit_system", {
  sys <- load_solar_system()
  expect_s3_class(sys, "orbit_system")
})

test_that("load_solar_system includes all bodies by default", {
  sys <- load_solar_system()
  expected <- c("Sun", "Mercury", "Venus", "Earth", "Mars",
                "Jupiter", "Saturn", "Uranus", "Neptune", "Moon", "Pluto")
  expect_true(all(expected %in% sys$bodies$id))
  expect_equal(nrow(sys$bodies), length(expected))
})

test_that("load_solar_system can exclude Moon", {
  sys <- load_solar_system(moon = FALSE)
  expect_false("Moon" %in% sys$bodies$id)
  expect_equal(nrow(sys$bodies), 10) # Sun + 8 planets + Pluto
})

test_that("load_solar_system can exclude Pluto", {
  sys <- load_solar_system(pluto = FALSE)
  expect_false("Pluto" %in% sys$bodies$id)
  expect_equal(nrow(sys$bodies), 10) # Sun + 8 planets + Moon
})

test_that("load_solar_system can exclude both Moon and Pluto", {
  sys <- load_solar_system(moon = FALSE, pluto = FALSE)
  expect_equal(nrow(sys$bodies), 9) # Sun + 8 planets
  expect_false("Moon" %in% sys$bodies$id)
  expect_false("Pluto" %in% sys$bodies$id)
})

test_that("planets are at reasonable distances from the Sun", {
  sys <- load_solar_system(moon = FALSE, pluto = FALSE)
  sun <- sys$bodies[sys$bodies$id == "Sun", ]

  for (pid in c("Mercury", "Venus", "Earth", "Mars",
                "Jupiter", "Saturn", "Uranus", "Neptune")) {
    body <- sys$bodies[sys$bodies$id == pid, ]
    r <- sqrt((body$x - sun$x)^2 + (body$y - sun$y)^2 + (body$z - sun$z)^2)

    # Distance should be within 30% of the semi-major axis
    # (because eccentricity means periapsis < a)
    a_lookup <- switch(pid,
      Mercury = distance_mercury_sun, Venus = distance_venus_sun,
      Earth = distance_earth_sun, Mars = distance_mars_sun,
      Jupiter = distance_jupiter_sun, Saturn = distance_saturn_sun,
      Uranus = distance_uranus_sun, Neptune = distance_neptune_sun
    )
    expect_true(r > a_lookup * 0.7, label = paste(pid, "too close"))
    expect_true(r < a_lookup * 1.3, label = paste(pid, "too far"))
  }
})

test_that("planets have reasonable orbital speeds", {
  sys <- load_solar_system(moon = FALSE, pluto = FALSE)
  sun <- sys$bodies[sys$bodies$id == "Sun", ]

  for (pid in c("Mercury", "Venus", "Earth", "Mars",
                "Jupiter", "Saturn", "Uranus", "Neptune")) {
    body <- sys$bodies[sys$bodies$id == pid, ]
    v <- sqrt((body$vx - sun$vx)^2 + (body$vy - sun$vy)^2 +
              (body$vz - sun$vz)^2)

    v_lookup <- switch(pid,
      Mercury = speed_mercury, Venus = speed_venus,
      Earth = speed_earth, Mars = speed_mars,
      Jupiter = speed_jupiter, Saturn = speed_saturn,
      Uranus = speed_uranus, Neptune = speed_neptune
    )

    # Speed should be within 30% of the mean orbital speed
    expect_true(v > v_lookup * 0.7, label = paste(pid, "too slow"))
    expect_true(v < v_lookup * 1.3, label = paste(pid, "too fast"))
  }
})

test_that("load_solar_system is simulatable", {
  sys <- load_solar_system(moon = FALSE, pluto = FALSE)

  # Should run without error for a short simulation
  result <- simulate_system(sys,
    time_step = seconds_per_day,
    duration  = seconds_per_day * 30
  )

  expect_true(nrow(result) > 0)
  expect_true("time" %in% names(result))
})
