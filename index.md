# orbitr ![](reference/figures/logo.png)

**A tidy physics engine for building and visualizing orbital
simulations.**

`orbitr` is a lightweight N-body gravitational physics engine built for
the R ecosystem. Simulate planetary orbits, binary star systems, or
chaotic three-body problems in a few lines of pipe-friendly code. Under
the hood it ships a compiled C++ acceleration engine via `Rcpp` and
falls back gracefully to a fully vectorized pure-R implementation.

``` r
library(orbitr)

create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  add_body("Moon",  mass = mass_moon,
           x = distance_earth_sun + distance_earth_moon,
           vy = speed_earth + speed_moon) |>
  simulate(time_step = 3600, duration = 86400 * 365) |>
  shift_reference_frame("Earth") |>
  plot_orbits()
```

## Installation

``` r
# install.packages("devtools")
devtools::install_github("DRosenman/orbitr")
```

For 3D interactive plotting, you’ll also want:

``` r
install.packages("plotly")
```

## Quick Start

The workflow is simple: create a system, add bodies, simulate, and plot.

``` r
create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_body("Moon",  mass = mass_moon, x = distance_earth_moon, vy = speed_moon) |>
  simulate(time_step = 3600, duration = 86400 * 28) |>
  plot_orbits()
```

1.  **[`create_system()`](https://drosenman.github.io/orbitr/reference/create_system.md)**
    initializes an empty simulation with standard gravitational constant
    G.
2.  **[`add_body()`](https://drosenman.github.io/orbitr/reference/add_body.md)**
    places a body with a given mass, position, and velocity. Built-in
    constants like `mass_earth` and `distance_earth_moon` save you from
    looking anything up.
3.  **[`simulate()`](https://drosenman.github.io/orbitr/reference/simulate.md)**
    runs the N-body integration. The default Velocity Verlet integrator
    conserves energy for stable long-term orbits.
4.  **[`plot_orbits()`](https://drosenman.github.io/orbitr/reference/plot_orbits.md)**
    produces a quick 2D trajectory plot — or an interactive 3D plotly
    visualization if any body has Z-axis motion.

The output is a standard tidy tibble, so you can plug it straight into
`ggplot2`, `plotly`, `dplyr`, or whatever you normally use.

## Learn More

- **[Quick Start
  Guide](https://drosenman.github.io/orbitr/articles/quick-start.md)** —
  Full getting-started walkthrough
- **[The
  Physics](https://drosenman.github.io/orbitr/articles/the-physics.md)**
  — Gravitational equations, integrators, and the C++ engine
- **[Examples](https://drosenman.github.io/orbitr/articles/examples.md)**
  — Earth-Moon, Sun-Earth-Moon, Kepler-16, and more
- **[Unstable
  Orbits](https://drosenman.github.io/orbitr/articles/unstable-orbits.md)**
  — Why most random configurations are chaotic
- **[3D
  Plotting](https://drosenman.github.io/orbitr/articles/plotting-3d.md)**
  — Interactive 3D visualization with plotly
- **[Custom
  Visualization](https://drosenman.github.io/orbitr/articles/custom-visualization.md)**
  — Build your own plots with ggplot2 and plotly
- **[Physical
  Constants](https://drosenman.github.io/orbitr/articles/physical-constants.md)**
  — All built-in masses, distances, and speeds
