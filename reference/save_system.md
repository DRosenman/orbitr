# Save an orbit_system to disk

Saves the full \`orbit_system\` object (bodies, forces, and time) to an
\`.rds\` file so it can be restored later with \[load_system()\]. This
preserves everything — the gravitational constant, body states, and
class — exactly as it was.

## Usage

``` r
save_system(system, path)
```

## Arguments

- system:

  An \`orbit_system\` object.

- path:

  File path to save to. Should end in \`.rds\`.

## Value

\`system\`, invisibly.

## Examples

``` r
# \donttest{
sys <- create_system() |>
  add_sun() |>
  add_planet("Earth", parent = "Sun")

save_system(sys, file.path(tempdir(), "my_system.rds"))
# }
```
