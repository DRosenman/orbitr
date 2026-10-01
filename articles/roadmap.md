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
[`add_body()`](https://orbit-r.com/reference/add_body.md) as an optional
parameter with a sensible default, something like:

``` r
add_body <- function(system, id, mass, x = 0, y = 0, z = 0,
                     vx = 0, vy = 0, vz = 0, r = NULL)
```

If `r` is supplied for any body in the system, the integrator would
check for overlaps on each step and handle them according to a
user-chosen policy (elastic bounce, inelastic merge, simulation halt,
etc.).

In the meantime, the existing `softening` parameter on
[`simulate_system()`](https://orbit-r.com/reference/simulate_system.md)
partly works around the missing-radius problem by preventing the
gravitational force from blowing up at very small separations — see [The
Physics](https://orbit-r.com/articles/the-physics.md) for details.

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
[`simulate_system()`](https://orbit-r.com/reference/simulate_system.md),
since most users wouldn’t need it.

## Setup helpers

### ~~Construct bodies from Keplerian orbital elements~~ ✅ Added in v0.2.0

Implemented as
[`add_body_keplerian()`](https://orbit-r.com/reference/add_body_keplerian.md).
See
[`?add_body_keplerian`](https://orbit-r.com/reference/add_body_keplerian.md)
for details.

### ~~A `load_solar_system()` convenience~~ ✅ Added in v0.2.0

Implemented as
[`load_solar_system()`](https://orbit-r.com/reference/load_solar_system.md).
Builds the Sun, all eight planets, the Moon, and Pluto using real
Keplerian elements from JPL DE440. See
[`?load_solar_system`](https://orbit-r.com/reference/load_solar_system.md)
for details.

## Quality of life

### ~~Save and load simulation state~~ ✅ Added in v0.3.0

Implemented as
[`save_system()`](https://orbit-r.com/reference/save_system.md) /
[`load_system()`](https://orbit-r.com/reference/load_system.md), which
write a full `orbit_system` to an `.rds` file and restore it later, and
[`export_bodies()`](https://orbit-r.com/reference/export_bodies.md),
which writes the body table to CSV for use outside R. See
[`?save_system`](https://orbit-r.com/reference/save_system.md) for
details.

### Progress bar for long simulations

A simple progress indicator on
[`simulate_system()`](https://orbit-r.com/reference/simulate_system.md)
for runs that take more than a few seconds, with an option to disable it
for scripted use.

### Built-in conservation diagnostics ✅ Added in v1.0.0

Implemented as
[`get_energy()`](https://orbit-r.com/reference/get_energy.md),
[`get_momentum()`](https://orbit-r.com/reference/get_momentum.md), and
[`get_angular_momentum()`](https://orbit-r.com/reference/get_momentum.md),
which compute the system totals at every time step, and
[`conserved_quantities()`](https://orbit-r.com/reference/conserved_quantities.md),
which joins them with relative errors against the initial values. See
[Checking a
Simulation](https://orbit-r.com/articles/checking-a-simulation.md).

### Variable time steps ✅ Partly addressed in v1.0.0

[`simulate_system()`](https://orbit-r.com/reference/simulate_system.md)
still integrates with a fixed step, but
[`continue_simulation()`](https://orbit-r.com/reference/continue_simulation.md)
lets you run in segments with different steps — large steps where
nothing is happening, small ones through a close approach — and
[`system_from_simulation()`](https://orbit-r.com/reference/system_from_simulation.md)
rebuilds a system from any snapshot of a run. A true adaptive-step
integrator that keeps Verlet’s energy behavior is a harder problem and
remains on the list.

## Suggestions Welcome

If any of these sound useful, if you’d like to see something not on this
list, or if you have a use case that `orbitr` doesn’t currently handle
well, please open an issue on
[GitHub](https://github.com/DRosenman/orbitr/issues). I’d love to hear
about how people are using the package and what would make it more
useful. Pull requests are also very welcome.
