test_that("shift_reference_frame centers the target body at origin", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400)

  shifted <- shift_reference_frame(sim, "A")

  a_data <- shifted[shifted$id == "A", ]
  expect_true(all(a_data$x == 0))
  expect_true(all(a_data$y == 0))
  expect_true(all(a_data$z == 0))
  expect_true(all(a_data$vx == 0))
  expect_true(all(a_data$vy == 0))
  expect_true(all(a_data$vz == 0))
})

test_that("shift_reference_frame preserves relative distances", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 3600)

  # Distance between A and B at t=0 should be the same before and after shift
  t0_orig <- sim[sim$time == 0, ]
  r_orig <- sqrt(
    (t0_orig$x[t0_orig$id == "A"] - t0_orig$x[t0_orig$id == "B"])^2 +
    (t0_orig$y[t0_orig$id == "A"] - t0_orig$y[t0_orig$id == "B"])^2
  )

  shifted <- shift_reference_frame(sim, "A")
  t0_shift <- shifted[shifted$time == 0, ]
  r_shift <- sqrt(
    (t0_shift$x[t0_shift$id == "A"] - t0_shift$x[t0_shift$id == "B"])^2 +
    (t0_shift$y[t0_shift$id == "A"] - t0_shift$y[t0_shift$id == "B"])^2
  )

  expect_equal(r_orig, r_shift)
})

test_that("shift_reference_frame keep_center = FALSE removes center body", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 3600)

  shifted <- shift_reference_frame(sim, "A", keep_center = FALSE)
  expect_false("A" %in% shifted$id)
  expect_true("B" %in% shifted$id)
})

test_that("shift_reference_frame keep_center = TRUE keeps center body", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 3600)

  shifted <- shift_reference_frame(sim, "A", keep_center = TRUE)
  expect_true("A" %in% shifted$id)
  expect_true("B" %in% shifted$id)
})

test_that("shift_reference_frame errors on unknown body", {
  sim <- create_system() |>
    add_body("A", mass = 1) |>
    simulate_system(time_step = 60, duration = 60)

  expect_error(shift_reference_frame(sim, "Z"), "not found")
})

test_that("shift_reference_frame preserves number of rows", {
  sim <- create_system() |>
    add_body("A", mass = 1e30) |>
    add_body("B", mass = 1e24, x = 1e11, vy = 30000) |>
    simulate_system(time_step = 3600, duration = 86400)

  shifted <- shift_reference_frame(sim, "A")
  expect_equal(nrow(shifted), nrow(sim))
})
