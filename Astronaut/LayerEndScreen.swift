//
//  LayerEndScreen.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 15/12/15.
//  Copyright © 2015 YaLu. All rights reserved.
//

import SpriteKit

class LayerEndScreen: SKNode {
    
    //Interface
    var totalScore = SKLabelNode(text: "")
    
    //Buttons
    var refresh = SKSpriteNode(imageNamed: "PlayButton32")
    var menu = SKSpriteNode(imageNamed: "MenuButton32")
    var gameShare = SKSpriteNode(imageNamed: "ShareButton18")
    
    //Vars
    var scalingFactor:CGFloat = 1
    
    override init() {
        super.init()
        
        if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
            scalingFactor = interScene.scalingfactoriPhone
        } else if interScene.deviceType == .IPadRetina || interScene.deviceType == .IPad {
            scalingFactor = interScene.scalingfactoriPad
        }
        
        refresh.setScale(scalingFactor)
        refresh.position = CGPoint(x: -(interScene.screenSize.width / 8), y: -(interScene.screenSize.height / 4.5))
        refresh.zPosition = 1.2
        refresh.texture?.filteringMode = .Nearest
        refresh.name = "refresh"
        addChild(refresh)
        
        menu.setScale(scalingFactor)
        menu.position = CGPoint(x: interScene.screenSize.width / 8, y: -(interScene.screenSize.height / 4.5))
        menu.zPosition = 1.2
        menu.texture?.filteringMode = .Nearest
        menu.name = "menu"
        addChild(menu)
        
        gameShare.setScale(scalingFactor)
        gameShare.position = CGPoint(x: 0, y: 0)
        gameShare.zPosition = 1.2
        gameShare.texture?.filteringMode = .Nearest
        gameShare.name = "share"
        addChild(gameShare)
        
        totalScore = SKLabelNode(fontNamed: "Minecraft")
        totalScore.fontSize = 15
        totalScore.fontColor = UIColor(rgba: "#5F6575")
        totalScore.position = CGPoint(x: 0, y: interScene.screenSize.height / 8)
        totalScore.zPosition = 1.2
        totalScore.setScale(scalingFactor)
        addChild(totalScore)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) hast not been implemented")
    }
    
}
