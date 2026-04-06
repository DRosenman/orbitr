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
  add_body("Earth", mass = 5.972e24) |>
  add_body("Moon", mass = 7.342e22, x = 3.844e8, vy = 1022, vz = 150) |>
  simulate_system(time_step = 3600, duration = 86400 * 30) |>
  plot_orbits_3d()
} # }
```
