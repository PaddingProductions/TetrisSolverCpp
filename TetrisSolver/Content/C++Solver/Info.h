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

struct Pos {
    Pos (int _x, int _y);
    int x;
    int y;
};

struct Instruction {
    Instruction (int _x, int _r, int _spin = -1);
    int x;
    int r;
    int spin = 0;
    bool hold = false;
};

struct TSpin {
    TSpin();
    TSpin(Pos& pos, int type, int completeness);
    Pos pos = Pos(0,0);
    int type;
    int filledRows = 0;
    int completeness = 0;
    bool complete = false;
    const int* map;
};

struct Future {
    Future ();
    Future (const std::vector<std::vector<int>>& chart);
    std::vector<std::vector<int>> chart;
    Instruction instruction = Instruction(0,0);
    bool impossible = false;
    int clears = 0;
    int score = 0;
    int executedTSpin = -1;
    int piece = -1;
    TSpin tspin = TSpin();
};


struct Piece {
    Piece (int _ID, int _x, int _r);
    Piece (int _ID, int _x, int _y, int _r);
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


extern const int* TSpinDoubleMaps [2];
extern const int kTSDCompleteCondition;
extern const int TSpinDoubleLMap [9];
extern const int TSpinDoubleRMap [9];

// settings
extern bool g_findTSpins;

#endif /* Info_h */
