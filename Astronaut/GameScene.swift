//
//  GameScene.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	
	var startGameButton = SKSpriteNode(imageNamed: "GameButton32")
	var nameLabel = SKSpriteNode(imageNamed: "Astronautica32")
	var menuOptionButton = SKSpriteNode(imageNamed: "SettingsButton32")
	var menuHSButton = SKSpriteNode(imageNamed: "LeaderboardsButton32")
	var highScoreLabel = SKLabelNode(text: "Highscore: 0")
	let bg = SKSpriteNode(imageNamed: "Background188")
	var highScore:Int = 0
	let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 0.2, duration: 0.2)
    
	override func didMoveToView(view: SKView) {
        
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
		highScoreLabel.text = "Highscore: " + String(highScore)
		
		addChild(bg)
		bg.zPosition = 1.0
		addChild(nameLabel)
		nameLabel.position.x = 0
		nameLabel.position.y = (self.size.height / 4.5)
		nameLabel.zPosition = 1.1
		
		addChild(startGameButton)
		startGameButton.name = "startGameButton"
		startGameButton.hidden = false
		startGameButton.position.y = -(self.size.height / 4.5)
		startGameButton.position.x = 0
		startGameButton.zPosition = 1.1
		
		addChild(highScoreLabel)
		highScoreLabel.hidden = false
		highScoreLabel.position.x = 0
		highScoreLabel.position.y = -(self.size.height / 36)
		highScoreLabel.zPosition = 1.1
		highScoreLabel.setScale(1)
		highScoreLabel.alpha = 0.3
		highScoreLabel.fontColor = UIColor.whiteColor()
		
		addChild(menuOptionButton)
		menuOptionButton.name = "menuOptionButton"
		menuOptionButton.hidden = false
		menuOptionButton.position.y = -(self.size.height / 4.5)
		menuOptionButton.position.x = self.size.width / 3
		menuOptionButton.zPosition = 1.1
		
		addChild(menuHSButton)
		menuHSButton.name = "menuHSButton"
		menuHSButton.hidden = false
		menuHSButton.position.y = -(self.size.height / 4.5)
		menuHSButton.position.x = -(self.size.width / 3)
		menuHSButton.zPosition = 1.1
		
	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
			let location = touch.locationInNode(self)
			if self.nodeAtPoint(location) == self.startGameButton {
                self.startGameButton.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.menuHSButton {
                self.menuHSButton.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.menuOptionButton {
                self.menuOptionButton.runAction(buttonPressDark)
            }
        }
	}
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.startGameButton {
                self.startGameButton.runAction(buttonPressLight){
                    self.showPlayScene()
                }
                
            } else if self.nodeAtPoint(location) == self.menuHSButton {
                self.menuHSButton.runAction(buttonPressLight){
                    EasyGameCenter.showGameCenterLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard")
                }
            } else if self.nodeAtPoint(location) == self.menuOptionButton {
                self.menuOptionButton.runAction(buttonPressLight) {
                    self.showOptionScene()
                }
                
                
            }
        }
        
    }
	
    func showOptionScene() {
    
        let transition = SKTransition.fadeWithDuration(1)
        var scene = OptionScene(size: self.size)
        let skView = self.view as SKView!
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.size = skView.bounds.size
        scene.optionSceneActive = true
        skView.presentScene(scene, transition: transition)

        
    }
    
	func showPlayScene() {
        
        let transition = SKTransition.fadeWithDuration(1)
        var scene = PlayScene(size: self.size)
        let skView = self.view as SKView!
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.size = skView.bounds.size
        scene.playSceneActive = true
        skView.presentScene(scene, transition: transition)
        
	}
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
	}
	
}