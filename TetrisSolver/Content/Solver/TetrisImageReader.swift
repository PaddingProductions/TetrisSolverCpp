//
//  MinesweeperCornerFinder.swift
//  ScreenReader
//
//  Created by shine on 5/28/21.
//
/*
import Foundation

let boarder = 0x393939ff
let black = 0x000000ff
let grey = 0x6a6a6aff
let boardSize: CGSize = CGSize(width: 480, height: 960)
let blockSize: Int = 48

let PieceToColor: [Int] = [
    0xbf4424ff, //J
    0x2863d4ff, //L
    0x34ae70ff, //S
    0x3d2ec6ff, //Z
    0x8637a1ff, //T
    0xd29a43ff, //I
    0x37a1daff  //O
]
let ColorToPiece: [Int:Int] = [
    0xbf4424ff: 0, //J
    0x2863d4ff: 1, //L
    0x34ae70ff: 2, //S
    0x3d2ec6ff: 3, //Z
    0x8637a1ff: 4, //T
    0xd29a43ff: 5, //I
    0x37a1daff: 6, //O
]
let PieceToShadow: [Int] = [
    0x5f2112ff, //J
    0x103169ff, //L
    0x155637ff, //S
    0x1d1462ff, //Z
    0x431a50ff, //T
    0x684c1fff, //I
    0x17506cff  //O
]

func TetrisGetTopCorner (bitmap: Bitmap) -> CGPoint {
    var pos = CGPoint(x: 0, y: bitmap.h / 2)
    var color = getBitmapValue( bitmap:bitmap, posX: Int(pos.x), posY: Int(pos.y))
    
    while color != boarder {
        pos.x += 1
        color = getBitmapValue( bitmap:bitmap, posX: Int(pos.x), posY: Int(pos.y))
    }
    print(color)
    while color == boarder  {
        pos.y -= 1
        color = getBitmapValue( bitmap:bitmap, posX: Int(pos.x), posY: Int(pos.y))
        print("\(pos.y): \(color)")
    }
    pos.y += 1
    return pos
}

func TetrisGetBottomCorner (bitmap: Bitmap, tC: CGPoint) -> CGPoint {
    
    var pos = tC
    pos.y += CGFloat(boardSize.height)
    pos.x += CGFloat(boardSize.width)
    return pos
}

func TetrisGetHoldCorner (tC: CGPoint, bitmap: Bitmap) -> CGPoint {
    var pos = tC
    pos.x -= CGFloat((4 * blockSize) + 17)
    return pos;
}

func TetrisGetPreviewCorner (tC: CGPoint, bitmap: Bitmap) -> CGPoint {
    var pos = tC
    pos.x += CGFloat(blockSize * 11)
    pos.y += CGFloat(blockSize)
    var c1 = 0
    var c2 = 0
    while (c1 == black && c2 == black) {  // two-column scan for block
        c1 = getBitmapValue( bitmap:bitmap, posX: Int(pos.x), posY: Int(pos.y))
        c2 = getBitmapValue( bitmap:bitmap, posX: Int(pos.x), posY: Int(pos.y) + blockSize)
        
        pos.x += 1
    }
    if (ColorToPiece[c2] == 6) {
        pos.x -= CGFloat(blockSize)
    }
    
    return pos;
}

func TetrisGetPiece (bitmap: Bitmap, refC: CGPoint) -> Int {
    
    for y in 0...2 {
        for x in 0...3 {
            let color: Int = getBitmapValue(
                bitmap:bitmap,
                posX: Int(refC.x + CGFloat(x * blockSize) + 10),
                posY: Int(refC.y + CGFloat(y * blockSize) + 10)
            )
            
            if (ColorToPiece[color] != nil) {
                return ColorToPiece[color]!
            }
        }
    }
    return -1
}

func getCurrentPiece(bitmap: Bitmap, tC: CGPoint) -> Int {
    for y in 0..<20 {
        let color: Int = getBitmapValue(
            bitmap:bitmap,
            posX: Int(tC.x + CGFloat(4 * blockSize) + 10),
            posY: Int(tC.y + CGFloat(y * blockSize) + 10)
        )
        
        if (ColorToPiece[color] != nil) {
            return ColorToPiece[color]!
        }
    }
    return -1
}

func getCurrentPiecePos (bitmap: Bitmap, tC: CGPoint) -> Int {
    for y in 0..<20 {
        let color: Int = getBitmapValue(
            bitmap:bitmap,
            posX: Int(tC.x + CGFloat(4 * blockSize) + 10),
            posY: Int(tC.y + CGFloat(y * blockSize) + 10)
        )
        
        if (ColorToPiece[color] != nil) {
            return y
        }
    }
    return -1
}

func checkIfFilled (bitmap: Bitmap, tC: CGPoint, x: Int, y:Int, cP: Int) -> Int {
    

    var pos = tC
    pos.x += CGFloat( x * blockSize  + 10)
    pos.y += CGFloat( y * blockSize  + 10)
    let color: Int = getBitmapValue(
        bitmap:bitmap,
        posX: Int(pos.x),
        posY: Int(pos.y)
    )
    // we need to ignore it if it's a node of the current piece, otherwise it would think there's a floating island
    if (color == PieceToShadow[cP]) {
        return 0
    }
    if (color == grey) {
        return -1
    }
    if (color != black) {
        return 1
    }
    return 0
}
*/
