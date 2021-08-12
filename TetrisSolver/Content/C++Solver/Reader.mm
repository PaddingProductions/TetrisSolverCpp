//
//  Reader.mm
//  TetrisSolver
//
//  Created by shine on 7/3/21.
//

#import <Foundation/Foundation.h>
#include "Info.h"
#include "Reader.h"
#include "Bitmap.h"

#include <vector>
#include <list>
#include <map>

using namespace std;

uint32_t boarder = 0x393939ff;
uint32_t black = 0x000000ff;
uint32_t grey = 0x6a6a6aff;
Pos boardSize = Pos(480, 960);
int blockSize = 48;

uint32_t PieceToColor[7] = {
    0xbf4424ff, //J
    0x2863d4ff, //L
    0x34ae70ff, //S
    0x3d2ec6ff, //Z
    0x8637a1ff, //T
    0xd29a43ff, //I
    0x37a1daff  //O
};

map<uint32_t,int> ColorToPiece;
void initialize_ColorToPiece () {
    ColorToPiece[0xbf4424ff] = 0;
    ColorToPiece[0x2863d4ff] = 1;
    ColorToPiece[0x34ae70ff] = 2;
    ColorToPiece[0x3d2ec6ff] = 3;
    ColorToPiece[0x8637a1ff] = 4;
    ColorToPiece[0xd29a43ff] = 5;
    ColorToPiece[0x37a1daff] = 6;
}
uint32_t shadowColor[7] = {
    0x5f2112ff, //J
    0x103169ff, //L
    0x155637ff, //S
    0x1d1462ff, //Z
    0x431a50ff, //T
    0x684c1fff, //I
    0x17506cff  //O
};

bool ColorCompare(uint32_t c1, uint32_t c2, int range) {
    int c1r = (c1 >> 8) & 0xFF;
    int c1g = (c1 >> 16) & 0xFF;
    int c1b = (c1 >> 24) & 0xFF;

    int c2r = (c2 >> 8) & 0xFF;
    int c2g = (c2 >> 16) & 0xFF;
    int c2b = (c2 >> 24) & 0xFF;
    
    if (abs(c1r - c2r) >= range) return false;
    if (abs(c1g - c2g) >= range) return false;
    if (abs(c1b - c2b) >= range) return false;
    
    return true;
}



Pos TetrisGetTopCorner (ObjC_Bitmap* bitmap)  {
    Pos pos = Pos(50, int([bitmap height]) / 2);
    uint32_t color = [bitmap getValue:pos.x :pos.y];
    
    while (ColorCompare(color, black, 3)) {
        pos.x ++;
        color = [bitmap getValue:pos.x :pos.y];
    }
    while (!ColorCompare(color, black, 3))  {
        pos.y --;
        color = [bitmap getValue:pos.x :pos.y];
    }
    pos.y ++;
    return pos;
}

Pos TetrisGetBottomCorner (ObjC_Bitmap* bitmap, Pos& tC) {
    
    Pos pos = tC;
    pos.y += CGFloat(boardSize.y);
    pos.x += CGFloat(boardSize.x);
    return pos;
}

Pos TetrisGetHoldCorner (ObjC_Bitmap* bitmap, Pos& tC)  {
    Pos pos = tC;
    pos.x -= CGFloat((4 * blockSize) + 17);
    return pos;
}

Pos TetrisGetPreviewCorner (ObjC_Bitmap* bitmap, Pos& tC) {
    Pos pos = tC;
    pos.x += blockSize * 11;
    pos.y += blockSize;
    uint32_t c1 = 0;
    uint32_t c2 = 0;
    while (ColorCompare(c1,black,3) && ColorCompare(c2,black,3)) {  // two-column scan for block
        c1 = [bitmap getValue:pos.x :pos.y];
        c2 = [bitmap getValue:pos.x :(pos.y + blockSize)];
        
        pos.x ++;
    }
    if (ColorCompare(c2, PieceToColor[6], 10))
        pos.x -= CGFloat(blockSize);
    
    return pos;
}

int TetrisGetPiece (ObjC_Bitmap* bitmap, Pos& refC) {
    for (int y=0; y<3; y++) {
        for (int x=0; x<4; x++) {
            uint32_t color = [bitmap getValue: refC.x + x*blockSize +10 :refC.y + y*blockSize +10];
            
            for (int i=0; i<7; i++)
                if (ColorCompare(color, PieceToColor[i], 10))
                    return i;
        }
    }
    return -1;
}

int GetInitialPiece (ObjC_Bitmap* bitmap, Pos& tC) {

    for (int y=0; y<20; y++) {
        for (int x=3; x<7; x++) {
            uint32_t color = [bitmap getValue :tC.x +x*blockSize +10 :tC.y + y*blockSize +10];

            for (int i=0; i<7; i++)
                if (ColorCompare(color, PieceToColor[i], 10))
                    return i;
        }
    }

    return -1;
}
int getCurrentPiece(ObjC_Bitmap* bitmap, Pos pos) {

    for (int y=0; y<20; y++) {
        for (int x=3; x<7; x++) {
            uint32_t color = [bitmap getValue:pos.x + x*blockSize +10 :pos.y + y*blockSize +10];
            
            for (int i=0; i<7; i++)
                if (ColorCompare(color, PieceToColor[i], 10))
                    return i;
        }
    }

    return -1;
}



int checkIfFilled (ObjC_Bitmap* bitmap, Pos& tC, int x, int y, int cP) {
    Pos pos = tC;
    pos.x += x * blockSize  + 10;
    pos.y += y * blockSize  + 10;
    uint32_t color = [bitmap getValue:pos.x :pos.y];
    
    if (ColorCompare(color, shadowColor[cP], 10))
        return 0;
    if (ColorCompare(color, grey, 10))
        return -1;
    if (!ColorCompare(color, black, 10)) {
        return 1;
    }
    
    return 0;
}

