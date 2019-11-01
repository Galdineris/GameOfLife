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

    var scnView: SCNView?
    var scnScene: SCNScene?
    var cameraNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new scene
        setupView()
        setupScene()
        setupCamera()
        placeSpheres(matrix: globalMatrix)
    }

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
        scnView.backgroundColor = UIColor.black
        scnView.autoenablesDefaultLighting = true

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }

    func setupScene() {
        // Create Scene Object
        scnScene = GameOfLifeScene()
        // unwrap the SCNView
        guard let scnView = self.view as? SCNView, let scene = scnScene else {
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
        let radius: Int = 1
        var color: UIColor = .white
        guard let scene = scnScene else {
            return
        }
        for col in 0...matrix.count - 1 {
            for row in 0...matrix[0].count - 1 {
                if matrix[row][col] == 1 {
                    color = UIColor.blue
                } else {
                    color = UIColor.orange
                }
                let cell = CellNode(radius: CGFloat(radius), color)
                cell.position = SCNVector3(col * radius * 3, row * radius * 3, 0)
                scene.rootNode.addChildNode(cell)
            }
        }
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        guard let scnView = self.view as? SCNView else {
            return
        }

        // check what nodes are tapped
        let tappedNodes = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(tappedNodes, options: [:])
        // check that we clicked on at least one object
        if !hitResults.isEmpty {
            // retrieved the first clicked object
            _ = hitResults[0]
        }
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
