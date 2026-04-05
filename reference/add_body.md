# Add a physical body to the system

This function introduces a new celestial or physical body into your
\`orbit_system\`. You must provide a unique identifier and its mass. By
default, the body will be placed at the origin (0, 0, 0) with zero
initial velocity unless specified.

## Usage

``` r
add_body(system, id, mass, x = 0, y = 0, z = 0, vx = 0, vy = 0, vz = 0)
```

## Arguments

- system:

  An \`orbit_system\` object created by \`create_system()\`.

- id:

  A unique character string to identify the body (e.g., "Earth",
  "Apollo").

- mass:

  The mass of the object in kilograms.

- x:

  Initial X-axis position in meters (default 0).

- y:

  Initial Y-axis position in meters (default 0).

- z:

  Initial Z-axis position in meters (default 0).

- vx:

  Initial velocity along the X-axis in meters per second (default 0).

- vy:

  Initial velocity along the Y-axis in meters per second (default 0).

- vz:

  Initial velocity along the Z-axis in meters per second (default 0).

## Value

The updated \`orbit_system\` object containing the newly added body.

## Examples

``` r
if (FALSE) { # \dontrun{
my_universe <- create_system() |>
  add_body(id = "Earth", mass = 5.97e24) |>
  add_body(id = "Moon", mass = 7.34e22, x = 3.84e8, vy = 1022)
} # }
```
