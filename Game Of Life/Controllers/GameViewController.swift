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
    var pauseButton: UIButton?
    var safeArea: UIEdgeInsets = UIEdgeInsets(top: 88, left: 44, bottom: 34, right: 44)
    var spawnTime: TimeInterval = 0
    var timeLoopSize: Float = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()

        // create a new scene
        setupView()
        setupScene()
        setupCamera()
        setupHUD()
        GameLogic.newGame(size: 100)
        placeSpheres(matrix: GameLogic.controlMatrix)
    }

    override func viewSafeAreaInsetsDidChange() {
        safeArea = self.view.safeAreaInsets
    }

    @objc
    func handleTap(_ gestureRecognized: UIGestureRecognizer) {
        // retrieve the SCNView
        guard let scnView = scnView else {
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
                    spawnTime += TimeInterval(1/timeLoopSize)
                    GameLogic.changeState(of: tappedNode.location)
                    if GameLogic.controlMatrix[tappedNode.location.x][tappedNode.location.y] != 0 {
                        tappedNode.color = UIColor.systemYellow
                    } else {
                        tappedNode.color = UIColor.systemGray
                    }
                }
            }

        }
    }

    @objc
    func buttonPress() {
        GameLogic.paused.toggle()
        guard let safePauseBtn = pauseButton else {
            return
        }
        if safePauseBtn.titleLabel?.text == "Start"{
            safePauseBtn.setTitle("Stop", for: .normal)
        } else {
            safePauseBtn.setTitle("Start", for: .normal)
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

extension GameViewController {
    func setupView() {
        // unwrap the SCNView
        scnView = SCNView(frame: self.view.frame)

        guard let safeScnView = scnView else {
            return
        }

        self.view = safeScnView
        safeScnView.delegate = self
        safeScnView.loops = true
        safeScnView.isPlaying = true

        // allows the user to manipulate the camera
        safeScnView.allowsCameraControl = true

        // show statistics such as fps and timing information
        safeScnView.showsStatistics = true

        // configure the view
        safeScnView.backgroundColor = UIColor.white
        safeScnView.autoenablesDefaultLighting = true

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        safeScnView.addGestureRecognizer(tapGesture)
    }

    func setupHUD() {
        setupPauseButton()
    }

    func setupPauseButton(){
        pauseButton = UIButton(frame: .zero)
        guard let safePauseBtn = pauseButton else {
            return
        }

        safePauseBtn.backgroundColor = UIColor(white: 0.0, alpha: 1)
        safePauseBtn.layer.cornerRadius = 10
        safePauseBtn.setTitle("Start", for: .normal)
        safePauseBtn.titleLabel?.textColor = .white
        safePauseBtn.addTarget(self, action: #selector(buttonPress), for: .touchDown)

        self.view.addSubview(safePauseBtn)

        safePauseBtn.translatesAutoresizingMaskIntoConstraints = false
        safePauseBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.safeArea.top).isActive = true
        safePauseBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        safePauseBtn.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.2).isActive = true
        safePauseBtn.heightAnchor.constraint(equalToConstant: self.view.frame.width * 0.2).isActive = true
    }

    func setupScene() {
        // Create Scene Object
        scnScene = GameOfLifeScene()
        // unwrap the SCNView
        guard let scnView = scnView, let scene = scnScene else {
            return
        }

        // set the scene to the view
        scnView.scene = scene
    }

    func setupCamera() {
        // unwrap the cameraNode
        guard let safeScnView = scnView else {
            return
        }
        cameraNode = safeScnView.pointOfView
        guard let camera = cameraNode else {
            return
        }
        camera.position = SCNVector3(0, 0, 30)
    }

    func placeSpheres(matrix: [[Int]]) {
        nodes = []
        let radius: CGFloat = 0.5
        let dislocation: CGFloat = ((radius * 2) * CGFloat(matrix.count)) * CGFloat(sqrtf(2))/2
        guard let scene = scnScene else {
            return
        }
        for row in 0...matrix.count - 1 {
            for col in 0...matrix[0].count - 1 {
                let cell = CellNode(radius: CGFloat(radius))
                cell.location = (row, col)
                nodes.append(cell)
                cell.position = SCNVector3((CGFloat(col) * radius * 2.5) - dislocation,
                                           (CGFloat(row) * radius * 2.5) - dislocation,
                                           0)
                scene.rootNode.addChildNode(cell)
            }
        }
        updateSpheres(matrix: matrix)
    }

    func updateSpheres(matrix: [[Int]]) {
        for node in nodes {
            if matrix[node.location.x][node.location.y] != 0 {
                node.color = UIColor.systemYellow
            } else {
                node.color = UIColor.systemGray
            }
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > spawnTime && !GameLogic.paused {
            GameLogic.nextGen()
            updateSpheres(matrix: GameLogic.controlMatrix)
            spawnTime = time + TimeInterval(timeLoopSize/1)
        }
    }
}
