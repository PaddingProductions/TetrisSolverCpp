//
//  SRS.m
//  ScreenReader
//
//  Created by shine on 8/7/21.
//

#import <Foundation/Foundation.h>
#include "Solver.h"
#include "Info.h"
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

void Solver::Spin (Future* future, Piece* piece, int nR, bool log) {
    
    if (!isValid(future->chart, piece, true)) return;
    if (piece->r == nR) return;
    if ((piece->r + 2) %4 == nR) return;
    
    Pos* offset1 = KickTable[piece->ID][piece->r];
    Pos* offset2 = KickTable[piece->ID][nR];

    Pos kickTests[5];
    
    for (int i=0; i<5; i++) {
        kickTests[i] = Pos(
            offset1[i].x - offset2[i].x,
            offset1[i].y - offset2[i].y
        );
    }

    for (int i=0; i<5; i++) {
        Piece testPiece = Piece(piece->ID, piece->x + kickTests[i].x, piece->y - kickTests[i].y, nR);
        
        if (isValid(future->chart, &testPiece, true)) {

            if (log) {
                NSLog(@"Before: x: %d, r: %d", piece->x, piece->r);
                printChart(future->chart);
            }
            
            piece->r = nR;
            piece->map = &pieceMaps[piece->ID].maps[nR * piece->size * piece->size];
            piece->x += kickTests[i].x;
            piece->y -= kickTests[i].y; // the kick table is generated under the assumption that y axis grows upwards
            
            if (log) {
                Future nf = *future;
                findDropLocation(nf.chart, piece);
                addToChart(nf.chart, piece);
                clear(nf.chart);
                NSLog(@"After: nR: %d, kick x: %d, kick y: %d", nR, kickTests[i].x, kickTests[i].y);
                printChart(nf.chart);
            }
            break;
        }
    }
}

