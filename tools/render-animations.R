# Pre-render vignette animations as GIFs and save to man/figures/.
# Run this once after changing any animation; the vignettes reference
# these files as static images so pkgdown::build_site() doesn't have
# to re-render them on every build.
#
# Usage (from package root):
#   source("tools/render-animations.R")

library(orbitr)
library(gganimate)

out_dir <- "man/figures"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

save_anim <- function(anim, file, width = 700, height = 500) {
  message("Rendering ", file, " ...")
  gganimate::anim_save(
    filename = file.path(out_dir, file),
    animation = anim
  )
  message("  done.")
}

# --- quick-start: Sun-Earth ---------------------------------------------------
sim <- create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  simulate_system(time_step = seconds_per_day, duration = seconds_per_year)

save_anim(
  animate_system(sim, fps = 15, duration = 5),
  "quick-start-earth-orbit-anim.gif"
)

# --- examples: Earth-Moon -----------------------------------------------------
earth_moon <- create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_body("Moon",  mass = mass_moon, x = distance_earth_moon, vy = speed_moon) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 28)

save_anim(
  animate_system(earth_moon, fps = 15, duration = 5),
  "examples-earth-moon-anim.gif"
)

# --- examples: Sun-Earth-Moon (Earth frame) -----------------------------------
sun_earth_moon <- create_system() |>
  add_body("Sun",   mass = mass_sun) |>
  add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
  add_body("Moon",  mass = mass_moon,
           x = distance_earth_sun + distance_earth_moon,
           vy = speed_earth + speed_moon) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_year) |>
  shift_reference_frame("Earth")

save_anim(
  animate_system(sun_earth_moon, fps = 15, duration = 6),
  "examples-sun-earth-moon-anim.gif"
)

# --- examples: Kepler-16 ------------------------------------------------------
AU <- distance_earth_sun
m_A <- 0.68 * mass_sun
m_B <- 0.20 * mass_sun
m_planet <- 0.333 * mass_jupiter
a_bin <- 0.22 * AU
r_A <- a_bin * m_B / (m_A + m_B)
r_B <- a_bin * m_A / (m_A + m_B)
v_A <- sqrt(gravitational_constant * m_B^2 / ((m_A + m_B) * a_bin))
v_B <- sqrt(gravitational_constant * m_A^2 / ((m_A + m_B) * a_bin))
r_planet <- 0.7048 * AU
v_planet <- sqrt(gravitational_constant * (m_A + m_B) / r_planet)

kepler16 <- create_system() |>
  add_body("Star A", mass = m_A, x = r_A, vy = v_A) |>
  add_body("Star B", mass = m_B, x = -r_B, vy = -v_B) |>
  add_body("Kepler-16b", mass = m_planet, x = r_planet, vy = v_planet) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 228.8 * 3)

save_anim(
  animate_system(kepler16, fps = 15, duration = 6),
  "examples-kepler16-anim.gif"
)

# --- unstable-orbits: three-body chaos ----------------------------------------
three_body <- create_system() |>
  add_body("Star A", mass = 1e30, x = 1e11, y = 0, vx = 0, vy = 15000) |>
  add_body("Star B", mass = 1e30, x = -5e10, y = 8.66e10, vx = -12990, vy = -7500) |>
  add_body("Star C", mass = 1e30, x = -5e10, y = -8.66e10, vx = 14000, vy = -8000) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_year * 3)

save_anim(
  animate_system(three_body, fps = 15, duration = 6),
  "unstable-orbits-three-body-anim.gif"
)

message("\nAll animations rendered to ", out_dir, "/")
