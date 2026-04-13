# orbitr 0.2.0

## New functions

- `add_body_keplerian()`: Add a body to the system using classical Keplerian
  orbital elements (semi-major axis, eccentricity, inclination, longitude of
  ascending node, argument of periapsis, true anomaly) instead of raw Cartesian
  state vectors. The elements are converted to position and velocity relative to
  a specified parent body.

- `add_planet()`: Add a known solar system body by name with real orbital
  data looked up automatically. Just specify the name and parent — mass,
  semi-major axis, eccentricity, inclination, and orientation are filled in
  from JPL DE440 values. Any element can be overridden for "what if" scenarios
  (e.g., `add_planet("Mars", parent = "Sun", e = 0)` for a circular Mars).

- `load_solar_system()`: One-liner that builds a complete solar system — the
  Sun, all eight planets, the Moon, and optionally Pluto — using real orbital
  data from the JPL DE440 ephemeris. Returns a ready-to-simulate `orbit_system`.
  Use `moon = FALSE` or `pluto = FALSE` to exclude those bodies.

## Bug fixes

- `three_d` parameter on `plot_orbits()`, `plot_system()`, and
  `animate_system()` now supports `FALSE` to force 2D output even when the
  data has Z-axis motion. Previously, `three_d = FALSE` was the default but
  could not override the auto-detection.

- Fixed frozen 3D animations in `animate_system_3d()` caused by
  `redraw = FALSE` in plotly animation options.

# orbitr 0.1.0

Initial release.

## Core engine

- N-body gravitational simulation with three integration methods: Velocity Verlet (default), Euler-Cromer, and standard Euler.
- Compiled C++ acceleration engine via Rcpp with automatic fallback to vectorized R.
- Optional gravitational softening to prevent singularities at close approach.

## Workflow

- `create_system()` / `add_body()` / `simulate_system()` pipe-friendly API.
- Tidy tibble output (one row per body per time step) for use with dplyr, ggplot2, plotly, etc.
- `shift_reference_frame()` to re-center simulations on any body.

## Visualization

- `plot_orbits()` / `plot_orbits_3d()` for quick trajectory plots (ggplot2 2D, plotly 3D).
- `plot_system()` / `plot_system_3d()` for single-time-step snapshots.
- `animate_system()` / `animate_system_3d()` for animated orbits via gganimate or plotly.
- Automatic 2D/3D dispatch based on whether any body has non-zero Z motion.

## Built-in constants

- Real-world masses, orbital distances, and speeds for the Sun, all eight planets, and the Moon.
- `gravitational_constant` for scaling gravity in `create_system()`.
- `seconds_per_hour`, `seconds_per_day`, `seconds_per_year` time helpers.
