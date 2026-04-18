# Plot Orbital Trajectories (Smart 2D/3D Dispatch)

Plot Orbital Trajectories (Smart 2D/3D Dispatch)

## Usage

``` r
plot_orbits(sim_data, three_d = NULL)
```

## Arguments

- sim_data:

  A tibble output from \`simulate_system()\`

- three_d:

  Logical. If TRUE, forces a 3D plot even for 2D data.

## Value

A \`ggplot\` object (2D) or a \`plotly\` HTML widget (3D) showing the
orbital trajectories of all bodies in the simulation.
