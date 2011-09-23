%module "Math::R"
%{
#include <Rmath.h>
%}

// Strangely enough, rnbeta(...) is declared but not implemented...
%ignore rnbeta;

// Rename normal distribution functions
%rename(pnorm) pnorm5;
%rename(qnorm) qnorm5;
%rename(dnorm) dnorm4;

// Include the <Rmath.h>
%include Rmath.h
