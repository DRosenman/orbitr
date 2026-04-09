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
