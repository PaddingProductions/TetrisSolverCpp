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
#import "Info.h"
#import "Instruction.h"
#import "Algorithm.h"

using namespace std;


Present present = Present();

void printChart (const vector<vector<int>>& chart) {
    for (int y=0; y<20; y++) {
        string str;
        for (int x=0; x<10; x++) {
            str += 48 + chart[y][x]; str += ' ';
        }
        NSLog(@"%s", str.c_str());
    }
}

int grader (Future& future) {
    vector<vector<int>>& chart = future.chart;
    int score = 100000;
    int heights[10];
    int avgH = 0;
    int maxH = -1;
    

    for (int x=0; x<10; x++) {
        int height = -1;
        for (int y=0; y<20; y++) {
            if (chart[y][x]) {
                height = max(height, 20 - y);
            }
            if (chart[y][x] == 0 && height != -1) { // if hole
                if (!future.downstack) // if you just switched from attacking to ds, increase penalty for hole
                    score -= 500;
                score -= 500;    // reduce score if hole
                future.holes += 1;
                
                int weight = 25 * max(0, 3 - abs( avgH - (20 - y) ));
                if (future.downstack) weight *= 2;
                score -= weight * (height - (20 - y)) * (height - (20 - y)); // reduce score for block ontop of hole
                future.penalties += (height - (20 - y));
                future.downstack = true;
            }
        }
        heights[x] = height;
        avgH += height;
        maxH = max (height, maxH);
    }
    avgH /= 10;

    // if in safe condition, try to do b2b tetris spam
    if (!future.downstack) {
        if (heights[0] != 0)
            future.impossible = true;
        if (future.clears == 4)
            score += 100;
        else if (future.clears > 0)
            score -= 40;
    } else {
        score += future.clears * 100;
        //score += (present.maxH - maxH) * 10;
    }
    
    
    int total = 0;
    int prevValue = heights[0];
    for (int x=0; x<10; x++) {
        int diff = heights[x] - prevValue;
        total += abs( diff ) * abs( diff );         // difference from previous
        prevValue = heights[x];
        
        score -= abs(heights[x] - avgH) * 5; // flat stack
    }
    score -= total * 5;
    
    
    return score;
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
            for (int i=y; i > 0; i--) {
                for (int k=0; k<10; k++) {
                    chart[i][k] = chart[i-1][k];
                }
            }
        }
    }
    return clears;
}

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

Future solve (const vector<vector<int>>& chart, const int* pieces, int hold, int index, int size) {
    
    Future children[80];
    predict(children, chart, pieces[index]);
    predict(&children[40], chart, hold);
    for (int i=0; i<40; i++)  {
        children[40+i].instruction.hold = true;
        children[40+i].holdPiece = pieces[index];
    }

    if (index != size - 1) {
        for (int i=0; i < 80; i++) {
            if (children[i].impossible) continue; // no need looking further for invalid solves
            if (i <= 40) hold = pieces[index];
            Future result = solve(children[i].chart, pieces, hold, index+1, size);
            children[i].score = result.score;
            children[i].holes = result.holes;
            children[i].downstack = result.downstack;
            children[i].impossible = result.impossible;
            children[i].clears = result.clears;
        }
    } else {
        for (int i=0; i < 80; i++) {
            if (children[i].impossible) continue;
            children[i].score = grader(children[i]);
        }
    }
    
    int highestScore = -1000000;  // highest score
    int best = -1;    // index of best future 
    
    for (int i=0; i < 80; i++) {
        if (children[i].impossible) continue;
        if (children[i].score > highestScore) {
            highestScore = children[i].score;
            best = i;
        }
    }
    if (best == -1) {
        NSLog(@"Error, no valid solutions.");
    }
    return children[best];
}

Future TetrisSolver (const vector<vector<int>>& chart, const int* pieces, int hold, int size) {
    
    present = Present(chart);
    NSDate *start = [NSDate date];
    NSLog(@"");
    printChart(chart);
    Future result = solve(chart, pieces, hold, false, size);
    NSLog(@" ");
    if (result.chart.size() != 0) printChart(result.chart);
    NSTimeInterval timeInterval = [start timeIntervalSinceNow];
    NSLog(@" ---- pieces: %c, %c", PieceNames[pieces[0]], PieceNames[pieces[1]]);
    NSLog(@" ---- time consumed: %f", timeInterval);
    NSLog(@" ---- results: holes: %d, clears: %d", result.holes, result.clears);
    NSLog(@" ---- penalties: %d", result.penalties);
    NSLog(result.downstack ? @" ---- downstack: true" : @" ---- downstack: false");

    return result;
}
