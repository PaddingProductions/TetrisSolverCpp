//
//  Algorithm.h
//  TetrisSolver
//
//  Created by shine on 7/4/21.
//

#ifndef Solver_h
#define Solver_h
#include "Info.h"
#include <vector>

class Solver {
private:
    void printChart (const std::vector<std::vector<int>>& chart);

    int clear (std::vector<std::vector<int>>& chart);
    std::vector<std::vector<int>> addToChart (const std::vector<std::vector<int>>& ref, Piece* piece);
    bool isValid (const std::vector<std::vector<int>>& chart, Piece* piece, bool ignoreTop = false);
    void findDropLocation (const std::vector<std::vector<int>>& chart, Piece* piece);
    void Spin(Future* future, Piece* piece, int nR, bool log = false);
    bool _3CornerCheck(std::vector<std::vector<int>>& chart, Piece* piece);
    
    Future ApplyPiece(const Field* field, Piece* piece, PieceType pieceID, int x, int base_r, int spin_r);
    int GenerateFutures (std::vector<Future>& futures, const Field* field, PieceType pieceID, int startAt);
    
    Future solve (const Field* field);
    int Evaluate (Future* future);
public:
    Future Solve (const Field* field);
};

#endif /* Solver_h */
