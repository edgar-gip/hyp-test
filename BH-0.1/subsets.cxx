// hyp-test: Non-parametric hypothesis testing.
// Copyright (C) 2006-2012  Ignasi Abío i Roig <ignasi.abio@gmail.com>
//                          Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include "subsets.hxx"

// #include <cassert>
// #include <iostream>

#define I(x) (((x) * ((x)-1))/2)

using namespace std;

static void computeSetsRec (const vector<vector<double> >& probs, double alpha, vector<vector<bool> >& list, double currentProb, vector<vector<uint> >& currentSets, uint next);
static double computeProb (const vector<vector<double> >& probs, const vector<uint>& set);
static uint computeSize (const vector<vector<uint> >& sets,  uint remain);
static void addToList (vector<vector<bool> >&list, const vector<vector<uint> >& sets);

#ifdef MAIN
static void printSets(vector<vector<uint> >& currentSets);
#endif


void computeSets (const vector<vector<double> >& probs, double alpha, vector<vector<bool> >& list) {
  vector<vector<uint> > currentSets;
  computeSetsRec(probs, alpha, list, 1, currentSets, 0);
}

static double computeProb (const vector<vector<double> >& probs, const vector<uint>& set) {
  double ret = 1.;
  uint k = set.size()-1;
  for (uint i = 0; i < k; i++)
    if ( ret > probs[set[i]][set[k]] ) ret = probs[set[i]][set[k]];
  return ret;
}

static uint computeSize (const vector<vector<uint> >& sets, uint remain) {
  uint maximum = 0;
  uint count = 0;
  for (uint i = 0; i < sets.size(); i++) {
    if ( maximum < sets[i].size() ) maximum = sets[i].size();
    count += I(sets[i].size());
  }
  count += I(maximum+remain) - I(maximum);
  return count;
}

static void addToList (vector<vector<bool> >&list, const vector<vector<uint> >& sets) {
  for (uint k = 0; k < sets.size(); k++)
    for (uint i = 0; i < sets[k].size()-1; i++)
      for (uint j = i+1; j < sets[k].size(); j++) {
        uint ind1 = sets[k][i];
        uint ind2 = sets[k][j];
        list[ind1][ind2] = true;
        list[ind2][ind1] = true;
      }
}

static void computeSetsRec (const vector<vector<double> >& probs, double alpha, vector<vector<bool> >& list,  double currentProb, vector<vector<uint> >& currentSets, uint next) {
  uint remain = probs.size() + 1 - next;
  uint currentSize = computeSize(currentSets, remain);
    if ( currentProb * currentSize <= alpha ) return; // branch
  if ( remain == 0 ) {
    addToList(list, currentSets);
    return;
  }
  for (uint i = 0; i < currentSets.size(); i++) {
    currentSets[i].push_back(next);
    double nextProb = computeProb(probs, currentSets[i]);
    if ( nextProb > currentProb ) nextProb = currentProb;
    computeSetsRec(probs, alpha, list, nextProb, currentSets, next+1);
    currentSets[i].pop_back();
  }
  currentSets.push_back(vector<uint>(1, next));
  computeSetsRec(probs, alpha, list, currentProb, currentSets, next+1);
  currentSets.pop_back();
}

#ifdef MAIN
static void printSets(vector<vector<uint> >& sets) {
  cout << "(";
  for (uint i=0; i < sets.size(); i++) {
    cout << (i==0?" (":", (");
    for (uint j = 0; j < sets[i].size(); j++) cout << sets[i][j]<< " ";
    cout << ")";
  }
  cout << ")" << endl;
}

int main(void) {
  uint N = 5;
  vector<vector<double> > p(N, vector<double>(N, 1.));
  vector<vector<bool> > l(N, vector<bool>(N, false));

  p[0][1] = 0.0048;
  p[0][2] = 0.245;
  p[0][3] = 4.487e-8;
  p[0][4] = 0.0128;
  p[1][2] = 0.0101;
  p[1][3] = 0.008;
  p[1][4] = 0.744;
  p[2][3] = 1.736e-7;
  p[2][4] = 0.0247;
  p[3][4] = 0.0029;

  p[1][0] = p[0][1];
  p[2][0] = p[0][2];
  p[3][0] = p[0][3];
  p[4][0] = p[0][4];
  p[2][1] = p[1][2];
  p[3][1] = p[1][3];
  p[4][1] = p[1][4];
  p[3][2] = p[2][3];
  p[4][2] = p[2][4];
  p[4][3] = p[3][4];

  computeSets(p, 0.05, l);
  for(uint i = 0; i < N; i++)
    for(uint j = 0; j < N; j++)
      if(l[i][j]) cout << i << " " << j << endl;
  return 0;
}
#endif
