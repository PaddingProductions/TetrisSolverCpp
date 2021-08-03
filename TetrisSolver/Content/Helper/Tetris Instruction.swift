//
//  Tetris Instruction.swift
//  ScreenReader
//
//  Created by shine on 6/18/21.
//

import Foundation

struct TetrisInstruction {
    init () {}
    init (source: ObjC_Instruction) {
        var instruction: [CGKeyCode] = []
        if source.hold() {
            instruction.append(Keycode.c)
        }
        for _ in 0..<source.r() {
            instruction.append(Keycode.upArrow)
        }
        if (source.x() < pieceInitialPosition) {
            for _ in 0..<(pieceInitialPosition - Int(source.x())) {
                instruction.append(Keycode.leftArrow)
            }
        }
        if (source.x() > pieceInitialPosition) {
            for _ in 0..<(Int(source.x()) - pieceInitialPosition) {
                instruction.append(Keycode.rightArrow)
            }
        }
        if (source.spin() != source.r()) {
            instruction.append(Keycode.downArrow);
            
            if (source.r() - source.spin() == -1) {
                instruction.append(Keycode.upArrow);
            }
            if (source.r() - source.spin() == 1) {
                instruction.append(Keycode.z);
            }
        }
        instruction.append(Keycode.space)
        
        self.instruction = instruction
    }
    
    func execute () {
        for key in instruction {
            var hold = 100;
            if (key == Keycode.downArrow) {
                hold = 40000;
            }
            PressKey(key: key, hold: hold)
        }
    }
    var instruction: [CGKeyCode] = []
}


let pieceInitialPosition: Int = 4
