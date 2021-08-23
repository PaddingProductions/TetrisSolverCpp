//
//  Info.h
//  TetrisSolver
//
//  Created by shine on 7/4/21.
//

#ifndef Info_h
#define Info_h

#include <vector>
#include <list>

#import "../Classes/Instruction.h"
#import "../Classes/Bitmap.h"

extern char PieceNames[7];

extern double d_prediction_size_avg;
extern double d_prediction_time_avg;
extern double d_solve_time_avg;
extern double d_evaluater_time_avg;

enum class ClearType : uint8_t {
    None = 0,
    clear1,
    clear2,
    clear3,
    clear4,
    tspin1,
    tspin2,
    tspin3
};

enum class PieceType : uint8_t {
    J,
    L,
    S,
    Z,
    T,
    I,
    O,
    None
};

struct Pos {
    Pos ();
    Pos (int _x, int _y);
    int x = 0;
    int y = 0;
};

struct Instruction {
    Instruction ();
    Instruction (int _x, int _r, int _spin);
    int x = -1;
    int r = -1;
    int spin = -1;
    bool hold = false;
};


struct Piece {
    Piece ();
    Piece (PieceType _ID, int _x, int _y = 0, int _r = 0);
    int set_int_rep ();
    
    PieceType ID = PieceType::T;
    int r = 0;
    int x = 0;
    int y = 0;
    const int* map = nullptr;
    int center = 0;
    int size = 0;
    int int_r = 0;
    friend bool operator < (const Piece& p1, const Piece& p2);
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
    PieceType piece = PieceType::None;
    PieceType hold = PieceType::None;
    int b2b = 0;
    int combo = 0;
};

struct Placement {
    Placement ();
    Placement (int x, int r, PieceType pieceID);
    
    Instruction instruct;
    Piece piece;
    bool valid = true;
};


struct Future {
    Future ();
    Future (const Field* field);
    Placement placement;
    std::vector<std::vector<int>> chart;
    bool impossible = false;
    ClearType clears = ClearType::None;
    int score = 0;
    int b2b;
    int combo;
    bool b2bBreak = false;
    
    int int_r;
    int set_int_r();
};
extern const Future c_emptyFuture;


struct PieceMap {
    PieceMap (int c, int s, const int* maps);
    int center;
    int size;
    const int* maps;
};
extern int pieceInitialPos;
extern PieceMap pieceMaps[7];

void ComputePlacements ();
extern std::vector<std::vector<Placement>> c_placementChart;

extern const int* TSpinDoubleMaps [2];
extern const int kTSDCompleteCondition;
extern const int TSpinDoubleLMap [9];
extern const int TSpinDoubleRMap [9];

// settings
extern bool g_findTSpins;
extern bool g_4w;

#endif /* Info_h */
