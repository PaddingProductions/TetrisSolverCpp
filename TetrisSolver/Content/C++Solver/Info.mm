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

bool g_findTSpins = false;


Instruction::Instruction (int _x, int _r, int _spin) {
    x = _x;
    r = _r;
    spin = _spin;
    if (spin == -1) spin = _r; 
}

Future::Future () {}
Future::Future (const std::vector<std::vector<int>>& c) {
    chart = c;
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

Pos::Pos (int _x, int _y) {
    x = _x;
    y = _y;
}

Piece::Piece (int _ID, int _x, int _r) {
    ID = _ID;
    r = _r;
    x = _x;
    y = 0;
    map = (pieceMaps[ID].maps) + _r*4*4;
    centerX = pieceMaps[ID].centerX;
    centerY = pieceMaps[ID].centerY;
}
Piece::Piece (int _ID, int _x, int _y, int _r) {
    ID = _ID;
    r = _r;
    x = _x;
    y = _y;
    map = (pieceMaps[ID].maps) + _r*4*4;
    centerX = pieceMaps[ID].centerX;
    centerY = pieceMaps[ID].centerY;
}

PieceMap::PieceMap (int cX, int cY, const int* maps_) {
    centerX = cX;
    centerY = cY;
    maps = maps_;
}

const int mapJ[] = {
    // origin
    1,0,0,0,
    1,1,1,0,
    0,0,0,0,
    0,0,0,0,

    // right
    0,1,1,0,
    0,1,0,0,
    0,1,0,0,
    0,0,0,0,

    // 2
    0,0,0,0,
    1,1,1,0,
    0,0,1,0,
    0,0,0,0,

    // left
    0,1,0,0,
    0,1,0,0,
    1,1,0,0,
    0,0,0,0,
};
const int mapL[] = {
    // origin
    0,0,1,0,
    1,1,1,0,
    0,0,0,0,
    0,0,0,0,

    // right
    0,1,0,0,
    0,1,0,0,
    0,1,1,0,
    0,0,0,0,

    // 2
    0,0,0,0,
    1,1,1,0,
    1,0,0,0,
    0,0,0,0,

    // left
    1,1,0,0,
    0,1,0,0,
    0,1,0,0,
    0,0,0,0,
};
const int mapS[] = {
    
    0,1,1,0,
    1,1,0,0,
    0,0,0,0,
    0,0,0,0,

    0,1,0,0,
    0,1,1,0,
    0,0,1,0,
    0,0,0,0,

    0,0,0,0,
    0,1,1,0,
    1,1,0,0,
    0,0,0,0,

    1,0,0,0,
    1,1,0,0,
    0,1,0,0,
    0,0,0,0
};
const int mapZ[] = {
    
    1,1,0,0,
    0,1,1,0,
    0,0,0,0,
    0,0,0,0,

    0,0,1,0,
    0,1,1,0,
    0,1,0,0,
    0,0,0,0,

    0,0,0,0,
    1,1,0,0,
    0,1,1,0,
    0,0,0,0,

    0,1,0,0,
    1,1,0,0,
    1,0,0,0,
    0,0,0,0
};
const int mapT[] = {

    0,1,0,0,
    1,1,1,0,
    0,0,0,0,
    0,0,0,0,

    0,1,0,0,
    0,1,1,0,
    0,1,0,0,
    0,0,0,0,

    0,0,0,0,
    1,1,1,0,
    0,1,0,0,
    0,0,0,0,

    0,1,0,0,
    1,1,0,0,
    0,1,0,0,
    0,0,0,0
};
const int mapI[] = {

    0,0,0,0,
    1,1,1,1,
    0,0,0,0,
    0,0,0,0,

    0,0,1,0,
    0,0,1,0,
    0,0,1,0,
    0,0,1,0,

    0,0,0,0,
    0,0,0,0,
    1,1,1,1,
    0,0,0,0,

    0,1,0,0,
    0,1,0,0,
    0,1,0,0,
    0,1,0,0
};
const int mapO[] = {

    0,1,1,0,
    0,1,1,0,
    0,0,0,0,
    0,0,0,0,

    0,0,0,0,
    0,1,1,0,
    0,1,1,0,
    0,0,0,0,

    0,0,0,0,
    1,1,0,0,
    1,1,0,0,
    0,0,0,0,

    1,1,0,0,
    1,1,0,0,
    0,0,0,0,
    0,0,0,0
};

PieceMap pieceMaps[7] = {
    PieceMap( // J
        1,
        1,
        mapJ
    ),
    PieceMap( // L
        1,
        1,
        mapL
    ),
    PieceMap( // S
        1,
        1,
        mapS
    ),
    PieceMap( // Z
        1,
        1,
        mapZ
    ),
    
    PieceMap(   // T
        1,
        1,
        mapT
    ),
    PieceMap( // I
        1,
        1,
        mapI
    ),
    PieceMap( // O
        1,
        1,
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
