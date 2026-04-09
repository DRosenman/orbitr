# Changelog

## orbitr 0.1.0

Initial release.

### Core engine

- N-body gravitational simulation with three integration methods:
  Velocity Verlet (default), Euler-Cromer, and standard Euler.
- Compiled C++ acceleration engine via Rcpp with automatic fallback to
  vectorized R.
- Optional gravitational softening to prevent singularities at close
  approach.

### Workflow

- [`create_system()`](https://orbit-r.com/reference/create_system.md) /
  [`add_body()`](https://orbit-r.com/reference/add_body.md) /
  [`simulate_system()`](https://orbit-r.com/reference/simulate_system.md)
  pipe-friendly API.
- Tidy tibble output (one row per body per time step) for use with
  dplyr, ggplot2, plotly, etc.
- [`shift_reference_frame()`](https://orbit-r.com/reference/shift_reference_frame.md)
  to re-center simulations on any body.

### Visualization

- [`plot_orbits()`](https://orbit-r.com/reference/plot_orbits.md) /
  [`plot_orbits_3d()`](https://orbit-r.com/reference/plot_orbits_3d.md)
  for quick trajectory plots (ggplot2 2D, plotly 3D).
- [`plot_system()`](https://orbit-r.com/reference/plot_system.md) /
  [`plot_system_3d()`](https://orbit-r.com/reference/plot_system_3d.md)
  for single-time-step snapshots.
- [`animate_system()`](https://orbit-r.com/reference/animate_system.md)
  /
  [`animate_system_3d()`](https://orbit-r.com/reference/animate_system_3d.md)
  for animated orbits via gganimate or plotly.
- Automatic 2D/3D dispatch based on whether any body has non-zero Z
  motion.

### Built-in constants

- Real-world masses, orbital distances, and speeds for the Sun, all
  eight planets, and the Moon.
- `gravitational_constant` for scaling gravity in
  [`create_system()`](https://orbit-r.com/reference/create_system.md).
- `seconds_per_hour`, `seconds_per_day`, `seconds_per_year` time
  helpers.
