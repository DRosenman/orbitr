#' Save an orbit_system to disk
#'
#' Saves the full `orbit_system` object (bodies, forces, and time) to an
#' `.rds` file so it can be restored later with [load_system()]. This
#' preserves everything — the gravitational constant, body states, and
#' class — exactly as it was.
#'
#' @param system An `orbit_system` object.
#' @param path File path to save to. Should end in `.rds`.
#'
#' @return `system`, invisibly.
#' @export
#'
#' @examples
#' \donttest{
#' sys <- create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun")
#'
#' save_system(sys, file.path(tempdir(), "my_system.rds"))
#' }
save_system <- function(system, path) {
  if (!inherits(system, "orbit_system")) stop("Input must be an `orbit_system`.")
  saveRDS(system, file = path)
  invisible(system)
}


#' Load an orbit_system from disk
#'
#' Restores an `orbit_system` previously saved with [save_system()].
#'
#' @param path File path to an `.rds` file created by [save_system()].
#'
#' @return An `orbit_system` object.
#' @export
#'
#' @examples
#' \donttest{
#' sys <- create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun")
#'
#' path <- file.path(tempdir(), "my_system.rds")
#' save_system(sys, path)
#' restored <- load_system(path)
#' }
load_system <- function(path) {
  if (!file.exists(path)) stop(sprintf("File not found: %s", path))
  obj <- readRDS(path)
  if (!inherits(obj, "orbit_system")) {
    stop("The file does not contain an `orbit_system` object.")
  }
  obj
}


#' Export body states to CSV
#'
#' Writes the body table (id, mass, position, and velocity) from an
#' `orbit_system` to a CSV file. This is useful for sharing initial
#' conditions with collaborators or loading them into other tools like
#' Python or Excel.
#'
#'
#' @param system An `orbit_system` object.
#' @param path File path to save to. Should end in `.csv`.
#'
#' @return `system`, invisibly.
#' @export
#'
#' @examples
#' \donttest{
#' sys <- create_system() |>
#'   add_sun() |>
#'   add_planet("Earth", parent = "Sun") |>
#'   add_planet("Mars",  parent = "Sun")
#'
#' export_bodies(sys, file.path(tempdir(), "bodies.csv"))
#' }
export_bodies <- function(system, path) {
  if (!inherits(system, "orbit_system")) stop("Input must be an `orbit_system`.")
  utils::write.csv(system$bodies, file = path, row.names = FALSE)
  invisible(system)
}
