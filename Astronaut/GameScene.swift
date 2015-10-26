//
//  GameScene.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit
import iAd
import AVFoundation

class GameScene: SKScene, EGCDelegate {
    
    var startGameButton = SKSpriteNode(imageNamed: "GameButton32")
	var nameLabel = SKSpriteNode(imageNamed: "Astronautica32")
	var menuOptionButton = SKSpriteNode(imageNamed: "SettingsButton32")
	var menuHSButton = SKSpriteNode(imageNamed: "LeaderboardsButton32")
	var highScoreLabel = SKLabelNode(text: "Highscore: 0")
    let bg = SKSpriteNode(imageNamed: "Background188")
    let bg2 = SKSpriteNode(imageNamed: "Background188")
    let bg3 = SKSpriteNode(imageNamed: "Background188")
    let satelliteTexture:SKTexture = SKTexture(imageNamed: "Satellite15")
    var bgAnimSpeed:CGFloat = 4
    var ticks:Int = 0
	var highScore:Int = 0
    var highScoreBefore:Int = 0
	let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 0, duration: 0.2)
    var lastSpriteName:String = ""
    var scalingFactor:CGFloat = 1
    var scalingFactorX:CGFloat = 1
    var tickCount:Int = 0
    var spawnActive = false
    var enemies:[Enemy] = []
    var explosionAnimationFrames = [SKTexture]()
    var achievementEwokBool:Bool = false
    var achievementEwokCount:Int = 0
    var satelliteSoundPlay:Bool = false
    var gameSpeed:Float = 1
    var endOfScreenRight = CGFloat()
    var endOfScreenLeft = CGFloat()
    
	override func didMoveToView(view: SKView) {
        
        loadingNSUser()
        showAds()
        loadMusicState()
        
        endOfScreenLeft = (self.size.width / 2) * CGFloat(-1) - ((SKSpriteNode(texture: satelliteTexture).size.width / 2) * scalingFactor)
        endOfScreenRight = (self.size.width / 2) + ((SKSpriteNode(texture: satelliteTexture).size.width / 2) * scalingFactor)

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchLsButton", name: "switchLbButton", object: nil)
        
        scalingFactor = (self.size.height * 2) / 640 //iPhone 5 Height, so iPhone 5 has original scaled sprites.
        scalingFactorX = self.size.width / (nameLabel.size.width + 20)
        
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
		highScoreLabel = SKLabelNode(fontNamed: "Minecraft")
		highScoreLabel.fontSize = 15
        highScoreLabel.fontColor = UIColor(rgba: "#5F6575")
		highScoreLabel.text = "Highscore: " + String(highScore)
		
        bg.zPosition = 0.9
        bg2.zPosition = 0.9
        bg3.zPosition = 0.9
        
        bg.setScale(scalingFactor)
        bg2.setScale(scalingFactor)
        bg3.setScale(scalingFactor)
        
        addChild(bg)
        bg.position.x = 0
        bg2.position.x = self.size.width
        bg3.position.x = self.size.width * 2
        addChild(bg2)
        addChild(bg3)

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
        
        switchLsButton()
        
        let explosionAtlas = SKTextureAtlas(named: "explosion")
        
        let numImagesExplosion = explosionAtlas.textureNames.count
        for var i=1; i<(numImagesExplosion + 3) / 3; i++ {
            
            let explosionTextureName = "explosion32-\(i)"
            explosionAnimationFrames.append(explosionAtlas.textureNamed(explosionTextureName))
        }
        
        startBGAnim()
	}

    
    func switchLsButton() {
        if interScene.connectedToGC == true {
            menuHSButton.runAction(SKAction.animateWithTextures([SKTexture(imageNamed: "LeaderboardsButton32")], timePerFrame: 1.0))
        } else {
            menuHSButton.texture = SKTexture(imageNamed: "DLeaderboardsButton32")
        }
    }
    
    func loadingNSUser() {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("Ads") {
            interScene.adState = NSUserDefaults.standardUserDefaults().boolForKey("Ads").boolValue
        } else {
            interScene.adState = true
        }
        
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("secretUnlocked") {
            secretUnlock.secretUnlocked = NSUserDefaults.standardUserDefaults().boolForKey("secretUnlocked")
        } else {
            secretUnlock.secretUnlocked = false
        }
        
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("heroColorRed") {
            heroColor.heroColorRed = NSUserDefaults.standardUserDefaults().floatForKey("heroColorRed")
        } else {
            heroColor.heroColorRed = 1.0
        }
        
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("heroColorGreen") {
            heroColor.heroColorGreen = NSUserDefaults.standardUserDefaults().floatForKey("heroColorGreen")
        } else {
            heroColor.heroColorGreen = 1.0
        }
        
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("heroColorBlue") {
            heroColor.heroColorBlue = NSUserDefaults.standardUserDefaults().floatForKey("heroColorBlue")
        } else {
            heroColor.heroColorBlue = 1.0
        }
    }
    
    func whichEnemy() {
        let number:Int = Int(arc4random_uniform(2))
        if number == 0 {
            randomEnemyShow("Asteroid16")
        } else {
            randomEnemyShow("Satellite15")
            satelliteSoundPlay = false
        }
    }
    
    func randomEnemyShow(named: String) {
        enemies = []
        
        let enemy:Enemy = Enemy(imageNamed: named)
        enemy.name = named
        
        enemy.zPosition = 1.3
        enemy.setScale(scalingFactor)
        enemy.position.x = (self.size.width / 2) + ((SKSpriteNode(imageNamed: named).size.width / 2) * scalingFactor)
        enemy.position.y = self.size.height / 4.5
        enemy.hidden = false
        enemy.moving = true
        enemies.append(enemy)
        addChild(enemy)
    }
    
    func showAds(){
        if interScene.adState == true {
            interScene.smallAdLoad = true
            NSNotificationCenter.defaultCenter().postNotificationName("showadsID", object: nil)
        } else {
            hideAds()
        }
    }
    
    func hideAds(){
        interScene.smallAdLoad = false
        NSNotificationCenter.defaultCenter().postNotificationName("hideadsID", object: nil)
    }
    
    func loadMusicState() {
        if interScene.musicState == true {
            NSNotificationCenter.defaultCenter().postNotificationName("MusicOn", object: nil)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName("MusicOff", object: nil)
        }
    }
    
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
			let location = touch.locationInNode(self)
			if self.nodeAtPoint(location) == self.startGameButton {
                lastSpriteName = self.startGameButton.name!
                self.startGameButton.runAction(buttonPressDark)
            } else if self.nodeAtPoint(location) == self.menuHSButton {
                if interScene.connectedToGC == true {
                    lastSpriteName = self.menuHSButton.name!
                    self.menuHSButton.runAction(buttonPressDark)
                }
            } else if self.nodeAtPoint(location) == self.menuOptionButton {
                lastSpriteName = self.menuOptionButton.name!
                self.menuOptionButton.runAction(buttonPressDark)
            }
            for enemy in enemies {
                if self.nodeAtPoint(location) == enemy {
                    enemy.moving = false
                    explosionEmit(enemy)
                }
            }
        }
	}
    
    func removeButtonAnim() {
    
        if lastSpriteName == self.startGameButton.name  {
            
            startGameButton.removeAllActions()
            startGameButton.runAction(buttonPressLight)
        
        } else if lastSpriteName == self.menuHSButton.name  {
            
            if interScene.connectedToGC == true {
                menuHSButton.removeAllActions()
                menuHSButton.runAction(buttonPressLight)
            }
            
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
                        self.resetSecret()
                        self.showPlayScene()
                    }
                }
            } else if self.nodeAtPoint(location) == self.menuHSButton {
                removeButtonAnim()
                if lastSpriteName == menuHSButton.name {
                    if interScene.connectedToGC == true {
                        self.menuHSButton.runAction(buttonPressLight){
                            self.resetSecret()
                            EGC.showGameCenterLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard")
                        }
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
    
    func toggleSecret() {
        resetSecret()
        if secretUnlock.secretUnlocked == true {
            secretUnlock.secretUnlocked = false
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "secretUnlocked")
        } else {
            secretUnlock.secretUnlocked = true
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "secretUnlocked")
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func resetSecret() {
        secretUnlock.secretStep1 = false
        secretUnlock.secretStep2 = false
        secretUnlock.secretStep3 = false
        secretUnlock.secretStep4 = false
        secretUnlock.secretStep5 = false
        secretUnlock.secretStep6 = false
    }
    
    func unlockEwokAchievement() {
        EGC.reportAchievement(progress: 100.00, achievementIdentifier: "astronautica.achievement_20enemies", showBannnerIfCompleted: true, addToExisting: false)
    }
    
    func explosionEmit(enemy: Enemy) {
        playExplosionSound()
        satelliteSoundPlay = false
        if achievementEwokBool == false {
            if achievementEwokCount < 20 {
                achievementEwokCount++
            } else {
                achievementEwokBool = true
                achievementEwokCount = 20
                unlockEwokAchievement()
            }
        }
        
        if enemy.name == "Satellite15" {
            if secretUnlock.secretStep1 == true && secretUnlock.secretStep5 == true {
                secretUnlock.secretStep6 = true
                toggleSecret()
            } else if secretUnlock.secretStep1 == false {
                secretUnlock.secretStep1 = true
            } else if secretUnlock.secretStep1 == true {
                
            } else {
                resetSecret()
            }
        } else {
            resetSecret()
        }
        
        enemy.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
            
            enemy.hidden = true
            enemy.spawned = false
            enemy.moving = false
            enemy.removeFromParent()
            self.spawnActive = false
            
        })
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
    
    func updateEnemyPosition() {
        for enemy in enemies {
            if enemy.moving == true {
                if enemy.position.x > (self.size.width / 2) * CGFloat(-1) - ((SKSpriteNode(texture: satelliteTexture).size.width / 2) * scalingFactor) {
                    if enemy.name == "Asteroid16" {
                        let degreeRotation = (CDouble(self.speed) * M_PI / 180) * CDouble(enemy.rotationSpeed)
                        if enemy.rotationDirection == 0 {
                            enemy.zRotation -= CGFloat(degreeRotation)
                        } else {
                            enemy.zRotation += CGFloat(degreeRotation)
                        }
                    } else if enemy.name == "Satellite15" {
                        enemy.position.y = CGFloat((Double(enemy.position.y))) + CGFloat(sin(enemy.angle / 2) * enemy.range)
                        if enemy.position.y > self.size.height / 2 - enemy.size.height / 2{
                            enemy.angle = enemy.angle + Float(M_1_PI)
                        } else if enemy.position.y < -(self.size.height / 2 - enemy.size.height / 2) {
                            enemy.angle = enemy.angle + Float(M_1_PI)
                        }
                        enemy.angle = enemy.angle + 0.1
                    }
                    if enemy.name == "Asteroid16" {
                        enemy.position.x -= 3.5
                    } else if enemy.name == "Satellite15" {
                        enemy.position.x -= 2.5
                    }
                } else {
                    enemy.spawned = false
                    enemy.moving = false
                    enemy.hidden = true
                    enemy.removeFromParent()
                    spawnActive = false
                }
            }
        }
    }
    
    func playExplosionSound() {
        print("Explosionstate: \(interScene.soundState)")
        if interScene.soundState == true {
            self.runAction(interScene.explosionSound)
        }
    }
    
    func startBGAnim() {
        bg.runAction(SKAction.moveToX(bg.position.x - self.size.width * 2 - SKSpriteNode(texture: satelliteTexture).size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
        bg2.runAction(SKAction.moveToX(bg2.position.x - self.size.width * 2 - SKSpriteNode(texture: satelliteTexture).size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
        bg3.runAction(SKAction.moveToX(bg3.position.x - self.size.width * 2 - SKSpriteNode(texture: satelliteTexture).size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
    }
    
    func stopBGAnim() {
        bg.removeAllActions()
        bg2.removeAllActions()
        bg3.removeAllActions()
    }

    func updateBGPosition() {
        
        if bg.position.x <= endOfScreenLeft - self.size.width / 2{
            
            bg.position.x = self.size.width * 2
            stopBGAnim()
            startBGAnim()
            
        }
        if bg2.position.x <= endOfScreenLeft - self.size.width / 2{
            
            bg2.position.x = self.size.width * 2
            stopBGAnim()
            startBGAnim()
            
        }
        if bg3.position.x <= endOfScreenLeft - self.size.width / 2{
            
            bg3.position.x = self.size.width * 2
            stopBGAnim()
            startBGAnim()
            
        }
    }
    
	override func update(currentTime: CFTimeInterval) {
        
        updateBGPosition()
        updateEnemyPosition()
        
        if ticks == 20 {
            highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
            if highScore > highScoreBefore {
        
                highScoreLabel.text = "Highscore: " + String(highScore)
                NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey: "highScore")
            
            }
            if spawnActive == false {
                let number:Int = Int(arc4random_uniform(10))
                if number == 0 {
                    spawnActive = true
                    whichEnemy()
                }
            }
            
            highScoreBefore = highScore
            ticks = 0
        }
        ticks = ticks + 1
	}
}