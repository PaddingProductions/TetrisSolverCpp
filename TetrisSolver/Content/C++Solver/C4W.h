//
//  C4W.h
//  TetrisSolver
//
//  Created by shine on 8/4/21.
//

#include "Info.h"
#include "Solver.h"
#ifndef C4W_h
#define C4W_h

class C4W_Executor : Solver {
    
    Future Execute (const Field* field);
};

#endif /* C4W_h */
