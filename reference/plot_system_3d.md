# Plot 3D Interactive System Snapshot at a Single Time

The 3D counterpart to \[plot_system()\]. Draws every body's position at
a chosen time as a sphere in an interactive plotly scene, optionally
with the full orbital trajectories shown faintly behind.

## Usage

``` r
plot_system_3d(sim_data, time = NULL, trails = TRUE)
```

## Arguments

- sim_data:

  A tibble output from \[simulate_system()\].

- time:

  Time (in simulation seconds) to snapshot. Defaults to the last time
  step. Snaps to the closest available time in the data.

- trails:

  Logical. If \`TRUE\` (the default), the full orbit paths are drawn
  faintly behind the snapshot points.

## Value

A \`plotly\` HTML widget.

## Examples

``` r
if (FALSE) { # \dontrun{
create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_body("Moon",  mass = mass_moon,
           x = distance_earth_moon, vy = speed_moon, vz = 100) |>
  simulate_system(time_step = 3600, duration = 86400 * 30) |>
  plot_system_3d()
} # }
```
