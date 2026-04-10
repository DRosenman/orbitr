# Animate the System Over Time in Interactive 3D

The 3D counterpart to \[animate_system()\]. Builds a \`plotly\` 3D scene
with the bodies as moving markers and an interactive Play / Pause
control plus a time slider. Optionally shows the full orbit paths drawn
faintly behind.

## Usage

``` r
animate_system_3d(sim_data, fps = 20, duration = 10, trails = FALSE)
```

## Arguments

- sim_data:

  A tibble output from \[simulate_system()\].

- fps:

  Frames per second target for playback. Default \`20\`. Combined with
  \`duration\`, controls how many time steps are sampled into frames.

- duration:

  Total playback length in seconds. Default \`10\`.

- trails:

  Logical. If \`TRUE\` (the default), the full orbit paths are drawn
  faintly behind the animated markers.

## Value

A \`plotly\` HTML widget with a built-in play button and time slider.

## Examples

``` r
if (FALSE) { # \dontrun{
create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_body("Moon",  mass = mass_moon,
           x = distance_earth_moon, vy = speed_moon, vz = 100) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 30) |>
  animate_system_3d()
} # }
```
