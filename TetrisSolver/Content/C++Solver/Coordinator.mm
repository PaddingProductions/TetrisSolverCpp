#import <Foundation/Foundation.h>
#include <vector>
#include <string>
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
    
     }
    
    bool initialize (ObjC_Bitmap* bitmap) {
        
        m_solver.reset();
        m_gameOver = false;
        m_field = Field();
        m_field.piece = GetInitialPiece(bitmap, m_topCorner);
        m_previews.resize(5);
        
        if (m_field.piece == -1)  // safety
            return false;
        
        
        for (int i=0; i<5; i++) {
            Pos corner = Pos(m_previewCorner.x, m_previewCorner.y + (i * blockSize * 3));
            int piece = TetrisGetPiece(bitmap, corner);
            
            m_previews[i] = piece;
        }
        m_solver.Find_4w(m_field.piece, &m_previews);
        
        fetchChart(bitmap);
        for (int cy=0; cy<20; cy++) {
            if (checkIfFilled(bitmap, m_topCorner, 4, cy, m_field.piece)) {
                for (int y=0; y<2; y++) {
                    for (int x=3; x<7; x++) {
                        m_field.chart[cy+y][x] = 0;
                    }
                }
                break;
            }
        }
        return true;
    }
    
    ObjC_Instruction* solve () {
        
        bool emptyHold = false; // since setting it to preview[0] is a temporary measure,
                                // we need to set it back into -1 after we're done
        if (m_field.hold == -1) {
            m_field.hold = m_previews[0];
            emptyHold = true;
        }
        
        Future future = Future();
        future = m_solver.Solve(&m_field);
        
        if (emptyHold) m_field.hold = -1;
        if (future.instruction.hold == true)
            m_field.hold = m_field.piece;
        m_field.update(future.chart, future.combo, future.b2b);
        
        return [[ObjC_Instruction alloc] init:future.instruction.x :future.instruction.r :future.instruction.hold :future.instruction.spin];
    }

    void fetchPiece (ObjC_Bitmap* bitmap) {
        
        m_field.piece = getCurrentPiece(bitmap, m_topCorner);

        for (int i=0; i<5; i++) {
            Pos corner = Pos(m_previewCorner.x, m_previewCorner.y + (i * blockSize * 3));
            int piece = TetrisGetPiece(bitmap, corner);
            m_previews[i] = piece;
        }
    }
    
    void fetchChart (ObjC_Bitmap* bitmap) {

        m_gameOver = true;
        bool perfectClear = true;
        
        for (int y=0; y<20; y++) {
            for (int x=0; x<10; x++) {
                if (x >= 3 && x <= 6 && y < 1) {
                    m_field.chart[y][x] = 0;
                    continue;
                }
                
                m_field.chart[y][x] = checkIfFilled(
                    bitmap,
                    m_topCorner,
                    x,
                    y,
                    m_field.piece
                );
                Pos pos = m_topCorner;
                pos.x += x * blockSize +10;
                pos.y += y * blockSize +10;
                
                if (m_field.chart[y][x] != 0)
                    perfectClear = false;
                if (m_field.chart[y][x] == 1)  // if it isn't a greyed out block
                    m_gameOver = false;
                if (m_field.chart[y][x] == -1)
                    m_field.chart[y][x] = 1;
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
    Field m_field;
    
    Solver m_solver = Solver();
        
    vector<int> m_previews;
    bool m_gameOver = false;
};








@implementation ObjC_Coordinator
{
    TetrisCoordinator* m_solver;
    int m_timeConsumed;
    bool m_tSpinFinder;
}

-(id) init: (ObjC_Bitmap*) bitmap windowPos: (CGPoint)windowPos {
    
    self = [super init];
    if (self) {
        m_tSpinFinder = true;
        
        initialize_ColorToPiece();
        Pos wPos = Pos(int(windowPos.x), int(windowPos.y));
        m_solver = new TetrisCoordinator(bitmap, wPos);
    }
    return self;
}
- (void) set_FindTspins :(bool)input {
    g_findTSpins = input;
}
- (void) set_4w :(bool)input {
    g_4w = input;
}
- (void) dealloc {
    delete m_solver;
}
-(bool) reset: (ObjC_Bitmap*)bitmap {
    return m_solver->initialize(bitmap);
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
@end
