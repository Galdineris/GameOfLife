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
    var location: (Int, Int) = (0, 0)
    var color: UIColor = UIColor.systemGray {
        didSet {
            DispatchQueue.main.async {
                self.updateColor()
            }
        }
    }

    override init() {
        super.init()
    }

    init(radius: CGFloat) {
        super.init()
        let geometry = SCNSphere(radius: radius)
        self.geometry = geometry
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func updateColor() {
        if let geo = self.geometry, let first = geo.materials.first {
            first.diffuse.contents = self.color
        }
    }
}
