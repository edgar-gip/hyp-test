#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <bh.hxx>

MODULE = BH		PACKAGE = BH

AV*
bergmannHommelOnline(_k, _inBars, _alpha)
    unsigned int _k
    AV* _inBars
    double _alpha
  PROTOTYPE: $\@$
  PREINIT:
    std::list<bar> outBars;
  PPCODE:
    // Call function
    outBars = bergmannHommelOnline(_k, _inBars, _alpha);

    // Reserve space in the stack
    EXTEND(SP, outBars.size());

    // For each one
    for (std::list<bar>::const_iterator it = outBars.begin();
         it != outBars.end(); ++it) {
      // Create an AV
      AV* cs = newAV();
      av_extend(cs, 3);

      // Insert them
      av_store(cs, 0, newSVuv(it->first));
      av_store(cs, 1, newSVuv(it->second));
      av_store(cs, 2, newSVnv(it->pvalue));

      // Push it
      PUSHs(sv_2mortal(newRV_noinc(reinterpret_cast<SV*>(cs))));
    }
