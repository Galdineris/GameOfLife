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

    init(size: CGFloat) {
        super.init()
        self.geometry = SCNSphere(radius: size)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
