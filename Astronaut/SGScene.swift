//
//  SGScene.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 09/12/15.
//  Copyright © 2015 YaLu. All rights reserved.
//

import SpriteKit

class SGScene: SKScene {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in  touches {
            let location = touch.locationInNode(self)
            screenInteractionStarted(location)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in  touches {
            let location = touch.locationInNode(self)
            screenInteractionMoved(location)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in  touches {
            let location = touch.locationInNode(self)
            screenInteractionEnded(location)
        }
    }
    
    func screenInteractionStarted(location: CGPoint) {
    }
    
    func screenInteractionMoved(location: CGPoint) {
    }
    
    func screenInteractionEnded(location: CGPoint) {
    }
    
}
