# Print an orbit_system

Displays a compact, human-readable summary of an \`orbit_system\`
showing the gravitational constant and a tibble of body states.

## Usage

``` r
# S3 method for class 'orbit_system'
print(x, ...)
```

## Arguments

- x:

  An \`orbit_system\` object.

- ...:

  Additional arguments (ignored).

## Value

\`x\`, invisibly.

## Examples

``` r
create_system() |>
  add_sun() |>
  add_planet("Earth", parent = "Sun") |>
  add_planet("Mars",  parent = "Sun")
#> ───────────────────────────────── orbit_system ───────────────────────────────── 
#> G: 6.6743e-11 (standard)
#> Bodies: 3
#> 
#> # A tibble: 3 × 8
#>   id       mass             x             y            z      vx     vy    vz
#>   <chr>   <dbl>         <dbl>         <dbl>        <dbl>   <dbl>  <dbl> <dbl>
#> 1 Sun   1.99e30            0             0            0       0      0     0 
#> 2 Earth 5.97e24 -32965585121. 143360295956.           0  -29520. -6788.    0 
#> 3 Mars  6.42e23 188789951360. -83706961610. -6395443036.  10750. 24226.  243.
```
