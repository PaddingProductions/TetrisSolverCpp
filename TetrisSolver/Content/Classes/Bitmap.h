//
//  Header.h
//  TetrisSolver
//
//  Created by shine on 7/1/21.
//


#ifndef Header_h
#define Header_h

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>


@interface ObjC_Bitmap : NSObject
-(id) init: (CGImageRef)image;

-(CFDataRef) data;
-(size_t)  width;
-(size_t)  height;
-(size_t)  bitsPerComponent;
-(size_t)  bitsPerPixel;
-(size_t)  bytesPerRow;

-(uint32_t) getValue:(int)x :(int)y;
@end


#endif /* Header_h */
