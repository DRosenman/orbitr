test_that("remove_body removes a single body", {
  sys <- create_system() |>
    add_body("A", mass = 1) |>
    add_body("B", mass = 2) |>
    add_body("C", mass = 3)

  result <- remove_body(sys, "B")
  expect_equal(nrow(result$bodies), 2)
  expect_equal(result$bodies$id, c("A", "C"))
})

test_that("remove_body removes multiple bodies", {
  sys <- create_system() |>
    add_body("A", mass = 1) |>
    add_body("B", mass = 2) |>
    add_body("C", mass = 3)

  result <- remove_body(sys, c("A", "C"))
  expect_equal(nrow(result$bodies), 1)
  expect_equal(result$bodies$id, "B")
})

test_that("remove_body errors on non-existent body", {
  sys <- create_system() |>
    add_body("A", mass = 1)

  expect_error(remove_body(sys, "Z"), "not found")
})

test_that("remove_body errors on non-existent body in mixed vector", {
  sys <- create_system() |>
    add_body("A", mass = 1) |>
    add_body("B", mass = 2)

  expect_error(remove_body(sys, c("A", "Z")), "not found")
  # System should be unchanged since the call errored
  expect_equal(nrow(sys$bodies), 2)
})

test_that("remove_body errors on non-orbit_system input", {
  expect_error(remove_body(list(), "A"), "orbit_system")
})

test_that("remove_body errors on empty id vector", {
  sys <- create_system() |>
    add_body("A", mass = 1)

  expect_error(remove_body(sys, character(0)), "non-empty")
})

test_that("remove_body errors on non-character id", {
  sys <- create_system() |>
    add_body("A", mass = 1)

  expect_error(remove_body(sys, 1), "non-empty character")
})

test_that("remove_body preserves orbit_system class", {
  sys <- create_system() |>
    add_body("A", mass = 1) |>
    add_body("B", mass = 2)

  result <- remove_body(sys, "A")
  expect_s3_class(result, "orbit_system")
})

test_that("remove_body preserves system properties", {
  sys <- create_system(G = 1.0) |>
    add_body("A", mass = 1) |>
    add_body("B", mass = 2)

  result <- remove_body(sys, "A")
  expect_equal(result$forces$gravity$G, 1.0)
  expect_equal(result$time, 0)
})

test_that("remove_body works in a pipe with add_planet", {
  sys <- create_system() |>
    add_sun() |>
    add_planet("Earth", parent = "Sun") |>
    add_planet("Mars",  parent = "Sun") |>
    remove_body("Mars")

  expect_equal(sys$bodies$id, c("Sun", "Earth"))
})
