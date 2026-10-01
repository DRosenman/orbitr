# Conserved quantities and how well a simulation conserved them

Joins \[get_energy()\], \[get_momentum()\], and
\[get_angular_momentum()\] into one tibble and adds the relative error
of each quantity against its value at the first time step. In exact
Newtonian gravity all three are constant, so the errors measure the
integrator, and their shape tells you what is wrong when something is.

## Usage

``` r
conserved_quantities(sim_data, G = NULL, softening = NULL)
```

## Arguments

- sim_data:

  A tibble output from \[simulate_system()\].

- G:

  The gravitational constant the simulation was run with. Defaults to
  the value recorded by \[simulate_system()\] in the \`"G"\` attribute
  of \`sim_data\`, or to \[gravitational_constant\] if that attribute is
  absent.

- softening:

  The softening length (in meters) the simulation was run with. The
  potential energy is computed with the same softened distance,
  \`sqrt(r^2 + softening^2)\`, that the force used; if the two do not
  match, the energy will appear to drift when it has not. Defaults to
  the value recorded by \[simulate_system()\], or 0.

## Value

A tibble with one row per time step and columns \`time\`, \`kinetic\`,
\`potential\`, \`energy\`, \`px\`, \`py\`, \`pz\`, \`Lx\`, \`Ly\`,
\`Lz\`, \`energy_error\`, \`momentum_error\`, and
\`angular_momentum_error\`.

## Details

\`energy_error\` is \\(E - E_0)/\|E_0\|\\. \`momentum_error\` is
\\\|\mathbf{P} - \mathbf{P}\_0\|\\ divided by \\\sum_j m_j
\|\mathbf{v}\_j\|\\ at the first step (total momentum is often exactly
zero, so it cannot be its own scale). \`angular_momentum_error\` is
\\\|\mathbf{L} - \mathbf{L}\_0\| / \|\mathbf{L}\_0\|\\. An error is
\`NA\` when its scale is zero.

## What to expect

The Velocity Verlet and Euler-Cromer integrators are built from "kicks"
and "drifts" that conserve linear and angular momentum exactly, so for
\`method = "verlet"\` or \`"euler_cromer"\` those two errors should stay
at the level of floating-point rounding (around 1e-15) for any time
step. Energy is conserved only approximately: with Verlet its error
oscillates once per orbit within a band whose width scales as the square
of the time step, and does not grow. A steady drift in energy means the
time step is too large for the fastest or most eccentric orbit in the
system, or that \`method = "euler"\` was used. A sudden jump marks a
close encounter the step could not resolve. A drift in momentum or
angular momentum under Verlet points to a problem in the setup rather
than the integrator.

## Examples

``` r
# \donttest{
sim <- create_system() |>
  add_body("Star", mass = 1e30) |>
  add_body("Planet", mass = 1e24, x = 1e11, vy = 30000) |>
  simulate_system(time_step = seconds_per_hour * 6,
                  duration = seconds_per_year * 2)

cq <- conserved_quantities(sim)

# Verlet: bounded energy error, momenta at rounding level
range(cq$energy_error)
#> [1] 0.000000e+00 6.694853e-06
max(cq$angular_momentum_error)
#> [1] 2.619339e-15

plot(cq$time / seconds_per_day, cq$energy_error, type = "l",
     xlab = "Day", ylab = "Relative energy error")

# }
```
