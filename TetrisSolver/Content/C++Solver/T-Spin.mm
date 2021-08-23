//
//  T-Spin.m
//  ScreenReader
//
//  Created by shine on 7/30/21.
//
#include <vector>

#include "Solver.h"
#include "../Lib/Library.h"

using namespace std;

int AssessTsd (const vector<vector<int>>& chart, const int* map, int pX, int pY, int type)  {
    int completeness = 0;
    vector<bool> completed;
    
    for  (int y=0; y<3; y++) {
        for  (int x=0; x<3; x++) {  // for all nodes
            int cY = pY +y;
            int cX = pX +x;
            
            if (cY >= 20 || cX >= 10 || cY < 0 || cX < 0) return -1;
            
            if (map[y*3 + x] == 1) {
                completeness += chart[cY][cX];
                completed.push_back(chart[cY][cX]);
            } else {
                if (chart[cY][cX] == 1) return -1;
            }
        }
    }
    // must have two empty columns for the piecce to drop down into.
    
    if (type == 0) for (int y=0; y<pY; y++) if (chart[y][pX   ]) return -1;
                   for (int y=0; y<pY; y++) if (chart[y][pX +1]) return -1;
    if (type == 1) for (int y=0; y<pY; y++) if (chart[y][pX +2]) return -1;
    
    
    
    // to avoid impossible T-spins, i.e.
    // #
    // <><><>#
    // # <>  #
    // index [0] will always be the overhang because of scanning order.
    
    // if overhang but no corrisponding base
    if (completed[0] && !completed[1+ (type == 0)]) return -1;

    for (int i=0; i<2; i++) { // for each base
        if (!completed[1 +i]) { // if the base is not filled
            // make sure that there are no blocks existing that renders it impossible to
            // complete the base (tspin as a whole)
            // the restriction is as follows:
            // #     |X|
            // <><><>|X|
            // # <>  |X|
            
            for (int y=0; y<3; y++) {
                int cX = pX -1 + (i *4);
                int cY = pY + y;
                
                if (chart[cY][cX]) return -1;
            }
        }
    }
    
    return completeness;
}

TSpin Solver::FindBestTsd (Future* future) {
    
    TSpin best = TSpin();
    int bestScore = -2;
    
    for (int i=0; i<2; i++) {
        const int* map = TSpinDoubleMaps[i];
        for (int x=1; x<7; x++) { // other postions are impossible
            for (int y=0; y<20; y++) {
                int score = AssessTsd(future->chart, map, x, y, i);
                
                if (score > bestScore ) {
                    bestScore = score;
                    Pos pos = Pos(x,y);
                    int type = 20 + i;
                    best = TSpin(pos, type, score);
                }
            }
        }
    }
    
    // find filled rows
    for (int i=1; i<3; i++) {
        bool filled = true;
        for (int x=0; x<10; x++)
            if (x < best.pos.x || x >= best.pos.x +3)
                filled &= future->chart[best.pos.x +i][x] == 1;
        best.filledRows += filled;
    }
    
    return best;
}
