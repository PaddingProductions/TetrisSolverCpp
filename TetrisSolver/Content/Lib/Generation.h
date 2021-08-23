//
//  Generation.h
//  TetrisSolver
//
//  Created by Shine Chang on 8/21/21.
//

#include "Info.h"

#ifndef Generation_h
#define Generation_h

void applySpin (Future* future, Placement* placement, int nR);
void applyPlacement (Future* future, Placement* placement);

int applyPiece (std::vector<Future>* futures, const Field* field, PieceType pieceID, int startIndex);

#endif /* Generation_h */
