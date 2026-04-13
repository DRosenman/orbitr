# Examples

``` r
library(orbitr)
library(ggplot2)
library(dplyr)
```

## The Full Solar System

The fastest way to get a complete solar system simulation:

``` r
solar <- load_solar_system() |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year)

solar |> plot_orbits(three_d = FALSE)
```

![](examples_files/figure-html/full-solar-system-1.png)

All planets start at their periapsis (closest point to the Sun) by
default, with real eccentricities, inclinations, and orbital
orientations from JPL. The inner planets complete their orbits quickly
while the outer planets barely move in a single year.

## The Inner Solar System

Use [`add_planet()`](https://orbit-r.com/reference/add_planet.md) to
pick specific bodies without looking up any numbers:

``` r
create_system() |>
  add_body("Sun", mass = mass_sun) |>
  add_planet("Mercury", parent = "Sun") |>
  add_planet("Venus",   parent = "Sun") |>
  add_planet("Earth",   parent = "Sun") |>
  add_planet("Mars",    parent = "Sun") |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year * 2) |>
  plot_orbits(three_d = FALSE)
```

![](examples_files/figure-html/inner-solar-system-1.png)

Notice how Mercury’s orbit is visibly eccentric compared to the
near-circular orbits of Venus and Earth. Mars also shows some
elongation.

## The Earth-Moon System

Using [`add_planet()`](https://orbit-r.com/reference/add_planet.md) for
the Moon:

``` r
earth_moon <- create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_planet("Moon", parent = "Earth") |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 28)

earth_moon |> plot_orbits()
```

And animated, so you can watch the Moon actually swing around:

``` r
animate_system(earth_moon, fps = 15, duration = 5)
```

![](../reference/figures/examples-earth-moon-anim.gif)

## The Sun-Earth System

A full year with daily time steps.

``` r
create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year) |>
  plot_orbits()
```

![](examples_files/figure-html/unnamed-chunk-4-1.png)

## The Three-Body Problem (Sun-Earth-Moon)

Because `orbitr` uses N-body gravity, nested hierarchies require no
special setup. Piggyback the Moon’s initial conditions onto Earth’s
using simple vector addition. Note that at this scale, the Earth and
Moon orbits overlap — the Earth-Moon distance (~384,000 km) is tiny
compared to the Earth-Sun distance (~150 million km). Use
`shift_reference_frame("Earth")` (shown in the next example) to zoom
into the Earth-Moon subsystem:

``` r
create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  add_body("Moon",  mass = mass_moon,
           x = distance_earth_sun + distance_earth_moon,
           vy = speed_earth + speed_moon) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_year) |>
  plot_orbits()
```

![](examples_files/figure-html/unnamed-chunk-5-1.png)

## Shifting Your Point of View

The three-body plot above is heliocentric (Sun at center). To see the
Moon’s path *from Earth’s perspective*, pipe the results through
[`shift_reference_frame()`](https://orbit-r.com/reference/shift_reference_frame.md):

``` r
sun_earth_moon <- create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  add_body("Moon",  mass = mass_moon,
           x = distance_earth_sun + distance_earth_moon,
           vy = speed_earth + speed_moon) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_year) |>
  shift_reference_frame("Earth")

sun_earth_moon |> plot_orbits()
```

![](examples_files/figure-html/sun-earth-moon-sim-1.png)

Animating the Earth-frame view makes the Moon’s monthly loops around
Earth obvious as the Sun drifts across the background:

``` r
animate_system(sun_earth_moon, fps = 15, duration = 6)
```

![](../reference/figures/examples-sun-earth-moon-anim.gif)

## The Kepler-16 System: A Real Circumbinary Planet

Kepler-16b was the first confirmed planet orbiting two stars — a
real-life Tatooine. The system has a K-type star (0.68 solar masses) and
an M-type star (0.20 solar masses) orbiting each other every ~41 days,
with a Saturn-sized planet orbiting the pair at about 0.7 AU.

``` r
AU <- distance_earth_sun

# Star masses
m_A <- 0.68 * mass_sun
m_B <- 0.20 * mass_sun
m_planet <- 0.333 * mass_jupiter

# Binary star orbit (~0.22 AU separation)
a_bin <- 0.22 * AU
r_A <- a_bin * m_B / (m_A + m_B)
r_B <- a_bin * m_A / (m_A + m_B)
v_A <- sqrt(gravitational_constant * m_B^2 / ((m_A + m_B) * a_bin))
v_B <- sqrt(gravitational_constant * m_A^2 / ((m_A + m_B) * a_bin))

# Planet orbit (0.7048 AU from barycenter)
r_planet <- 0.7048 * AU
v_planet <- sqrt(gravitational_constant * (m_A + m_B) / r_planet)

kepler16 <- create_system() |>
  add_body("Star A", mass = m_A, x = r_A, vy = v_A) |>
  add_body("Star B", mass = m_B, x = -r_B, vy = -v_B) |>
  add_body("Kepler-16b", mass = m_planet, x = r_planet, vy = v_planet) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 228.8 * 3)

kepler16 |> plot_orbits()
```

![](examples_files/figure-html/unnamed-chunk-7-1.png)

The animation makes the circumbinary structure pop — the two stars whirl
tightly around their common center while the planet traces a much wider,
slower loop around the pair:

``` r
animate_system(kepler16, fps = 15, duration = 6)
```

![](../reference/figures/examples-kepler16-anim.gif)

## A Comet Crossing the Inner Solar System

[`add_body_keplerian()`](https://orbit-r.com/reference/add_body_keplerian.md)
shines for objects with extreme orbits. Here’s a Halley-like comet on a
highly eccentric, steeply inclined orbit that plunges through the inner
solar system:

``` r
create_system() |>
  add_body("Sun", mass = mass_sun) |>
  add_planet("Earth", parent = "Sun") |>
  add_body_keplerian(
    "Comet", mass = 2.2e14, parent = "Sun",
    a = 2.5 * distance_earth_sun, e = 0.85,
    i = 50, lan = 60, arg_pe = 120, nu = 150
  ) |>
  simulate_system(time_step = seconds_per_hour * 6, duration = seconds_per_year * 3) |>
  plot_orbits()
```

The comet’s orbit is tilted 50° out of the ecliptic and has an
eccentricity of 0.85, meaning its farthest distance from the Sun is over
12 times its closest approach. Starting at $\nu = 150{^\circ}$ places it
near apoapsis, heading inward.

## What-If: Circular Mars

One of the nice things about
[`add_planet()`](https://orbit-r.com/reference/add_planet.md) is that
you can override individual elements while keeping everything else real.
What if Mars had a perfectly circular orbit?

``` r
bind_rows(
  create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Mars", parent = "Sun") |>
    simulate_system(time_step = seconds_per_day,
                    duration = seconds_per_day * 687) |>
    filter(id == "Mars") |>
    mutate(case = "Real Mars (e = 0.093)"),
  create_system() |>
    add_body("Sun", mass = mass_sun) |>
    add_planet("Mars", parent = "Sun", e = 0) |>
    simulate_system(time_step = seconds_per_day,
                    duration = seconds_per_day * 687) |>
    filter(id == "Mars") |>
    mutate(case = "Circular Mars (e = 0)")
) |>
  ggplot2::ggplot(ggplot2::aes(x = x, y = y, color = case)) +
  ggplot2::geom_path(linewidth = 0.8) +
  ggplot2::coord_equal() +
  ggplot2::theme_minimal() +
  ggplot2::labs(color = NULL)
```

![](examples_files/figure-html/circular-mars-1.png)
