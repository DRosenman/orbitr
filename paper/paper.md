---
title: 'orbitr: A Tidy N-Body Engine for R'
tags:
  - R
  - orbital mechanics
  - N-body simulation
  - celestial mechanics
  - physics education
  - tidy data
authors:
  - name: Dave Rosenman
    # orcid: 0000-0000-0000-0000   # add yours if you have one (recommended by JOSS)
    affiliation: 1
affiliations:
  - name: Georgia Institute of Technology, Atlanta, GA, United States   # match the affiliation on the EdArXiv preprint
    index: 1
date: 30 September 2026
bibliography: paper.bib
---

# Summary

`orbitr` is an R package for building, simulating, and visualizing gravitational N-body systems. A user assembles a system with a short pipeline, `create_system() |> add_sun() |> add_planet("Earth")`, and `simulate_system()` integrates the equations of motion in a compiled C++ kernel, returning every body's position and velocity at every time step as a tidy data frame [@Wickham2014]. That design choice is the point of the package: the output of a simulation is a dataset, so the tools R users already know become the tools for doing orbital mechanics. Kepler's third law is a `group_by()` and a `summarize()`; a precession rate is a `mutate()` and a linear fit.

Real solar-system bodies are available by name with JPL orbital elements (`add_planet()`, `load_solar_system()`), arbitrary orbits can be specified by position and velocity (`add_body()`) or by classical Keplerian elements (`add_body_keplerian()`), and a library of SI constants such as `mass_sun`, `distance_earth_sun`, and `speed_earth` removes the lookups that usually stand between a student and a first orbit. `plot_orbits()` dispatches automatically between static `ggplot2` [@Wickham2016] output and interactive three-dimensional `plotly` [@Sievert2020] views, `animate_system()` renders animations with fading trails, and `shift_reference_frame()` re-centers a finished simulation on any body. The package is on CRAN and documented at <https://orbit-r.com>.

# Statement of need

Gravitational dynamics has mature open-source engines in other languages: REBOUND [@Rein2012] in C with Python bindings, Mercury [@Chambers1999] in Fortran, and a long tradition of teaching codes in Python [@Newman2013]. R has had almost nothing. The orbit-related packages on CRAN target satellite propagation around Earth (for example `asteRisk` [@asteRisk]) rather than general N-body gravity, so an R user who wants to watch three bodies interact, or check a planet's perihelion drift, has had to leave the language.

That gap matters because R is where a large population of students, instructors, and analysts already works. Physics and astronomy courses increasingly teach computation through data-analysis workflows, and many undergraduates meet `dplyr` and `ggplot2` before they meet a numerical integrator. `orbitr` lets them do physics with the tools they have. It also addresses a problem that is not specific to R: in most N-body codes the interesting derived quantities (periods, energies, libration amplitudes, precession rates) require post-processing inside the engine's own object model. In `orbitr` they are ordinary data operations on an ordinary table, which makes results easy to inspect, plot, test, and share.

The intended users are instructors building course material in R, students and self-learners exploring celestial mechanics, and researchers who want a quick-look N-body tool inside an R analysis pipeline.

# Design and implementation

The integration kernel is written in C++ and exposed through Rcpp [@Eddelbuettel2011]. It implements several fixed-step integrators, including the symplectic velocity Verlet scheme [@Verlet1967], with optional gravitational softening for close encounters; the N-body formulation follows Aarseth [@Aarseth2003]. On a laptop the kernel advances a 1,000-body system in roughly 11 ms per step. All state is carried in plain numeric vectors, so a simulation of a few bodies over centuries runs in seconds and returns directly to R as a `tibble`.

The R interface is a set of pipeable verbs that build an `orbit_system` object incrementally. Every function that adds a body returns the updated system, so a complete solar system with the Sun, eight planets, the Moon, and Pluto is one line, and any orbital element can be overridden to pose "what if" questions ("what if Mars had a circular orbit?"). The package ships with vignettes covering two-body orbits from scratch, Keplerian elements, custom visualization, three-dimensional plotting, and the three-body problem, and it is covered by a `testthat` suite run on CRAN.

# Validation

A companion preprint [@Rosenman2026] uses `orbitr` and a few lines of `dplyr` per problem to reproduce four benchmark results of celestial mechanics: the figure-eight three-body choreography of Chenciner and Montgomery [@Chenciner2000], which closes on itself to within about $10^{-5}$ over three periods; libration of a Trojan test body around Jupiter's L4 point, together with the instability at L1; the Moon's 18.6-year nodal regression and 8.85-year apsidal precession, obtained from nothing but Newtonian point-mass gravity; and sensitive dependence on initial conditions for a Jupiter-crossing orbit, where a one-metre displacement grows to unrelated orbits with an e-folding time of roughly 60 years.

# AI usage disclosure

<!-- JOSS requires this section (Policies > AI usage policy). If earlier Claude versions were used for earlier orbitr code, list them too. -->

Generative AI was used in the development of `orbitr` and in preparing this paper.

1. *Tools:* Claude Fable 5.1 (Anthropic), accessed through claude.ai, during 2026.
2. *Scope:* Code generation and refactoring for the R interface and the Rcpp kernel, drafting of function documentation and vignettes, test scaffolding, and editorial drafting of this manuscript. The physics formulation, package architecture, API design, and choice of numerical methods were decided by the author.
3. *Human verification:* The author reviewed, modified, and tested all AI-assisted code and text, and validated the numerical results reported here and in the companion preprint against published values.

# Acknowledgements

The physics and numerics in `orbitr` were informed by the textbooks of Thornton and Marion, Newman [@Newman2013], and Aarseth [@Aarseth2003], and the C++ engine drew on the Rcpp documentation.

# References
