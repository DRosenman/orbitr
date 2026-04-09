## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

- Windows 11 (local), R 4.x
- GitHub Actions: ubuntu-latest (R release), macOS-latest (R release), windows-latest (R release)

## Notes

This is the first submission of `orbitr` to CRAN.

The package includes compiled C++ code (via Rcpp) for the gravitational acceleration kernel. It compiles cleanly on all tested platforms and falls back gracefully to a pure-R implementation if the compiled code is unavailable.
