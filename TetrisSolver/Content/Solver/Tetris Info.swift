//
//  Tetris Info.swift
//  ScreenReader
//
//  Created by shine on 6/18/21.
//

import Foundation

let PieceNames: [String] = [
    "J",
    "L",
    "S",
    "Z",
    "T",
    "I",
    "O"
]
struct Pos {
    init (x: Int, y: Int) {
        self.x = x;
        self.y = y;
    }
    var x: Int;
    var y: Int;
}

struct Piece {
    init (id: Int) {
        self.init(
            id: id,
            x: pieceInitialPosition,
            y: 0,
            r: 0,
            map: pieceMaps[id]
        )
    }
    init (id: Int, x:Int, r: Int) {
        self.id = id
        self.r = r
        self.x = x
        self.y =  0
        self.map = pieceMaps[id].maps[r]
        self.centerX = pieceMaps[id].centerX
        self.centerY = pieceMaps[id].centerY
    }
    init (id: Int, x:Int, y:Int, r: Int, map: PieceMap) {
        self.id = id
        self.r = r
        self.x = x
        self.y = y
        self.map = map.maps[r]
        self.centerX = map.centerX
        self.centerY = map.centerY
    }
    var id: Int
    var r: Int
    var x: Int
    var y: Int
    var map: [[Int]]
    var centerX: Int
    var centerY: Int
}

struct PieceMap {
    init ( centerX:Int, centerY: Int, maps: [[[Int]]]) {
        self.centerX = centerX
        self.centerY = centerY
        self.maps = maps
    }
    var centerX: Int
    var centerY: Int
    var maps: [[[Int]]]
}

struct TetrisInstruction {
    init () {}
    init (x: Int, r: Int, h: Bool) {
        var instruction: [CGKeyCode] = []
        if h {
            instruction.append(Keycode.c)
        }
        for _ in 0..<r {
            instruction.append(Keycode.upArrow)
        }
        if (x < pieceInitialPosition) {
            for _ in 0..<(pieceInitialPosition - x) {  instruction.append(Keycode.leftArrow)
            }
        }
        if (x > pieceInitialPosition) {
            for _ in 0..<(x - pieceInitialPosition) {  instruction.append(Keycode.rightArrow)
            }
        }
        instruction.append(Keycode.space)
        
        self.instruction = instruction
    }
    
    func execute () {
        for key in instruction {
            PressKey(key: key)
        }
    }
    var instruction: [CGKeyCode] = []
}


let pieceInitialPosition: Int = 4

let pieceMaps: [PieceMap] = [
    PieceMap(   // J
        centerX: 1,
        centerY: 1,
        maps: [
            [  // origin
                [1,0,0],
                [1,1,1],
                [0,0,0],
            ],
              
            [ // right
                [0,1,1],
                [0,1,0],
                [0,1,0],
            ],
            [  // 2
                [0,0,0],
                [1,1,1],
                [0,0,1],
            ],
            [  // left
                [0,1,0],
                [0,1,0],
                [1,1,0],
            ]
        ]
    ),
    PieceMap( // L
        centerX: 1,
        centerY: 1,

        maps:[
            [
                [0,0,1],
                [1,1,1],
                [0,0,0],
            ],
            [
                [0,1,0],
                [0,1,0],
                [0,1,1],
            ],
            [
                [0,0,0],
                [1,1,1],
                [1,0,0],
            ],
            [
                [1,1,0],
                [0,1,0],
                [0,1,0],
            ]
        ]
    ),



    PieceMap( // S
        centerX: 1,
        centerY: 1,
        
        maps: [
            [
                [0,1,1],
                [1,1,0],
                [0,0,0],
            ],
              
            [
                [0,1,0],
                [0,1,1],
                [0,0,1],
            ],
            [
                [0,0,0],
                [0,1,1],
                [1,1,0],
            ],
            [
                [1,0,0],
                [1,1,0],
                [0,1,0],
            ]
        ]
    ),
    PieceMap( // Z
        centerX: 1,
        centerY: 1,
        maps:[
            [
                [1,1,0],
                [0,1,1],
                [0,0,0],
            ],
            [
                [0,0,1],
                [0,1,1],
                [0,1,0],
            ],
            [
                [0,0,0],
                [1,1,0],
                [0,1,1],
            ],
            [
                [0,1,0],
                [1,1,0],
                [1,0,0],
            ]
        ]
    ),
    
    PieceMap(   // T
        centerX: 1,
        centerY: 1,
        maps: [
            [
                [0,1,0],
                [1,1,1],
                [0,0,0],
            ],
              
            [
                [0,1,0],
                [0,1,1],
                [0,1,0],
            ],
            [
                [0,0,0],
                [1,1,1],
                [0,1,0],
            ],
            [
                [0,1,0],
                [1,1,0],
                [0,1,0],
            ]
        ]
    ),
    
    PieceMap( // I
        centerX: 1,
        centerY: 1,
        maps: [
            [
                [0,0,0,0],
                [1,1,1,1],
                [0,0,0,0],
                [0,0,0,0],
            ],
            [
                [0,0,1,0],
                [0,0,1,0],
                [0,0,1,0],
                [0,0,1,0],
            ],
            [
                [0,0,0,0],
                [0,0,0,0],
                [1,1,1,1],
                [0,0,0,0],
            ],
            [
                [0,1,0,0],
                [0,1,0,0],
                [0,1,0,0],
                [0,1,0,0],
            ]
        ]
    ),
    PieceMap( // O
        centerX: 1,
        centerY: 1,
        maps:[
            [
                [0,1,1],
                [0,1,1],
                [0,0,0],
            ],
            [
                [0,0,0],
                [0,1,1],
                [0,1,1],
            ],
            [
                [0,0,0],
                [1,1,0],
                [1,1,0],
            ],
            [
                [1,1,0],
                [1,1,0],
                [0,0,0],
            ]
        ]
    )
]
