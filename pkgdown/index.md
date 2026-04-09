
# orbitr

**A tidy physics engine for building and visualizing orbital simulations in R.**

> **Early beta** — `orbitr` is functional and the physics engine is stable, but this is an early release. Function names, defaults, and behavior may change between versions. Feedback, bug reports, and contributions are welcome on [GitHub](https://github.com/DRosenman/orbitr).

`orbitr` is a lightweight N-body gravitational simulator built for the R ecosystem. Simulate planetary orbits, binary star systems, or chaotic three-body problems in a few lines of pipe-friendly code. Under the hood it ships a compiled C++ engine via `Rcpp` and falls back gracefully to a pure-R implementation.

## Installation

```r
# install.packages("devtools")
devtools::install_github("DRosenman/orbitr")
```

## Four Lines to an Orbit

```r
library(orbitr)

sim <- create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  simulate_system(time_step = 86400, duration = 86400 * 365)

sim |> plot_orbits()
```

![Closed elliptical trajectory of Earth orbiting the Sun over one year](man/figures/README-sun-earth-plot-1.png)

And animated:

```r
animate_system(sim, fps = 15, duration = 5)
```

![Animated GIF of Earth orbiting the Sun, with Earth leaving a fading trail as it moves](man/figures/README-earth-orbit-anim-1.gif)

## Features

- **Tidy output** — `simulate_system()` returns a standard tibble (one row per body per time step), ready for `dplyr`, `ggplot2`, `plotly`, or anything else in the R ecosystem.
- **Built-in physical constants** — real-world masses, distances, and orbital speeds for the Sun, all eight planets, and the Moon, so you don't have to look anything up. See [Physical Constants](articles/physical-constants.html).
- **C++ engine** — a compiled `Rcpp` acceleration kernel handles the $O(n^2)$ gravity loop, with automatic fallback to vectorized R if the compiled code isn't available.
- **Three integrators** — Velocity Verlet (default, symplectic, energy-conserving), Euler-Cromer (fast preview), and standard Euler (educational comparison). See [The Physics](articles/the-physics.html).
- **2D and 3D plotting** — `plot_orbits()` returns a `ggplot` for planar sims and auto-dispatches to an interactive `plotly` widget when any body has Z-axis motion. See [3D Plotting](articles/plotting-3d.html).
- **Animations** — `animate_system()` renders orbits as GIFs with fading trails via `gganimate`, or as interactive 3D animations with `plotly`.
- **Reference frame shifting** — `shift_reference_frame("Earth")` re-centers the simulation on any body, turning a heliocentric view into a geocentric one. See [Reference Frames](articles/reference-frames.html).

## Kepler-16: A Real Circumbinary Planet

Kepler-16b orbits two stars — a real-life Tatooine. `orbitr` handles multi-body gravitational interactions natively, no special setup needed:

```r
G  <- 6.6743e-11
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
  simulate_system(time_step = 3600, duration = 86400 * 228.8 * 3) |>
  animate_system(fps = 15, duration = 6)
```

![Animated GIF of Kepler-16b orbiting a binary star system](man/figures/examples-kepler16-anim.gif)

## Learn More

- **[Get Started](articles/quick-start.html)** — install, simulate, and plot your first orbit
- **[Building Two-Body Orbits](articles/building-two-body-orbits.html)** — the physics of choosing positions, velocities, and masses
- **[Examples](articles/examples.html)** — Earth-Moon, Sun-Earth-Moon, Kepler-16, and more
- **[Unstable Orbits](articles/unstable-orbits.html)** — why most random configurations are chaotic
- **[Custom Visualization](articles/custom-visualization.html)** — build your own plots with ggplot2 and plotly
- **[The Physics](articles/the-physics.html)** — gravitational equations, integrators, and the C++ engine
