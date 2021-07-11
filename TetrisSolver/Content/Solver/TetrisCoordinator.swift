//
//  MinesweeperSolver.swift
//  ScreenReader
//
//  Created by shine on 5/28/21.
//
/*
import Foundation

func printChart (chart: [[Int]]) {
    for y in 0...(20 - 1) {
        var str: String = ""
        for x in 0...(10 - 1) {
            if chart[y][x] >= 0 {
                str += " "
            }
            str += "\(chart[y][x])"
        }
        print(str)
    }
    print()
}

class TetrisCoordinator {
    
    let windowPos: CGPoint
    let previewCorner: CGPoint
    let blockSize: Int = 48
    let topCorner: CGPoint
    let bottomCorner: CGPoint
    var currentPiece: Int = -1
    var holdPiece: Int = -1
    var previewPieces: [Int] = [-1,-1,-1,-1,-1]
    var chart: [[Int]] = []
    var gameOver: Bool = false
    
    init (bitmap: Bitmap, windowPos: CGPoint) {
        
        let topCorner = TetrisGetTopCorner(bitmap: bitmap)
        let bottomCorner = TetrisGetBottomCorner(bitmap: bitmap, tC: topCorner);
        let previewCorner = TetrisGetPreviewCorner(tC: topCorner, bitmap: bitmap)

        self.windowPos = windowPos
        self.topCorner = topCorner
        self.bottomCorner = bottomCorner;
        self.previewCorner = previewCorner
        
        for _ in 0...(20 - 1) {
            var container: [Int] = []
            for _ in 0...(10 - 1) {
                container.append(0)
            }
            chart.append(container)
        }
    }
    

    
    func initPieces (bitmap: Bitmap) {

        currentPiece = getCurrentPiece(bitmap:bitmap, tC: topCorner)
        
        for i in 0..<5 {
            let corner = CGPoint(x: previewCorner.x, y: previewCorner.y + CGFloat(i * blockSize * 3))
            let piece: Int = TetrisGetPiece(bitmap: bitmap, refC: corner)
            previewPieces[i] = piece
        }

        for y in 0..<20 {
            for x in 0..<10 {
                    
                if (x >= 3 && x <= 6 && y == 0) {continue}
                    
                chart[y][x] = checkIfFilled(
                    bitmap: bitmap,
                    tC: topCorner,
                    x:x,
                    y:y,
                    cP: currentPiece
                )
            }
        }
    }
    
    func solve (bitmap: Bitmap) {
        
        var future: Future = Future()
        
        //future = TetrisSolver(chart: chart, pieces: [currentPiece, previewPieces[0]])
        
        if (holdPiece != -1) {
            let cfuture = TetrisSolver(
                chart: chart,
                pieces: [currentPiece, previewPieces[0]]
            )
            let hfuture = TetrisSolver(
                chart: chart,
                pieces: [holdPiece, previewPieces[0]]
            )
            if (cfuture.score > hfuture.score) {
                future = cfuture
            } else {
                future = hfuture
                future.instruction.instruction.insert(Keycode.c, at:0)
                swap(&holdPiece, &currentPiece)
            }
        } else {
            let cfuture = TetrisSolver(
                chart: chart,
                pieces: [currentPiece, previewPieces[0]]
            )
            let pfuture = TetrisSolver(
                chart: chart,
                pieces: [previewPieces[0], previewPieces[1]]
            )
            
            if (cfuture.score > pfuture.score) {
                future = cfuture
            } else {
                holdPiece = currentPiece
                currentPiece = previewPieces[0]
                previewPieces.remove(at: 0)
                previewPieces.append(-1)
                future = pfuture
                future.instruction.instruction.insert(Keycode.c, at:0)
            }
        }
        chart = future.chart
        future.instruction.execute()
    }
    
    func fetchPiece (bitmap: Bitmap) {
        currentPiece = previewPieces[0]
        
        for i in 0..<5 {
            let corner = CGPoint(x: previewCorner.x, y: previewCorner.y + CGFloat(i * blockSize * 3))
            let piece: Int = TetrisGetPiece(bitmap: bitmap, refC: corner)
            previewPieces[i] = piece
        }
    }
    
    func fetchChart (bitmap: Bitmap) {

        gameOver = true
        for y in 0..<20 {
            for x in 0..<10 {
                
                if (x >= 3 && x <= 6 && y == 0) {continue}
                
                chart[y][x] = checkIfFilled(
                    bitmap: bitmap,
                    tC: topCorner,
                    x:x,
                    y:y,
                    cP: currentPiece
                )
                if (chart[y][x] == 1) { // if it isn't a greyed out block
                    gameOver = false
                }
                if (chart[y][x] == -1) {
                    chart[y][x] = 1
                }
            }
        }
        if (gameOver) {
            return
        }
    }
    func fetchNext (bitmap: Bitmap) {
        
        fetchPiece(bitmap: bitmap)
        fetchChart(bitmap: bitmap)
    }
}
*/
