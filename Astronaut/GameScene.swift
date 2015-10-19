//
//  GameScene.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit
import iAd

class GameScene: SKScene, EGCDelegate {
    
    var startGameButton = SKSpriteNode(imageNamed: "GameButton32")
	var nameLabel = SKSpriteNode(imageNamed: "Astronautica32")
	var menuOptionButton = SKSpriteNode(imageNamed: "SettingsButton32")
	var menuHSButton = SKSpriteNode(imageNamed: "LeaderboardsButton32")
	var highScoreLabel = SKLabelNode(text: "Highscore: 0")
	let bg = SKSpriteNode(imageNamed: "Background188")
    var ticks:Int = 0
	var highScore:Int = 0
    var highScoreBefore:Int = 0
	let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 0, duration: 0.2)
    var lastSpriteName:String = ""
    var scalingFactor:CGFloat = 1
    var scalingFactorX:CGFloat = 1
    var tickCount:Int = 0
    
	override func didMoveToView(view: SKView) {
        
        showAds()
        loadSoundState()
        
        scalingFactor = (self.size.height * 2) / 640 //iPhone 5 Height, so iPhone 5 has original scaled sprites.
        scalingFactorX = self.size.width / (nameLabel.size.width + 20)
        
        bg.setScale(scalingFactor)
        
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
		highScoreLabel = SKLabelNode(fontNamed: "Minecraft")
		highScoreLabel.fontSize = 18
		highScoreLabel.text = "Highscore: " + String(highScore)
		
		addChild(bg)
		bg.zPosition = 1.0
		nameLabel.position.x = 0
		nameLabel.position.y = (self.size.height / 4.5)
        nameLabel.zPosition = 1.2
        if nameLabel.size.width > self.size.width {
            nameLabel.setScale(scalingFactorX)
        } else {
            nameLabel.setScale(scalingFactor)
        }
        addChild(nameLabel)
        
        startGameButton.setScale(scalingFactor)
		addChild(startGameButton)
		startGameButton.name = "startGameButton"
		startGameButton.hidden = false
		startGameButton.position.y = -(self.size.height / 4.5)
		startGameButton.position.x = 0
		startGameButton.zPosition = 1.2
		
        highScoreLabel.setScale(scalingFactor)
		addChild(highScoreLabel)
		highScoreLabel.hidden = false
		highScoreLabel.position.x = 0
		highScoreLabel.position.y = -(self.size.height / 36)
		highScoreLabel.zPosition = 1.2
		highScoreLabel.setScale(1)
		highScoreLabel.alpha = 0.3
		highScoreLabel.fontColor = UIColor(rgba: "#d7d7d7") //will fix later
		
        menuOptionButton.setScale(scalingFactor)
		addChild(menuOptionButton)
		menuOptionButton.name = "menuOptionButton"
		menuOptionButton.hidden = false
		menuOptionButton.position.y = -(self.size.height / 4.5)
		menuOptionButton.position.x = self.size.width / 3
		menuOptionButton.zPosition = 1.2
		
        menuHSButton.setScale(scalingFactor)
		addChild(menuHSButton)
		menuHSButton.name = "menuHSButton"
		menuHSButton.hidden = false
		menuHSButton.position.y = -(self.size.height / 4.5)
		menuHSButton.position.x = -(self.size.width / 3)
		menuHSButton.zPosition = 1.2
		
	}
    
    func showAds(){
    
        NSNotificationCenter.defaultCenter().postNotificationName("showadsID", object: nil)
        
    }
    
    func hideAds(){
    
        NSNotificationCenter.defaultCenter().postNotificationName("hideadsID", object: nil)
    
    }
    
    func loadSoundState() {
        interScene.soundState = NSUserDefaults.standardUserDefaults().boolForKey("soundBool")
        interScene.musicState = NSUserDefaults.standardUserDefaults().boolForKey("musicBool")
    }
    
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
			let location = touch.locationInNode(self)
			if self.nodeAtPoint(location) == self.startGameButton {
                lastSpriteName = self.startGameButton.name!
                self.startGameButton.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.menuHSButton {
                lastSpriteName = self.menuHSButton.name!
                self.menuHSButton.runAction(buttonPressDark){
                }
            } else if self.nodeAtPoint(location) == self.menuOptionButton {
                lastSpriteName = self.menuOptionButton.name!
                self.menuOptionButton.runAction(buttonPressDark)
            }
        }
	}
    
    func removeButtonAnim() {
    
        if lastSpriteName == self.startGameButton.name  {
            
            startGameButton.removeAllActions()
            startGameButton.runAction(buttonPressLight)
        
        } else if lastSpriteName == self.menuHSButton.name  {
        
            menuHSButton.removeAllActions()
            menuHSButton.runAction(buttonPressLight)
        
        } else if lastSpriteName == self.menuOptionButton.name {
        
            menuOptionButton.removeAllActions()
            menuHSButton.runAction(buttonPressLight)
            
        }
    
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.nodeAtPoint(location) == self.startGameButton {
                removeButtonAnim()
                if lastSpriteName == startGameButton.name {
                    self.startGameButton.runAction(buttonPressLight){
                        self.showPlayScene()
                    }
                }
            } else if self.nodeAtPoint(location) == self.menuHSButton {
                removeButtonAnim()
                if lastSpriteName == menuHSButton.name {
                    self.menuHSButton.runAction(buttonPressLight){
                        EGC.showGameCenterLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard")
                    }
                }
            } else if self.nodeAtPoint(location) == self.menuOptionButton {
                removeButtonAnim()
                if lastSpriteName == menuOptionButton.name {
                    self.menuOptionButton.runAction(buttonPressLight) {
                        self.showOptionScene()
                    }
                }
            } else  {
        
                menuHSButton.removeAllActions()
                menuOptionButton.removeAllActions()
                startGameButton.removeAllActions()
                
                self.menuHSButton.runAction(buttonPressLight)
                self.menuOptionButton.runAction(buttonPressLight)
                self.startGameButton.runAction(buttonPressLight)
                
            }
        }
        
    }
	
    func showOptionScene() {
        
        let transition = SKTransition.fadeWithDuration(1)
        let scene = OptionScene(size: self.size)
        let skView = self.view as SKView!
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.size = skView.bounds.size
        scene.optionSceneActive = true
        skView.presentScene(scene, transition: transition)

        
    }
    
	func showPlayScene() {
        
        hideAds()
        
        let transition = SKTransition.fadeWithDuration(1)
        let scene = PlayScene(size: self.size)
        let skView = self.view as SKView!
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.size = skView.bounds.size
        skView.presentScene(scene, transition: transition)
        
        scene.scoreBefore = highScore
        
	}
	
	override func update(currentTime: CFTimeInterval) {
        if ticks == 20 {
            highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
            if highScore > highScoreBefore {
        
                highScoreLabel.text = "Highscore: " + String(highScore)
            
            }
            
            highScoreBefore = highScore
            ticks = 0
        }
        ticks = ticks + 1
	}
	
}