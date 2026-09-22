# Extract the body table from a system

Returns the bodies in an \`orbit_system\` as a standalone tibble. Useful
when you want to inspect, filter, or save the body states without
dealing with the full system object.

## Usage

``` r
get_bodies(system)
```

## Arguments

- system:

  An \`orbit_system\` object.

## Value

A tibble with columns \`id\`, \`mass\`, \`x\`, \`y\`, \`z\`, \`vx\`,
\`vy\`, \`vz\`.

## Examples

``` r
sys <- create_system() |>
  add_sun() |>
  add_planet("Earth", parent = "Sun") |>
  add_planet("Mars",  parent = "Sun")

# Get the tibble
get_bodies(sys)
#> # A tibble: 3 × 8
#>   id       mass             x             y            z      vx     vy    vz
#>   <chr>   <dbl>         <dbl>         <dbl>        <dbl>   <dbl>  <dbl> <dbl>
#> 1 Sun   1.99e30            0             0            0       0      0     0 
#> 2 Earth 5.97e24 -32965585121. 143360295956.           0  -29520. -6788.    0 
#> 3 Mars  6.42e23 188789951360. -83706961610. -6395443036.  10750. 24226.  243.

# Use with dplyr
# \donttest{
get_bodies(sys) |>
  dplyr::filter(mass > 1e24)
#> # A tibble: 2 × 8
#>   id       mass             x             y     z      vx     vy    vz
#>   <chr>   <dbl>         <dbl>         <dbl> <dbl>   <dbl>  <dbl> <dbl>
#> 1 Sun   1.99e30            0             0      0      0      0      0
#> 2 Earth 5.97e24 -32965585121. 143360295956.     0 -29520. -6788.     0
# }
```
