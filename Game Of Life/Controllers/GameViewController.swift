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

    var gridSize: Int = 20
    var nodes: [CellNode] = []
    var gameOfLife: GameOfLifeLogic = GameOfLifeLogic()
    var scnView: SCNView?
    var scnScene: SCNScene?
    var cameraNode: SCNNode?
    var pauseButton: UIButton?
    var changeButton: UIButton?
    var resetButton: UIButton?
    var safeArea: UIEdgeInsets = UIEdgeInsets(top: 88,
                                              left: 44,
                                              bottom: 34,
                                              right: 44)
    var spawnTime: TimeInterval = 0
    var timeLoopSize: Float = 1
    var historyStacking: Bool = false
    var currentLayer: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        setupHUD()
        gameOfLife.newGame(size: gridSize)
        placeSpheres(matrix: gameOfLife.controlMatrix)
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
                    spawnTime += TimeInterval(timeLoopSize/1)
                    gameOfLife.changeState(of: tappedNode.location)
                    if gameOfLife.controlMatrix[tappedNode.location.x][tappedNode.location.y] != 0 {
                        tappedNode.color = UIColor.systemYellow
                    } else {
                        tappedNode.color = UIColor(red: 72, green: 72, blue: 74, alpha: 0.2)
                    }
                }
            }

        }
    }

    @objc
    func playBtnPress() {
        gameOfLife.paused.toggle()
        guard let safePauseBtn = pauseButton else {
            return
        }
        if gameOfLife.paused {
            safePauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            safePauseBtn.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        }
    }
    @objc
    func changeBtnPress() {
        historyStacking.toggle()
        guard let safeChangeBtn = changeButton else {
            return
        }
        if historyStacking {
            safeChangeBtn.setImage(UIImage(systemName: "hexagon.fill"), for: .normal)
        } else {
            safeChangeBtn.setImage(UIImage(systemName: "hexagon"), for: .normal)
        }
    }

    @objc
    func resetBtnPress() {
        historyStacking = false
        currentLayer = 0
        clearScene()
        gameOfLife.newGame(size: gridSize)
        placeSpheres(matrix: gameOfLife.controlMatrix)
        guard let safePauseBtn = pauseButton, let safeChangeBtn = changeButton else {
            return
        }
        safePauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        safeChangeBtn.setImage(UIImage(systemName: "hexagon"), for: .normal)
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
        safeScnView.showsStatistics = false

        // configure the view
        safeScnView.backgroundColor = UIColor.black
        safeScnView.autoenablesDefaultLighting = true

        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        safeScnView.addGestureRecognizer(tapGesture)
    }

    func setupHUD() {
        setupPauseButton()
        setupChangeButton()
        setupResetButton()
    }

    func setupPauseButton() {
        pauseButton = UIButton(frame: .zero)
        guard let safePauseBtn = pauseButton else {
            return
        }

        safePauseBtn.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        safePauseBtn.layer.cornerRadius = 10
        safePauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        safePauseBtn.tintColor = .white
        safePauseBtn.addTarget(self, action: #selector(playBtnPress), for: .touchDown)

        self.view.addSubview(safePauseBtn)

        safePauseBtn.translatesAutoresizingMaskIntoConstraints = false
        safePauseBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.safeArea.top).isActive = true
        safePauseBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        safePauseBtn.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.2).isActive = true
        safePauseBtn.heightAnchor.constraint(equalToConstant: self.view.frame.width * 0.2).isActive = true
    }

    func setupChangeButton() {
        changeButton = UIButton(frame: .zero)
        guard let safeChangeButton = changeButton else {
            return
        }

        safeChangeButton.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        safeChangeButton.layer.cornerRadius = 10
        safeChangeButton.setImage(UIImage(systemName: "hexagon"), for: .normal)
        safeChangeButton.tintColor = .white
        safeChangeButton.addTarget(self, action: #selector(changeBtnPress), for: .touchDown)

        self.view.addSubview(safeChangeButton)

        safeChangeButton.translatesAutoresizingMaskIntoConstraints = false
        if let safePauseBtn = pauseButton {
            safeChangeButton.topAnchor.constraint(equalTo: safePauseBtn.bottomAnchor,
                                              constant: self.view.frame.width * 0.04).isActive = true
        } else {
            safeChangeButton.topAnchor.constraint(equalTo: self.view.topAnchor,
                                              constant: self.safeArea.top).isActive = true
        }
        safeChangeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        safeChangeButton.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.2).isActive = true
        safeChangeButton.heightAnchor.constraint(equalToConstant: self.view.frame.width * 0.2).isActive = true
    }

    func setupResetButton() {
        resetButton = UIButton(frame: .zero)
        guard let safeResetButton = resetButton else {
            return
        }

        safeResetButton.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        safeResetButton.layer.cornerRadius = 10
        safeResetButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        safeResetButton.tintColor = .white
        safeResetButton.addTarget(self, action: #selector(resetBtnPress), for: .touchDown)

        self.view.addSubview(safeResetButton)

        safeResetButton.translatesAutoresizingMaskIntoConstraints = false
        if let safeChangeBtn = changeButton {
            safeResetButton.topAnchor.constraint(equalTo: safeChangeBtn.bottomAnchor,
                                              constant: self.view.frame.width * 0.04).isActive = true
        } else {
            safeResetButton.topAnchor.constraint(equalTo: self.view.bottomAnchor,
                                              constant: self.safeArea.bottom).isActive = true
        }
        safeResetButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        safeResetButton.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.2).isActive = true
        safeResetButton.heightAnchor.constraint(equalToConstant: self.view.frame.width * 0.2).isActive = true
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

    func placeSpheres(matrix: [[Int]], layer: CGFloat  = 0) {
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
                                           (radius * 5) * layer)
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
                node.color = UIColor(red: 72, green: 72, blue: 74, alpha: 0.2)
            }
        }
    }

    func clearScene() {
        guard let scene = scnScene else {
            return
        }
        scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > spawnTime && !gameOfLife.paused {
            gameOfLife.nextGen()
            spawnTime = time + TimeInterval(timeLoopSize/1)
            if self.historyStacking {
                self.currentLayer += 1
                placeSpheres(matrix: gameOfLife.controlMatrix, layer: CGFloat(currentLayer))
            } else {
                updateSpheres(matrix: gameOfLife.controlMatrix)
            }
        }
    }
}
