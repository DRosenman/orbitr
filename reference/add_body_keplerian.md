# Add a body using Keplerian orbital elements

A convenience wrapper around \[add_body()\] that lets you specify an
orbit using classical Keplerian elements instead of raw Cartesian state
vectors. The elements are converted to position and velocity in the
reference frame of the parent body, which must already exist in the
system.

## Usage

``` r
add_body_keplerian(
  system,
  id,
  mass,
  a,
  e = 0,
  i = 0,
  lan = 0,
  arg_pe = 0,
  nu = 0,
  parent
)
```

## Arguments

- system:

  An \`orbit_system\` object created by \[create_system()\].

- id:

  A unique character string to identify the body.

- mass:

  The mass of the body in kilograms.

- a:

  Semi-major axis in meters. Positive for a bound orbit (\`e \< 1\`);
  negative for a hyperbolic orbit (\`e \> 1\`), in which case the
  periapsis distance is \`a \* (1 - e)\`, which is positive.

- e:

  Eccentricity (0 = circle, 0 \< e \< 1 = ellipse, e \> 1 = hyperbola).
  Default 0. Exactly parabolic orbits (\`e = 1\`) are not supported; use
  a value slightly above or below 1.

- i:

  Inclination in degrees. Default 0.

- lan:

  Longitude of ascending node in degrees. Default 0.

- arg_pe:

  Argument of periapsis in degrees. Default 0.

- nu:

  True anomaly in degrees. Default 0 (body starts at periapsis). For a
  hyperbolic orbit, \`nu\` must lie between the asymptotes, \`abs(nu) \<
  acos(-1/e) \* 180 / pi\`.

- parent:

  Character id of the parent body (must already exist in \`system\`).
  The orbital elements are defined relative to this body.

## Value

The updated \`orbit_system\` with the new body added.

## Keplerian Elements

Six numbers fully describe a Keplerian orbit:

- \`a\` (semi-major axis):

  The size of the orbit — half the longest diameter of the ellipse, in
  meters. Negative for a hyperbolic orbit.

- \`e\` (eccentricity):

  The shape of the orbit. 0 is a perfect circle; values between 0 and 1
  are ellipses; values above 1 are hyperbolas (unbound flybys).

- \`i\` (inclination):

  The tilt of the orbital plane relative to the reference plane, in
  degrees.

- \`lan\` (longitude of ascending node):

  The angle from the reference direction to where the orbit crosses the
  reference plane going "upward," in degrees. Sometimes written as
  \\\Omega\\.

- \`arg_pe\` (argument of periapsis):

  The angle within the orbital plane from the ascending node to the
  closest-approach point, in degrees. Sometimes written as \\\omega\\.

- \`nu\` (true anomaly):

  Where the body currently sits along its orbit, measured as an angle
  from periapsis in degrees. 0 = at periapsis (closest), 180 = at
  apoapsis (farthest).

## Examples

``` r
# \donttest{
# Earth orbiting the Sun with real orbital elements
system <- create_system() |>
  add_sun() |>
  add_body_keplerian(
    "Earth", mass = mass_earth,
    a = distance_earth_sun, e = 0.0167, i = 0.00005,
    parent = "Sun"
  )

# An interstellar visitor on a hyperbolic orbit (e > 1 needs a < 0):
# 'Oumuamua-like, perihelion 0.255 AU, approaching from 140 degrees
# before perihelion
q <- 0.2553 * distance_earth_sun
e <- 1.2
system <- system |>
  add_body_keplerian(
    "Visitor", mass = 1e10,
    a = -q / (e - 1), e = e, i = 122.7, nu = -140,
    parent = "Sun"
  )

# Mars with its notable eccentricity
system <- system |>
  add_body_keplerian(
    "Mars", mass = mass_mars,
    a = distance_mars_sun, e = 0.0934, i = 1.85,
    lan = 49.6, arg_pe = 286.5, nu = 0,
    parent = "Sun"
  )
# }
```
