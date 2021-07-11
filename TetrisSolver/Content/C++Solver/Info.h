//
//  Info.h
//  TetrisSolver
//
//  Created by shine on 7/4/21.
//

#ifndef Info_h
#define Info_h
#include "Instruction.h"
#include "Bitmap.h"
#include <vector>
#include <list>

extern char PieceNames[7];

struct Instruction {
    Instruction (int _x, int _r);
    int x;
    int r;
    bool hold = false;
};

struct Future {
    Future ();
    Future (const std::vector<std::vector<int>>& c);
    std::vector<std::vector<int>> chart;
    Instruction instruction = Instruction(0,0);
    bool impossible = false;
    int score = 0;
    int clears = 0;
    int holes = 0;
    bool downstack = false;
    int holdPiece = -1;
    int penalties = 0;
};

struct Present {
    Present ();
    Present (const std::vector<std::vector<int>>& chart);
    bool critical = false;
    int maxH = -1;
};

struct Pos {
    Pos (int _x, int _y);
    int x;
    int y;
};

struct Piece {
    Piece (int _ID, int _x, int _r);
    int ID;
    int r;
    int x;
    int y;
    const int* map;
    int centerX;
    int centerY;
};

struct PieceMap {
    PieceMap (int cX, int cY, const int* maps);
    int centerX;
    int centerY;
    const int* maps;
};
extern int pieceInitialPos;
extern PieceMap pieceMaps[7];


#endif /* Info_h */
