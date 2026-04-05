#' @useDynLib orbitr, .registration = TRUE
#' @importFrom Rcpp sourceCpp
NULL

#' Initialize an orbitr simulation system
#'
#' Sets up the foundational data structure for an orbital simulation. Universal
#' N-body gravity is automatically integrated into the system using the specified
#' gravitational constant.
#'
#' @param G The gravitational constant. Defaults to standard physics (6.6743e-11).
#'   To simulate a zero-gravity environment (inertia only), set `G = 0`.
#' @return An empty `orbit_system` object ready for bodies to be added.
#' @export
#'
#' @examples
#' # Creates a system with standard gravity
#' my_universe <- create_system()
#'
#' # Creates a universe with 10x stronger gravity
#' heavy_universe <- create_system(G = 6.6743e-10)
#'
#' # Creates a zero-gravity sandbox
#' floating_universe <- create_system(G = 0)
create_system <- function(G = 6.6743e-11) {
  sys <- list(
    bodies = tibble::tibble(
      id = character(), mass = numeric(),
      x = numeric(), y = numeric(), z = numeric(),
      vx = numeric(), vy = numeric(), vz = numeric()
    ),
    forces = list(
      gravity = list(type = "n_body_gravity", G = G)
    ),
    time = 0
  )

  structure(sys, class = "orbit_system")
}
