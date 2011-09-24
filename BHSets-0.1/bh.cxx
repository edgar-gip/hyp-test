#include "bh.hxx"

#include <algorithm>
#include <cassert>
#include <cstdlib>
#include <iostream>
#include <iterator>

#include <tr1/unordered_set>

// Bergman-Hommel namespace
namespace bh {

  // Namespace imports
  using namespace std;
  using tr1::unordered_set;

  // Comparison set hash
  struct cs_hash {
    size_t
    operator()(const comp_set& _cs) const {
      size_t key = size_t();

      for (comp_set::const_iterator it = _cs.begin();
	   it != _cs.end(); ++it) {
	assert(it->second > it->first);

	size_t idx = it->first + it->second * (it->second - 1) / 2;
	key ^= (size_t(1) << (idx % (8 * sizeof(size_t))));
      }

      return key;
    }
  };

  // Lexicographical sort
  template <typename T>
  struct lexicographical {
    bool
    operator()(const T& _a, const T& _b) const {
      size_t sa = _a.size();
      size_t sb = _b.size();

      if (sa != sb) {
	return sa < sb;
      }
      else {
	return _a < _b;
      }
    }
  };

  // Hypothesis set
  typedef unordered_set<comp_set, cs_hash> hypothesis_set;

  // Callback
  struct callback {
    // Reference to set
    hypothesis_set& E_;

    // Constructor
    callback(hypothesis_set& _E) :
      E_(_E) {
    }

    // Call!
    void
    operator()(index_set& _c1, index_set& _c2);
  };

  // For each possible division
  static void
  divisions(const index_set& _cls, int _i,
	    index_set& _c1, index_set& _c2,
	    callback& _callback) {
    // Last one?
    if (_i == _cls.size() - 1) {
      // c1 is empty?
      if (_c1.empty())
	return;

      // Add it to c2
      _c2.push_back(_cls[_i]);

      // Call the callback
      _callback(_c1, _c2);

      // Pop
      _c2.pop_back();
    }
    else {
      // Add it to c1, and make the recursive call
      _c1.push_back(_cls[_i]);
      divisions(_cls, _i + 1, _c1, _c2, _callback);
      _c1.pop_back();

      // Add it to c2, and make the recursive call
      _c2.push_back(_cls[_i]);
      divisions(_cls, _i + 1, _c1, _c2, _callback);
      _c2.pop_back();
    }
  }

  // Bergmann-Hommel exhaustive sets (recursive function)
  static hypothesis_set
  exhaustiveSetsRec(const vector<index>& _cls) {
    // Result
    hypothesis_set E;

    // At least two classifiers?
    if (_cls.size() >= 2) {
      // Generate all pair-wise comparisons
      comp_set all;
      all.reserve(_cls.size() * (_cls.size() - 1) / 2);
      for (int i = 0; i < _cls.size(); ++i)
	for (int j = i + 1; j < _cls.size(); ++j)
	  all.push_back(comparison(_cls[i], _cls[j]));

      // Insert them
      E.insert(all);

      // For each possible division
      index_set c1, c2;
      callback cb(E);
      divisions(_cls, 0, c1, c2, cb);
    }

    // Return the total
    return E;
  }

  // Callback -> Call!
  void
  callback::operator()(index_set& _c1, index_set& _c2) {
    // Recursive call
    hypothesis_set E1 = exhaustiveSetsRec(_c1);
    hypothesis_set E2 = exhaustiveSetsRec(_c2);

    // Add
    E_.insert(E1.begin(), E1.end());
    E_.insert(E2.begin(), E2.end());

    // Append combinations
    for (hypothesis_set::const_iterator e1 = E1.begin();
	 e1 != E1.end(); ++e1) {
      for (hypothesis_set::const_iterator e2 = E2.begin();
	   e2 != E2.end(); ++e2) {
	comp_set comb(e1->size() + e2->size());
	copy(e1->begin(), e1->end(), comb.begin());
	copy(e2->begin(), e2->end(), comb.begin() + e1->size());

	E_.insert(comb);
      }
    }
  }

  // Bergmann-Hommel exhaustive sets
  hypothesis_list
  exhaustiveSets(int _k) {
    // Generate starting _cls
    index_set cls0(_k);
    for (int i = 0; i < _k; ++i) cls0[i] = i;

    // Call
    hypothesis_set E = exhaustiveSetsRec(cls0);

    // Sort
    hypothesis_list E_s(E.begin(), E.end());
    sort(E_s.begin(), E_s.end(), lexicographical<comp_set>());

    // Return
    return E_s;
  }
}

// Main
#ifdef MAIN
int main(int argc, const char* argv[]) {
  // Get arguments
  if (argc != 2) {
    std::cerr << "Usage: " << argv[0] << " <k>" << std::endl;
    return -1;
  }

  // Parse
  int k = std::atoi(argv[1]);

  // Call
  bh::hypothesis_list E = bh::exhaustiveSets(k);

  // Display
  for (bh::hypothesis_list::const_iterator it = E.begin();
       it != E.end(); ++it) {
    for (bh::comp_set::const_iterator cit = it->begin();
	 cit != it->end(); ++cit)
      std::cout << char('A' + cit->first) << '='
		<< char('A' + cit->second) << ' ';
    std::cout << std::endl;
  }

  // OK
  return 0;
}
#endif
