test_that("create_system returns an orbit_system", {
  sys <- create_system()
  expect_s3_class(sys, "orbit_system")
})

test_that("create_system has empty bodies tibble", {
  sys <- create_system()
  expect_equal(nrow(sys$bodies), 0)
  expect_true(tibble::is_tibble(sys$bodies))
  expect_equal(
    names(sys$bodies),
    c("id", "mass", "x", "y", "z", "vx", "vy", "vz")
  )
})

test_that("create_system uses default G", {
  sys <- create_system()
  expect_equal(sys$forces$gravity$G, gravitational_constant)
})

test_that("create_system accepts custom G", {
  sys <- create_system(G = 0)
  expect_equal(sys$forces$gravity$G, 0)

  sys10 <- create_system(G = gravitational_constant * 10)
  expect_equal(sys10$forces$gravity$G, gravitational_constant * 10)
})

test_that("create_system starts at time 0", {
  sys <- create_system()
  expect_equal(sys$time, 0)
})
