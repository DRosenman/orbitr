# Total linear and angular momentum of a simulated system

\`get_momentum()\` computes the total linear momentum \\\mathbf{P} =
\sum_j m_j \mathbf{v}\_j\\ and \`get_angular_momentum()\` the total
angular momentum about the origin, \\\mathbf{L} = \sum_j m_j
\mathbf{r}\_j \times \mathbf{v}\_j\\, at every time step of a
simulation.

## Usage

``` r
get_momentum(sim_data)

get_angular_momentum(sim_data)
```

## Arguments

- sim_data:

  A tibble output from \[simulate_system()\].

## Value

A tibble with one row per time step: \`time, px, py, pz\` (kg m/s) for
\`get_momentum()\`, and \`time, Lx, Ly, Lz\` (kg m^2/s) for
\`get_angular_momentum()\`.

## Details

Both are conserved exactly by Newtonian gravity, because every force
comes in an equal and opposite pair directed along the line between the
two bodies. The Velocity Verlet and Euler-Cromer integrators also
conserve both to floating-point rounding, at any time step, so a drift
in either points to a problem in the setup rather than the step size. A
system whose total momentum is not zero has a center of mass that drifts
at a constant velocity; see \`shift_reference_frame(sim_data,
"barycenter")\`.

## Examples

``` r
# \donttest{
# A binary built with zero total momentum
sim <- create_system() |>
  add_body("A", mass = 2e30, x = 5e10, vy = 15000) |>
  add_body("B", mass = 1e30, x = -1e11, vy = -30000) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_year)

get_momentum(sim)          # px, py, pz all zero to rounding
#> # A tibble: 8,767 × 4
#>     time    px    py    pz
#>    <dbl> <dbl> <dbl> <dbl>
#>  1     0     0     0     0
#>  2  3600     0     0     0
#>  3  7200     0     0     0
#>  4 10800     0     0     0
#>  5 14400     0     0     0
#>  6 18000     0     0     0
#>  7 21600     0     0     0
#>  8 25200     0     0     0
#>  9 28800     0     0     0
#> 10 32400     0     0     0
#> # ℹ 8,757 more rows
get_angular_momentum(sim)  # Lz constant to rounding
#> # A tibble: 8,767 × 4
#>     time    Lx    Ly      Lz
#>    <dbl> <dbl> <dbl>   <dbl>
#>  1     0     0     0 4.50e45
#>  2  3600     0     0 4.50e45
#>  3  7200     0     0 4.50e45
#>  4 10800     0     0 4.50e45
#>  5 14400     0     0 4.50e45
#>  6 18000     0     0 4.50e45
#>  7 21600     0     0 4.50e45
#>  8 25200     0     0 4.50e45
#>  9 28800     0     0 4.50e45
#> 10 32400     0     0 4.50e45
#> # ℹ 8,757 more rows
# }
```
