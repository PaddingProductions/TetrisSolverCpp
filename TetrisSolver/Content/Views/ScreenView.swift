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
    let zoomW: Double = 100.0
    let zoomH: Double = 100.0
    @State var screenImage: CGImage? = nil
    @State var screenBitmap: ObjC_Bitmap?
    @State var mousePos: CGPoint = CGPoint(x: 0, y:0)
    @State var mouseColor: Int = 0
    @State var mouseZoomImage: CGImage? = nil
    @State var solver: ObjC_Coordinator?
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
    
    func onMouseClick (mouseWindowPos: CGPoint, geo: GeometryProxy) {
        let x = Double(mouseWindowPos.x) / Double( geo.size.width ) * Double(screenImage!.width )
        let y = Double(mouseWindowPos.y) / Double( geo.size.height) * Double(screenImage!.height)
        
        mousePos = CGPoint(x:Int(x),y:Int(y))
        mouseColor = Int(screenBitmap!.getValue( Int32(x), Int32(y) ))
        mouseZoomImage = cropToBounds(
            image: screenImage!,
            x: x,
            y: y,
            width : zoomW,
            height: zoomH
        )
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
                        if (solver != nil) {
                            Button("init") {
                                solver = ObjC_Coordinator(screenBitmap, windowPos: targetWindow.pos)
                            }
                            Button("General Solve") {
                                LClick (pos: CGPoint(x: targetWindow.pos.x + 10, y: targetWindow.pos.y + 10))
                                PressKey(key: Keycode.f4)

                                usleep(1900000)
                                while (!solver!.begin(screenBitmap!)) {
                                    self.update()
                                    usleep(100)
                                }
                                print(" ---- begun");
                                while (!solver!.gameOver() && !solver!.abort()) {
                                    
                                    let start = DispatchTime.now()

                                    let commands = solver!.solve()
                                    let instruction = TetrisInstruction(
                                        x: Int(commands!.x()),
                                        r: Int(commands!.r()),
                                        h: Bool(commands!.hold())
                                    );
                                    instruction.execute()
                                    
                                    let end = DispatchTime.now()
                                    let microTime: Int = Int((end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000)
                                    print ( useconds_t(max( 1, delay - microTime )) )
                                    usleep( useconds_t(max( 1, delay - microTime )) )
                                    self.update()
                                    solver!.update(screenBitmap!)
                                }
                                print(" ---- end")
                            }
                            Button("Limited Solve") {
                                LClick (pos: CGPoint(x: targetWindow.pos.x + 10, y: targetWindow.pos.y + 10))
                                PressKey(key: Keycode.f4)
                                
                                while (!solver!.begin(screenBitmap!)) {
                                    self.update()
                                    usleep(100000)
                                }
                                for _ in 0..<3 {
                                    let start = DispatchTime.now()

                                    let commands = solver!.solve()
                                    let instruction = TetrisInstruction(
                                        x: Int(commands!.x()),
                                        r: Int(commands!.r()),
                                        h: Bool(commands!.hold())
                                    );
                                    instruction.execute()
                                    
                                    let end = DispatchTime.now()
                                    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
                                    usleep(
                                        max(
                                            1,
                                            useconds_t(
                                                UInt64( delay * 1_000_000_000) - nanoTime
                                            )
                                        )
                                    )
                                    self.update()
                                    solver!.update(screenBitmap!)
                                }
                                print(" ---- end")
                            }
                        }
                    }
                    VStack {
                        Text("X: \(mousePos.x)")
                        Text("Y: \(mousePos.y)")
                    }
                    VStack {
                        Text("Hex: \(mouseColor)")
                        Text("B: \(intToHex(int: self.mouseColor)[0])")
                        Text("G: \(intToHex(int: self.mouseColor)[1])")
                        Text("R: \(intToHex(int: self.mouseColor)[2])")
                        Text("A: \(intToHex(int: self.mouseColor)[3])")
                    }
                    
                    Circle()
                        .fill(Color(color: mouseColor))
                        .frame(width: 100, height: 100)
                    
                    if mouseZoomImage != nil {
                        Image(decorative: mouseZoomImage!, scale: 1.0)
                    }
                }
            }
            //TetrisSolverView(solver: solver!)
            if self.screenImage != nil {
                    GeometryReader { geo in
                        Image(decorative: screenImage!, scale: 1.0)
                            .resizable()
                            .gesture (
                                DragGesture (minimumDistance: 0).onEnded({ (value) in
                                    self.onMouseClick(mouseWindowPos: value.location, geo: geo)
                                })
                            )
                    }
                    .aspectRatio(
                        CGFloat(Double(screenImage!.width) / Double(screenImage!.height)),
                        contentMode: .fit
                    )
            }
        }
        .onAppear() {
            self.update()
            solver = ObjC_Coordinator(screenBitmap, windowPos: targetWindow.pos)
        }
    }
}
