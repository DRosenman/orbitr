# Roadmap

`orbitr` is a work in progress. This page is a running list of features
I’m thinking about adding in future versions. Nothing here is promised,
and the priority order is loose — it mostly reflects what I personally
find interesting or what users have asked for. If any of these sound
useful (or terrible), let me know. Suggestions, feedback, and pull
requests are all very welcome.

## Physics

### A `radius` argument on `add_body()`

Right now bodies are treated as point masses. This is fine for most
orbital distances — gravity outside a sphere behaves exactly as if all
the mass were concentrated at its center (the shell theorem) — but it
means there’s no concept of two bodies physically touching. Adding an
optional `radius` parameter would enable collision detection, merging on
contact, and more realistic close-encounter behavior.

I’d probably add it to
[`add_body()`](https://drosenman.github.io/orbitr/reference/add_body.md)
as an optional parameter with a sensible default, something like:

``` r
add_body <- function(system, id, mass, x = 0, y = 0, z = 0,
                     vx = 0, vy = 0, vz = 0, r = NULL)
```

If `r` is supplied for any body in the system, the integrator would
check for overlaps on each step and handle them according to a
user-chosen policy (elastic bounce, inelastic merge, simulation halt,
etc.).

In the meantime, the existing `softening` parameter on
[`simulate_system()`](https://drosenman.github.io/orbitr/reference/simulate_system.md)
partly works around the missing-radius problem by preventing the
gravitational force from blowing up at very small separations — see [The
Physics](https://drosenman.github.io/orbitr/articles/the-physics.md) for
details.

### Non-gravitational forces

Optional support for forces beyond pure Newtonian gravity:

- **Atmospheric drag** for low orbits around bodies with atmospheres
- **Radiation pressure** for small bodies near a star
- **J2 oblateness corrections** for orbits around non-spherical bodies
  (Earth’s equatorial bulge measurably perturbs satellite orbits)

### General-relativistic corrections

A small post-Newtonian correction term would let `orbitr` reproduce real
GR effects like the precession of Mercury’s perihelion. Probably opt-in
via an argument on
[`simulate_system()`](https://drosenman.github.io/orbitr/reference/simulate_system.md),
since most users wouldn’t need it.

## Setup helpers

### Construct bodies from Keplerian orbital elements

The current
[`add_body()`](https://drosenman.github.io/orbitr/reference/add_body.md)
takes raw Cartesian state vectors (`x`, `y`, `z`, `vx`, `vy`, `vz`). For
users who think in classical orbital elements — semi-major axis $a$,
eccentricity $e$, inclination $i$, longitude of ascending node $\Omega$,
argument of periapsis $\omega$, true anomaly $\nu$ — a helper that
converts those into the right Cartesian inputs would be a
quality-of-life win:

``` r
add_body_keplerian(system, "Mars", mass = mass_mars,
                   a = distance_mars_sun, e = 0.0934,
                   i = 1.85, Omega = 49.6, omega = 286.5, nu = 0,
                   parent = "Sun")
```

### A `load_solar_system()` convenience

A one-liner that pre-builds the Sun and all eight planets with real
ephemeris values, so you can skip straight to interesting experiments
without typing out a dozen
[`add_body()`](https://drosenman.github.io/orbitr/reference/add_body.md)
calls.

## Quality of life

### Save and load simulation state

Functions to serialize an `orbit_system` (or a completed simulation
tibble) to disk and reload it later. Useful for long-running simulations
and for sharing reproducible setups.

### Progress bar for long simulations

A simple progress indicator on
[`simulate_system()`](https://drosenman.github.io/orbitr/reference/simulate_system.md)
for runs that take more than a few seconds, with an option to disable it
for scripted use.

### Built-in conservation diagnostics

Helpers to compute total energy, total linear momentum, and total
angular momentum at every time step, so you can sanity-check an
integrator’s behavior over the course of a run. Useful for confirming
Velocity Verlet is doing its job, and for spotting cases where the time
step is too large.

## Suggestions Welcome

If any of these sound useful, if you’d like to see something not on this
list, or if you have a use case that `orbitr` doesn’t currently handle
well, please open an issue on
[GitHub](https://github.com/DRosenman/orbitr/issues). I’d love to hear
about how people are using the package and what would make it more
useful. Pull requests are also very welcome.
