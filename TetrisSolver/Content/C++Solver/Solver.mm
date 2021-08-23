//
//  Algorithm.m
//  TetrisSolver
//
//  Created by shine on 7/4/21.
//

#import <Foundation/Foundation.h>
#include <vector>
#include <set>

#include "../Lib/Library.h"
#include "Instruction.h"
#include "Solver.h"

using namespace std;



Future Solver::solve (const Field* field) {
    
    int size = 120;
    vector<Future> futures;
    futures.resize(2 * size);

    NSDate *start = [NSDate date];
    int end1 = applyPiece(&futures, field, field->piece, 0);
    int end2 = applyPiece(&futures, field, field->hold, end1);
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];

    d_prediction_time_avg = (d_prediction_time_avg + timeInterval) / 2.0;
    d_prediction_size_avg = (d_prediction_size_avg + end2) / 2.0;
    
    for (int i = end1; i < end2; i++)
        futures[i].placement.instruct.hold = true;
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
    
    Future result = solve(field);
    
    printChart(result.chart);
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@" ---- piece: %c, %c", PieceNames[int(field->piece)], PieceNames[int(field->hold)]);
    NSLog(@" ---- time consumed: %f", timeInterval);
    
    d_solve_time_avg = (d_solve_time_avg - timeInterval) / 2.0;
    
    return result;
}
