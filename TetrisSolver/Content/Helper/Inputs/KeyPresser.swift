//
//  KeyPresser.swift
//  ScreenReader
//
//  Created by shine on 6/17/21.
//

import Foundation


func PressKey (key: CGKeyCode, hold: Int = 10) {
    
    let keyDown = CGEvent(
        keyboardEventSource: nil,
        virtualKey: key,
        keyDown: true
    )!
    keyDown.post(
        tap: .cghidEventTap
    )

    let keyUp = CGEvent(
        keyboardEventSource: nil,
        virtualKey: key,
        keyDown:false
    )!
    usleep(useconds_t(hold))
    keyUp.post(
        tap: .cghidEventTap
    )
}
