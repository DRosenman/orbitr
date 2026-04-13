# Add a known solar system body by name

A convenience wrapper around \[add_body_keplerian()\] that looks up real
orbital elements for well-known solar system bodies. Instead of typing
out mass, semi-major axis, eccentricity, and inclination by hand, just
give the name and parent:

## Usage

``` r
add_planet(
  system,
  name,
  parent,
  nu = 0,
  a = NULL,
  e = NULL,
  i = NULL,
  lan = NULL,
  arg_pe = NULL,
  mass = NULL
)
```

## Arguments

- system:

  An \`orbit_system\` object.

- name:

  The name of the body. Must be one of: \`"Mercury"\`, \`"Venus"\`,
  \`"Earth"\`, \`"Mars"\`, \`"Jupiter"\`, \`"Saturn"\`, \`"Uranus"\`,
  \`"Neptune"\`, \`"Moon"\`, or \`"Pluto"\`. Case-sensitive.

- parent:

  Character id of the parent body, which must already exist in the
  system. For planets and Pluto this is typically \`"Sun"\`; for the
  Moon it is \`"Earth"\`.

- nu:

  True anomaly in degrees (default 0, body starts at periapsis). This is
  the most commonly overridden element — use it to spread planets around
  their orbits instead of starting them all at periapsis.

- a:

  Override semi-major axis (meters).

- e:

  Override eccentricity.

- i:

  Override inclination (degrees).

- lan:

  Override longitude of ascending node (degrees).

- arg_pe:

  Override argument of periapsis (degrees).

- mass:

  Override mass (kg).

## Value

The updated \`orbit_system\` with the body added.

## Details

“\` create_system() \|\> add_body("Sun", mass = mass_sun) \|\>
add_planet("Earth", parent = "Sun") \|\> add_planet("Moon", parent =
"Earth") “\`

Any Keplerian element can be overridden to explore "what if" scenarios
while keeping the rest of the real values:

“\` \# What if Mars had zero eccentricity? add_planet("Mars", parent =
"Sun", e = 0) “\`

## Examples

``` r
if (FALSE) { # \dontrun{
# Build the inner solar system
create_system() |>
  add_body("Sun", mass = mass_sun) |>
  add_planet("Mercury", parent = "Sun") |>
  add_planet("Venus",   parent = "Sun") |>
  add_planet("Earth",   parent = "Sun") |>
  add_planet("Mars",    parent = "Sun") |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year) |>
  plot_orbits()

# Earth-Moon system
create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_planet("Moon", parent = "Earth") |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 28) |>
  plot_orbits()

# What if Jupiter were twice as massive?
add_planet("Jupiter", parent = "Sun", mass = mass_jupiter * 2)
} # }
```
