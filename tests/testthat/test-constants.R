test_that("gravitational constant has correct value", {
  expect_equal(gravitational_constant, 6.6743e-11)
})

test_that("time constants have correct values", {
  expect_equal(seconds_per_hour, 3600)
  expect_equal(seconds_per_day, 86400)
  expect_equal(seconds_per_year, 86400 * 365.25)
})

test_that("mass constants are positive and reasonable", {
  masses <- list(
    mass_sun = mass_sun,
    mass_earth = mass_earth,
    mass_moon = mass_moon,
    mass_mars = mass_mars,
    mass_jupiter = mass_jupiter,
    mass_saturn = mass_saturn,
    mass_venus = mass_venus,
    mass_mercury = mass_mercury,
    mass_uranus = mass_uranus,
    mass_neptune = mass_neptune,
    mass_pluto = mass_pluto
  )

  for (name in names(masses)) {
    expect_true(masses[[name]] > 0, info = paste(name, "should be positive"))
    expect_true(is.numeric(masses[[name]]), info = paste(name, "should be numeric"))
  }

  # Sanity checks on relative ordering

  expect_true(mass_sun > mass_jupiter)
  expect_true(mass_jupiter > mass_saturn)
  expect_true(mass_saturn > mass_neptune)
  expect_true(mass_neptune > mass_uranus)
  expect_true(mass_earth > mass_moon)
  expect_true(mass_moon > mass_pluto)
})

test_that("distance constants are positive", {
  distances <- list(
    distance_earth_sun = distance_earth_sun,
    distance_earth_moon = distance_earth_moon,
    distance_mars_sun = distance_mars_sun,
    distance_jupiter_sun = distance_jupiter_sun,
    distance_venus_sun = distance_venus_sun,
    distance_mercury_sun = distance_mercury_sun,
    distance_saturn_sun = distance_saturn_sun,
    distance_uranus_sun = distance_uranus_sun,
    distance_neptune_sun = distance_neptune_sun,
    distance_pluto_sun = distance_pluto_sun
  )

  for (name in names(distances)) {
    expect_true(distances[[name]] > 0, info = paste(name, "should be positive"))
  }

  # Sanity: outer planets are farther from the Sun
  expect_true(distance_pluto_sun > distance_neptune_sun)
  expect_true(distance_neptune_sun > distance_uranus_sun)
  expect_true(distance_uranus_sun > distance_saturn_sun)
  expect_true(distance_saturn_sun > distance_jupiter_sun)
  expect_true(distance_jupiter_sun > distance_earth_sun)
  expect_true(distance_earth_sun > distance_venus_sun)
})

test_that("speed constants are positive", {
  speeds <- list(
    speed_earth = speed_earth,
    speed_moon = speed_moon,
    speed_mars = speed_mars,
    speed_jupiter = speed_jupiter,
    speed_venus = speed_venus,
    speed_mercury = speed_mercury,
    speed_saturn = speed_saturn,
    speed_uranus = speed_uranus,
    speed_neptune = speed_neptune,
    speed_pluto = speed_pluto
  )

  for (name in names(speeds)) {
    expect_true(speeds[[name]] > 0, info = paste(name, "should be positive"))
  }

  # Inner planets orbit faster than outer planets
  expect_true(speed_mercury > speed_earth)
  expect_true(speed_earth > speed_jupiter)
  expect_true(speed_jupiter > speed_saturn)
  expect_true(speed_saturn > speed_uranus)
  expect_true(speed_uranus > speed_neptune)
  expect_true(speed_neptune > speed_pluto)
})
