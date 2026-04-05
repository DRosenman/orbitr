#' Plot Orbital Trajectories (Smart 2D/3D Dispatch)
#'
#' @param sim_data A tibble output from `simulate()`
#' @param force_3d Logical. If TRUE, forces a 3D plot even for 2D data.
#' @export
plot_orbits <- function(sim_data, force_3d = FALSE) {

  # Check if there is any movement in the Z dimension
  is_3d <- force_3d || any(sim_data$z != 0)

  if (is_3d) {
    # Try to plot in 3D
    if (requireNamespace("plotly", quietly = TRUE)) {
      return(plot_orbits_3d(sim_data)) # Call your plotly function
    } else {
      warning("3D movement detected, but 'plotly' is not installed. Falling back to 2D plot.")
    }
  }

  # Fallback / Default: 2D ggplot
  # (Insert your existing ggplot2 logic here)
  library(ggplot2)
  ggplot(sim_data, aes(x = x, y = y, color = id)) +
    geom_path(linewidth = 1) +
    coord_equal() +
    labs(title = "2D Orbital Trajectories", x = "X (m)", y = "Y (m)") +
    theme_minimal()
}


#' Plot 3D Interactive Orbital Trajectories
#'
#' Generates an interactive 3D visualization of the orbital system using plotly.
#' You can click, drag to rotate, and scroll to zoom in on the trajectories.
#'
#' @param sim_data A tibble containing the simulation output from `simulate()`.
#'
#' @return A plotly HTML widget displaying the 3D orbits.
#' @export
#'
#' @examples
#' \dontrun{
#' create_system() |>
#'   add_body("Earth", mass = 5.972e24) |>
#'   add_body("Moon", mass = 7.342e22, x = 3.844e8, vy = 1022, vz = 150) |>
#'   simulate(time_step = 3600, duration = 86400 * 30) |>
#'   plot_orbits_3d()
#' }
plot_orbits_3d <- function(sim_data) {

  # Ensure plotly is available (good practice even if it's in Imports)
  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("The 'plotly' package is required for 3D plotting. Please install it.")
  }

  plotly::plot_ly(
    data = sim_data,
    x = ~x,
    y = ~y,
    z = ~z,
    color = ~id,
    type = 'scatter3d',
    mode = 'lines',
    line = list(width = 4),
    hoverinfo = 'text',
    text = ~paste("Body:", id, "<br>Time:", round(time / 86400, 1), "days")
  ) |>
    plotly::layout(
      title = "3D Orbital Trajectories",
      scene = list(
        xaxis = list(title = 'X (m)', showgrid = TRUE),
        yaxis = list(title = 'Y (m)', showgrid = TRUE),
        zaxis = list(title = 'Z (m)', showgrid = TRUE),
        # 'data' ensures the 3D space isn't stretched, keeping circular orbits looking circular
        aspectmode = "data"
      ),
      plot_bgcolor = "white",
      paper_bgcolor = "white"
    )
}
