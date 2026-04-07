
# orbitr

**A tidy physics engine for building and visualizing orbital simulations.**

> **Note:** `orbitr` is a work in progress. The physics engine is functional, but the built-in plotting functions (`plot_orbits()` and `plot_orbits_3d()`) are intentionally minimal — they exist to get you a quick look at your simulation, not to produce publication-quality figures. Since `simulate_system()` returns a standard tidy tibble, you have the full power of `ggplot2`, `plotly`, and any other visualization library at your disposal. See [Custom Visualization](articles/custom-visualization.html) for examples.

`orbitr` is a lightweight N-body gravitational physics engine built for the R ecosystem. Simulate planetary orbits, binary star systems, or chaotic three-body problems in a few lines of pipe-friendly code. Under the hood it ships a compiled C++ acceleration engine via `Rcpp` and falls back gracefully to a fully vectorized pure-R implementation.

```r
library(orbitr)

sim <- create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  simulate_system(time_step = 86400, duration = 86400 * 365)

sim
```

```
## # A tibble: 1,462 × 9
##    id       mass          x           y     z      vx          vy    vz  time
##    <chr>   <dbl>      <dbl>       <dbl> <dbl>   <dbl>       <dbl> <dbl> <dbl>
##  1 Sun   1.99e30         0          0       0   0        0            0     0
##  2 Earth 5.97e24 149600000000       0       0   0    29780            0     0
##  ...
```

`mass_sun`, `mass_earth`, `distance_earth_sun`, and `speed_earth` are built-in constants — real-world values in SI units (kg, meters, m/s) so you don't have to look anything up. `orbitr` ships constants for the Sun, all eight planets, and the Moon. See [Physical Constants](articles/physical-constants.html) for the full list.

`simulate_system()` returns a tidy tibble — one row per body per time step — ready for `dplyr`, `ggplot2`, `plotly`, or any other tool in the R ecosystem.

```r
sim |> plot_orbits()
```

![](man/figures/README-sun-earth-plot-1.png)

You'll notice only Earth's orbit is visible — the Sun is missing. That's a limitation of `plot_orbits()`: it draws trajectories using `geom_path()`, and the Sun barely moves during the simulation so its path is too small to see at this scale. The Sun *does* move — Newton's third law means Earth pulls on the Sun just as the Sun pulls on Earth, causing it to trace a tiny loop around the system's barycenter. It's just invisible at this zoom level because the Sun is ~330,000 times more massive than the Earth. This stellar wobble is real, though — it's exactly the method astronomers use to detect exoplanets.

By default, `plot_orbits()` returns a standard `ggplot` object for planar (2D) simulations, and a `plotly` HTML widget for simulations with any 3D motion. (You can also force 3D rendering on planar data with `three_d = TRUE`.) Because the 2D case returns a regular ggplot, you can layer additional geoms, scales, themes, and labels onto it with `+` like any other ggplot. One quick fix for the missing Sun is to drop a marker at the origin:

```r
sim |>
  plot_orbits() +
  ggplot2::geom_point(
    data = data.frame(x = 0, y = 0),
    ggplot2::aes(x = x, y = y),
    color = "gold",
    size = 6
  ) +
  ggplot2::labs(title = "Earth-Sun Orbit")
```

![](man/figures/README-sun-earth-plot-with-sun-1.png)

This works because the Sun sits essentially at the origin throughout the simulation — the barycenter wobble is well inside the Sun itself. For systems where the central body actually moves a noticeable amount, you'd want to pull its position from the simulation tibble instead of hardcoding `(0, 0)`.

For better 2D plots where you control point markers, axis ranges, and labels, use `ggplot2` directly on the simulation tibble (see [Custom Visualization](articles/custom-visualization.html)). For interactive 3D views where you can zoom in and find the Sun, see [3D Plotting](articles/plotting-3d.html).

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
  simulate_system(time_step = 3600, duration = 86400 * 28) |>
  plot_orbits()
```

1. **`create_system()`** initializes an empty simulation with standard gravitational constant G.
2. **`add_body()`** places a body with a given mass, position, and velocity. Built-in constants like `mass_earth` and `distance_earth_moon` save you from looking anything up.
3. **`simulate_system()`** runs the N-body integration. The default Velocity Verlet integrator conserves energy for stable long-term orbits.
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
