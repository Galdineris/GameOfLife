//
//  Cell.swift
//  Game Of Life
//
//  Created by Rafael Galdino on 31/10/19.
//  Copyright © 2019 Rafael Galdino. All rights reserved.
//

import SceneKit
import UIKit

class CellNode: SCNNode {
    var state: Int = 0
    var neighbors: Int = 0

    override init() {
        super.init()
    }

    init(radius: CGFloat, _ color: UIColor = .white) {
        super.init()
        let geometry = SCNSphere(radius: radius)
        geometry.materials.first?.diffuse.contents = color
        self.geometry = geometry
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
