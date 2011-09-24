#ifndef BH_HXX
#define BH_HXX

#include <utility>
#include <vector>

#ifdef PERL
#include <perl.h>
#endif

// Bergman-Hommel namespace
namespace bh {

  // Index
  typedef char index;

  // Index set
  typedef std::vector<index> index_set;

  // Comparison
  typedef std::pair<index, index> comparison;

  // Comparison set
  typedef std::vector<comparison> comp_set;

  // Hypothesis list
  typedef std::vector<comp_set> hypothesis_list;

  // Bergmann-Hommel exhaustive sets
  hypothesis_list
  exhaustiveSets(int _k);
}

#endif
