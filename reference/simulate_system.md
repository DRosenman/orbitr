# Simulate kinematics for an orbitr system

Propagates the physical state of an \`orbit_system\` through time using
numerical integration. This engine supports multiple mathematical
methods, defaulting to the energy-conserving Velocity Verlet algorithm
to ensure highly stable orbital trajectories.

## Usage

``` r
simulate_system(
  system,
  time_step = seconds_per_hour,
  duration = seconds_per_year,
  method = "verlet",
  softening = 0,
  use_cpp = TRUE
)
```

## Arguments

- system:

  An \`orbit_system\` object created by \`create_system()\`.

- time_step:

  The time increment per frame in seconds (default 3600s / 1 hour). For
  planetary orbits around a star, daily steps (\`86400\`) are usually
  sufficient. For lunar-scale or tighter orbits, hourly steps (\`3600\`)
  work well.

- duration:

  Total simulation time in seconds (default 31557600s / 1 year).

- method:

  The numerical integration method: "verlet" (default), "euler_cromer",
  or "euler".

- softening:

  A small distance (in meters) added to prevent numerical singularities
  when bodies pass very close to each other. The gravitational distance
  is computed as \`sqrt(r^2 + softening^2)\` instead of \`r\`. Default
  is 0 (no softening). A value like 1e4 (10 km) is reasonable for
  planetary simulations.

- use_cpp:

  Logical. If \`TRUE\` (default), uses the compiled C++ acceleration
  engine for better performance. Falls back to vectorized R if the C++
  code is not available.

## Value

A tidy \`tibble\` containing the physical state (time, id, mass, x, y,
z, vx, vy, vz) of every body at every time step.

## Examples

``` r
if (FALSE) { # \dontrun{
my_universe <- create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_body("Moon", mass = mass_moon, x = distance_earth_moon, vy = speed_moon) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 28)
} # }
```
