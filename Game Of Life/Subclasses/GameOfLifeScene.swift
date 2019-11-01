//
//  GameOfLifeScene.swift
//  Game Of Life
//
//  Created by Rafael Galdino on 31/10/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import SceneKit
import UIKit

class GameOfLifeScene: SCNScene {
    override init() {
        super.init()
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        self.rootNode.addChildNode(cameraNode)

        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        if let light = lightNode.light {
            light.type = .omni
        }
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)

        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        if let light = ambientLightNode.light {
            light.type = .ambient
            light.color = UIColor.darkGray
        }

        self.rootNode.addChildNode(lightNode)
        self.rootNode.addChildNode(ambientLightNode)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
