test_that("save_system and load_system roundtrip", {
  sys <- create_system() |>
    add_sun() |>
    add_planet("Earth", parent = "Sun")

  path <- file.path(tempdir(), "test_system.rds")
  on.exit(unlink(path), add = TRUE)

  save_system(sys, path)
  expect_true(file.exists(path))

  restored <- load_system(path)
  expect_s3_class(restored, "orbit_system")
  expect_equal(restored$bodies$id, sys$bodies$id)
  expect_equal(restored$bodies$mass, sys$bodies$mass)
  expect_equal(restored$forces$gravity$G, sys$forces$gravity$G)
})

test_that("save_system returns invisibly", {
  sys <- create_system() |> add_body("A", mass = 1)
  path <- file.path(tempdir(), "test_invisible.rds")
  on.exit(unlink(path), add = TRUE)

  expect_invisible(save_system(sys, path))
})

test_that("save_system errors on non-orbit_system", {
  expect_error(save_system(list(), "test.rds"), "orbit_system")
})

test_that("load_system errors on missing file", {
  expect_error(load_system("nonexistent.rds"), "not found")
})

test_that("load_system errors on non-orbit_system rds", {
  path <- file.path(tempdir(), "test_bad.rds")
  on.exit(unlink(path), add = TRUE)

  saveRDS(list(a = 1), path)
  expect_error(load_system(path), "orbit_system")
})

test_that("export_bodies writes a valid CSV", {
  sys <- create_system() |>
    add_sun() |>
    add_planet("Earth", parent = "Sun") |>
    add_planet("Mars",  parent = "Sun")

  path <- file.path(tempdir(), "test_bodies.csv")
  on.exit(unlink(path), add = TRUE)

  export_bodies(sys, path)
  expect_true(file.exists(path))

  df <- utils::read.csv(path)
  expect_equal(nrow(df), 3)
  expect_equal(df$id, c("Sun", "Earth", "Mars"))
  expect_true(all(c("id", "mass", "x", "y", "z", "vx", "vy", "vz") %in% names(df)))
})

test_that("export_bodies returns invisibly", {
  sys <- create_system() |> add_body("A", mass = 1)
  path <- file.path(tempdir(), "test_export_inv.csv")
  on.exit(unlink(path), add = TRUE)

  expect_invisible(export_bodies(sys, path))
})

test_that("export_bodies errors on non-orbit_system", {
  expect_error(export_bodies(list(), "test.csv"), "orbit_system")
})
