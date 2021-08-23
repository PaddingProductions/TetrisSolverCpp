//
//  Generation.m
//  ScreenReader
//
//  Created by Shine Chang on 8/21/21.
//

#import <Foundation/Foundation.h>
#include "Info.h"
#include "Mechanics.h"
#include "Generation.h"

#include <vector>
#include <set>

using namespace std;

void applySpin (Future* future, Placement* placement, int nR) {
    spin(future, &future->placement.piece, nR);
    findDropLocation(future, &future->placement.piece);
    if (!isValid(future, &placement->piece)) {future->impossible = true; return;}
    addToChart(future, &placement->piece);
    future->clears = clear(future);
}

void applyPlacement (Future* future, Placement* placement) {
    
    findDropLocation(future, &placement->piece);
    if (!isValid(future, &placement->piece)) {future->impossible = true; return;}
    addToChart(future, &placement->piece);
    future->clears = clear(future);
}

int applyPiece (vector<Future>* futures, const Field* field, PieceType pieceID, int startIndex) {

    int futures_i = startIndex;
    set<int> visited;
    int pID_int = int(pieceID);
    
    for (int i =0; i< c_placementChart[int(pieceID)].size(); i++) {
        
        Placement* base_placement;
        {
            Future* future = &(*futures)[futures_i];
            *future = Future(field);
            future->placement = c_placementChart[pID_int][i];
            
            applyPlacement(future, &future->placement);
            future->set_int_r();
            
            if (!visited.count(future->int_r) && !future->impossible)
                futures_i++;
            else
                visited.insert(future->int_r);
            base_placement = &future->placement;
        }
        {
            int nR = (base_placement->piece.r + 1) % 4;
            Future* future = &(*futures)[futures_i];
            *future = Future(field);
            future->placement = *base_placement;
            future->placement.instruct.spin = nR;

            applySpin(future, &future->placement, nR);
            future->set_int_r();
            
            if (!visited.count(future->int_r) && !future->impossible)
                futures_i++;
            else
                visited.insert(future->int_r);
        }
        {
            int nR = (base_placement->piece.r + 3) % 4;
            Future* future = &(*futures)[futures_i];
            *future = Future(field);
            future->placement = *base_placement;
            future->placement.instruct.spin = nR;
            
            applySpin(future, &future->placement, nR);
            future->set_int_r();
            
            if (!visited.count(future->int_r) && !future->impossible)
                futures_i++;
            else
                visited.insert(future->int_r);
        }
    }
    return futures_i;
}

