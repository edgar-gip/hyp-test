#include "bh.hxx"

#include <vector>

#include "subsets.hxx"


using namespace std;

// Perform the bergmann-hommel test
list<bar> bergmannHommelOnline(uint _k, AV* _inBars, double _alpha) {
  // P-value matrix
  vector< vector<double> > pValues(_k, vector<double>(_k, 0.0));

  // Fill it
  for (I32 i = 0; i <= av_len(_inBars); ++i) {
    // Fetch
    SV** ptr = av_fetch(_inBars, i, 0);

    /* Is it a reference? */
    if (not SvROK(*ptr))
      croak("_inBars[%d] does not contain a reference", i);
    SV* tgt = SvRV(*ptr);

    /* Is it an AV? */
    if (SvTYPE(tgt) != SVt_PVAV)
      croak("_inBars[%d] is not a reference to an array", i);
    AV* tgt_av = reinterpret_cast<AV*>(tgt);

    /* Does it have three elements? */
    if (av_len(tgt_av) != 2)
      croak("_inBars[%d] does not contain three elements", i);

    /* Get'em */
    UV 	   first  = SvUV(*(av_fetch(tgt_av, 0, 0)));
    UV 	   second = SvUV(*(av_fetch(tgt_av, 1, 0)));
    double pValue = SvNV(*(av_fetch(tgt_av, 2, 0)));

    /* Sanity */
    if (first < 0 or first >= _k)
      croak("_inBars[%d][0] = %u is not between 0 and %u", i, first, _k);
    if (second < 0 or second >= _k)
      croak("_inBars[%d][1] = %u is not between 0 and %u", i, second, _k);
    if (pValue < 0.0 or pValue > 1.0)
      croak("_inBars[%d][2] = %g is not between 0.0 and 1.0", i, pValue);
    if (first == second and pValue != 1.0)
      croak("_inBars[%d] corresponds to a diagonal entry, but is not 1.0", i);

    /* Set */
    pValues[first][second] = pValues[second][first] = pValue;
  }

  // Diagonal
  /* Ensure it is 1.0 */
  for (uint i = 0; i < _k; ++i)
    pValues[i][i] = 1.0;

  // Equivalence matrix
  vector< vector<bool> > equivalent(_k, vector<bool>(_k, false));

  // Call
  computeSets(pValues, _alpha, equivalent);

  // Results
  list<bar> results;
  for (uint i = 0; i < _k - 1; ++i)
    for (uint j = i + 1; j < _k; ++j)
      if (equivalent[i][j])
	results.push_back(bar(i, j, pValues[i][j]));

  // Return
  return results;
}
