#' Plot Orbital Trajectories (Smart 2D/3D Dispatch)
#'
#' @param sim_data A tibble output from `simulate_system()`
#' @param three_d Logical. If TRUE, forces a 3D plot even for 2D data.
#'
#' @return A `ggplot` object (2D) or a `plotly` HTML widget (3D) showing the
#'   orbital trajectories of all bodies in the simulation.
#' @export
plot_orbits <- function(sim_data, three_d = NULL) {

  # Check if there is any movement in the Z dimension
  is_3d <- if (is.null(three_d)) any(sim_data$z != 0) else three_d

  if (is_3d) {
    # Try to plot in 3D
    if (requireNamespace("plotly", quietly = TRUE)) {
      return(plot_orbits_3d(sim_data)) # Call your plotly function
    } else {
      warning("3D movement detected, but 'plotly' is not installed. Falling back to 2D plot.")
    }
  }

  # Fallback / Default: 2D ggplot
  ggplot2::ggplot(sim_data, ggplot2::aes(x = x, y = y, color = id)) +
    ggplot2::geom_path(linewidth = 1) +
    ggplot2::coord_equal() +
    ggplot2::labs(title = "2D Orbital Trajectories", x = "X (m)", y = "Y (m)") +
    ggplot2::theme_minimal()
}


#' Plot 3D Interactive Orbital Trajectories
#'
#' Generates an interactive 3D visualization of the orbital system using plotly.
#' You can click, drag to rotate, and scroll to zoom in on the trajectories.
#'
#' @param sim_data A tibble containing the simulation output from `simulate_system()`.
#'
#' @return A plotly HTML widget displaying the 3D orbits.
#' @export
#'
#' @examples
#' \donttest{
#' create_system() |>
#'   add_body("Earth", mass = mass_earth) |>
#'   add_body("Moon", mass = mass_moon,
#'            x = distance_earth_moon, vy = speed_moon, vz = 150) |>
#'   simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 30) |>
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
    text = ~paste("Body:", id, "<br>Time:", round(time / seconds_per_day, 1), "days")
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


#' Plot System Snapshot at a Single Time (Smart 2D/3D Dispatch)
#'
#' Plots the position of every body in the system at a single time step,
#' optionally with the full orbital trajectories drawn faintly behind. This is
#' the snapshot counterpart to [plot_orbits()], which draws full trajectories.
#'
#' If any body has non-zero motion in the Z dimension (or `three_d = TRUE`),
#' [plot_system_3d()] is used; otherwise a 2D `ggplot2` plot is returned.
#'
#' @param sim_data A tibble output from [simulate_system()].
#' @param time Time (in simulation seconds) to snapshot. Defaults to the last
#'   time step. The function snaps to the closest available time in the data.
#' @param trails Logical. If `TRUE` (the default), the full orbit paths are
#'   drawn faintly behind the snapshot points. Set `FALSE` for a pure snapshot
#'   showing only the body positions at the chosen time.
#' @param three_d Logical. If `TRUE`, forces a 3D plot even for planar data.
#'
#' @return A `ggplot` object (2D) or a `plotly` HTML widget (3D).
#' @export
#'
#' @examples
#' \donttest{
#' sim <- create_system() |>
#'   add_body("Sun",   mass = mass_sun) |>
#'   add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_year)
#'
#' # Final state with faint orbit trails
#' plot_system(sim)
#'
#' # State at day 100, no trails
#' plot_system(sim, time = seconds_per_day * 100, trails = FALSE)
#' }
plot_system <- function(sim_data, time = NULL, trails = FALSE, three_d = NULL) {

  is_3d <- if (is.null(three_d)) any(sim_data$z != 0) else three_d

  if (is_3d) {
    if (requireNamespace("plotly", quietly = TRUE)) {
      return(plot_system_3d(sim_data, time = time, trails = trails))
    } else {
      warning("3D motion detected, but 'plotly' is not installed. Falling back to 2D plot.")
    }
  }

  snap <- snapshot_at(sim_data, time)

  p <- ggplot2::ggplot(mapping = ggplot2::aes(x = x, y = y, color = id))

  if (isTRUE(trails)) {
    p <- p + ggplot2::geom_path(data = sim_data, linewidth = 0.6, alpha = 0.35)
  }

  p +
    ggplot2::geom_point(data = snap, size = 4) +
    ggplot2::coord_equal() +
    ggplot2::labs(
      title = sprintf("System Snapshot (t = %.3g s)", snap$time[1]),
      x = "X (m)", y = "Y (m)"
    ) +
    ggplot2::theme_minimal()
}


#' Plot 3D Interactive System Snapshot at a Single Time
#'
#' The 3D counterpart to [plot_system()]. Draws every body's position at a
#' chosen time as a sphere in an interactive plotly scene, optionally with the
#' full orbital trajectories shown faintly behind.
#'
#' @param sim_data A tibble output from [simulate_system()].
#' @param time Time (in simulation seconds) to snapshot. Defaults to the last
#'   time step. Snaps to the closest available time in the data.
#' @param trails Logical. If `TRUE` (the default), the full orbit paths are
#'   drawn faintly behind the snapshot points.
#'
#' @return A `plotly` HTML widget.
#' @export
#'
#' @examples
#' \donttest{
#' create_system() |>
#'   add_body("Earth", mass = mass_earth) |>
#'   add_body("Moon",  mass = mass_moon,
#'            x = distance_earth_moon, vy = speed_moon, vz = 100) |>
#'   simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 30) |>
#'   plot_system_3d()
#' }
plot_system_3d <- function(sim_data, time = NULL, trails = FALSE) {

  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("The 'plotly' package is required for 3D plotting. Please install it.")
  }

  snap <- snapshot_at(sim_data, time)

  fig <- plotly::plot_ly()

  if (isTRUE(trails)) {
    fig <- fig |>
      plotly::add_trace(
        data = sim_data,
        x = ~x, y = ~y, z = ~z,
        color = ~id,
        type = 'scatter3d',
        mode = 'lines',
        line = list(width = 3),
        opacity = 0.35,
        hoverinfo = 'skip',
        showlegend = FALSE
      )
  }

  fig <- fig |>
    plotly::add_trace(
      data = snap,
      x = ~x, y = ~y, z = ~z,
      color = ~id,
      type = 'scatter3d',
      mode = 'markers',
      marker = list(size = 6),
      hoverinfo = 'text',
      text = ~paste0(
        "Body: ", id,
        "<br>Time: ", round(time / seconds_per_day, 2), " days",
        "<br>x: ", signif(x, 4),
        "<br>y: ", signif(y, 4),
        "<br>z: ", signif(z, 4)
      )
    )

  fig |>
    plotly::layout(
      title = sprintf("System Snapshot (t = %.3g s)", snap$time[1]),
      scene = list(
        xaxis = list(title = 'X (m)', showgrid = TRUE),
        yaxis = list(title = 'Y (m)', showgrid = TRUE),
        zaxis = list(title = 'Z (m)', showgrid = TRUE),
        aspectmode = "data"
      ),
      plot_bgcolor = "white",
      paper_bgcolor = "white"
    )
}


#' Animate the System Over Time (Smart 2D/3D Dispatch)
#'
#' Plays the simulation forward as an animation. Bodies move through their
#' orbits frame by frame, optionally leaving a fading wake behind them. This is
#' the animated counterpart to [plot_system()] — a moving snapshot rather than
#' a single frozen one.
#'
#' If any body has non-zero motion in the Z dimension (or `three_d = TRUE`),
#' [animate_system_3d()] is used; otherwise a 2D `gganimate` animation is
#' returned.
#'
#' @param sim_data A tibble output from [simulate_system()].
#' @param fps Frames per second of the rendered animation. Default `20`.
#' @param duration Length of the animation in seconds. Default `10`. Together
#'   with `fps`, this determines how many simulation time steps are sampled
#'   into frames (`fps * duration`). If your simulation has fewer steps than
#'   that, every step becomes a frame.
#' @param trails Logical. If `TRUE` (the default), each body leaves a fading
#'   wake of its recent positions behind it. Set `FALSE` for naked moving dots.
#' @param three_d Logical. If `TRUE`, forces a 3D animation even for planar
#'   data.
#'
#' @return A rendered `gganimate` animation (2D) or a `plotly` HTML widget with
#'   built-in play/pause controls (3D). The 2D return value can be saved to
#'   disk with [gganimate::anim_save()].
#'
#' @details
#' The 2D path requires the `gganimate` package, which is in `Suggests`.
#' Install it with `install.packages("gganimate")`. Rendering a 2D animation
#' is much slower than a static plot — expect tens of seconds for typical
#' simulations, since every frame is drawn and encoded as a GIF (or MP4).
#'
#' The 3D path uses `plotly`'s built-in `frame` aesthetic, which produces an
#' interactive HTML widget with a play button and time slider. No GIF encoding
#' is involved, so 3D animations render essentially instantly.
#'
#' @export
#'
#' @examples
#' \donttest{
#' sim <- create_system() |>
#'   add_body("Sun",   mass = mass_sun) |>
#'   add_body("Earth", mass = mass_earth, x = distance_earth_sun, vy = speed_earth) |>
#'   simulate_system(time_step = seconds_per_day, duration = seconds_per_year)
#'
#' # 2D fading-wake animation (requires gganimate)
#' anim <- animate_system(sim, fps = 20, duration = 8)
#' anim
#'
#' # Save to disk
#' gganimate::anim_save(file.path(tempdir(), "earth_orbit.gif"), anim)
#' }
animate_system <- function(sim_data, fps = 20, duration = 10,
                           trails = FALSE, three_d = NULL) {

  is_3d <- if (is.null(three_d)) any(sim_data$z != 0) else three_d

  if (is_3d) {
    if (requireNamespace("plotly", quietly = TRUE)) {
      return(animate_system_3d(sim_data, fps = fps, duration = duration,
                               trails = trails))
    } else {
      warning("3D motion detected, but 'plotly' is not installed. Falling back to 2D animation.")
    }
  }

  if (!requireNamespace("gganimate", quietly = TRUE)) {
    stop("The 'gganimate' package is required for 2D animations. Install it with install.packages(\"gganimate\").")
  }

  # Pick a renderer that actually produces a rendered animation. Without one
  # of these, gganimate silently falls back to file_renderer(), which writes
  # individual PNG frames to a tempdir and returns the file paths instead of
  # a playable animation.
  renderer <- if (requireNamespace("gifski", quietly = TRUE)) {
    gganimate::gifski_renderer()
  } else if (requireNamespace("magick", quietly = TRUE)) {
    gganimate::magick_renderer()
  } else {
    stop(
      "No animation renderer available. Install one of:\n",
      "  install.packages(\"gifski\")   # recommended, fast GIF encoder\n",
      "  install.packages(\"magick\")   # alternative renderer\n",
      "Without one of these, gganimate would silently dump individual PNG ",
      "frames to a tempdir instead of producing a playable animation."
    )
  }

  frames <- downsample_frames(sim_data, fps = fps, duration = duration)

  p <- ggplot2::ggplot(frames, ggplot2::aes(x = x, y = y, color = id, group = id)) +
    ggplot2::geom_point(size = 4) +
    ggplot2::coord_equal() +
    ggplot2::labs(
      title = "Time: {round(frame_time / seconds_per_day, 1)} days",
      x = "X (m)", y = "Y (m)"
    ) +
    ggplot2::theme_minimal() +
    gganimate::transition_time(time)

  if (isTRUE(trails)) {
    p <- p + gganimate::shadow_wake(wake_length = 0.1, alpha = 0.35)
  }

  gganimate::animate(p, fps = fps, duration = duration, renderer = renderer)
}


#' Animate the System Over Time in Interactive 3D
#'
#' The 3D counterpart to [animate_system()]. Builds a `plotly` 3D scene with
#' the bodies as moving markers and an interactive Play / Pause control plus a
#' time slider. Optionally shows the full orbit paths drawn faintly behind.
#'
#' @param sim_data A tibble output from [simulate_system()].
#' @param fps Frames per second target for playback. Default `20`. Combined
#'   with `duration`, controls how many time steps are sampled into frames.
#' @param duration Total playback length in seconds. Default `10`.
#' @param trails Logical. If `TRUE` (the default), the full orbit paths are
#'   drawn faintly behind the animated markers.
#'
#' @return A `plotly` HTML widget with a built-in play button and time slider.
#' @export
#'
#' @examples
#' \donttest{
#' create_system() |>
#'   add_body("Earth", mass = mass_earth) |>
#'   add_body("Moon",  mass = mass_moon,
#'            x = distance_earth_moon, vy = speed_moon, vz = 100) |>
#'   simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 30) |>
#'   animate_system_3d()
#' }
animate_system_3d <- function(sim_data, fps = 20, duration = 10, trails = FALSE) {

  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("The 'plotly' package is required for 3D animation. Please install it.")
  }

  frames <- downsample_frames(sim_data, fps = fps, duration = duration)

  fig <- plotly::plot_ly()

  if (isTRUE(trails)) {
    fig <- fig |>
      plotly::add_trace(
        data = sim_data,
        x = ~x, y = ~y, z = ~z,
        color = ~id,
        type = 'scatter3d',
        mode = 'lines',
        line = list(width = 3),
        opacity = 0.35,
        hoverinfo = 'skip',
        showlegend = FALSE
      )
  }

  fig <- fig |>
    plotly::add_trace(
      data = frames,
      x = ~x, y = ~y, z = ~z,
      color = ~id,
      frame = ~time,
      type = 'scatter3d',
      mode = 'markers',
      marker = list(size = 6),
      hoverinfo = 'text',
      text = ~paste0(
        "Body: ", id,
        "<br>Time: ", round(time / seconds_per_day, 2), " days"
      )
    )

  fig |>
    plotly::animation_opts(
      frame = 1000 / fps,
      transition = 0,
      redraw = TRUE
    ) |>
    plotly::layout(
      title = "System Animation",
      scene = list(
        xaxis = list(title = 'X (m)', showgrid = TRUE),
        yaxis = list(title = 'Y (m)', showgrid = TRUE),
        zaxis = list(title = 'Z (m)', showgrid = TRUE),
        aspectmode = "data"
      ),
      plot_bgcolor = "white",
      paper_bgcolor = "white"
    )
}


# Internal helper: downsample a simulation tibble to roughly `fps * duration`
# unique time steps, evenly spaced across the available simulation times. If
# the sim already has fewer steps than that, returns it unchanged.
downsample_frames <- function(sim_data, fps, duration) {

  if (!"time" %in% names(sim_data)) {
    stop("`sim_data` must have a `time` column. Did you pass the output of simulate_system()?")
  }

  available <- sort(unique(sim_data$time))
  n_frames  <- max(2, round(fps * duration))

  if (length(available) <= n_frames) {
    return(sim_data)
  }

  keep_idx <- round(seq(1, length(available), length.out = n_frames))
  keep <- available[keep_idx]
  sim_data[sim_data$time %in% keep, , drop = FALSE]
}


# Internal helper: pick the rows of `sim_data` whose `time` is closest to the
# requested time. If `time` is NULL, uses the last available time step.
snapshot_at <- function(sim_data, time = NULL) {

  if (!"time" %in% names(sim_data)) {
    stop("`sim_data` must have a `time` column. Did you pass the output of simulate_system()?")
  }

  available <- sort(unique(sim_data$time))

  if (is.null(time)) {
    target <- available[length(available)]
  } else {
    target <- available[which.min(abs(available - time))]
  }

  sim_data[sim_data$time == target, , drop = FALSE]
}
