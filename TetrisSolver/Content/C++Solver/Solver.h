//
//  Algorithm.h
//  TetrisSolver
//
//  Created by shine on 7/4/21.
//

#ifndef Solver_h
#define Solver_h
#include "Info.h"
#include <vector>

Future Solver (const std::vector<std::vector<int>>& chart, int piece, int holdPiece);
Future Test_Solver (const std::vector<std::vector<int>>& chart, int piece, int hold);
std::vector<std::vector<int>> Test_Evaluator (const std::vector<std::vector<int>>& chart);

#endif /* Solver_h */
