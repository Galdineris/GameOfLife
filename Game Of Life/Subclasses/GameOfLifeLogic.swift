//
//  GameLogic.swift
//  Game Of Life
//
//  Created by Rafael Galdino on 01/11/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import Foundation
import SceneKit

struct Cell: Hashable, Equatable {
    var xIndex: Int = 0
    var yIndex: Int = 0
    init(_ xIndex: Int, _ yIndex: Int) {
        self.xIndex = xIndex
        self.yIndex = yIndex
    }
}

class GameOfLifeLogic {
    var size: Int = 0
    var controlMatrix: [[Int]] = [[0, 0, 0],
                                  [0, 0, 0],
                                  [0, 0, 0]]
    var liveCells: Set<Cell> = Set()
    var paused: Bool = true

    private func createSqrMatrix() {
        self.controlMatrix = []
        for index in 0...size - 1 {
            controlMatrix.append([])
            for _ in 0...size - 1 {
                controlMatrix[index].append(0)
            }
        }
    }

    public func newGame(size: Int) {
        self.size = size
        self.createSqrMatrix()
        self.paused = true
    }

    public func nextGen() {
        var neighbors: Int = 0
        for cell in liveCells {
            for row in (cell.xIndex - 1)...(cell.xIndex + 1) {
                for col in ((cell.yIndex - 1)...(cell.yIndex + 1)) {
                    neighbors = getSum(of: (row, col))
                    if neighbors == 3 {
                        liveCells.insert(Cell(row, col))
                    } else if neighbors == 2 && controlMatrix[row][col] == 1 {
                        liveCells.insert(Cell(row, col))
                    } else {
                        liveCells.remove(Cell(row, col))
                    }
                }
            }
        }
        createSqrMatrix()
        for cell in liveCells {
            controlMatrix[cell.xIndex][cell.yIndex] = 1
        }
    }

    private func getSum(of location: (x: Int, y: Int)) -> Int {
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

    private func getState(of location: (x: Int, y: Int)) -> Int {
        if location.x >= size || location.y >= size || location.x < 0 || location.y < 0 {
            return 0
        }
        return controlMatrix[location.x][location.y]
    }

    public func changeState(of location: (x: Int, y: Int)) {
        if location.x >= size || location.y >= size || location.x < 0 || location.y < 0 {
            return
        }
        switch controlMatrix[location.x][location.y] {
        case 0:
            controlMatrix[location.x][location.y] = 1
            liveCells.insert(Cell(location.x, location.y))
        default:
            controlMatrix[location.x][location.y] = 0
            liveCells.remove(Cell(location.x, location.y))
        }
    }
}
