//
//  GameLogic.swift
//  Game Of Life
//
//  Created by Rafael Galdino on 01/11/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import Foundation
import SceneKit

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
        var neighbors: Int = 0
        alive = []
        for row in 0...size - 1 {
            for col in 0...size - 1 {
                neighbors = getSum(of: (row, col))
                if neighbors == 3 {
                    alive.append((row, col))
                } else if neighbors == 2 && controlMatrix[row][col] == 1 {
                    alive.append((row, col))
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
            for col in location.y-1...location.y+1 {
                sum += getState(of: (row, col))
            }
        }
        sum -= controlMatrix[location.x][location.y]
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
        switch controlMatrix[location.x][location.y] {
        case 0:
            controlMatrix[location.x][location.y] = 1
            alive.append(location)
        default:
            controlMatrix[location.x][location.y] = 0
            if let first = alive.firstIndex(where: { (place) -> Bool in
                return place == location
            }) {
                alive.remove(at: first)
            }
        }
    }
}
