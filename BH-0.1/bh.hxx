#ifndef BH_HXX
#define BH_HXX

#include <list>
#include <vector>

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>


// Bar
struct bar {
  // First
  unsigned int first;

  // Second
  unsigned int second;

  // P-value
  double pvalue;

  // Constructor
  bar(unsigned int _first, unsigned _second, double _pvalue) :
    first(_first), second(_second), pvalue(_pvalue) {
  }
};


// Perform the bergmann-hommel test
std::list<bar> bergmannHommelOnline(unsigned int _k, AV* _inBars,
                                    double _alpha);

#endif
