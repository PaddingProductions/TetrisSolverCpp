//
//  Bitmap.m
//  ScreenReader
//
//  Created by shine on 7/1/21.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#include <algorithm>
#include <vector>

#import "Instruction.h"
#import "Bitmap.h"

using namespace std;

@implementation ObjC_Bitmap
{
    CFDataRef m_data;
    size_t m_w;
    size_t m_h;
    size_t m_bitsPerComponent;
    size_t m_bitsPerPixel;
    size_t m_bytesPerRow;
}

- (id) init: (CGImage*)image {
    self = [super init];
    if (self) {
        //...
        CGDataProviderRef dataProvider = CGImageGetDataProvider(image);

        m_data = CGDataProviderCopyData(dataProvider);
        m_w = CGImageGetWidth(image);
        m_h = CGImageGetHeight(image);
        m_bitsPerComponent = CGImageGetBitsPerComponent(image);
        m_bitsPerPixel = CGImageGetBitsPerPixel(image);
        m_bytesPerRow = CGImageGetBytesPerRow(image);
    }
    return self;
}
- (CFDataRef) data {return m_data;}
- (size_t) width   {return m_w;}
- (size_t) height  {return m_h;}
- (size_t) bitsPerComponent {return m_bitsPerComponent;}
- (size_t) bitsPerPixel {return m_bitsPerPixel;}
- (size_t) bytesPerRow  {return m_bytesPerRow;}

- (uint32_t) getValue: (int)x :(int)y {
    
    const UInt8 * buf = CFDataGetBytePtr(m_data);

    uint64_t index = (y * m_bytesPerRow) + (x * 4);
    int b = buf[index];
    int g = buf[index+1];
    int r = buf[index+2];
    int a = buf[index+3];
    uint32_t color = (b << 24) + (g << 16) + (r << 8) + a;
    
    return color;
}
@end
