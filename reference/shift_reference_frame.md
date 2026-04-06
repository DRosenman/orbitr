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
if (FALSE) { # \dontrun{
# Simulate Sun-Earth-Moon
orbit_data <- create_system() |>
  add_body("Sun", mass = 1.989e30) |>
  add_body("Earth", mass = 5.97e24, x = 1.496e11, vy = 29780) |>
  add_body("Moon", mass = 7.34e22, x = 1.496e11 + 3.84e8, vy = 29780 + 1022) |>
  simulate_system(time_step = 3600, duration = 86400 * 365)

# Shift view to Earth and plot
orbit_data |>
  shift_reference_frame(center_id = "Earth") |>
  plot_orbits()
} # }
```
