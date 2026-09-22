# Load an orbit_system from disk

Restores an \`orbit_system\` previously saved with \[save_system()\].

## Usage

``` r
load_system(path)
```

## Arguments

- path:

  File path to an \`.rds\` file created by \[save_system()\].

## Value

An \`orbit_system\` object.

## Examples

``` r
# \donttest{
sys <- create_system() |>
  add_sun() |>
  add_planet("Earth", parent = "Sun")

path <- file.path(tempdir(), "my_system.rds")
save_system(sys, path)
restored <- load_system(path)
# }
```
