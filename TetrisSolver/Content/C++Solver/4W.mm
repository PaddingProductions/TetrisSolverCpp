//
//  C4W.m
//  ScreenReader
//
//  Created by shine on 8/4/21.
//

#import <Foundation/Foundation.h>
#include <vector>
#include <list>
#include <algorithm>
#include "Info.h"
#include "Instruction.h"
#include "Solver.h"


using namespace std;

void Solver::Find_4w(const int cP, const vector<int>* previews) {
    
    int pieces[6];
    pieces[0] = cP;
    for (int i=0; i<5; i++) pieces[i+1] = (*previews)[i];
    for (int i=0; i<6; i++) {
        switch (pieces[i]) {
            case 2: // s
                _4w_wellPos = 6;
                _4w_seedDirect = 0;
                return;
            case 3: // z
                _4w_wellPos = 0;
                _4w_seedDirect = 1;
                return;
            case 4: // t
                _4w_wellPos = 6;
                _4w_seedDirect = 0;
                return;
            case 5: // i
                _4w_wellPos = 6;
                _4w_seedDirect = 0;
                return;
            default:
                continue;
        }
    }
    if (_4w_wellPos == -1)
        _4w_building = false;
}

struct _4w_Weights {
    int height = -10;
    int bumpiness = -24;
    int bumpiness_sq = -7;
};

_4w_Weights _4w_weights = _4w_Weights();

int Solver::_4w_Evaluate (Future* future, const vector<int>& stack) {

    
    vector<vector<int>>& chart = future->chart;
    
    if (future->clears != 0) {
        future->impossible = true;
        return 0;
    }
    
    int maxHeight = -1;
    int heights[10] = {0,0,0,0,0,0,0,0,0,0}; // first contact with filled
    
    // gets hieght and well pos (if well exists)
    for (int x=0; x<10; x++) {
        for (int y=0; y<20; y++) {
            if (chart[y][x] == 1) {
                maxHeight = max(maxHeight, 20-y);
                heights[x] = 20-y;
                break;
            }
        }
    }
    for (int i=0; i<stack.size(); i++) {
        int x = stack[i];
        future->_4w_value = min(future->_4w_value, heights[x]);
    }
    
    for (int x=_4w_wellPos; x<_4w_wellPos+4; x++)
        if (heights[x] > 2) {
            future->impossible = true;
            return 0;
        }

    // checks for holes and covering cells
    for (int i=0; i<stack.size(); i++) {
        int x = stack[i];

        for (int y=0; y<20; y++) {
            if (y > 0) {
                if (chart[y][x] == 0 && chart[y-1][x] == 1) {
                    future->impossible = true;
                    return 0;
                }
            }
        }
    }
    
    int totalDifference = 0;
    int totalDifference_sq = 0;
    int prev = stack[0];
    
    for (int i=1; i<stack.size(); i++) {
        int x = stack[i];
        
        int diff = abs(heights[x] - heights[prev]);
        totalDifference += diff;
        totalDifference_sq += diff * diff;
        prev = x;
    }

    
    int score = 0;
    score += maxHeight * _4w_weights.height;
    score += totalDifference * _4w_weights.bumpiness;
    score += totalDifference_sq * _4w_weights.bumpiness_sq;

    return score;
}


Future Solver::Build_4w(const Field* field) {
    vector<int> stack; stack.resize(6);
    for (int i=0; i<6; i++) stack[i] = (_4w_wellPos + 4 + i) % 10;
    
    if (!_4w_seedPlaced) { // if seed not placed
        
        int seedPos = _4w_wellPos +(_4w_seedDirect * 3);
        if (field->piece == 2 || field->piece == 3 || field->piece == 4 || field->piece == 5) {
            Piece piece = Piece(field->piece, seedPos);
            Future future = Future(field);
            future.instruction = Instruction(seedPos, 0, 0);
            
            findDropLocation(future.chart, &piece);
            addToChart(future.chart, &piece);
        
            _4w_seedPlaced = true;
            return future;
        }
        if (field->hold == 2 || field->hold == 3 || field->hold == 4 || field->hold == 5) {
            Piece piece = Piece(field->hold, seedPos);
            Future future = Future(field);
            future.instruction = Instruction(seedPos, 0, 0);
            future.instruction.hold = true;
            
            findDropLocation(future.chart, &piece);
            addToChart(future.chart, &piece);
            
            _4w_seedPlaced = true;
            return future;
        }
        for (int i=0; i<6; i++) // remove seed ledge from stack
            if (stack[i] == _4w_wellPos - 1 + (_4w_seedDirect * 5)) // if seed column
                stack.erase(stack.begin() + i);
    }
    
        
    int size = 120;
    vector<Future> futures;
    futures.resize(2 * size);
    
    int end1 = GenerateFutures(futures, field, field->piece, 0);
    int end2 = GenerateFutures(futures, field, field->hold, end1);
    for (int i = end1; i < end2; i++)
        futures[i].instruction.hold = true;
    futures.resize(end2);

    for (int i=0; i < futures.size(); i++) {
        if (futures[i].impossible) continue;
        futures[i].score = _4w_Evaluate(&futures[i], stack);
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
    
    if (best == -1) return Solve_4w(field);
    if (futures[best]._4w_value >= 13) _4w_building = false;
    
    return futures[best];
}

Future Solver::Solve_4w(const Field* field) {
    
    int size = 120;
    vector<Future> futures;
    futures.resize(2 * size);
    
    int end1 = GenerateFutures(futures, field, field->piece, 0);
    int end2 = GenerateFutures(futures, field, field->hold, end1);
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
        if (futures[i].combo != _4w_prevCombo +1) {
            futures[i].impossible = 0;
            continue;
        }
        if (futures[i].score > highestScore || best == -1) {
            highestScore = futures[i].score;
            best = i;
        }
    }
    
    if (best == -1) {
        _4w_finished = true;
        return solve(field);
    }
    _4w_prevCombo++;
    return futures[best];
}
