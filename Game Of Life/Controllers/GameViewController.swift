//
//  GameViewController.swift
//  Game Of Life
//
//  Created by Rafael Galdino on 31/10/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var globalMatrix: [[Int]] = [[1, 0, 0],
                                 [0, 1, 0],
                                 [0, 0, 1]]
    var nodes: [CellNode] = []
    var scnView: SCNView?
    var scnScene: SCNScene?
    var cameraNode: SCNNode?
    var spawnTime: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new scene
        setupView()
        setupScene()
        setupCamera()
        GameLogic.newGame(size: 10)
        placeSpheres(matrix: GameLogic.controlMatrix)
    }

    @objc
    func handleTap(_ gestureRecognized: UIGestureRecognizer) {
        // retrieve the SCNView
        guard let scnView = self.view as? SCNView else {
            return
        }
        // check if tap has ended
        if gestureRecognized.state == .ended {
            // check what nodes are tapped
            let tapLocation: CGPoint = gestureRecognized.location(in: scnView)
            let hitResults = scnView.hitTest(tapLocation, options: [:])
            if !hitResults.isEmpty {
                // retrieved the first clicked object
                if let tappedNode = hitResults[0].node as? CellNode {
                    GameLogic.changeState(of: tappedNode.location)
                    placeSpheres(matrix: GameLogic.controlMatrix)
                }
                
            }
        }

        // check that we clicked on at least one object
    }
    override var shouldAutorotate: Bool {
        return false
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}

extension GameViewController {
    func setupView() {
        // unwrap the SCNView
        guard let scnView = self.view as? SCNView else {
            return
        }
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true

        // show statistics such as fps and timing information
        scnView.showsStatistics = true

        // configure the view
        scnView.backgroundColor = UIColor.white
        scnView.autoenablesDefaultLighting = true

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }

    func setupScene() {
        // Create Scene Object
        scnScene = GameOfLifeScene()
        // unwrap the SCNView
        guard
            let scnView = self.view as? SCNView,
            let scene = scnScene
            else {
            return
        }
        // set the scene to the view
        scnView.scene = scene
    }

    func setupCamera() {
        // unwrap the cameraNode
        guard let scnView = self.view as? SCNView else {
            return
        }
        cameraNode = scnView.pointOfView
        guard let camera = cameraNode else {
            return
        }
        camera.position = SCNVector3(0, 0, 30)
    }

    func placeSpheres(matrix: [[Int]]) {
        for node in nodes {
            node.removeFromParentNode()
        }
        nodes = []
        let radius: CGFloat = 0.5
        var color: UIColor = .white
        guard let scene = scnScene else {
            return
        }
        for row in 0...matrix.count - 1 {
            for col in 0...matrix[0].count - 1 {
                if matrix[row][col] == 0 {
                    color = UIColor.systemGray
                } else {
                    color = UIColor.systemYellow
                }
                let cell = CellNode(radius: CGFloat(radius))
                cell.location = (row, col)
                nodes.append(cell)
                cell.color = color
                cell.position = SCNVector3(CGFloat(col) * radius * 2.5, CGFloat(row) * radius * 2.5, 0)
                scene.rootNode.addChildNode(cell)
            }
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > spawnTime && !GameLogic.paused {
            GameLogic.nextGen()
            placeSpheres(matrix: GameLogic.controlMatrix)
            spawnTime = time + TimeInterval(1.0)
        }
    }
}
