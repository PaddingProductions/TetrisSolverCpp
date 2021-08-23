//
//  Moves.m
//  TetrisSolver
//
//  Created by Shine Chang on 8/20/21.
//

#include "Moves.h"
#include "Mechanics.h"

#include <vector>
#include <set>

using namespace std;

Placement::Placement () {};
Placement::Placement (int x, int r, PieceType pieceID) {
    instruc.x = x;
    instruc.r = r;
    
    piece = Piece(pieceID, pieceInitialPos, 0, 0);
    Future tF = Future();
    Spin(&tF, &piece, r);
    
    piece.x += x - pieceInitialPos;
    valid = isValid(tF.chart, &piece, true);
}
void Placement::ApplySpin (Future* future, int nR) {
    
    Spin(&future, &piece, nR);
    findDropLocation(future->chart, &piece);
    
    vector<vector<int>> result = addToChart(future->chart, &piece);
    future->clears = static_cast<ClearType>(clear(result));
}

vector<vector<Placement>> placements;

void ComputePlacements () {
    placements.resize(7);
    
    for (int p = 0; p < 7; p++) {
        placements[p].resize(120);
        set<int> visited;
        
        int i = 0;
        for (int x=0; x<10; x++) {
            for (int r=0; r<4; r++) {
                Placement placement = Placement(x, r, static_cast<PieceType>(p));
                
                if (visited.count(placement.piece.set_int_rep())) {
                    placements[p][i++] = placement;
                    visited.insert(placement.piece.int_r);
                }
            }
        }
        placements[p].resize(i);
    }
}


Future ApplyPiece (const Field* field, Placement ) {
      

}


int GenerateFutures (vector<Future>& futures, const Field* field, int pieceID, int startAt) {
    
    // NOTE:
    // piece.x != instruction.x
    // this is because a kick may change the piece's x position
    
    int i = startAt;
    set<int> visited;
    
    for (int p = 0; p < placements[static_cast<int>(pieceID)].size(); p++) {
        
        Future future = Future(field);
        Placement placement = placements[static_cast<int>(pieceID)][p];
        placement.ApplyTo(future);
        
        if (placement.piece.ID == PieceType::T)
            if (placement.piece.r == nR) // if spun && sucessful
                if (_3CornerCheck(future->chart, &placement.piece)) // 3 corner rule
                    future.clears = static_cast<ClearType>(
                                                           int(ClearType::tspin1) +
                                                           int(future.clears)
                                                           );
        future->chart = result;

        
        if (future->clears != ClearType::None) future->combo ++;
        else future->combo = 0;
        
        if (int(future.clears) >= int(ClearType::clear4)) future->b2b ++;
        else {
            if (future.b2b != 0)
                future.b2bBreak = true;
            future.b2b = 0;
        }
        return future;
    }
    return i;
}
