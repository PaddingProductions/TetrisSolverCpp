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

extern long long d_sizeSum;
extern long long d_solveCallCnt;
extern double d_timeSum;
extern long long d_timeCallCnt;
extern double d_evaluater_time_avg;

struct Pos {
    Pos ();
    Pos (int _x, int _y);
    int x = 0;
    int y = 0;
};

struct Instruction {
    Instruction (int _x, int _r, int _spin);
    int x;
    int r;
    int spin;
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

struct Field {
    Field ();
    void update (const std::vector<std::vector<int>>& _chart, int _combo, int _b2b );
    std::vector<std::vector<int>> chart;
    bool impossible = false;
    int piece = -1;
    int hold = -1;
    int b2b = 0;
    int combo = 0;
    TSpin tspin = TSpin();
};


struct Future {
    Future ();
    Future (const Field* field);
    std::vector<std::vector<int>> chart;
    Instruction instruction = Instruction(0,0,0);
    bool impossible = false;
    int clears = 0;
    int score = 0;
    int executedTSpin = -1;
    int piece = -1;
    int b2b;
    int combo;
    bool b2bBreak = false;
    int _4w_value = 22;
    TSpin tspin = TSpin();
};



struct Piece {
    Piece ();
    Piece (int _ID, int _x);
    Piece (int _ID, int _x, int _y, int _r);
    int ID = -1;
    int r = 0;
    int x = 0;
    int y = 0;
    const int* map = nullptr;
    int center = 0;
    int size = 0;
};

struct PieceMap {
    PieceMap (int c, int s, const int* maps);
    int center;
    int size;
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
extern bool g_4w;

#endif /* Info_h */
