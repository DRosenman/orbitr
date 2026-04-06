
# orbitr

**A tidy physics engine for building and visualizing orbital simulations.**

> **Note:** `orbitr` is a work in progress. The physics engine is functional, but the built-in plotting functions (`plot_orbits()` and `plot_orbits_3d()`) are intentionally minimal — they exist to get you a quick look at your simulation, not to produce publication-quality figures. Since `simulate()` returns a standard tidy tibble, you have the full power of `ggplot2`, `plotly`, and any other visualization library at your disposal. See [Custom Visualization](articles/custom-visualization.html) for examples.

`orbitr` is a lightweight N-body gravitational physics engine built for the R ecosystem. Simulate planetary orbits, binary star systems, or chaotic three-body problems in a few lines of pipe-friendly code. Under the hood it ships a compiled C++ acceleration engine via `Rcpp` and falls back gracefully to a fully vectorized pure-R implementation.

```r
library(orbitr)

sim <- create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  add_body("Moon",  mass = mass_moon,
           x = distance_earth_sun + distance_earth_moon,
           vy = speed_earth + speed_moon) |>
  simulate(time_step = 3600, duration = 86400 * 365)

sim
```

```
## # A tibble: 26,283 × 9
##    id       mass          x           y     z      vx          vy    vz  time
##    <chr>   <dbl>      <dbl>       <dbl> <dbl>   <dbl>       <dbl> <dbl> <dbl>
##  1 Sun   1.99e30         0          0       0   0        0            0     0
##  2 Earth 5.97e24 149600000000       0       0   0    29780            0     0
##  3 Moon  7.34e22 149984400000       0       0   0    30802            0     0
##  ...
```

`simulate()` returns a tidy tibble — one row per body per time step — ready for `dplyr`, `ggplot2`, `plotly`, or any other tool in the R ecosystem.

```r
sim |>
  shift_reference_frame("Earth") |>
  plot_orbits()
```

![](man/figures/README-unnamed-chunk-2-1.png)

## Installation

```r
# install.packages("devtools")
devtools::install_github("DRosenman/orbitr")
```

For 3D interactive plotting, you'll also want:

```r
install.packages("plotly")
```

## Quick Start

The workflow is simple: create a system, add bodies, simulate, and plot.

```r
create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_body("Moon",  mass = mass_moon, x = distance_earth_moon, vy = speed_moon) |>
  simulate(time_step = 3600, duration = 86400 * 28) |>
  plot_orbits()
```

1. **`create_system()`** initializes an empty simulation with standard gravitational constant G.
2. **`add_body()`** places a body with a given mass, position, and velocity. Built-in constants like `mass_earth` and `distance_earth_moon` save you from looking anything up.
3. **`simulate()`** runs the N-body integration. The default Velocity Verlet integrator conserves energy for stable long-term orbits.
4. **`plot_orbits()`** produces a quick 2D trajectory plot — or an interactive 3D plotly visualization if any body has Z-axis motion. For more control, use `ggplot2` or `plotly` directly on the simulation tibble.

The output is a standard tidy tibble, so you can plug it straight into `ggplot2`, `plotly`, `dplyr`, or whatever you normally use.

## Learn More

- **[Quick Start Guide](articles/quick-start.html)** — Full getting-started walkthrough
- **[Examples](articles/examples.html)** — Earth-Moon, Sun-Earth-Moon, Kepler-16, and more
- **[Physical Constants](articles/physical-constants.html)** — All built-in masses, distances, and speeds
- **[3D Plotting](articles/plotting-3d.html)** — Interactive 3D visualization with plotly
- **[Custom Visualization](articles/custom-visualization.html)** — Build your own plots with ggplot2 and plotly
- **[The Physics](articles/the-physics.html)** — Gravitational equations, integrators, and the C++ engine
- **[Reference Frames](articles/reference-frames.html)** — Shift your perspective with `shift_reference_frame()`
- **[Unstable Orbits](articles/unstable-orbits.html)** — Why most random configurations are chaotic
