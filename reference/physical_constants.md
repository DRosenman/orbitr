# Physical Constants for Orbital Mechanics

A curated set of real-world masses and orbital distances for use as
convenient starting points in \`orbitr\` simulations. All values are in
SI units (kilograms and meters).

## Usage

``` r
mass_sun

mass_earth

mass_moon

mass_mars

mass_jupiter

mass_saturn

mass_venus

mass_mercury

distance_earth_sun

distance_earth_moon

distance_mars_sun

distance_jupiter_sun

distance_venus_sun

distance_mercury_sun

speed_earth

speed_moon

speed_mars

speed_jupiter

speed_venus

speed_mercury
```

## Format

Numeric scalar in kilograms.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

An object of class `numeric` of length 1.

## Details

\`mass_sun\`: Mass of the Sun (1.989 x 10^30 kg). Source: IAU 2015
nominal solar mass.

\`mass_earth\`: Mass of the Earth (5.972 x 10^24 kg). Source: IAU 2015
nominal Earth mass.

\`mass_moon\`: Mass of the Moon (7.342 x 10^22 kg). Source: JPL DE440
ephemeris.

\`mass_mars\`: Mass of Mars (6.417 x 10^23 kg). Source: JPL DE440
ephemeris.

\`mass_jupiter\`: Mass of Jupiter (1.898 x 10^27 kg). Source: JPL DE440
ephemeris.

\`mass_saturn\`: Mass of Saturn (5.683 x 10^26 kg). Source: JPL DE440
ephemeris.

\`mass_venus\`: Mass of Venus (4.867 x 10^24 kg). Source: JPL DE440
ephemeris.

\`mass_mercury\`: Mass of Mercury (3.301 x 10^23 kg). Source: JPL DE440
ephemeris.

\`distance_earth_sun\`: Semi-major axis of Earth's orbit around the Sun
(1.496 x 10^11 m, ~149.6 million km). Earth's actual distance varies
between ~147.1 million km (perihelion) and ~152.1 million km (aphelion).

\`distance_earth_moon\`: Semi-major axis of the Moon's orbit around
Earth (3.844 x 10^8 m, ~384,400 km). The Moon's actual distance varies
between ~363,300 km (perigee) and ~405,500 km (apogee).

\`distance_mars_sun\`: Semi-major axis of Mars's orbit around the Sun
(2.279 x 10^11 m, ~227.9 million km). Mars has a notably eccentric orbit
(e = 0.093), ranging from ~206.7 million km to ~249.2 million km.

\`distance_jupiter_sun\`: Semi-major axis of Jupiter's orbit around the
Sun (7.785 x 10^11 m, ~778.5 million km).

\`distance_venus_sun\`: Semi-major axis of Venus's orbit around the Sun
(1.082 x 10^11 m, ~108.2 million km). Venus has the most circular orbit
of any planet (e = 0.007).

\`distance_mercury_sun\`: Semi-major axis of Mercury's orbit around the
Sun (5.791 x 10^10 m, ~57.9 million km). Mercury has the most eccentric
planetary orbit (e = 0.206), ranging from ~46.0 million km to ~69.8
million km.

\`speed_earth\`: Mean orbital speed of Earth around the Sun (29,780
m/s).

\`speed_moon\`: Mean orbital speed of the Moon around Earth (1,022 m/s).

\`speed_mars\`: Mean orbital speed of Mars around the Sun (24,070 m/s).

\`speed_jupiter\`: Mean orbital speed of Jupiter around the Sun (13,060
m/s).

\`speed_venus\`: Mean orbital speed of Venus around the Sun (35,020
m/s).

\`speed_mercury\`: Mean orbital speed of Mercury around the Sun (47,360
m/s).

## A Note on "Distance" Constants

Orbital distances are not truly constant. Every orbit is an ellipse, so
the separation between two bodies changes continuously. The distances
provided here are \*\*semi-major axes\*\* — the average of the closest
approach (periapsis) and farthest point (apoapsis). The semi-major axis
is the single most characteristic length scale of an elliptical orbit:
it determines the orbital period via Kepler's Third Law, and when paired
with the circular velocity at that distance, it produces a near-circular
orbit that closely approximates the real trajectory.

For example, the Earth-Sun distance varies from about 147.1 million km
(perihelion in January) to 152.1 million km (aphelion in July). The
semi-major axis of 149.598 million km sits right in the middle and gives
the correct orbital period of one year.
