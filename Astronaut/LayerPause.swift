//
//  LayerPause.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 15/12/15.
//  Copyright © 2015 YaLu. All rights reserved.
//

import SpriteKit

class LayerPause : SKNode {
    
    
    //Buttons
    var gamePlay = SKSpriteNode(imageNamed: "PlayButton32")
    var menuPause = SKSpriteNode(imageNamed: "MenuButton32")
    
    //Vars
    var scalingFactor:CGFloat = 1
    
    override init() {
        super.init()

        if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
            scalingFactor = interScene.scalingfactoriPhone
        } else if interScene.deviceType == .IPadRetina || interScene.deviceType == .IPad {
            scalingFactor = interScene.scalingfactoriPad
        }
        
        gamePlay.setScale(scalingFactor)
        //gamePlay.position.x = -(self.size.width / 8)
        gamePlay.position = CGPoint(x: -(interScene.screenSize.width / 8), y: 0)
        gamePlay.zPosition = 1.2
        gamePlay.texture?.filteringMode = .Nearest
        gamePlay.name = "gamePlay"
        addChild(gamePlay)
        
        menuPause.setScale(scalingFactor)
        //menuPause.position.x = self.size.width / 8
        menuPause.position = CGPoint(x: interScene.screenSize.width / 8, y: 0)
        menuPause.zPosition = 1.2
        menuPause.texture?.filteringMode = .Nearest
        menuPause.name = "menuPause"
        addChild(menuPause)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
    
}
