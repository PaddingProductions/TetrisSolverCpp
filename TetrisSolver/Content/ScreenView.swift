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

    @StateObject var evaluatorTestInput = EvaluatorTestInput()
    @StateObject var evaluatorTestOutput = EvaluatorTestOutput()
    let speed: Double = 5; // in PPS
    let delay: Int;
    
    @State var findTSpins = false;
    
    init (targetWindow: TargetWindow) {
        
        self.delay = Int( max( 100000.0, ((1/speed) * 1000000) ) )
        print(Int( max( 100000.0, ((1/speed) * 1000000) ) ))
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
                            
                            
                            var start = DispatchTime.now();
                            while (!m_solver!.gameOver()) {
                                let instruction = TetrisInstruction(source: m_solver!.solve()!)
                                instruction.execute()
                                
                                let end = DispatchTime.now();
                                
                                let microTime: Int = Int((end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000)
                                usleep( useconds_t(max( 1, delay - microTime )) )
                                
                                start = DispatchTime.now();
                                self.update()
                                m_solver!.update(screenBitmap!)
                            }
                        }
                        Button("PvP Solve") {
                            LClick (pos: CGPoint(x: targetWindow.pos.x + 10, y: targetWindow.pos.y + 10))

                            usleep(100000)
                            self.update()
                            
                            while (!m_solver!.reset(screenBitmap!)) {
                                self.update()
                                usleep(100)
                            }
                            var start = DispatchTime.now();
                            while (!m_solver!.gameOver()) {
                                let instruction = TetrisInstruction(source: m_solver!.solve()!)
                                instruction.execute()
                                
                                let end = DispatchTime.now();
                                
                                let microTime: Int = Int((end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000)
                                usleep( useconds_t(max( 1, delay - microTime )) )
                                
                                start = DispatchTime.now();
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
                            var start = DispatchTime.now();
                            for _ in 0..<7 {
                                let instruction = TetrisInstruction(source: m_solver!.solve()!)
                                instruction.execute()
                                
                                let end = DispatchTime.now();
                                
                                let microTime: Int = Int((end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000)
                                usleep( useconds_t(max( 1, delay - microTime )) )
                                
                                start = DispatchTime.now();
                                self.update()
                                m_solver!.update(screenBitmap!)
                            }
                        }
                    
                        Button("Test Solver") {
                            
                            if (evaluatorTestInput.piece == -1) {
                                print(" ---- no piece set")
                                }
                            evaluatorTestOutput.chart = m_solver!.testSolver(
                                evaluatorTestInput.chart,
                                piece: Int32(evaluatorTestInput.piece)
                            );
                        }
                        Button("Test Evaluator") {
                            evaluatorTestOutput.chart = m_solver!.testEvaluator( evaluatorTestInput.chart );
                        }
                        
                        Toggle(isOn: $findTSpins) {
                            Text("Enable T-Spin Finder").bold()
                        }
                        Button("Set Settings") {
                            m_solver!.set_FindTspins( self.findTSpins )
                        }
                    }
                }
                Divider()
                EvaluatorTestView(
                    evaluatorTestInput: self.evaluatorTestInput,
                    evaluatorTestOutput: self.evaluatorTestOutput
                )
                //OutputChartView(self.EvaluatorOutput)
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
