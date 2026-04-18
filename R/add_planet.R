#' Add a known solar system body by name
#'
#' A convenience wrapper around [add_body_keplerian()] that looks up real
#' orbital elements for well-known solar system bodies. Instead of typing out
#' mass, semi-major axis, eccentricity, and inclination by hand, just give
#' the name and parent:
#'
#' ```
#' create_system() |>
#'   add_body("Sun", mass = mass_sun) |>
#'   add_planet("Earth", parent = "Sun") |>
#'   add_planet("Moon", parent = "Earth")
#' ```
#'
#' Any Keplerian element can be overridden to explore "what if" scenarios
#' while keeping the rest of the real values:
#'
#' ```
#' # What if Mars had zero eccentricity?
#' add_planet("Mars", parent = "Sun", e = 0)
#' ```
#'
#' @param system An `orbit_system` object.
#' @param name The name of the body. Must be one of: `"Mercury"`, `"Venus"`,
#'   `"Earth"`, `"Mars"`, `"Jupiter"`, `"Saturn"`, `"Uranus"`, `"Neptune"`,
#'   `"Moon"`, or `"Pluto"`. Case-sensitive.
#' @param parent Character id of the parent body, which must already exist in
#'   the system. For planets and Pluto this is typically `"Sun"`; for the Moon
#'   it is `"Earth"`.
#' @param nu True anomaly in degrees (default 0, body starts at periapsis).
#'   This is the most commonly overridden element — use it to spread planets
#'   around their orbits instead of starting them all at periapsis.
#' @param a Override semi-major axis (meters).
#' @param e Override eccentricity.
#' @param i Override inclination (degrees).
#' @param lan Override longitude of ascending node (degrees).
#' @param arg_pe Override argument of periapsis (degrees).
#' @param mass Override mass (kg).
#'
#' @return The updated `orbit_system` with the body added.
#' @export
#'
#' @examples
#' \donttest{
#' # Build the inner solar system
#' create_system() |>
#'   add_body("Sun", mass = mass_sun) |>
#'   add_planet("Mercury", parent = "Sun") |>
#'   add_planet("Venus",   parent = "Sun") |>
#'   add_planet("Earth",   parent = "Sun") |>
#'   add_planet("Mars",    parent = "Sun") |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_year) |>
#'   plot_orbits()
#'
#' # Earth-Moon system
#' create_system() |>
#'   add_body("Earth", mass = mass_earth) |>
#'   add_planet("Moon", parent = "Earth") |>
#'   simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 28) |>
#'   plot_orbits()
#'
#' # What if Jupiter were twice as massive?
#' add_planet("Jupiter", parent = "Sun", mass = mass_jupiter * 2)
#' }
add_planet <- function(system, name, parent, nu = 0,
                       a = NULL, e = NULL, i = NULL,
                       lan = NULL, arg_pe = NULL, mass = NULL) {

  if (!inherits(system, "orbit_system")) stop("Input must be an `orbit_system`.")
  if (missing(parent)) stop("`parent` must be specified.")

  # Case-insensitive parent matching
  parent_match <- match(tolower(parent), tolower(system$bodies$id))
  if (is.na(parent_match)) {
    stop(sprintf("Parent body '%s' not found in system.", parent))
  }
  parent <- system$bodies$id[parent_match]

  # --- Lookup table: JPL DE440 / NASA Fact Sheet mean elements (J2000) ---
  catalog <- list(
    Mercury = list(
      mass = mass_mercury, a = distance_mercury_sun, e = 0.2056,
      i = 7.00, lan = 48.33, arg_pe = 29.12
    ),
    Venus = list(
      mass = mass_venus, a = distance_venus_sun, e = 0.0068,
      i = 3.39, lan = 76.68, arg_pe = 54.88
    ),
    Earth = list(
      mass = mass_earth, a = distance_earth_sun, e = 0.0167,
      i = 0.00, lan = -11.26, arg_pe = 114.21
    ),
    Mars = list(
      mass = mass_mars, a = distance_mars_sun, e = 0.0934,
      i = 1.85, lan = 49.58, arg_pe = 286.50
    ),
    Jupiter = list(
      mass = mass_jupiter, a = distance_jupiter_sun, e = 0.0489,
      i = 1.30, lan = 100.46, arg_pe = 273.87
    ),
    Saturn = list(
      mass = mass_saturn, a = distance_saturn_sun, e = 0.0565,
      i = 2.49, lan = 113.72, arg_pe = 339.39
    ),
    Uranus = list(
      mass = mass_uranus, a = distance_uranus_sun, e = 0.0457,
      i = 0.77, lan = 74.23, arg_pe = 96.99
    ),
    Neptune = list(
      mass = mass_neptune, a = distance_neptune_sun, e = 0.0113,
      i = 1.77, lan = 131.72, arg_pe = 273.19
    ),
    Moon = list(
      mass = mass_moon, a = distance_earth_moon, e = 0.0549,
      i = 5.15, lan = 125.08, arg_pe = 318.15
    ),
    Pluto = list(
      mass = mass_pluto, a = distance_pluto_sun, e = 0.2488,
      i = 17.16, lan = 110.30, arg_pe = 113.83
    )
  )

  # Case-insensitive name matching
  catalog_match <- match(tolower(name), tolower(names(catalog)))
  if (is.na(catalog_match)) {
    stop(sprintf(
      "'%s' is not a recognized body. Available: %s.",
      name, paste(names(catalog), collapse = ", ")
    ))
  }
  canonical_name <- names(catalog)[catalog_match]
  body <- catalog[[canonical_name]]

  # Apply any user overrides
  if (!is.null(mass))   body$mass   <- mass
  if (!is.null(a))      body$a      <- a
  if (!is.null(e))      body$e      <- e
  if (!is.null(i))      body$i      <- i
  if (!is.null(lan))    body$lan    <- lan
  if (!is.null(arg_pe)) body$arg_pe <- arg_pe

  add_body_keplerian(
    system, id = canonical_name, mass = body$mass, parent = parent,
    a = body$a, e = body$e, i = body$i,
    lan = body$lan, arg_pe = body$arg_pe, nu = nu
  )
}
