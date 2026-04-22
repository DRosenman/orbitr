# orbitr

**A tidy physics engine for building and visualizing orbital simulations
in R.**

> **Early beta** — `orbitr` is functional and the physics engine is
> stable, but this is an early release. Function names, defaults, and
> behavior may change between versions. Feedback, bug reports, and
> contributions are welcome on
> [GitHub](https://github.com/DRosenman/orbitr).

`orbitr` is a lightweight N-body gravitational simulator built for the R
ecosystem. Simulate planetary orbits, binary star systems, or chaotic
three-body problems in a few lines of pipe-friendly code. Under the hood
it ships a compiled C++ engine via `Rcpp` and falls back gracefully to a
pure-R implementation.

## Installation

``` r
# Install from CRAN:
install.packages("orbitr")

# Or install the development version from GitHub:
# install.packages("devtools")
devtools::install_github("DRosenman/orbitr")
```

## Four Lines to an Orbit

For solar system bodies like the Sun and planets, you can use
convenience functions like
[`add_sun()`](https://orbit-r.com/reference/add_sun.md) and
[`add_planet()`](https://orbit-r.com/reference/add_planet.md) — they use
real masses and orbital data from JPL automatically:

``` r
library(orbitr)

create_system() |>
  add_sun() |>
  add_planet("Earth", parent = "Sun") |>
  add_planet("Mars",  parent = "Sun") |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year * 2) |>
  plot_orbits()
```

Or build the whole solar system in one line with
[`load_solar_system()`](https://orbit-r.com/reference/load_solar_system.md):

``` r
load_solar_system() |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year) |>
  plot_orbits()
```

Don’t need every body? Use
[`remove_body()`](https://orbit-r.com/reference/remove_body.md) to drop
them:

``` r
load_solar_system() |>
  remove_body(c("Pluto", "Moon")) |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year) |>
  plot_orbits()
```

You can also specify positions and velocities manually with
[`add_body()`](https://orbit-r.com/reference/add_body.md) — useful for
custom or fictional systems, or when you want full control:

``` r
sim <- create_system() |>
  add_sun() |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year)

sim |> plot_orbits()
```

![Closed elliptical trajectory of Earth orbiting the Sun over one
year](reference/figures/README-sun-earth-plot-1.png)

Closed elliptical trajectory of Earth orbiting the Sun over one year

And animated:

``` r
animate_system(sim, fps = 15, duration = 5)
```

![Animated GIF of Earth orbiting the Sun, with Earth leaving a fading
trail as it moves](reference/figures/README-earth-orbit-anim-1.gif)

Animated GIF of Earth orbiting the Sun, with Earth leaving a fading
trail as it moves

## Features

- **Tidy output** —
  [`simulate_system()`](https://orbit-r.com/reference/simulate_system.md)
  returns a standard tibble (one row per body per time step), ready for
  `dplyr`, `ggplot2`, `plotly`, or anything else in the R ecosystem.
- **Built-in physical constants** — real-world masses, distances, and
  orbital speeds for the Sun, all eight planets, and the Moon, so you
  don’t have to look anything up. See [Physical
  Constants](https://orbit-r.com/articles/physical-constants.md).
- **C++ engine** — a compiled `Rcpp` acceleration kernel handles the
  $O\left( n^{2} \right)$ gravity loop, with automatic fallback to
  vectorized R if the compiled code isn’t available.
- **Three integrators** — Velocity Verlet (default, symplectic,
  energy-conserving), Euler-Cromer (fast preview), and standard Euler
  (educational comparison). See [The
  Physics](https://orbit-r.com/articles/the-physics.md).
- **2D and 3D plotting** —
  [`plot_orbits()`](https://orbit-r.com/reference/plot_orbits.md)
  returns a `ggplot` for planar sims and auto-dispatches to an
  interactive `plotly` widget when any body has Z-axis motion. See [3D
  Plotting](https://orbit-r.com/articles/plotting-3d.md).
- **Animations** —
  [`animate_system()`](https://orbit-r.com/reference/animate_system.md)
  renders orbits as GIFs with fading trails via `gganimate`, or as
  interactive 3D animations with `plotly`.
- **Reference frame shifting** — `shift_reference_frame("Earth")`
  re-centers the simulation on any body, turning a heliocentric view
  into a geocentric one. See [Reference
  Frames](https://orbit-r.com/articles/reference-frames.md).

## Kepler-16: A Real Circumbinary Planet

Kepler-16b orbits two stars — a real-life Tatooine. `orbitr` handles
multi-body gravitational interactions natively, no special setup needed:

``` r
G  <- gravitational_constant
AU <- distance_earth_sun

m_A <- 0.68 * mass_sun
m_B <- 0.20 * mass_sun
a_bin <- 0.22 * AU

r_A <- a_bin * m_B / (m_A + m_B)
r_B <- a_bin * m_A / (m_A + m_B)
v_A <- sqrt(G * m_B^2 / ((m_A + m_B) * a_bin))
v_B <- sqrt(G * m_A^2 / ((m_A + m_B) * a_bin))

r_planet <- 0.7048 * AU
v_planet <- sqrt(G * (m_A + m_B) / r_planet)

create_system() |>
  add_body("Star A",      mass = m_A,                 x = r_A,      vy = v_A) |>
  add_body("Star B",      mass = m_B,                 x = -r_B,     vy = -v_B) |>
  add_body("Kepler-16b",  mass = 0.333 * mass_jupiter, x = r_planet, vy = v_planet) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 228.8 * 3) |>
  animate_system(fps = 15, duration = 6)
```

![Animated GIF of Kepler-16b orbiting a binary star
system](reference/figures/examples-kepler16-anim.gif)

Animated GIF of Kepler-16b orbiting a binary star system

## Learn More

- **[Get Started](https://orbit-r.com/articles/quick-start.md)** —
  install, simulate, and plot your first orbit
- **[Building Two-Body
  Orbits](https://orbit-r.com/articles/building-two-body-orbits.md)** —
  the physics of choosing positions, velocities, and masses
- **[Examples](https://orbit-r.com/articles/examples.md)** — Earth-Moon,
  Sun-Earth-Moon, Kepler-16, and more
- **[Unstable Orbits](https://orbit-r.com/articles/unstable-orbits.md)**
  — why most random configurations are chaotic
- **[Custom
  Visualization](https://orbit-r.com/articles/custom-visualization.md)**
  — build your own plots with ggplot2 and plotly
- **[The Physics](https://orbit-r.com/articles/the-physics.md)** —
  gravitational equations, integrators, and the C++ engine
- **[Interactive Demo](https://daverosenman.shinyapps.io/orbitr/)** —
  try orbitr in your browser with the Shiny app
