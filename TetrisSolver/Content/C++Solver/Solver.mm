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
#include "T-Spin.h"

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

void predict (Future* list, const vector<vector<int>>& chart, int pieceID) {
    
    int size = 40;
    for (int i=0; i<size; i++) {
        list[i] = Future(chart);
        list[i].piece = pieceID;
    }
    
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
            if (g_findTSpins) list[i].tspin = FindBestTsd(&list[i]);
        }
    }
}

Future solve (const vector<vector<int>>& chart, int piece, int hold) {
    
    Future children[81];
    predict(children, chart, piece);
    predict(&children[40], chart, hold);
    for (int i=0; i<40; i++)  
        children[40+i].instruction.hold = true;
    
    

    // define children #81, the one that executes the tspin.
    {
        children[80] = Future(chart);
        children[80].tspin = FindBestTsd(&children[80]);

        
        if (g_findTSpins && (piece == 4 || hold == 4) && children[80].tspin.complete) {
            TSpin& tspin = children[80].tspin;
            Piece piece_o = Piece(piece, tspin.pos.x +1, tspin.pos.y+1, 2);
                
            addToChart(children[80].chart, piece_o);
            children[80].clears = clear(children[80].chart);
            children[80].instruction = Instruction(tspin.pos.x +1, 1+ (2* (tspin.type %10 == 0)), 2);
            if (hold == 4) children[80].instruction.hold = true; // if the T is the held piece
            children[80].executedTSpin = children[80].clears;
        
        } else
            children[80].impossible = true;
        
    }
    
    for (int i=0; i < 81; i++) {
        if (children[i].impossible) continue;
        children[i].score = Evaluate(&children[i]);
    }

    
    int highestScore = 0;  // highest score
    int best = -1;    // index of best future 
    
    for (int i=0; i < 81; i++) {
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

Future Solver (const vector<vector<int>>& chart, int piece, int hold) {

    NSDate *start = [NSDate date];
    
    Future result = solve(chart, piece, hold);
    
    printChart(result.chart);
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@" ---- piece: %c", PieceNames[piece]);//, PieceNames[pieces[1]]);
    NSLog(@" ---- time consumed: %f", timeInterval);

    return result;
}

Future Test_Solver (const vector<vector<int>>& chart, int piece, int hold) {
    
    Future result = solve(chart, piece, hold);
    
    return result;
}

vector<vector<int>> Test_Evaluator (const vector<vector<int>>& in_chart) {
    
    Future future = Future(in_chart);
    
    // 4 = hole, 2 = well, 3 = tspin (expected)
    vector<vector<int>>& chart = future.chart;

    TSpin tsd = FindBestTsd(&future);
    int wellDepth = 21;
    int wellPos = -1;
    int heights[10] = {0,0,0,0,0,0,0,0,0,0};
    
    // gets hieght and well pos (if well exists)
    for (int x=0; x<10; x++)
        for (int y=0; y<20; y++)
            if (chart[y][x]) {
                heights[x] = 20-y;
                break;
            }
    wellDepth = 21;
    wellPos = -1;
    for (int x=0; x<10; x++)
        if (wellDepth > heights[x]) {
            wellDepth = heights[x];
            wellPos = x;
        }
    chart[19 - wellDepth][wellPos] = 2;
    
    // checks for holes and covering cells
    for (int x=0; x<10; x++) {

        bool hole = false;
        for (int y=0; y<20; y++) {
            
            if (x >= tsd.pos.x && x < tsd.pos.x +3 && y == tsd.pos.y +1) continue;
            if (y > 0) {
                if (chart[y][x] == 0 && chart[y-1][x]) {
                    if (!hole) {    //if first hole of column, punishes for every filled cell ontop of it
                        hole = true;
                        chart[y][x] = 4;
                    }
                }
            }
        }
    }
    
    for (int y=0; y<3; y++)
        for (int x=0; x<3; x++)
            if (tsd.map[y*3 +x])
                chart[tsd.pos.y +y][tsd.pos.x +x] = 3;


    return future.chart;
}
