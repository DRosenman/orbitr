test_that("plot_orbits returns a ggplot for 2D data", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400)

  p <- plot_orbits(sim)
  expect_s3_class(p, "ggplot")
})

test_that("plot_orbits returns plotly for 3D data", {
  skip_if_not_installed("plotly")

  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000, vz = 1000) |>
    simulate_system(time_step = 3600, duration = 86400)

  p <- plot_orbits(sim)
  expect_s3_class(p, "plotly")
})

test_that("plot_orbits three_d = TRUE forces plotly", {
  skip_if_not_installed("plotly")

  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400)

  p <- plot_orbits(sim, three_d = TRUE)
  expect_s3_class(p, "plotly")
})

test_that("plot_system returns a ggplot for 2D data", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400)

  p <- plot_system(sim)
  expect_s3_class(p, "ggplot")
})

test_that("plot_system accepts time parameter", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400)

  expect_no_error(plot_system(sim, time = 3600))
  expect_no_error(plot_system(sim, time = 0))
})

test_that("plot_orbits_3d returns plotly", {
  skip_if_not_installed("plotly")

  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400)

  p <- plot_orbits_3d(sim)
  expect_s3_class(p, "plotly")
})
