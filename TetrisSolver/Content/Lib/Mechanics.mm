//
//  Mechanics.m
//  ScreenReader
//
//  Created by Shine Chang on 8/20/21.
//

#include "Mechanics.h"
#include "Info.h"

#include <vector>
#include <set>
#include <list>
#include <string>

using namespace std;

void printChart (const vector<vector<int>>& chart) {
    for (int y=0; y<20; y++) {
        string str;
        for (int x=0; x<10; x++) {
            if (chart[y][x] == 1)
                str += "* ";
            else
                str += ". ";
        }
        NSLog(@"%@", @(str.c_str()));
    }
}



void addToChart (Future* future, const Piece* piece) {
    for  (int y=0; y<piece->size; y++) {
        for (int x=0; x<piece->size; x++) {  // for all nodes
            int currX = piece->x - piece->center + x;
            int currY = piece->y - piece->center + y;
            
            if (piece->map[y*piece->size +x] == 1)
                future->chart[currY][currX] = 1;
        }
    }
}

bool _3CornerCheck(const Future* future) {
    
    const Piece* piece = &future->placement.piece;
    const vector<vector<int>>& chart = future->chart;
    
    int cnt = 0;
    if (piece->x > 0 && piece->y > 0) cnt += chart[piece->x -1][piece->y-1];
    if (piece->x > 0 && piece->y < 19) cnt += chart[piece->x -1][piece->y+1];
    if (piece->x < 9 && piece->y < 19) cnt += chart[piece->x +1][piece->y+1];
    if (piece->x < 9 && piece->y > 0) cnt += chart[piece->x +1][piece->y-1];

    return cnt >= 3;
}

bool isValid (const Future* future, const Piece* piece, bool ignoreTop) {
    
    const vector<vector<int>>& chart = future->chart;
    
    for  (int y=0; y<piece->size; y++) {
        for (int x=0; x<piece->size; x++) {
            
            if (piece->map[y*piece->size + x] == 0) continue; // no need to process empty nodes
        
            int currX = piece->x - piece->center + x;
            int currY = piece->y - piece->center + y;

            if (currX < 0 || currX >= 10 || currY >= 20) return false;
            if (currY < 0) { if (ignoreTop) { continue; } else {return false;} }
            if (chart[currY][currX] == 1) return false;
        }
    }
    return true;
}

void findDropLocation (Future* future, Piece* piece) {
    do {
        piece->y ++;
    } while (isValid(future, piece, true));
    piece->y --;
}

ClearType clear (Future* future) {
    int clears = 0;
    for (int y=0; y<20; y++){
        bool clear = true;
        for (int x=0; x<10; x++) {
            if (future->chart[y][x] == 0) {
                clear = false;
                break;
            }
        }
        if (clear) {
            clears++;
            for (int i=y; i > 0; i--)
                for (int k=0; k<10; k++)
                    future->chart[i][k] = future->chart[i-1][k];
        }
    }
    ClearType clearType = static_cast<ClearType>(clears);
    
    if (future->placement.piece.ID == PieceType::T)
        if (future->placement.instruct.spin != future->placement.instruct.r) // if spun
            if (_3CornerCheck(future)) // 3 corner rule
                clearType = static_cast<ClearType>(
                                                   int(ClearType::tspin1) +
                                                   int(clearType)
                                                  );
    return clearType;
}


