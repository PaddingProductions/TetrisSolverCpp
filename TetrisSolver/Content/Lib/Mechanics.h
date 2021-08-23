//
//  Mechanics.h
//  TetrisSolver
//
//  Created by Shine Chang on 8/20/21.
//

#include "Info.h"

#include <vector>
#ifndef Mechanics_h
#define Mechanics_h

void printChart (const std::vector<std::vector<int>>& chart);
void spin(const Future* future,  Piece* piece, int nR);

ClearType clear (Future* future);
bool isValid (const Future* future, const Piece* piece, bool ignoreTop = false);
void findDropLocation (Future* future, Piece* piece);
bool _3CornerCheck(const Future* future, const Piece* piece);
void addToChart (Future* future, const Piece* piece);

#endif /* Mechanics_h */
