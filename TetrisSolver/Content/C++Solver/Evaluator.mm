//
//  Evaluator.m
//  ScreenReader
//
//  Created by shine on 7/20/21.
//

#import <Foundation/Foundation.h>
#include "Evaluator.h"
#include <vector>

using namespace std;


struct Weights {
    int height = 10;
    int height_H2 = -50;
    int height_Q4 = -500;
    int holes = -400;
    int hole_depth = -25;
    int hole_depth_sq = 1;
    int clears[4] = {-120, -100, -50, 500};
    int bumpiness = -24;
    int bumpiness_sq = -7;
    int max_well_depth = 70;
    int well_depth = 20;
    int well_placement[10] = {3, -1, 1, 3, 1, 1, 3, 1, -1, 3};
    
};

Weights weights = Weights();

int Evaluate (Future* future) {
    

    vector<vector<int>>& chart = future->chart;
    
    int maxHeight = -1;
    int holes = 0;
    int heights[10] = {0,0,0,0,0,0,0,0,0,0};
    int wellValue = 0;
    int wellDepth = 21;
    int wellPos = -1;
    int cellsCoveringHoles = 0;
    int cellsCoveringHoles_sq = 0;
    
    // gets hieght and well pos (if well exists)
    for (int x=0; x<10; x++) {
        for (int y=0; y<20; y++) {
            if (chart[y][x] == 1) {
                maxHeight = max(maxHeight, 20-y);
                if (wellDepth > 20 - y) {
                    wellDepth = 20 - y;
                    wellPos = x;
                }
                heights[x] = 20-y;
                break;
            }
        }
    }
    // checks for holes and covering cells
    for (int x=0; x<10; x++) {
        bool hole = false;
        for (int y=0; y<20; y++) {
            if (y > 0) {
                if (chart[y][x] == 0 && chart[y-1][x] == 1) {
                    if (!hole) {    //if first hole of column, punishes for every filled cell ontop of it
                        hole = true;
                        int cells = min(5, heights[x] - (20-y));
                        cellsCoveringHoles += cells;
                        cellsCoveringHoles_sq = cells * cells;
                    }
                    holes++;
                }
            }
        }
    }
    // gets well value (how many lines it can clear)
    int secondDeepestPoint = 21;
    for (int x=0; x<10; x++)
        if (x != wellPos)
            secondDeepestPoint = min(secondDeepestPoint, heights[x]);
    wellValue = secondDeepestPoint - wellDepth;
    
    int totalDifference = 0;
    int totalDifference_sq = 0;
    int prev = 0;
    for (int x=1; x<10; x++) {
        if (x == wellPos) continue;
        
        int diff = abs(heights[x] - heights[prev]);
        totalDifference += diff;
        totalDifference_sq += diff * diff;
        prev = x;
    }

    
    int score = 0;
    score += maxHeight * weights.height;
    if (maxHeight >= 10) score += maxHeight * weights.height_H2;
    if (maxHeight >= 15) score += maxHeight * weights.height_Q4;
    score += holes * weights.holes;
    score += weights.clears[future->clears];
    score += totalDifference * weights.bumpiness;
    score += totalDifference_sq * weights.bumpiness_sq;
    score += wellValue * weights.well_depth * weights.well_placement[wellPos];
    if (wellDepth == 0) score += wellValue * weights.max_well_depth * weights.well_placement[wellPos];
    score += cellsCoveringHoles * weights.hole_depth;
    score += cellsCoveringHoles_sq * weights.hole_depth_sq;
    
    return score;
}


