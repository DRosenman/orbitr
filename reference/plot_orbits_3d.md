# Plot 3D Interactive Orbital Trajectories

Generates an interactive 3D visualization of the orbital system using
plotly. You can click, drag to rotate, and scroll to zoom in on the
trajectories.

## Usage

``` r
plot_orbits_3d(sim_data)
```

## Arguments

- sim_data:

  A tibble containing the simulation output from \`simulate_system()\`.

## Value

A plotly HTML widget displaying the 3D orbits.

## Examples

``` r
if (FALSE) { # \dontrun{
create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_body("Moon", mass = mass_moon,
           x = distance_earth_moon, vy = speed_moon, vz = 150) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 30) |>
  plot_orbits_3d()
} # }
```
