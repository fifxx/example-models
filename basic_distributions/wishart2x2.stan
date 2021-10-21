// Sample from 2 x 2 Wishart
// calculate matrix directly through non-matrix parameters

// This is only an example of how to compute transforms and Jacobians;
// the built-in types cov_matrix and corr_matrix (or their Cholesky
// factor versions) should be used for covariance and correlation
// matrices

// WARNING: This simple parameterization only works for 2 x 2 matrices
// because positive definiteness is simple.

transformed data {
  cov_matrix[2] S = [[2, 0], [0, 0.5]];
}
parameters {
  real x;
  real<lower=0> sd1;
  real<lower=0> sd2;
}
transformed parameters {
  real rho = tanh(x);
  real cov = rho * sd1 * sd2;
  matrix[2, 2] W = [[sd1 ^ 2, cov], [cov, sd2 ^ 2]];
}
model {
  // apply log Jacobian determinant of transform:
  // (sd1,sd2,x) -> (W[1,1],W[2,2],W[1,2])
  //     | d W[1,1] / d sd1   d W[1,1] / d sd2   d W[1,1] / d x |
  // J = | d W[2,2] / d sd1   d W[2,2] / d sd2   d W[2,2] / d x |
  //     | d W[1,2] / d sd1   d W[1,2] / d sd2   d W[1,2] / d x |
  //
  //     | 2 * sd1                     0                0                     |
  //   = | 0                         2 * sd2            0                     |
  //     | rho * sd2               rho * sd1        sd1 * sd2 * (1 - rho^2)   |
  
  target += 2 * (log2() + log(sd1) + log(sd2)) + log1m(rho ^ 2);
  
  W ~ wishart(4, S);
}
