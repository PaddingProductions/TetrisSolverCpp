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
