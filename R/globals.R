# Suppress R CMD check NOTEs for non-standard evaluation columns used in
# dplyr/ggplot2 pipelines. These are column names, not global variables.
utils::globalVariables(c(

  # simulation tibble columns
  "x", "y", "z", "vx", "vy", "vz", "id", "time",

  # temporary columns in shift_reference_frame()
  "ref_x", "ref_y", "ref_z", "ref_vx", "ref_vy", "ref_vz"
))
