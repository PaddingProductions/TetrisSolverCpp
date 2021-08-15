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
    
    Future ApplyPiece(const Field* field, Piece* piece, int ID, int x, int base_r, int spin_r);
    int GenerateFutures (std::vector<Future>& futures, const Field* field, int pieceID, int startAt);
    
    Future solve (const Field* field);
    int Evaluate (Future* future);

    Future Build_4w (const Field* field);
    Future Solve_4w (const Field* field);
    int _4w_Evaluate (Future* future, const std::vector<int>& stack);
    
    
    int _4w_wellPos = -1;
    int _4w_seedDirect = -1;
    bool _4w_building = true;
    bool _4w_seedPlaced = false;
    bool _4w_finished = false;
    int _4w_prevCombo = 0;
public:
    void reset();
    
    Future Solve (const Field* field);

    void Find_4w (const int cP, const std::vector<int>* previews);
};

#endif /* Solver_h */
