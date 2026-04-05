# NA

I built an R package for N-body orbital mechanics simulation called
orbitr, and I just pushed it to GitHub.

It lets you set up gravitational systems — planets, moons, binary stars,
chaotic three-body problems — in a few lines of pipe-friendly R code and
simulate them forward in time. Under the hood there’s a C++ engine (via
Rcpp) for speed, with a pure-R fallback so it works everywhere.

A few things it does:

- Three numerical integrators (Velocity Verlet, Euler-Cromer, standard
  Euler) so you can see firsthand why symplectic methods matter for
  orbital stability
- Built-in physical constants (masses, distances, orbital speeds) for
  the Sun, Earth, Moon, Mars, Jupiter, Venus, Mercury, and Saturn — no
  more Googling “mass of Jupiter in kg”
- Reference frame shifting — switch from a heliocentric to geocentric
  view in one line
- Smart 2D/3D plotting — flat orbits get a clean ggplot2 chart, and the
  moment you add motion in the Z direction it automatically switches to
  an interactive 3D plotly visualization
- The output is just a tidy tibble, so you can plug it straight into
  ggplot2, plotly, dplyr, or whatever you normally use

This is still a beta release. If you’re into physics, R, or
computational science and want to try it out:

devtools::install_github(“daverosenman/orbitr”)

I’d love feedback — especially on the API design and what features would
make this more useful. Link to the repo in the comments.

\#RStats \#OpenSource \#Physics \#DataScience \#Simulation
