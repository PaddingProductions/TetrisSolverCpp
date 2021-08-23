//
//  Algorithm.h
//  TetrisSolver
//
//  Created by shine on 7/4/21.
//


#ifndef Solver_h
#define Solver_h

#include <vector>

#include "../Lib/Library.h"

class Solver {
private:

    TSpin FindBestTsd (Future* future);
    int Evaluate (Future* future);
    
    Future solve (const Field* field);
public:
    Future Solve (const Field* field);
};

#endif /* Solver_h */
