//
//  KeyPresser.swift
//  ScreenReader
//
//  Created by shine on 6/17/21.
//

import Foundation


func PressKey (key: CGKeyCode) {
    
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
    keyUp.post(
        tap: .cghidEventTap
    )
}
