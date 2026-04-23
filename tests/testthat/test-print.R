test_that("print.orbit_system prints empty system", {
  sys <- create_system()
  out <- capture.output(print(sys))
  expect_true(any(grepl("orbit_system", out)))
  expect_true(any(grepl("none", out)))
  expect_true(any(grepl("standard", out)))
})

test_that("print.orbit_system prints system with bodies", {
  sys <- create_system() |>
    add_sun() |>
    add_planet("Earth", parent = "Sun")

  out <- capture.output(print(sys))
  expect_true(any(grepl("orbit_system", out)))
  expect_true(any(grepl("Bodies: 2", out)))
  expect_true(any(grepl("Sun", out)))
  expect_true(any(grepl("Earth", out)))
})

test_that("print.orbit_system shows custom G", {
  sys <- create_system(G = 1.0)
  out <- capture.output(print(sys))
  expect_true(any(grepl("1", out)))
  expect_false(any(grepl("standard", out)))
})

test_that("print.orbit_system shows zero gravity", {
  sys <- create_system(G = 0)
  out <- capture.output(print(sys))
  expect_true(any(grepl("no gravity", out)))
})

test_that("print.orbit_system returns invisibly", {
  sys <- create_system()
  expect_invisible(print(sys))
})
