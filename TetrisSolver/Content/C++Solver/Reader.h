//
//  Reader.h
//  TetrisSolver
//
//  Created by shine on 7/4/21.
//

#ifndef Reader_h
#define Reader_h

#include "Bitmap.h"
#include "Info.h"


extern int blockSize;

Pos TetrisGetTopCorner (ObjC_Bitmap* bitmap);
Pos TetrisGetBottomCorner (ObjC_Bitmap* bitmap, Pos& tC);
Pos TetrisGetHoldCorner (ObjC_Bitmap* bitmap, Pos& tC);
Pos TetrisGetPreviewCorner (ObjC_Bitmap* bitmap, Pos& tC);

int TetrisGetPiece (ObjC_Bitmap* bitmap, Pos& refC);
int getCurrentPiece(ObjC_Bitmap* bitmap, Pos& tC);

int checkIfFilled (ObjC_Bitmap* bitmap, Pos& tC, int x, int y, int cP);
void initialize_ColorToPiece();

#endif /* Reader_h */
