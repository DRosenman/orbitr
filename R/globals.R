# Suppress R CMD check NOTEs for non-standard evaluation columns used in
# dplyr/ggplot2 pipelines. These are column names, not global variables.
utils::globalVariables(c(

  # simulation tibble columns
  "x", "y", "z", "vx", "vy", "vz", "id", "time", "mass",

  # temporary columns in shift_reference_frame()
  "ref_x", "ref_y", "ref_z", "ref_vx", "ref_vy", "ref_vz",

  # columns in get_energy(), get_momentum(), conserved_quantities()
  "kinetic", "potential", "energy", "px", "py", "pz", "Lx", "Ly", "Lz",
  "p_scale", "energy_error", "momentum_error", "angular_momentum_error"
))
