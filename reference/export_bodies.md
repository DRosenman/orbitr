# Export body states to CSV

Writes the body table (id, mass, position, and velocity) from an
\`orbit_system\` to a CSV file. This is useful for sharing initial
conditions with collaborators or loading them into other tools like
Python or Excel.

## Usage

``` r
export_bodies(system, path)
```

## Arguments

- system:

  An \`orbit_system\` object.

- path:

  File path to save to. Should end in \`.csv\`.

## Value

\`system\`, invisibly.

## Examples

``` r
# \donttest{
sys <- create_system() |>
  add_sun() |>
  add_planet("Earth", parent = "Sun") |>
  add_planet("Mars",  parent = "Sun")

export_bodies(sys, file.path(tempdir(), "bodies.csv"))
# }
```
