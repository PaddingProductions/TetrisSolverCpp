//
//  ChartView.swift
//  ScreenReader
//
//  Created by shine on 7/23/21.

import SwiftUI

class EvaluatorTestInput: ObservableObject {
    @Published var chart: String = ""
    @Published var piece: Int = -1;

    init () {
        for _ in 0..<200 {
            self.chart.append("0");
        }
    }
}
class EvaluatorTestOutput: ObservableObject {
    @Published var chart: String = ""

    init () {
        for _ in 0..<200 {
            self.chart.append("0");
        }
    }
}


struct EvaluatorTestView: View {
    
    @ObservedObject var evaluatorTestInput: EvaluatorTestInput
    @ObservedObject var evaluatorTestOutput: EvaluatorTestOutput
    let blockSize: CGFloat = 10
    

    
    func onMouseClick ( x: Int, y: Int ) {
        let i = evaluatorTestInput.chart.index(evaluatorTestInput.chart.startIndex, offsetBy: y * 10 + x);
        if (evaluatorTestInput.chart[i] == "0") {
            evaluatorTestInput.chart.remove(at: i);
            evaluatorTestInput.chart.insert("1", at: i);
        } else  {
            evaluatorTestInput.chart.remove(at: i);
            evaluatorTestInput.chart.insert("0", at: i);
        }
    }
    
    var body: some View {
        HStack {
            VStack {
                Button("J") {
                    evaluatorTestInput.piece = 0
                }
                Button("L") {
                    evaluatorTestInput.piece = 1
                }
                Button("S") {
                    evaluatorTestInput.piece = 2
                }
                Button("Z") {
                    evaluatorTestInput.piece = 3
                }
                Button("T") {
                    evaluatorTestInput.piece = 4
                }
                Button("I") {
                    evaluatorTestInput.piece = 5
                }
                Button("O") {
                    evaluatorTestInput.piece = 6
                }
            }
            VStack (spacing: 0) {
                ForEach((0..<20), id: \.self) { y in
                    HStack (spacing: 0){
                        ForEach ((0..<10), id: \.self) { x in
                            let i = evaluatorTestInput.chart.index(evaluatorTestInput.chart.startIndex, offsetBy: y * 10 + x);
                            if evaluatorTestInput.chart[i] == "1" {
                                Rectangle()
                                    .fill(Color(color: 0xaaaaaaff))
                                    .frame(width: blockSize, height: blockSize)
                                    .padding(CGFloat(0))
                                    .gesture (
                                        DragGesture (minimumDistance: 0).onEnded({ (value) in
                                            onMouseClick(x:x, y:y)
                                        })
                                    )
                            } else {
                                Rectangle()
                                    .fill(Color(color: 0x000000ff))
                                    .frame(width: blockSize, height: blockSize)
                                    .padding(CGFloat(0))
                                    .gesture (
                                        DragGesture (minimumDistance: 0).onEnded({ (value) in
                                            onMouseClick(x:x, y:y)
                                        })
                                    )
                            }
                        }
                    }
                }
            }
            Divider()
            VStack (spacing: 0) {
                ForEach((0..<20), id: \.self) { y in
                    HStack (spacing: 0){
                        ForEach ((0..<10), id: \.self) { x in
                            let i = evaluatorTestOutput.chart.index(evaluatorTestOutput.chart.startIndex, offsetBy: y * 10 + x);
                            if evaluatorTestOutput.chart[i] == "0" {
                                Rectangle()
                                    .fill(Color(color: 0x000000ff))
                                    .frame(width: blockSize, height: blockSize)
                                    .padding(CGFloat(0))
                            }
                            if evaluatorTestOutput.chart[i] == "1" {
                                Rectangle()
                                    .fill(Color(color: 0xaaaaaaff))
                                    .frame(width: blockSize, height: blockSize)
                                    .padding(CGFloat(0))
                            }
                            if evaluatorTestOutput.chart[i] == "2" {
                                Rectangle()
                                    .fill(Color(color: 0x00aa00ff))
                                    .frame(width: blockSize, height: blockSize)
                                    .padding(CGFloat(0))
                            }
                            if evaluatorTestOutput.chart[i] == "3" {
                                Rectangle()
                                    .fill(Color(color: 0xaa0000ff))
                                    .frame(width: blockSize, height: blockSize)
                                    .padding(CGFloat(0))
                            }
                            if evaluatorTestOutput.chart[i] == "4" {
                                Rectangle()
                                    .fill(Color(color: 0x0000aaff))
                                    .frame(width: blockSize, height: blockSize)
                                    .padding(CGFloat(0))
                            }
                        }
                    }
                }
            }
        }
    }
}
