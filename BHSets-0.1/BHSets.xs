#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <map>

#include <bh.hxx>

MODULE = BHSets		PACKAGE = BHSets

void
exhaustiveSets(_k)
    int _k
  PROTOTYPE: $
  PPCODE:
    // Call function
    bh::hypothesis_list E = bh::exhaustiveSets(_k);

    // Comparisons
    std::map<bh::comparison, SV*> comparison_sv;

    // Reserve space in the stack
    EXTEND(SP, E.size());

    // For each one
    for (bh::hypothesis_list::const_iterator e = E.begin();
         e != E.end(); ++e) {
      // Create an AV
      AV* cs = newAV();
      av_extend(cs, e->size());

      // For each element
      for (I32 i = 0; i < e->size(); ++i) {
	// Is the pair already there?
	std::map<bh::comparison, SV*>::iterator it =
	  comparison_sv.find((*e)[i]);
	if (it == comparison_sv.end()) {
	  // Create it
	  SV* csv =
	    sv_2mortal(newSVpvf("%d,%d", (*e)[i].first, (*e)[i].second));

	  // Insert it
	  it = comparison_sv.insert(std::make_pair((*e)[i], csv)).first;
	}

	// Point to it
	av_store(cs, i, SvREFCNT_inc(it->second));
      }

      // Push it
      PUSHs(sv_2mortal(newRV_noinc(reinterpret_cast<SV*>(cs))));
    }
