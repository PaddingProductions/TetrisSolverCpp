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
        print("x: \(source.x())")
        print("r: \(source.r())")
        if (source.spin() != source.r()) {
            instruction.append(Keycode.downArrow);
            
            if ((source.r() + 1) % 4 == source.spin()) {
                instruction.append(Keycode.upArrow);
            }
            if ((source.r() + 2) % 4 == source.spin()) {
                instruction.append(Keycode.s);
            }
            if ((source.r() + 3) % 4 == source.spin()) {
                instruction.append(Keycode.z);
            }
            print("spun: \(source.r()) -> \(source.spin())")
        }
        
        instruction.append(Keycode.space)
        
        self.instruction = instruction
    }
    
    
    func execute () {
        for key in instruction {
            var hold = 100;
            if (key == Keycode.downArrow) {
                hold = 40000 //40000
                g_spun = true;
            }
            PressKey(key: key, hold: hold)
        }
    }
    var instruction: [CGKeyCode] = []
}

var g_spun = false;
let pieceInitialPosition: Int = 4
