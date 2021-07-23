//
//  Instruction.m
//  ScreenReader
//
//  Created by shine on 7/1/21.
//

#import <Foundation/Foundation.h>
#import "Instruction.h"

@implementation ObjC_Instruction
{
    int m_x;
    int m_r;
    int m_h;
}

- (id) init: (int)x :(int)r :(bool)h {
    self = [super init];
    if (self) {
        
        m_r = r;
        m_x = x;
        m_h = h;
    }
    return self;
}
-(int) x {return m_x;}
-(int) r {return m_r;}
-(bool) hold {return m_h;}
@end
