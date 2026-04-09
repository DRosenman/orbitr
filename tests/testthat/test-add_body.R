test_that("add_body adds a body to the system", {
  sys <- create_system() |>
    add_body("Earth", mass = mass_earth)

  expect_equal(nrow(sys$bodies), 1)
  expect_equal(sys$bodies$id, "Earth")
  expect_equal(sys$bodies$mass, mass_earth)
})

test_that("add_body defaults position and velocity to zero", {
  sys <- create_system() |>
    add_body("test", mass = 1)

  expect_equal(sys$bodies$x, 0)
  expect_equal(sys$bodies$y, 0)
  expect_equal(sys$bodies$z, 0)
  expect_equal(sys$bodies$vx, 0)
  expect_equal(sys$bodies$vy, 0)
  expect_equal(sys$bodies$vz, 0)
})

test_that("add_body sets custom position and velocity", {
  sys <- create_system() |>
    add_body("test", mass = 1, x = 100, y = 200, z = 300, vx = 10, vy = 20, vz = 30)

  expect_equal(sys$bodies$x, 100)
  expect_equal(sys$bodies$y, 200)
  expect_equal(sys$bodies$z, 300)
  expect_equal(sys$bodies$vx, 10)
  expect_equal(sys$bodies$vy, 20)
  expect_equal(sys$bodies$vz, 30)
})

test_that("add_body can chain multiple bodies", {
  sys <- create_system() |>
    add_body("A", mass = 1) |>
    add_body("B", mass = 2) |>
    add_body("C", mass = 3)

  expect_equal(nrow(sys$bodies), 3)
  expect_equal(sys$bodies$id, c("A", "B", "C"))
})

test_that("add_body preserves orbit_system class", {
  sys <- create_system() |>
    add_body("test", mass = 1)

  expect_s3_class(sys, "orbit_system")
})

test_that("add_body rejects duplicate IDs", {
  sys <- create_system() |>
    add_body("Earth", mass = mass_earth)

  expect_error(add_body(sys, "Earth", mass = 1), "already exists")
})

test_that("add_body rejects non-orbit_system input", {
  expect_error(add_body(list(), "test", mass = 1), "orbit_system")
})

test_that("add_body rejects negative mass", {
  expect_error(
    create_system() |> add_body("test", mass = -1),
    "non-negative"
  )
})

test_that("add_body rejects non-numeric mass", {
  expect_error(
    create_system() |> add_body("test", mass = "heavy"),
    "numeric"
  )
})

test_that("add_body accepts zero mass", {
  sys <- create_system() |>
    add_body("massless", mass = 0)

  expect_equal(sys$bodies$mass, 0)
})
