//
//  Info.cpp
//  TetrisSolver
//
//  Created by shine on 7/2/21.
//

#include <vector>
#include <map>
#include <list>
#include "Bitmap.h"
#include "Instruction.h"
#include "Info.h"

using namespace std;

double d_prediction_size_avg = 0;
double d_solve_time_avg = 0;
double d_evaluater_time_avg = 0;

bool g_findTSpins = false;
bool g_4w = false;

Instruction::Instruction (int _x, int _r, int _spin) {
    x = _x;
    r = _r;
    spin = _spin;
}


Field::Field () {
    chart.resize(20);
    for (int y=0; y<20; y++) {
        chart[y].resize(10);
        for (int x=0; x<10; x++) {
            chart[y][x] = 0;
        }
    }
}
void Field::update (const vector<vector<int>>& _chart, int _combo, int _b2b ) {
    b2b = _b2b;
    combo = _combo;
    chart = _chart;
}


Future::Future () {}
Future::Future (const Field* field) {
    chart = field->chart;
    b2b = field->b2b;
    combo = field->combo;
}



TSpin::TSpin() {};
TSpin::TSpin(Pos& p, int t, int c) {
    pos = p;
    type = t;
    completeness = c;
    switch (type / 10) {
        case 2:
            map = TSpinDoubleMaps[type % 10];
            if (completeness == kTSDCompleteCondition)
                complete = true;
    }
};


int pieceInitialPos = 4;
char PieceNames[7] = {
    'J',
    'L',
    'S',
    'Z',
    'T',
    'I',
    'O'
};



Pos::Pos () {}
Pos::Pos (int _x, int _y) {
    x = _x;
    y = _y;
}

Piece::Piece () {}
Piece::Piece (PieceType _ID, int _x) {
    ID = _ID;
    x = _x;
    size = pieceMaps[int(ID)].size;
    map = (pieceMaps[int(ID)].maps);
    center = pieceMaps[int(ID)].center;
}
Piece::Piece (PieceType _ID, int _x, int _y, int _r) {
    ID = _ID;
    x = _x;
    y = _y;
    r = _r;
    size = pieceMaps[int(ID)].size;
    map = (pieceMaps[int(ID)].maps) + r*size*size;
    center = pieceMaps[int(ID)].center;
}
int Piece::set_int_rep () {
    if (x < 0 || y < 0 || x >= 10 || y >= 20)
        return -1;
    
    int_r = (int_r << 3) + int(ID);
    int_r = (int_r << 4) + x;
    int_r = (int_r << 5) + y;
    int_r = (int_r << 2) + r;
    
    return int_r;
}

bool operator< (const Piece& p1, const Piece& p2) {
    if (p1.ID != p2.ID) return p1.ID < p2.ID;
    if (p1.x != p2.x) return p1.x < p2.x;
    if (p1.y != p2.y) return p1.y < p2.y;
    if (p1.r != p2.r) return p1.r < p2.r;
    return false;
}

PieceMap::PieceMap (int c, int s, const int* maps_) {
    center = c;
    size = s;
    maps = maps_;
}

const int mapJ[] = {
    // origin
    1,0,0,
    1,1,1,
    0,0,0,

    // right
    0,1,1,
    0,1,0,
    0,1,0,

    // 2
    0,0,0,
    1,1,1,
    0,0,1,

    // left
    0,1,0,
    0,1,0,
    1,1,0
};
const int mapL[] = {
    // origin
    0,0,1,
    1,1,1,
    0,0,0,

    // right
    0,1,0,
    0,1,0,
    0,1,1,

    // 2
    0,0,0,
    1,1,1,
    1,0,0,

    // left
    1,1,0,
    0,1,0,
    0,1,0
};
const int mapS[] = {
    
    0,1,1,
    1,1,0,
    0,0,0,

    0,1,0,
    0,1,1,
    0,0,1,

    0,0,0,
    0,1,1,
    1,1,0,

    1,0,0,
    1,1,0,
    0,1,0
};
const int mapZ[] = {
    
    1,1,0,
    0,1,1,
    0,0,0,

    0,0,1,
    0,1,1,
    0,1,0,

    0,0,0,
    1,1,0,
    0,1,1,

    0,1,0,
    1,1,0,
    1,0,0
};
const int mapT[] = {

    0,1,0,
    1,1,1,
    0,0,0,

    0,1,0,
    0,1,1,
    0,1,0,
    
    0,0,0,
    1,1,1,
    0,1,0,

    0,1,0,
    1,1,0,
    0,1,0
};
const int mapI[] = {

    0,0,0,0,0,
    0,0,0,0,0,
    0,1,1,1,1,
    0,0,0,0,0,
    0,0,0,0,0,

    0,0,0,0,0,
    0,0,1,0,0,
    0,0,1,0,0,
    0,0,1,0,0,
    0,0,1,0,0,

    0,0,0,0,0,
    0,0,0,0,0,
    1,1,1,1,0,
    0,0,0,0,0,
    0,0,0,0,0,

    0,0,1,0,0,
    0,0,1,0,0,
    0,0,1,0,0,
    0,0,1,0,0,
    0,0,0,0,0,
};
const int mapO[] = {

    0,1,1,
    0,1,1,
    0,0,0,

    0,0,0,
    0,1,1,
    0,1,1,

    0,0,0,
    1,1,0,
    1,1,0,

    1,1,0,
    1,1,0,
    0,0,0
};

PieceMap pieceMaps[7] = {
    PieceMap( // J
        1,
        3,
        mapJ
    ),
    PieceMap( // L
        1,
        3,
        mapL
    ),
    PieceMap( // S
        1,
        3,
        mapS
    ),
    PieceMap( // Z
        1,
        3,
        mapZ
    ),
    
    PieceMap(   // T
        1,
        3,
        mapT
    ),
    PieceMap( // I
        2,
        5,
        mapI
    ),
    PieceMap( // O
        1,
        3,
        mapO
    )
};


const int* TSpinDoubleMaps[2] = {TSpinDoubleRMap, TSpinDoubleLMap};
const int kTSDCompleteCondition = 3;
const int TSpinDoubleLMap [9] = {
    1,0,0,
    0,0,0,
    1,0,1
};
const int TSpinDoubleRMap [9] {
    0,0,1,
    0,0,0,
    1,0,1
};
