//
//  Solver.h
//  TetrisSolver
//
//  Created by shine on 6/30/21.
//

#ifndef Solver_h
#define Solver_h


#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Classes/Bitmap.h"
#import "Classes/Instruction.h"

@interface ObjC_Coordinator : NSObject
-(id) init: (ObjC_Bitmap*) image windowPos: (CGPoint)windowPos;
-(ObjC_Instruction*) solve;
-(void) update: (ObjC_Bitmap*) bitmap;
-(bool) begin: (ObjC_Bitmap*) bitmap;
-(bool) gameOver;
-(bool) abort;

@end

#endif /* Header_h */
