#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
List calc_acceleration_cpp(NumericVector x, NumericVector y, NumericVector z,
                           NumericVector mass, double G,
                           double softening = 0.0) {

  int n = x.size();
  NumericVector ax(n), ay(n), az(n);

  // If no gravity or only one body, return zeros
  if (G == 0 || n <= 1) {
    return List::create(Named("ax") = ax, Named("ay") = ay, Named("az") = az);
  }

  double eps2 = softening * softening;

  for (int j = 0; j < n; j++) {
    for (int k = 0; k < n; k++) {
      if (j != k) {

        // Distance components (direction from j toward k)
        double dx = x[k] - x[j];
        double dy = y[k] - y[j];
        double dz = z[k] - z[j];

        // Total distance with optional softening to prevent 1/r^2 singularity
        double r = sqrt(dx*dx + dy*dy + dz*dz + eps2);

        if (r > 0) {
          // Scalar acceleration: a = G * M_k / r^2
          double a = G * mass[k] / (r*r);

          // Decompose into directional components
          ax[j] += a * (dx / r);
          ay[j] += a * (dy / r);
          az[j] += a * (dz / r);
        }
      }
    }
  }

  return List::create(Named("ax") = ax, Named("ay") = ay, Named("az") = az);
}
