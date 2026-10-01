# Rebuild an orbit_system from a simulation snapshot

Takes the state of every body at one time step of a simulation and
returns a new \`orbit_system\` with those positions and velocities as
its initial conditions. This is the bridge from a finished run back to a
system you can modify (add a body, remove one, change a velocity) and
simulate again.

## Usage

``` r
system_from_simulation(sim_data, time = NULL, G = NULL)
```

## Arguments

- sim_data:

  A tibble output from \[simulate_system()\].

- time:

  The simulation time (in seconds) of the snapshot to use. Defaults to
  the last time step. Snaps to the closest available time.

- G:

  The gravitational constant for the new system. Defaults to the value
  recorded by \[simulate_system()\] in the \`"G"\` attribute of
  \`sim_data\`, or to \[gravitational_constant\] if that is absent.

## Value

An \`orbit_system\` whose bodies have the snapshot's positions and
velocities.

## Examples

``` r
# \donttest{
sim <- create_system() |>
  add_sun() |>
  add_planet("Earth", parent = "Sun") |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_day * 100)

# Where everything was on day 100, as a system ready to simulate again
later <- system_from_simulation(sim)
later
#> ───────────────────────────────── orbit_system ───────────────────────────────── 
#> G: 6.6743e-11 (standard)
#> Bodies: 2
#> 
#> # A tibble: 2 × 8
#>   id       mass        x             y     z        vx          vy    vz
#>   <chr>   <dbl>    <dbl>         <dbl> <dbl>     <dbl>       <dbl> <dbl>
#> 1 Sun   1.99e30 -4.51e 5       433299.     0    -0.123      0.0620     0
#> 2 Earth 5.97e24 -1.38e11 -59601314664.     0 11348.    -27451.         0
# }
```
