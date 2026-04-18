# Plot System Snapshot at a Single Time (Smart 2D/3D Dispatch)

Plots the position of every body in the system at a single time step,
optionally with the full orbital trajectories drawn faintly behind. This
is the snapshot counterpart to \[plot_orbits()\], which draws full
trajectories.

## Usage

``` r
plot_system(sim_data, time = NULL, trails = FALSE, three_d = NULL)
```

## Arguments

- sim_data:

  A tibble output from \[simulate_system()\].

- time:

  Time (in simulation seconds) to snapshot. Defaults to the last time
  step. The function snaps to the closest available time in the data.

- trails:

  Logical. If \`TRUE\` (the default), the full orbit paths are drawn
  faintly behind the snapshot points. Set \`FALSE\` for a pure snapshot
  showing only the body positions at the chosen time.

- three_d:

  Logical. If \`TRUE\`, forces a 3D plot even for planar data.

## Value

A \`ggplot\` object (2D) or a \`plotly\` HTML widget (3D).

## Details

If any body has non-zero motion in the Z dimension (or \`three_d =
TRUE\`), \[plot_system_3d()\] is used; otherwise a 2D \`ggplot2\` plot
is returned.

## Examples

``` r
# \donttest{
sim <- create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year)

# Final state with faint orbit trails
plot_system(sim)


# State at day 100, no trails
plot_system(sim, time = seconds_per_day * 100, trails = FALSE)

# }
```
