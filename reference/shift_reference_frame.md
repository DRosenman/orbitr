# Shift the coordinate reference frame of the simulation

Recalculates the positions and velocities of all bodies relative to a
specific target body. This effectively "anchors the camera" to the
chosen body, placing it at the origin (0, 0, 0) for all time steps.

## Usage

``` r
shift_reference_frame(sim_data, center_id, keep_center = TRUE)
```

## Arguments

- sim_data:

  A tidy \`tibble\` containing the output from \`simulate_system()\`.

- center_id:

  The character string ID of the body to use as the new origin.

- keep_center:

  Logical. Should the central body remain in the dataset (it will have 0
  for all coordinates) or be removed? Default is \`TRUE\`.

## Value

A tidy \`tibble\` with updated \`x\`, \`y\`, \`z\`, \`vx\`, \`vy\`, and
\`vz\` columns.

## Examples

``` r
# \donttest{
# Simulate Sun-Earth-Moon
orbit_data <- create_system() |>
  add_sun() |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  add_body("Moon", mass = mass_moon, x = distance_earth_sun + distance_earth_moon,
           vy = speed_earth + speed_moon) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_year)

# Shift view to Earth and plot
orbit_data |>
  shift_reference_frame(center_id = "Earth") |>
  plot_orbits()

# }
```
