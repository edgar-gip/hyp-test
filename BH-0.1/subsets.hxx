#ifndef SUBSETS_HXX
#define SUBSETS_HXX

#include <vector>

typedef unsigned int uint;

void computeSets (const std::vector<std::vector<double> >& probs,
                  double alpha,
                  std::vector<std::vector<bool> >& list);

#endif
