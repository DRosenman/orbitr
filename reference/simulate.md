# Simulate kinematics for an orbitr system

Propagates the physical state of an \`orbit_system\` through time using
numerical integration. This engine supports multiple mathematical
methods, defaulting to the energy-conserving Velocity Verlet algorithm
to ensure highly stable orbital trajectories.

## Usage

``` r
simulate(
  system,
  time_step = 60,
  duration = 86400,
  method = "verlet",
  softening = 0,
  use_cpp = TRUE
)
```

## Arguments

- system:

  An \`orbit_system\` object created by \`create_system()\`.

- time_step:

  The time increment per frame in seconds (default 60s).

- duration:

  Total simulation time in seconds (default 86400s / 1 day).

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
  add_body("Earth", mass = 5.97e24) |>
  add_body("Moon", mass = 7.34e22, x = 3.84e8, vy = 1022) |>
  simulate(time_step = 3600, duration = 86400 * 28)
} # }
```
