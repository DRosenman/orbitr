# Plot 3D Interactive System Snapshot at a Single Time

The 3D counterpart to \[plot_system()\]. Draws every body's position at
a chosen time as a sphere in an interactive plotly scene, optionally
with the full orbital trajectories shown faintly behind.

## Usage

``` r
plot_system_3d(sim_data, time = NULL, trails = FALSE)
```

## Arguments

- sim_data:

  A tibble output from \[simulate_system()\].

- time:

  Time (in simulation seconds) to snapshot. Defaults to the last time
  step. Snaps to the closest available time in the data.

- trails:

  Logical. If \`TRUE\` (the default), the full orbit paths are drawn
  faintly behind the snapshot points.

## Value

A \`plotly\` HTML widget.

## Examples

``` r
# \donttest{
create_system() |>
  add_body("Earth", mass = mass_earth) |>
  add_body("Moon",  mass = mass_moon,
           x = distance_earth_moon, vy = speed_moon, vz = 100) |>
  simulate_system(time_step = seconds_per_hour, duration = seconds_per_day * 30) |>
  plot_system_3d()

{"x":{"visdat":{"20a62aebfeef":["function () ","plotlyVisDat"],"20a65f935e08":["function () ","data"]},"cur_data":"20a65f935e08","attrs":{"20a65f935e08":{"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"x":{},"y":{},"z":{},"color":{},"type":"scatter3d","mode":"markers","marker":{"size":6},"hoverinfo":"text","text":{},"inherit":true}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"System Snapshot (t = 2.59e+06 s)","scene":{"xaxis":{"title":"X (m)","showgrid":true},"yaxis":{"title":"Y (m)","showgrid":true},"zaxis":{"title":"Z (m)","showgrid":true},"aspectmode":"data"},"plot_bgcolor":"white","paper_bgcolor":"white","hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[766872.16224342724],"y":[29613843.160846852],"z":[2897636.317108294],"type":"scatter3d","mode":"markers","marker":{"color":"rgba(102,194,165,1)","size":6,"line":{"color":"rgba(102,194,165,1)"}},"hoverinfo":"text","text":"Body: Earth<br>Time: 30 days<br>x: 766900<br>y: 29610000<br>z: 2898000","name":"Earth","textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[322022438.66905677],"y":[240227059.70339015],"z":[23505583.141231954],"type":"scatter3d","mode":"markers","marker":{"color":"rgba(141,160,203,1)","size":6,"line":{"color":"rgba(141,160,203,1)"}},"hoverinfo":"text","text":"Body: Moon<br>Time: 30 days<br>x: 3.22e+08<br>y: 240200000<br>z: 23510000","name":"Moon","textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}# }
```
