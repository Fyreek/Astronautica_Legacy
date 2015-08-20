//
//  GameScene.swift
//  Astronaut
//
//  Created by Luca Friedrich on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	
	var startGameNormalButton = SKSpriteNode(imageNamed: "buttontest")
	var startGameNormalLabel = SKLabelNode(text: "Start Normal Mode")
	var startGameItemsButton = SKSpriteNode(imageNamed: "buttontest")
	var startGameItemsLabel = SKLabelNode(text: "Start Items Mode")
	var nameLabel = SKLabelNode(text: "Dodge the Evil")
	var menuOptionButton = SKSpriteNode(imageNamed: "menuOption")
	var menuHSButton = SKSpriteNode(imageNamed: "menuHighScore")
	var highScoreLabel = SKLabelNode(text: "Highscore: 0")
	let bg = SKSpriteNode(imageNamed: "bg")
	var highScore:Int = 0
	
	override func didMoveToView(view: SKView) {
		
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
		highScoreLabel.text = "Highscore: " + String(highScore)
		
		addChild(bg)
		bg.zPosition = 1.0
		addChild(nameLabel)
		nameLabel.position.x = 0
		nameLabel.position.y = (self.size.height / 3)
		nameLabel.zPosition = 1.1
		nameLabel.setScale(1.5)
		nameLabel.fontColor = UIColor.blackColor()
		
		addChild(startGameNormalButton)
		startGameNormalButton.name = "startGameNormalButton"
		startGameNormalButton.hidden = false
		startGameNormalButton.position.y = self.size.height / 8
		startGameNormalButton.position.x = 0
		startGameNormalButton.zPosition = 1.1
		
		addChild(startGameNormalLabel)
		startGameNormalLabel.hidden = false
		startGameNormalLabel.position.x = 0
		startGameNormalLabel.position.y = startGameNormalButton.position.y - 5
		startGameNormalLabel.zPosition = 1.1
		startGameNormalLabel.setScale(0.6)
		startGameNormalLabel.fontColor = UIColor.blackColor()
		
		addChild(startGameItemsButton)
		startGameItemsButton.name = "startGameItemsButton"
		startGameItemsButton.hidden = false
		startGameItemsButton.position.y = -(self.size.height / 8)
		startGameItemsButton.position.x = 0
		startGameItemsButton.zPosition = 1.1
		
		addChild(startGameItemsLabel)
		startGameItemsLabel.hidden = false
		startGameItemsLabel.position.x = 0
		startGameItemsLabel.position.y = startGameItemsButton.position.y - 5
		startGameItemsLabel.zPosition = 1.1
		startGameItemsLabel.setScale(0.6)
		startGameItemsLabel.fontColor = UIColor.blackColor()
		
		addChild(highScoreLabel)
		highScoreLabel.hidden = false
		highScoreLabel.position.x = 0
		highScoreLabel.position.y = -(self.size.height / 3)
		highScoreLabel.zPosition = 1.1
		highScoreLabel.setScale(0.6)
		highScoreLabel.fontColor = UIColor.blackColor()
		
		addChild(menuOptionButton)
		menuOptionButton.name = "menuOptionButton"
		menuOptionButton.hidden = false
		menuOptionButton.position.y = 0
		menuOptionButton.position.x = self.size.width / 3
		menuOptionButton.zPosition = 1.1
		
		addChild(menuHSButton)
		menuHSButton.name = "menuHSButton"
		menuHSButton.hidden = false
		menuHSButton.position.y = 0
		menuHSButton.position.x = -(self.size.width / 3)
		menuHSButton.zPosition = 1.1
		
	}
	
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
	{
		for touch: AnyObject in touches {
			let location = touch.locationInNode(self)
			if self.nodeAtPoint(location) == self.startGameNormalButton {
				showPlayScene()
			} else if self.nodeAtPoint(location) == self.startGameNormalLabel {
				showPlayScene()
			}
		}
	}
	
	func showPlayScene() {
		
		var scene = PlayScene(size: self.size)
		let skView = self.view as SKView!
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .ResizeFill
		scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		scene.size = skView.bounds.size
		skView.presentScene(scene)
		
	}
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
	}
	
}