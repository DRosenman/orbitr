## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## CRAN NOTE: Possibly misspelled words

The flagged words are proper nouns used in academic references:

* **Verlet** — Loup Verlet, physicist who developed the Verlet integration
  algorithm. Verlet (1967) <doi:10.1103/PhysRev.159.98>.
* **Aarseth** — Sverre Aarseth, astrophysicist and author of
  *Gravitational N-Body Simulations*. Aarseth (2003, ISBN:0-521-43272-3).

## URL NOTE

The previous check flagged SSL errors for https://orbit-r.com/. This is the
package's pkgdown documentation site hosted on GitHub Pages with a custom
domain. The SSL certificate is valid and the site is accessible; the errors
appear to have been transient connectivity issues during the check.

## Previous submission

The previous submission (0.2.0) failed the Windows incoming check due to
compiled object files (.o, .dll) that were inadvertently included in the
source tarball. These have been removed and the package now builds cleanly
from source on all platforms.
