//
//  Moves.m
//  TetrisSolver
//
//  Created by Shine Chang on 8/20/21.
//

#include "Info.h"
#include "Mechanics.h"

#include <vector>
#include <list>
#include <set>

using namespace std;

Placement::Placement () {}
Placement::Placement (int x, int r, PieceType pieceID) {
    piece = Piece(pieceID, pieceInitialPos);
    spin(&c_emptyFuture, &piece, r);
    piece.x += x - pieceInitialPos;
    instruct = Instruction(x, r, r);

    valid = isValid(&c_emptyFuture, &piece, true); // ---
    
}

vector<vector<Placement>> c_placementChart;
void ComputePlacements () {
    c_placementChart.resize(7);
    
    for (int i=0; i<5; i++) {
        
        PieceType cP = static_cast<PieceType>(i);
        
        for (int x=0; x<10; x++) {
            for (int r=0; r<4; r++) {
                Placement placement = Placement(x, r, cP);
                if (!placement.valid) continue;
                
                c_placementChart[i].push_back(placement);
            }
        }
    }
    // I piece
    for (int x=0; x<10; x++) {
        for (int r=0; r<2; r++) {
            Placement placement = Placement(x, r, PieceType::I);
            if (!placement.valid) continue;
            
            c_placementChart[5].push_back(placement);
        }
    }

    // O piece
    c_placementChart[6].push_back(Placement(0,0, PieceType::O));
    c_placementChart[6].push_back(Placement(1,0, PieceType::O));
    c_placementChart[6].push_back(Placement(2,0, PieceType::O));
    c_placementChart[6].push_back(Placement(3,0, PieceType::O));
    c_placementChart[6].push_back(Placement(4,0, PieceType::O));
    c_placementChart[6].push_back(Placement(5,0, PieceType::O));
    c_placementChart[6].push_back(Placement(6,0, PieceType::O));
    c_placementChart[6].push_back(Placement(7,0, PieceType::O));
    c_placementChart[6].push_back(Placement(8,0, PieceType::O));
}
