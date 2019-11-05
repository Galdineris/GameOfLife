//
//  GameLogic.swift
//  Game Of Life
//
//  Created by Rafael Galdino on 01/11/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import Foundation

class GameLogic {
    static var size: Int = 0
    static var controlMatrix: [[Int]] = [[0, 0, 0],
                                      [0, 1, 1],
                                      [0, 1, 1]]
    static var alive: [(Int, Int)] = []
    static var paused: Bool = true

    private static func createSqrMatrix() {
        controlMatrix = []
        for index in 0...size - 1 {
            controlMatrix.append([])
            for _ in 0...size - 1 {
                controlMatrix[index].append(0)
            }
        }
    }

    public static func newGame(size: Int) {
        self.size = size
        self.createSqrMatrix()
    }

    public static func nextGen() {
        for row in 0...size - 1 {
            for col in 0...size - 1 {
                switch getSum(of: (row, col)) {
                case 2...3:
                    if alive.firstIndex(where: { (location) -> Bool in
                        return (location.0 == row && location.1 == col)
                    }) == nil {
                        alive.append((row, col))
                    }
                default:
                    if let cellIndex = alive.firstIndex(where: { (location) -> Bool in
                        return (location.0 == row && location.1 == col)
                    }) {
                        alive.remove(at: cellIndex)
                    }
                }
            }
        }
        createSqrMatrix()
        for index in alive {
            controlMatrix[index.0][index.1] = 1
        }
    }

    private static func getSum(of location: (x: Int, y: Int)) -> Int {
        if location.x >= size || location.y >= size || location.x < 0 || location.y < 0 {
            return 0
        }
        var sum: Int = 0
        for row in location.x-1...location.x+1 {
            for col in location.y-1...location.y+1 where (row != location.x || col != location.y) {
                sum += getState(of: (row, col))
            }
        }
        return sum
    }

    private static func getState(of location: (x: Int, y: Int)) -> Int {
        if location.x >= size || location.y >= size || location.x < 0 || location.y < 0 {
            return 0
        }
        return controlMatrix[location.x][location.y]
    }

    public static func changeState(of location: (x: Int, y: Int)) {
        if location.x >= size || location.y >= size || location.x < 0 || location.y < 0 {
            return
        }
        controlMatrix[location.x][location.y] = abs(controlMatrix[location.x][location.y] - 1)
    }

//    private static func spill(of location: (x: Int, y: Int)) {
//        if location.x >= size || location.y >= size || location.x < 0 || location.y < 0 {
//            return
//        }
//        for row in location.x-1...location.x+1 {
//            for col in location.y-1...location.y+1 where (row != location.x && col != location.y) {
//                changeState(of: location, by: 1)
//            }
//        }
//    }
//
//    private static func drain(of location: (x: Int, y: Int)) {
//        if location.x >= size || location.y >= size || location.x < 0 || location.y < 0 {
//            return
//        }
//        for row in location.x-1...location.x+1 {
//            for col in location.y-1...location.y+1 where (row != location.x && col != location.y) {
//                changeState(of: location, by: -1)
//            }
//        }
//    }
}
