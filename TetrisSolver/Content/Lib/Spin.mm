//
//  SRS.m
//  ScreenReader
//
//  Created by shine on 8/7/21.
//

#import <Foundation/Foundation.h>
#include "Mechanics.h"
#include <vector>

using namespace std;

// SRS kick table
Pos KickTable [7][4][5] = {
    { // J L S Z T
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos( 1, 0),
            Pos( 1,-1),
            Pos( 0, 2),
            Pos( 1, 2)
        },
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos(-1, 0),
            Pos(-1,-1),
            Pos( 0, 2),
            Pos(-1, 2)
        },
    },
    { // J L S Z T
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos( 1, 0),
            Pos( 1,-1),
            Pos( 0, 2),
            Pos( 1, 2)
        },
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos(-1, 0),
            Pos(-1,-1),
            Pos( 0, 2),
            Pos(-1, 2)
        },
    },
    { // J L S Z T
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos( 1, 0),
            Pos( 1,-1),
            Pos( 0, 2),
            Pos( 1, 2)
        },
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos(-1, 0),
            Pos(-1,-1),
            Pos( 0, 2),
            Pos(-1, 2)
        },
    },
    { // J L S Z T
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos( 1, 0),
            Pos( 1,-1),
            Pos( 0, 2),
            Pos( 1, 2)
        },
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos(-1, 0),
            Pos(-1,-1),
            Pos( 0, 2),
            Pos(-1, 2)
        },
    },
    { // J L S Z T
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos( 1, 0),
            Pos( 1,-1),
            Pos( 0, 2),
            Pos( 1, 2)
        },
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0, 0),
            Pos(-1, 0),
            Pos(-1,-1),
            Pos( 0, 2),
            Pos(-1, 2)
        },
    },
    { // I
        {
            Pos( 0, 0),
            Pos(-1, 0),
            Pos( 2, 0),
            Pos(-1, 0),
            Pos( 2, 0)
        },
        {
            Pos(-1, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 1),
            Pos( 0,-2)
        },
        {
            Pos(-1, 1),
            Pos( 1, 1),
            Pos(-2, 1),
            Pos( 1, 0),
            Pos(-2, 0),
        },
        {
            Pos( 0, 1),
            Pos( 0, 1),
            Pos( 0, 1),
            Pos( 0,-1),
            Pos( 0, 2),
        },
    },
    { // O
        {
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0),
            Pos( 0, 0)
        },
        {
            Pos( 0,-1),
            Pos( 0,-1),
            Pos( 0,-1),
            Pos( 0,-1),
            Pos( 0,-1)
        },
        {
            Pos(-1,-1),
            Pos(-1,-1),
            Pos(-1,-1),
            Pos(-1,-1),
            Pos(-1,-1)
        },
        {
            Pos(-1, 0),
            Pos(-1, 0),
            Pos(-1, 0),
            Pos(-1, 0),
            Pos(-1, 0)
        },
    },
};

void spin (const Future* future, Piece* piece, int nR) {
    
    // the kick table is generated under
    // the assumption that y axis grows upwards
    
    if (!isValid(future, piece, true)) return;
    if (piece->r == nR) return;
    if ((piece->r + 2) %4 == nR && piece->ID == PieceType::I) return;
    
    Pos* offset1 = KickTable[int(piece->ID)][piece->r];
    Pos* offset2 = KickTable[int(piece->ID)][nR];
    int pR = piece->r;
    
    Pos kickTests[5];
    
    for (int i=0; i<5; i++) {
        kickTests[i] = Pos(
            offset1[i].x - offset2[i].x,
            offset1[i].y - offset2[i].y
        );
    }

    for (int i=0; i<5; i++) {
        piece->r = nR;
        piece->map = &pieceMaps[int(piece->ID)].maps[nR * piece->size * piece->size];
        piece->x += kickTests[i].x;
        piece->y -= kickTests[i].y;
        
        if (isValid(future, piece, true)) break;
        
        piece->r = pR;
        piece->map = &pieceMaps[int(piece->ID)].maps[pR * piece->size * piece->size];
        piece->x -= kickTests[i].x;
        piece->y += kickTests[i].y;
    }
}

