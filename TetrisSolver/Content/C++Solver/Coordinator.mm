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
        
        m_chart.resize(20);
        for (int y=0; y<20; y++) {
            m_chart[y].resize(10);
            for (int x=0; x<10; x++) {
                m_chart[y][x] = 0;
            }
        }
     }
    
    bool initialize (ObjC_Bitmap* bitmap) {
 
        m_gameOver = false;
        m_hold = -1;
        m_currentPiece = GetInitialPiece(bitmap, m_topCorner);
       
        if (m_currentPiece == -1)  // safety
            return false;
        
        
        for (int i=0; i<5; i++) {
            Pos corner = Pos(m_previewCorner.x, m_previewCorner.y + (i * blockSize * 3));
            int piece = TetrisGetPiece(bitmap, corner);
            
            m_previews.push_back(piece);
        }
        return true;
    }
    
    ObjC_Instruction* solve () {
        if (m_currentPiece == -1)
            NSLog(@"Error, currentPiece Error.");
        

        Future future = Future();
        if (m_hold != -1)
            future = Solver(m_chart, m_currentPiece, m_hold);
        else
            future = Solver(m_chart, m_currentPiece, m_previews[0]);

        if (future.instruction.hold == true)
            m_hold = m_currentPiece
            ;
        
        return [[ObjC_Instruction alloc] init:future.instruction.x :future.instruction.r :future.instruction.hold :future.instruction.spin];
    }
    
    NSString* Test_solve (const char* chart, int piece) {
        
        vector<vector<int>> in_chart;
        in_chart.resize(20);
        for (int y=0; y<20; y++) {
            in_chart[y].resize(10);
            for (int x=0; x<10; x++)
                in_chart[y][x] = chart[y*10 +x] - 48;
        }
        
        vector<vector<int>> out_chart = Test_Solver(in_chart, piece, piece).chart;
        string str_chart;
        str_chart.resize(200);
        for (int y=0; y<20; y++)
            for (int x=0; x<10; x++)
                str_chart[y * 10 + x] = 48 + out_chart[y][x];
    
        return @(str_chart.c_str());
    }

    NSString* Test_evaluate (const char* str_in_chart) {
        
        vector<vector<int>> in_chart;
        in_chart.resize(20);
        for (int y=0; y<20; y++) {
            in_chart[y].resize(10);
            for (int x=0; x<10; x++)
                in_chart[y][x] = str_in_chart[y*10 +x] - 48;
        }
        
        vector<vector<int>> out_chart = Test_Evaluator(in_chart);
        string str_chart;
        str_chart.resize(200);
        for (int y=0; y<20; y++)
            for (int x=0; x<10; x++)
                str_chart[y * 10 + x] = 48 + out_chart[y][x];
        
        return @(str_chart.c_str());
    }
    
    void fetchPiece (ObjC_Bitmap* bitmap) {
        
        m_currentPiece = getCurrentPiece(bitmap, m_topCorner);

        for (int i=0; i<5; i++) {
            Pos corner = Pos(m_previewCorner.x, m_previewCorner.y + (i * blockSize * 3));
            int piece = TetrisGetPiece(bitmap, corner);
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
-(NSString*) testSolver: (NSString*)NSStr_chart piece:(int)piece {
    const char* chart = [NSStr_chart UTF8String];
    if (piece < 0 || piece >= 7) return NSStr_chart;
    NSString* output = m_solver->Test_solve(chart,piece);
    return output;
}
-(NSString*) testEvaluator: (NSString*)NSStr_chart {
    const char* chart = [NSStr_chart UTF8String];
    NSString* output = m_solver->Test_evaluate(chart);
    return output;
}
@end
