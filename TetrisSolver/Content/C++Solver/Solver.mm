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
#include <set>
#include "Info.h"
#include "Instruction.h"
#include "Solver.h"
#include "T-Spin.h"

using namespace std;


void Solver::printChart (const vector<vector<int>>& chart) {
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

vector<vector<int>> Solver::addToChart (const vector<vector<int>>& ref, Piece* piece) {
    
    vector<vector<int>> chart = ref;
    for  (int y=0; y<piece->size; y++) {
        for (int x=0; x<piece->size; x++) {  // for all nodes
            int currX = piece->x - piece->center + x;
            int currY = piece->y - piece->center + y;
            
            if (piece->map[y*piece->size +x] == 1)
                chart[currY][currX] = 1;
        }
    }
    return chart;
}

bool Solver::isValid (const vector<vector<int>>& chart, Piece* piece, bool ignoreTop) {
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

void Solver::findDropLocation (const vector<vector<int>>& chart, Piece* piece) {
    do {
        piece->y ++;
    } while (isValid(chart, piece, true));
    piece->y --;
}

int Solver::clear (vector<vector<int>>& chart) {
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

bool Solver::_3CornerCheck(vector<vector<int>>& chart, Piece* piece) {
    
    int cnt = 0;
    if (piece->x > 0 && piece->y > 0) cnt += chart[piece->x -1][piece->y-1];
    if (piece->x > 0 && piece->y < 19) cnt += chart[piece->x -1][piece->y+1];
    if (piece->x < 9 && piece->y < 19) cnt += chart[piece->x +1][piece->y+1];
    if (piece->x < 9 && piece->y > 0) cnt += chart[piece->x +1][piece->y-1]; 

    return cnt >= 3;
}

Future Solver::ApplyPiece (const Field* field, Piece* piece, PieceType pieceID, int x, int base_r, int spin_r) {
      
    Future future = Future(field);
    *piece = Piece(pieceID, pieceInitialPos);
    Spin(&future, piece, base_r);
    piece->x += x - pieceInitialPos;
    
    findDropLocation(future.chart, piece);
    Spin(&future, piece, spin_r);
    findDropLocation(future.chart, piece);

    if (!isValid(future.chart, piece)) {
        future.impossible = true;
        return future;
    }
    
    vector<vector<int>> result = addToChart(future.chart, piece);
    future.clears = static_cast<ClearType>(clear(result));

    if (piece->ID == PieceType::T)
        if (piece->r == spin_r && spin_r != base_r) // if spun && sucessful
            if (_3CornerCheck(future.chart, piece)) // 3 corner rule
                future.clears = static_cast<ClearType>(int(ClearType::tspin1) + int(future.clears));
    
    
    future.chart = result;
    if (g_findTSpins) future.tspin = FindBestTsd(&future);

    if (future.clears != ClearType::None) future.combo ++;
    else future.combo = 0;
    
    if (int(future.clears) >= int(ClearType::clear4)) future.b2b ++;
    else {
        if (future.b2b != 0)
            future.b2bBreak = true;
        future.b2b = 0;
    }
    return future;
}

int Solver::GenerateFutures (vector<Future>& futures, const Field* field, PieceType pieceID, int startAt) {
    
    // NOTE:
    // piece.x != instruction.x
    // this is because a kick may change the piece's x position
    
    int i = startAt;
    set<int> pieceSet;
    
    for (int x=0; x<10; x++) {
        for (int r=0; r<4; r++) {
            Piece piece = Piece();
            Future future = ApplyPiece(field, &piece, pieceID, x, r, r);
            future.instruction = Instruction(x, r, r);
            
            if (!future.impossible && !pieceSet.count(piece.set_int_rep())) {
                futures[i++] = future;
                pieceSet.insert(piece.int_r);
            }
        }
        if (pieceID == PieceType::I) continue;
        
        for (int r=0; r<4; r++) {
            for (int s=0; s<4; s++) {
                if (s == r) continue;
            
                Piece piece = Piece();
                Future future = ApplyPiece(field, &piece, pieceID, x, r, s);
                future.instruction = Instruction(x, r, s);
                                
                if (!future.impossible && !pieceSet.count(piece.set_int_rep())) {
                    futures[i++] = future;
                    pieceSet.insert(piece.int_r);
                }
            }
        }
    }
    return i;
}

Future Solver::solve (const Field* field) {
    
    int size = 120;
    vector<Future> futures;
    futures.resize(2 * size);
    
    int end1 = GenerateFutures(futures, field, field->piece, 0);
    int end2 = GenerateFutures(futures, field, field->hold, end1);
    d_prediction_size_avg = (d_prediction_size_avg + end2) / 2.0;
    
    for (int i = end1; i < end2; i++)
        futures[i].instruction.hold = true;
    futures.resize(end2);

    for (int i=0; i < futures.size(); i++) {
        if (futures[i].impossible) continue;
        futures[i].score = Evaluate(&futures[i]);
    }
    
    
    int highestScore = 0;  // highest score
    int best = -1;    // index of best future 
    
    for (int i=0; i < futures.size(); i++) {
        if (futures[i].impossible) continue;
        if (futures[i].score > highestScore || best == -1) {
            highestScore = futures[i].score;
            best = i;
        }
    }
    
    if (best == -1)
        NSLog(@"Error, no valid solutions.");
    
    return futures[best];
}

Future Solver::Solve (const Field* field) {

    NSDate *start = [NSDate date];
    
    Future result = Future();

    result = solve(field);
        
    
    printChart(result.chart);
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@" ---- piece: %c, %c", PieceNames[int(field->piece)], PieceNames[int(field->hold)]);
    NSLog(@" ---- time consumed: %f", timeInterval);
    
    d_solve_time_avg = (d_solve_time_avg - timeInterval) / 2.0;
    
    return result;
}
