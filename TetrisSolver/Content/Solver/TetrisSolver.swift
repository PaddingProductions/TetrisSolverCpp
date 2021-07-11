//
//  TetrisSimulator.swift
//  ScreenReader
//
//  Created by shine on 6/17/21.
//
/*
import Foundation
import Dispatch

// Rotation 0 = origin, clockwise
struct Future {
    init () {}
    init (chart: [[Int]]) {
        self.chart = chart
    }
    var chart: [[Int]] = []
    var instruction: TetrisInstruction = TetrisInstruction()
    var impossible = false
    var score: Int = 0
    var clears: Int = 0
    var holes: Int = 0
    var downstack: Bool = false
}

struct Present {
    init (chart: [[Int]]) {
        var maxH = -1
        self.chart = chart
        // average height
        for x in 0..<10 {
            var height = -1
            for y in 0..<20 {
                if (chart[y][x] == 1) {
                    height = 20 - y
                    break
                }
            }
            maxH = max( maxH, height )
        }

        if (maxH >= 15) {
            critical = true
        }
        self.maxH = maxH

    }
    var chart: [[Int]]
    var holes: Int = 0
    var critical: Bool = false
    let maxH : Int
}


func TetrisSolver (chart: [[Int]], pieces: [Int]) -> Future {
    
    func grader (future: inout Future) -> Int {
        graderRunCount += 1
        let chart = future.chart
        var score: Int = 1000000
        var heights: [Int] = []
        var avgH: Int = 0
        var maxH: Int = -1
        

        for x in 0..<10 {
            var height = -1
            for y in 0..<20 {
                if (chart[y][x] == 1) {
                    height = max(height, 20 - y)
                }
                if (chart[y][x] == 0 && height != -1) {
                    if (!future.downstack) { // if you just switched from attacking to ds, increase penalty for hole
                        score -= 1000
                    }
                    score -= 100    // reduce score if hole
                    future.holes += 1
                    
                    var weight = 5 * max(0, 5 - abs( avgH - (20 - y) ))
                    if (future.downstack) {weight *= 2}
                    score -= weight * (height - (20 - y)) // reduce score for block ontop of hole
                    future.downstack = true
                }
            }
            heights.append(height)
            avgH += height
            maxH = max (height, maxH)
        }
        avgH /= 10

        // if in safe condition, try to do b2b tetris spam
        if (!future.downstack) {
            if (heights[0] != 0) {
                //future.impossible = true
            }
            if (future.clears == 4) {
                score += 100
            } else if (future.clears > 0) {
                score -= 40
            }
        } else {
            score += future.clears * 5
            score += (present.maxH - maxH) * 10
        }
        
        
        var total = 0
        var prevValue = heights[0]
        for x in 1..<10 {
            let diff = heights[x] - prevValue
            total += abs( diff ) * abs( diff )         // difference from previous
            prevValue = heights[x]
            
            score -= abs(heights[x] - avgH) * 5 // flat stack
        }
        score -= total * 5
        
        
        return score
    }
    
    func addToChart (chart: inout [[Int]], piece: Piece) -> Bool {
        
        for  y in 0 ..< piece.map.count {
            for  x in 0 ..< piece.map[y].count {  // for all nodes
                let currX = piece.x + x - piece.centerX;
                let currY = piece.y + y - piece.centerY;
                
                if (currX < 0 || currY < 0 || currX >= 10 || currY >= 20) {
                    if (piece.map[y][x] == 1) {
                        return false
                    } else {
                        continue
                    }
                 }
                if (piece.map[y][x] == 1) {
                    chart[currY][currX] = 1
                }
            }
        }
        return true
    }

    func findDropLocation (chart: [[Int]], piece: inout Piece) {
        
        while (checkOverlap(chart: chart, piece: piece)) {
            piece.y += 1;
        }
        piece.y -= 1;
    }

    func checkOverlap (chart: [[Int]], piece: Piece) -> Bool {
        for  y in 0...(piece.map[0].count - 1) {
            for  x in 0...(piece.map[y].count - 1) {  // for all nodes
                
                if (piece.map[y][x] == 0) {continue;} // no need to process empty nodes
            
                let currX = piece.x + x - piece.centerX;
                let currY = piece.y + y - piece.centerY;

                if (currY < 0) { continue; } // if out of bounds on top, which can be ignored
                if (currX < 0 || currX >= 10 || currY >= 20) {
                    return false;
                }
                if (chart[currY][currX] == 1) {
                    return false;
                }
            }
        }
        return true;
    }
    
    func clear (chart: inout [[Int]]) -> Int {
        var clears = 0
        for y in 0..<20 {
            var clear = true
            for x in 0..<10 {
                if (chart[y][x] == 0) {
                    clear = false
                    break
                }
            }
            if (clear) {
                clears += 1
                chart.remove(at: y)
                chart.insert([0,0,0,0,0,0,0,0,0,0],at: 0)
            }
        }
        return clears
    }
    
    func predict (chart: [[Int]], pieceID: Int) -> [Future]{
        var futures: [Future] = []
        var size = 40
        //if (pieceID == 6) {size = 10}
        //if (pieceID == 5) {size = 20}

        for _ in 0..<size {  futures.append(Future(chart:chart)) }
        
        for r in 0..<4 {
            //if (r != 0 && pieceID == 6) {continue}
            //if (r >= 2 && pieceID == 5) {continue}
            
            for x in 0..<10 {
                let i = r * 10 + x
                
                var piece = Piece(id: pieceID, x: x, r: r)
                findDropLocation(chart: chart, piece: &piece)
                
                if (!addToChart(chart: &futures[i].chart, piece: piece)) {
                    futures[i].impossible = true
                    continue
                }
                futures[i].clears = clear(chart: &futures[i].chart)
                futures[i].instruction = TetrisInstruction(r:r, x:x)
            }
        }
        return futures
    }
    
    func solve (chart: [[Int]], pieces: [Int], index: Int) -> Future {
        
        var children = predict(chart: chart, pieceID: pieces[index])
        
        if (index != pieces.count - 1) {
            for i in 0..<children.count {
                let result = solve(chart: children[i].chart, pieces: pieces, index: index+1)
                children[i].score = result.score
            }
        } else {
            for i in 0..<children.count {
                if (children[i].impossible) {continue}
                children[i].score = grader(future: &children[i])
            }
        }
        
        var highestScore: Int = -1000000  // highest score
        var best: Int = -1    // index of best future (can be reverse-engineered into command)
        
        for i in 0..<children.count {
            if (children[i].impossible) {continue}
            if (children[i].score > highestScore) {
                highestScore = children[i].score
                best = i
            }
        }
        return children[best]
    }
    var graderRunCount = 0
    
    let present = Present(chart: chart)
    let start = DispatchTime.now()
    let result =  solve(chart: chart, pieces: pieces, index: 0)
    let end = DispatchTime.now()
    
    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000
    print("current piece \(pieces[0])")
    print("solver took \(timeInterval) seconds, calling \(graderRunCount) grades, resulting in \(result.holes) holes" )
    printChart(chart: result.chart)
    return result
}
*/
