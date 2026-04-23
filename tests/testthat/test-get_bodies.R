test_that("get_bodies returns the bodies tibble", {
  sys <- create_system() |>
    add_sun() |>
    add_planet("Earth", parent = "Sun")

  bodies <- get_bodies(sys)
  expect_s3_class(bodies, "tbl_df")
  expect_equal(nrow(bodies), 2)
  expect_equal(bodies$id, c("Sun", "Earth"))
  expect_true(all(c("id", "mass", "x", "y", "z", "vx", "vy", "vz") %in% names(bodies)))
})

test_that("get_bodies returns empty tibble for empty system", {
  bodies <- get_bodies(create_system())
  expect_s3_class(bodies, "tbl_df")
  expect_equal(nrow(bodies), 0)
})

test_that("get_bodies errors on non-orbit_system", {
  expect_error(get_bodies(list()), "orbit_system")
})
