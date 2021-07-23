//
//  Algorithm.m
//  TetrisSolver
//
//  Created by shine on 7/4/21.
//

#import <Foundation/Foundation.h>
#include <vector>
#include <list>
#include <algorithm>
#include <string>
#include "Info.h"
#include "Instruction.h"
#include "Solver.h"
#include "Evaluator.h"
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
        NSLog(@"%s", str.c_str());
    }
}

bool addToChart (vector<vector<int>>& chart, Piece& piece) {
    
    for  (int y=0; y<4; y++) {
        for (int x=0; x<4; x++) {  // for all nodes
            int currX = piece.x + x - piece.centerX;
            int currY = piece.y + y - piece.centerY;
            
            if (currX < 0 || currY < 0 || currX >= 10 || currY >= 20) {
                if (piece.map[y*4 +x] == 1)
                    return false;
                else
                    continue;
            }
            if (piece.map[y*4 +x] == 1)
                chart[currY][currX] = 1;
        }
    }
    return true;
}

bool checkOverlap (const vector<vector<int>>& chart, Piece& piece) {
    for  (int y=0; y<4; y++) {
        for  (int x=0; x<4; x++) {  // for all nodes
            
            if (piece.map[y*4 + x] == 0) continue; // no need to process empty nodes
        
            int currX = piece.x + x - piece.centerX;
            int currY = piece.y + y - piece.centerY;

            if (currY < 0)  continue;  // if out of bounds on top, which can be ignored
            if (currX < 0 || currX >= 10 || currY >= 20) return false;
            if (chart[currY][currX] == 1) return false;
        }
    }
    return true;
}

void findDropLocation (const vector<vector<int>>& chart, Piece& piece) {
    
    while (checkOverlap(chart, piece))
        piece.y ++;
    piece.y --;
}

int clear (vector<vector<int>>& chart) {
    int clears = 0;
    for (int y=0; y<20; y++){
        bool clear = true;
        for (int x=0; x<10; x++) {
            if (chart[y][x] == 0) {
                clear = false;
                break;
            }
        }
        if (clear) {
            clears++;
            for (int i=y; i > 0; i--)
                for (int k=0; k<10; k++)
                    chart[i][k] = chart[i-1][k];
        }
    }
    return clears;
}

int AssessTSpinPos (const vector<vector<int>>& chart, const int* map, int pX, int pY, int w, int h)  {
    int completeness = 0;
    for  (int y=0; y<h; y++) {
        for  (int x=0; x<w; x++) {  // for all nodes
            int cY = pY +y;
            int cX = pX +x;
            
            if (cY >= 20 || cX >= 10 || cY < 0 || cX < 0) return -1;
            
            if (map[y*w + x] == 1) {
                if (chart[cY][cX] == 1) completeness ++;
            } else {
                if (chart[cY][cX] == 1) return -1;
            }
        }
    }
    return completeness;
}

void FindBestTsd (Future* future) {
    
    TSpin best = TSpin();
    int bestScore = -2;
    
    for (int i=0; i<2; i++) {
        const int* map = TSpinDoubleMaps[i];
        for (int x=1; x<7; x++) { // other postions are impossible
            int y = 0;
            int score = 0;
            while (score != -1 && y < 20) {
                score = AssessTSpinPos(future->chart, map, x, y, 3, 3);
                
                if (score > bestScore ) {
                    bestScore = score;
                    Pos pos = Pos(x,y);
                    int type = 20 + i;
                    best = TSpin(pos, type);
                }
                y ++;
            }
        }
    }

    const int* map = best.map;
    for  (int y=0; y<3; y++) {
        for  (int x=0; x<3; x++) {  // for all nodes
            int cX = best.pos.x +x;
            int cY = best.pos.y +y;
            
            if (map[y*3 + x] == -1) future->desiredChart[cY][cX] = -1;
        }
    }
    
    for (auto it = best.wells.begin(); it != best.wells.end(); it++){
        for (int y=0; y<20; y++) {
            
        }
    }}

void predict (Future* list, const vector<vector<int>>& chart, int pieceID) {
    
    int size = 40;
    for (int i=0; i<size; i++) list[i] = Future(chart);
    
    for (int r=0; r<4; r++) {
        for (int x=0; x<10; x++) {
            int i = r * 10 + x;
            
            Piece piece = Piece(pieceID, x, r);
            findDropLocation(chart, piece);
            
            if (!addToChart(list[i].chart, piece)) {
                list[i].impossible = true;
                continue;
            }
            list[i].clears = clear(list[i].chart);
            list[i].instruction = Instruction(x,r);
        }
    }
}

Future solve (const vector<vector<int>>& chart, int piece, int hold) {
    
    Future children[80];
    predict(children, chart, piece);
    predict(&children[40], chart, hold);
    for (int i=0; i<40; i++)  {
        children[40+i].instruction.hold = true;
        children[40+i].holdPiece = piece;
    }

    for (int i=0; i < 80; i++) {
        if (children[i].impossible) continue;
        children[i].score = Evaluate(&children[i]);
    }

    
    int highestScore = 0;  // highest score
    int best = -1;    // index of best future 
    
    for (int i=0; i < 80; i++) {
        if (children[i].impossible) continue;
        if (children[i].score > highestScore || best == -1) {
            highestScore = children[i].score;
            best = i;
        }
    }
    if (best == -1)
        NSLog(@"Error, no valid solutions.");
    
    return children[best];
}

Future TetrisSolver (const vector<vector<int>>& chart, int piece, int hold) {

    NSDate *start = [NSDate date];
    
    //FindBestTsd(chart);
    Future result = solve(chart, piece, hold);
    
    printChart(result.chart);
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@" ---- piece: %c", PieceNames[piece]);//, PieceNames[pieces[1]]);
    NSLog(@" ---- time consumed: %f", timeInterval);

    return result;
}
