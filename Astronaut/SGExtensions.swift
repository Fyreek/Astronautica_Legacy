//
//  SGExtensions.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 09/12/15.
//  Copyright © 2015 YaLu. All rights reserved.
//

import SpriteKit

extension SKNode {

    func distanceBetweenX(locationX: CGFloat) -> CGFloat {
        let distanceX = abs(self.position.x - locationX)
        return distanceX
    }
    
    func distanceBetweenY(locationY: CGFloat) -> CGFloat {
        let distanceY = abs(self.position.y - locationY)
        return distanceY
    }
    
    
    
}

extension Array {
    func find(includedElement: Element -> Bool) -> Int?{
        for (idx, element) in self.enumerate() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}