#' Physical Constants for Orbital Mechanics
#'
#' @description
#' A curated set of real-world masses and orbital distances for use as convenient
#' starting points in `orbitr` simulations. All values are in SI units (kilograms
#' and meters).
#'
#' @section A Note on "Distance" Constants:
#' Orbital distances are not truly constant. Every orbit is an ellipse, so the
#' separation between two bodies changes continuously. The distances provided here
#' are **semi-major axes** — the average of the closest approach (periapsis) and
#' farthest point (apoapsis). The semi-major axis is the single most characteristic
#' length scale of an elliptical orbit: it determines the orbital period via Kepler's
#' Third Law, and when paired with the circular velocity at that distance, it produces
#' a near-circular orbit that closely approximates the real trajectory.
#'
#' For example, the Earth-Sun distance varies from about 147.1 million km (perihelion
#' in January) to 152.1 million km (aphelion in July). The semi-major axis of
#' 149.598 million km sits right in the middle and gives the correct orbital period
#' of one year.
#'
#' @name physical_constants
NULL

# --- Gravitational Constant ---

#' @rdname physical_constants
#' @details `gravitational_constant`: Newton's gravitational constant
#'   (6.6743 x 10^-11 m^3 kg^-1 s^-2). Source: CODATA 2018 recommended value.
#'   Use this with `create_system()` to scale gravity:
#'   `create_system(G = gravitational_constant * 10)`.
#' @export
gravitational_constant <- 6.6743e-11

# --- Time Conversions (seconds) ---

#' @rdname physical_constants
#' @details `seconds_per_hour`: 3,600 seconds. Convenient for setting `time_step`
#'   in lunar or close-orbit simulations.
#' @export
seconds_per_hour <- 3600

#' @rdname physical_constants
#' @details `seconds_per_day`: 86,400 seconds. Convenient for setting `time_step`
#'   in planetary-scale simulations.
#' @export
seconds_per_day <- 86400

#' @rdname physical_constants
#' @details `seconds_per_year`: 31,557,600 seconds (365.25 days, the Julian year).
#'   Convenient for setting `duration` in `simulate_system()`.
#' @export
seconds_per_year <- 86400 * 365.25

# --- Masses (kg) ---

#' @rdname physical_constants
#' @format Numeric scalar in kilograms.
#' @details `mass_sun`: Mass of the Sun (1.989 x 10^30 kg). Source: IAU 2015 nominal solar mass.
#' @export
mass_sun <- 1.989e30

#' @rdname physical_constants
#' @details `mass_earth`: Mass of the Earth (5.972 x 10^24 kg). Source: IAU 2015 nominal Earth mass.
#' @export
mass_earth <- 5.972e24

#' @rdname physical_constants
#' @details `mass_moon`: Mass of the Moon (7.342 x 10^22 kg). Source: JPL DE440 ephemeris.
#' @export
mass_moon <- 7.342e22

#' @rdname physical_constants
#' @details `mass_mars`: Mass of Mars (6.417 x 10^23 kg). Source: JPL DE440 ephemeris.
#' @export
mass_mars <- 6.417e23

#' @rdname physical_constants
#' @details `mass_jupiter`: Mass of Jupiter (1.898 x 10^27 kg). Source: JPL DE440 ephemeris.
#' @export
mass_jupiter <- 1.898e27

#' @rdname physical_constants
#' @details `mass_saturn`: Mass of Saturn (5.683 x 10^26 kg). Source: JPL DE440 ephemeris.
#' @export
mass_saturn <- 5.683e26

#' @rdname physical_constants
#' @details `mass_venus`: Mass of Venus (4.867 x 10^24 kg). Source: JPL DE440 ephemeris.
#' @export
mass_venus <- 4.867e24

#' @rdname physical_constants
#' @details `mass_mercury`: Mass of Mercury (3.301 x 10^23 kg). Source: JPL DE440 ephemeris.
#' @export
mass_mercury <- 3.301e23

#' @rdname physical_constants
#' @details `mass_uranus`: Mass of Uranus (8.681 x 10^25 kg). Source: JPL DE440 ephemeris.
#' @export
mass_uranus <- 8.681e25

#' @rdname physical_constants
#' @details `mass_neptune`: Mass of Neptune (1.024 x 10^26 kg). Source: JPL DE440 ephemeris.
#' @export
mass_neptune <- 1.024e26

#' @rdname physical_constants
#' @details `mass_pluto`: Mass of Pluto (1.309 x 10^22 kg). Source: JPL DE440 ephemeris.
#'   Pluto is a dwarf planet but is included for convenience.
#' @export
mass_pluto <- 1.309e22

# --- Orbital Distances: Semi-Major Axes (m) ---

#' @rdname physical_constants
#' @details `distance_earth_sun`: Semi-major axis of Earth's orbit around the Sun
#'   (1.496 x 10^11 m, ~149.6 million km). Earth's actual distance varies between
#'   ~147.1 million km (perihelion) and ~152.1 million km (aphelion).
#' @export
distance_earth_sun <- 1.496e11

#' @rdname physical_constants
#' @details `distance_earth_moon`: Semi-major axis of the Moon's orbit around Earth
#'   (3.844 x 10^8 m, ~384,400 km). The Moon's actual distance varies between
#'   ~363,300 km (perigee) and ~405,500 km (apogee).
#' @export
distance_earth_moon <- 3.844e8

#' @rdname physical_constants
#' @details `distance_mars_sun`: Semi-major axis of Mars's orbit around the Sun
#'   (2.279 x 10^11 m, ~227.9 million km). Mars has a notably eccentric orbit
#'   (e = 0.093), ranging from ~206.7 million km to ~249.2 million km.
#' @export
distance_mars_sun <- 2.279e11

#' @rdname physical_constants
#' @details `distance_jupiter_sun`: Semi-major axis of Jupiter's orbit around the Sun
#'   (7.785 x 10^11 m, ~778.5 million km).
#' @export
distance_jupiter_sun <- 7.785e11

#' @rdname physical_constants
#' @details `distance_venus_sun`: Semi-major axis of Venus's orbit around the Sun
#'   (1.082 x 10^11 m, ~108.2 million km). Venus has the most circular orbit of any
#'   planet (e = 0.007).
#' @export
distance_venus_sun <- 1.082e11

#' @rdname physical_constants
#' @details `distance_mercury_sun`: Semi-major axis of Mercury's orbit around the Sun
#'   (5.791 x 10^10 m, ~57.9 million km). Mercury has the most eccentric planetary
#'   orbit (e = 0.206), ranging from ~46.0 million km to ~69.8 million km.
#' @export
distance_mercury_sun <- 5.791e10

#' @rdname physical_constants
#' @details `distance_saturn_sun`: Semi-major axis of Saturn's orbit around the Sun
#'   (1.434 x 10^12 m, ~1.434 billion km).
#' @export
distance_saturn_sun <- 1.434e12

#' @rdname physical_constants
#' @details `distance_uranus_sun`: Semi-major axis of Uranus's orbit around the Sun
#'   (2.871 x 10^12 m, ~2.871 billion km).
#' @export
distance_uranus_sun <- 2.871e12

#' @rdname physical_constants
#' @details `distance_neptune_sun`: Semi-major axis of Neptune's orbit around the Sun
#'   (4.495 x 10^12 m, ~4.495 billion km).
#' @export
distance_neptune_sun <- 4.495e12

#' @rdname physical_constants
#' @details `distance_pluto_sun`: Semi-major axis of Pluto's orbit around the Sun
#'   (5.906 x 10^12 m, ~5.906 billion km). Pluto has a highly eccentric orbit
#'   (e = 0.249), ranging from ~4.437 billion km to ~7.376 billion km.
#' @export
distance_pluto_sun <- 5.906e12

# --- Mean Orbital Speeds (m/s) ---

#' @rdname physical_constants
#' @details `speed_earth`: Mean orbital speed of Earth around the Sun (29,780 m/s).
#' @export
speed_earth <- 29780

#' @rdname physical_constants
#' @details `speed_moon`: Mean orbital speed of the Moon around Earth (1,022 m/s).
#' @export
speed_moon <- 1022

#' @rdname physical_constants
#' @details `speed_mars`: Mean orbital speed of Mars around the Sun (24,070 m/s).
#' @export
speed_mars <- 24070

#' @rdname physical_constants
#' @details `speed_jupiter`: Mean orbital speed of Jupiter around the Sun (13,060 m/s).
#' @export
speed_jupiter <- 13060

#' @rdname physical_constants
#' @details `speed_venus`: Mean orbital speed of Venus around the Sun (35,020 m/s).
#' @export
speed_venus <- 35020

#' @rdname physical_constants
#' @details `speed_mercury`: Mean orbital speed of Mercury around the Sun (47,360 m/s).
#' @export
speed_mercury <- 47360

#' @rdname physical_constants
#' @details `speed_saturn`: Mean orbital speed of Saturn around the Sun (9,680 m/s).
#' @export
speed_saturn <- 9680

#' @rdname physical_constants
#' @details `speed_uranus`: Mean orbital speed of Uranus around the Sun (6,800 m/s).
#' @export
speed_uranus <- 6800

#' @rdname physical_constants
#' @details `speed_neptune`: Mean orbital speed of Neptune around the Sun (5,430 m/s).
#' @export
speed_neptune <- 5430

#' @rdname physical_constants
#' @details `speed_pluto`: Mean orbital speed of Pluto around the Sun (4,740 m/s).
#' @export
speed_pluto <- 4740
