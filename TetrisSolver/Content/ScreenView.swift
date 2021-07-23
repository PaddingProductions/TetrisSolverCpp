//
//  ScreenView.swift
//  ScreenReader
//
//  Created by shine on 5/25/21.
//

import SwiftUI
import Dispatch

struct ScreenView: View {
    
    let solveMode: Bool = true;
    let targetWindow: TargetWindow
    @State var screenImage: CGImage? = nil
    @State var screenBitmap: ObjC_Bitmap?
    @State var m_solver: ObjC_Coordinator?
    let speed: Double = 5; // in PPS
    let delay: Int;
    
    init (targetWindow: TargetWindow) {
        
        self.delay = Int( max( 30000.0, ((1/speed) * 1000000) ) )
        self.targetWindow = targetWindow
        let screenImage: CGImage? = targetWindow.captureImage()
        let bitmap = ObjC_Bitmap(screenImage!)
        self.screenImage = screenImage!
        self.screenBitmap = bitmap
        
    }

    func update () {
        screenImage = targetWindow.captureImage()!
        let bitmap = ObjC_Bitmap(screenImage!)
        self.screenBitmap = bitmap
    }
    
    var body: some View {
        ScrollView{
            //Stats & interactive buttons
            HStack {
                if screenImage != nil {
                    VStack {
                        Button("Update") {
                            update()
                        }
                        if (m_solver != nil) {
                            Button("init") {
                                m_solver = ObjC_Coordinator(screenBitmap, windowPos: targetWindow.pos)
                            }
                            Button("General Solve") {
                                LClick (pos: CGPoint(x: targetWindow.pos.x + 10, y: targetWindow.pos.y + 10))
                                PressKey(key: Keycode.f4)

                                usleep(1900000)
                                self.update()
                                
                                while (!m_solver!.reset(screenBitmap!)) {
                                    self.update()
                                    usleep(100)
                                }
                                print(" ---- beginning")
                                while (!m_solver!.gameOver()) {
                                    
                                    let start = DispatchTime.now()

                                    let commands = m_solver!.solve()
                                    let instruction = TetrisInstruction(
                                        x: Int(commands!.x()),
                                        r: Int(commands!.r()),
                                        h: Bool(commands!.hold())
                                    );
                                    instruction.execute()
                                    
                                    let end = DispatchTime.now()
                                    let microTime: Int = Int((end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000)
                                    usleep( useconds_t(max( 1, delay - microTime )) )
                                    self.update()
                                    m_solver!.update(screenBitmap!)
                                }
                            }
                            Button("Limited Solve") {
                                LClick (pos: CGPoint(x: targetWindow.pos.x + 10, y: targetWindow.pos.y + 10))
                                PressKey(key: Keycode.f4)

                                usleep(1900000)
                                self.update()
                                
                                while (!m_solver!.reset(screenBitmap!)) {
                                    self.update()
                                    usleep(100)
                                }
                                print(" ---- beginning")
                                for _ in 0..<5 {
                                    
                                    let start = DispatchTime.now()

                                    let commands = m_solver!.solve()
                                    let instruction = TetrisInstruction(
                                        x: Int(commands!.x()),
                                        r: Int(commands!.r()),
                                        h: Bool(commands!.hold())
                                    );
                                    instruction.execute()
                                    
                                    let end = DispatchTime.now()
                                    let microTime: Int = Int((end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000)
                                    usleep( useconds_t(max( 1, delay - microTime )) )
                                    self.update()
                                    m_solver!.update(screenBitmap!)
                                }
                            }
                        }
                    }
                }
            }
            if self.screenImage != nil {
                    GeometryReader { geo in
                        Image(decorative: screenImage!, scale: 1.0)
                            .resizable()
                    }
                    .aspectRatio(
                        CGFloat(Double(screenImage!.width) / Double(screenImage!.height)),
                        contentMode: .fit
                    )
            }
        }
        .onAppear() {
            self.update()
            m_solver = ObjC_Coordinator(screenBitmap, windowPos: targetWindow.pos)
        }
    }
}
