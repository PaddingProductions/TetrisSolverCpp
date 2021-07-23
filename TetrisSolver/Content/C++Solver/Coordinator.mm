#import <Foundation/Foundation.h>
#include <vector>
#include <list>
#include <map>
#include <algorithm>
#include "Coordinator.h"
#include "Bitmap.h"
#include "Instruction.h"
#include "Info.h"
#include "Reader.h"
#include "Solver.h"

using namespace std;

struct TetrisCoordinator {
    
    TetrisCoordinator (ObjC_Bitmap* bitmap, Pos wP)
        : m_topCorner(TetrisGetTopCorner(bitmap))
        , m_bottomCorner(TetrisGetBottomCorner(bitmap, m_topCorner))
        , m_previewCorner(TetrisGetPreviewCorner(bitmap, m_topCorner))
        , m_windowPos(wP) {
        
        vector<vector<int>> chart;
        chart.resize(20);
        for (int y=0; y<20; y++) {
            chart[y].resize(10);
            for (int x=0; x<10; x++) {
                chart[y][x] = 0;
            }
        }
        if (m_topCorner.x > 500 || m_topCorner.y > 500) {
            NSLog(@"Corner Read Error, Aborted. read: (%d, %d)", m_topCorner.x, m_topCorner.y);
            m_abort = true;
        }
     }
    
    bool initPieces (ObjC_Bitmap* bitmap) {
 
        m_gameOver = false;
        m_hold = -1;
        m_currentPiece = getCurrentPiece(bitmap, m_topCorner);
       
        if (m_currentPiece == -1) {  // safety
            return false;
        }
        
        for (int i=0; i<5; i++) {
            Pos corner = Pos(m_previewCorner.x, m_previewCorner.y + (i * blockSize * 3));
            int piece = TetrisGetPiece(bitmap, corner);
            
            m_previews.push_back(piece);
        }

        for (int y=0; y<20; y++) {
            for (int x=0; x<10; x++) {
                    
                if (x >= 3 && x <= 6 && y < 2) { m_chart[y][x] = 0; continue; }
                    
                m_chart[y][x] = checkIfFilled(
                    bitmap,
                    m_topCorner,
                    x,
                    y,
                    m_currentPiece
                );
            }
        }
        return true;
    }
    
    ObjC_Instruction* solve () {
        
        
        if (m_currentPiece == -1)
            NSLog(@"Error, currentPiece Error.");
        

        Future future = Future();
        if (m_hold != -1)
            future = TetrisSolver(m_chart, m_currentPiece, m_hold);
        else
            future = TetrisSolver(m_chart, m_currentPiece, m_previews[0]);

        if (future.instruction.hold == true)
            m_hold = future.holdPiece;
        
        return [[ObjC_Instruction alloc] init:future.instruction.x :future.instruction.r :future.instruction.hold];
    }
    
    void fetchPiece (ObjC_Bitmap* bitmap) {
        
        m_currentPiece = getCurrentPiece(bitmap, m_topCorner);

        for (int i=0; i<5; i++) {
            Pos corner = Pos(m_previewCorner.x, m_previewCorner.y + (i * blockSize * 3));
            int piece = TetrisGetPiece(bitmap, corner);
            if (piece == -1) {m_abort = true; return;} // safety
            m_previews[i] = piece;
        }
    }
    
    void fetchChart (ObjC_Bitmap* bitmap) {

        m_gameOver = true;
        bool perfectClear = false;
        
        for (int y=0; y<20; y++) {
            for (int x=0; x<10; x++) {
                if (x >= 3 && x <= 6 && y < 1) {
                    m_chart[y][x] = 0;
                    continue;
                }
                
                m_chart[y][x] = checkIfFilled(
                    bitmap,
                    m_topCorner,
                    x,
                    y,
                    m_currentPiece
                );
                Pos pos = m_topCorner;
                pos.x += x * blockSize +10;
                pos.y += y * blockSize +10;
                
                if (m_chart[y][x] != 0)
                    perfectClear = false;
                if (m_chart[y][x] == 1)  // if it isn't a greyed out block
                    m_gameOver = false;
                if (m_chart[y][x] == -1)
                    m_chart[y][x] = 1;
            }
        }
        if (perfectClear)
            m_gameOver = false;
    }
    
    bool update (ObjC_Bitmap* bitmap) {
        fetchPiece(bitmap);
        fetchChart(bitmap);
        
        return m_gameOver;
    }
    
    
    Pos m_topCorner;
    Pos m_bottomCorner;
    Pos m_previewCorner;
    Pos m_windowPos;
    vector<vector<int>> m_chart;

    int m_currentPiece;
    vector<int> m_previews;
    int m_hold = -1;
    bool m_gameOver = false;
    bool m_abort = false;
};



@implementation ObjC_Coordinator
{
    TetrisCoordinator* m_solver;
    int m_timeConsumed;
}

-(id) init: (ObjC_Bitmap*) bitmap windowPos: (CGPoint)windowPos {
    
    self = [super init];
    if (self) {
        initialize_ColorToPiece();
        Pos wPos = Pos(int(windowPos.x), int(windowPos.y));
        m_solver = new TetrisCoordinator(bitmap, wPos);
    }
    return self;
}

- (void) dealloc {
    delete m_solver;
}
-(bool) reset: (ObjC_Bitmap*)bitmap {
    return m_solver->initPieces(bitmap);
}
-(void) update: (ObjC_Bitmap*) bitmap {
    m_solver->update(bitmap);
}
-(ObjC_Instruction*) solve {
    return m_solver->solve();
}
-(bool) gameOver {
    return m_solver->m_gameOver;
}
-(bool) abort {
    return m_solver->m_abort;
}
@end
