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

class GameScene: SGScene, GCDelegate {
    
    var viewController: GameViewController!
    
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
	let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 0, duration: 0.2)
    var lastSpriteName:String = "empty"
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
    var versionLabel = SKLabelNode(text: "0")
    var timerVersion = NSTimer()
    var versionShown:Bool = false
    
	override func didMoveToView(view: SKView) {
        
        loadingNSUser()
        showAds()
        loadMusicState()
        
        endOfScreenLeft = (self.size.width / 2) * CGFloat(-1) - ((SKSpriteNode(texture: satelliteTexture).size.width / 2) * scalingFactor)
        endOfScreenRight = (self.size.width / 2) + ((SKSpriteNode(texture: satelliteTexture).size.width / 2) * scalingFactor)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipeGesture(_:)))
        swipeRight.direction = .Right
        self.view!.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipeGesture(_:)))
        swipeLeft.direction = .Left
        self.view!.addGestureRecognizer(swipeLeft)
        
        interScene.scalingfactoriPad = (self.size.height * 2) / 768 //iPad Mini Height
        interScene.scalingfactoriPhone = (self.size.height * 2) / 640 //iPhone 5 Height, so iPhone 5 has original scaled sprites.
        
        interScene.screenSize = CGSize(width: self.size.width, height: self.size.height)
        
        if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
            scalingFactor = interScene.scalingfactoriPhone
            interScene.scalingfactorSpeed = self.size.width * 2 / 1136
        } else if interScene.deviceType == .IPadRetina || interScene.deviceType == .IPad {
            scalingFactor = interScene.scalingfactoriPad
            interScene.scalingfactorSpeed = self.size.width * 2 / 1024
        }
        
        scalingFactorX = self.size.width / (nameLabel.size.width + 20)
        self.backgroundColor = UIColor(rgba: "#1E2124")

		highScoreLabel = SKLabelNode(fontNamed: "Minecraft")
		highScoreLabel.fontSize = 15
		highScoreLabel.text = "Highscore: " + String(interScene.highScore)
		
        bg.zPosition = 0.9
        bg2.zPosition = 0.9
        bg3.zPosition = 0.9
        
        bg.setScale(scalingFactor)
        bg2.setScale(scalingFactor)
        bg3.setScale(scalingFactor)
        
        bg.texture?.filteringMode = .Nearest
        bg2.texture?.filteringMode = .Nearest
        bg3.texture?.filteringMode = .Nearest
        
        addChild(bg)
        bg.position.x = 0
        bg2.position.x = self.size.width
        bg3.position.x = self.size.width * 2
        addChild(bg2)
        addChild(bg3)
        
		nameLabel.position.x = 0
		nameLabel.position.y = (self.size.height / 4.5)
        nameLabel.zPosition = 1.2
        nameLabel.name = "nameLabel"
        if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
            if nameLabel.size.width > self.size.width {
                nameLabel.setScale(scalingFactorX)
            } else {
                nameLabel.setScale(scalingFactor)
            }
        } else if interScene.deviceType == .IPadRetina || interScene.deviceType == .IPad {
            nameLabel.setScale(interScene.scalingfactoriPad)
        }
        nameLabel.texture?.filteringMode = .Nearest
        addChild(nameLabel)
        
        versionLabel = SKLabelNode(fontNamed: "Minecraft")
        versionLabel.fontSize = 15
        addChild(versionLabel)
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            self.versionLabel.text = "build \(version)"
        }
        versionLabel.fontColor = UIColor(rgba: "#5F6575")
        versionLabel.zPosition = 1.2
        versionLabel.position.x = nameLabel.position.x + nameLabel.size.width / 2 - 20 * scalingFactor
        versionLabel.position.y = nameLabel.position.y - nameLabel.size.height / 2 - 20 * scalingFactor
        versionLabel.alpha = 0
        versionLabel.hidden = true
        
        startGameButton.setScale(scalingFactor)
		addChild(startGameButton)
		startGameButton.name = "startGameButton"
		startGameButton.hidden = false
		startGameButton.position.y = -(self.size.height / 4.5)
		startGameButton.position.x = 0
		startGameButton.zPosition = 1.2
        startGameButton.texture?.filteringMode = .Nearest
		
        highScoreLabel.setScale(scalingFactor)
		addChild(highScoreLabel)
		highScoreLabel.hidden = false
		highScoreLabel.position.x = 0
		highScoreLabel.position.y = -(self.size.height / 36)
		highScoreLabel.zPosition = 1.2
		highScoreLabel.alpha = 1
		highScoreLabel.fontColor = UIColor(rgba: "#5F6575")
        highScoreLabel.name = "highScoreLabel"
		
        menuOptionButton.setScale(scalingFactor)
		addChild(menuOptionButton)
		menuOptionButton.name = "menuOptionButton"
		menuOptionButton.hidden = false
		menuOptionButton.position.y = -(self.size.height / 4.5)
		menuOptionButton.position.x = self.size.width / 3
		menuOptionButton.zPosition = 1.2
        menuOptionButton.texture?.filteringMode = .Nearest
		
        menuHSButton.setScale(scalingFactor)
		addChild(menuHSButton)
		menuHSButton.name = "menuHSButton"
		menuHSButton.hidden = false
		menuHSButton.position.y = -(self.size.height / 4.5)
		menuHSButton.position.x = -(self.size.width / 3)
		menuHSButton.zPosition = 1.2
        menuHSButton.texture?.filteringMode = .Nearest
        
        switchLsButton()
        
        let explosionAtlas = SKTextureAtlas(named: "explosion")
        
        let numImagesExplosion = explosionAtlas.textureNames.count
        for i in 1 ..< (numImagesExplosion + 3) / 3 {
            
            let explosionTextureName = "explosion32-\(i)"
            explosionAtlas.textureNamed(explosionTextureName).filteringMode = .Nearest
            explosionAnimationFrames.append(explosionAtlas.textureNamed(explosionTextureName))
        }
        
        startBGAnim()
        pulsingPlayButton()
	}
    
    func switchLsButton() {
        if interScene.connectedToGC == true {
            menuHSButton.runAction(SKAction.animateWithTextures([SKTexture(imageNamed: "LeaderboardsButton32")], timePerFrame: 1.0))
        } else {
            menuHSButton.texture = SKTexture(imageNamed: "DLeaderboardsButton32")
        }
    }
    
    func labelColorDark() {
        UIView.animateWithDuration(1.0, animations: {
            
            self.highScoreLabel.fontColor = UIColor(rgba: "#4C515E")
            
            }, completion: {(finished: Bool) -> Void in
                //Load new Stuff
        })
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                if lastSpriteName == "empty" {
                    GC.showGameCenterLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard")
                }
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                if lastSpriteName == "empty" {
                    showOptionScene()
                }
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func labelColorLight() {
        UIView.animateWithDuration(1.0, animations: {
            
            self.highScoreLabel.fontColor = UIColor(rgba: "#5F6575")
            
            }, completion: {(finished: Bool) -> Void in
                //Load new Stuff
        })
    }
    
    func labelColorLightAction() {
        UIView.animateWithDuration(1.0, animations: {
            
            self.highScoreLabel.fontColor = UIColor(rgba: "#5F6575")
            
            }, completion: {(finished: Bool) -> Void in
                self.viewController.showShareMenu()
        })
    }
    
    func loadingNSUser() {
        
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("firstStart") {
            interScene.firstStart = NSUserDefaults.standardUserDefaults().boolForKey("firstStart").boolValue
        } else {
            interScene.firstStart = true
        }
        
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("highScore") {
            interScene.highScoreBefore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
        } else {
            interScene.highScoreBefore = 0
        }
        
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
    
    func pulsingPlayButton() {
        let pulseUp = SKAction.scaleTo(scalingFactor + 0.02, duration: 1.0)
        let pulseDown = SKAction.scaleTo(scalingFactor - 0.02, duration: 1.0)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatActionForever(pulse)
        self.startGameButton.runAction(repeatPulse, withKey: "pulse")
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
        enemy.texture?.filteringMode = .Nearest
        addChild(enemy)
    }
    
    func showAds(){
        if interScene.adState == true {
            interScene.smallAdLoad = true
            viewController.showBannerAd()
        } else {
            hideAds()
        }
    }
    
    func hideAds(){
        interScene.smallAdLoad = false
        viewController.hideBannerAd()
    }
    
    func loadMusicState() {
        if interScene.musicState == true {
            viewController.extMusicOn()
        } else {
            viewController.extMusicOff()
        }
    }
    
    override func screenInteractionStarted(location: CGPoint) {
        
        if self.nodeAtPoint(location) == self.startGameButton {
            lastSpriteName = self.startGameButton.name!
            self.startGameButton.runAction(buttonPressDark)
            self.startGameButton.removeActionForKey("pulse")
        } else if self.nodeAtPoint(location) == self.menuHSButton {
            if interScene.connectedToGC == true {
                lastSpriteName = self.menuHSButton.name!
                self.menuHSButton.runAction(buttonPressDark)
            }
        } else if self.nodeAtPoint(location) == self.menuOptionButton {
            lastSpriteName = self.menuOptionButton.name!
            self.menuOptionButton.runAction(buttonPressDark)
        } else if self.nodeAtPoint(location) == self.highScoreLabel {
            lastSpriteName = self.highScoreLabel.name!
            labelColorDark()
        } else if self.nodeAtPoint(location) == self.nameLabel {
            if secretUnlock.secretUnlocked == true {
                lastSpriteName = self.nameLabel.name!
            }
        }
        for enemy in enemies {
            if self.nodeAtPoint(location) == enemy {
                enemy.moving = false
                explosionEmit(enemy)
            }
        }
    }
    
    override func screenInteractionEnded(location: CGPoint) {
        if self.nodeAtPoint(location) == self.startGameButton {
            removeButtonAnim()
            if lastSpriteName == startGameButton.name {
                self.startGameButton.runAction(buttonPressLight){
                    self.resetSecret()
                    self.showPlayScene()
                    self.lastSpriteName = "empty"
                }
            }
        } else if self.nodeAtPoint(location) == self.menuHSButton {
            removeButtonAnim()
            if lastSpriteName == menuHSButton.name {
                if interScene.connectedToGC == true {
                    self.menuHSButton.runAction(buttonPressLight){
                        self.resetSecret()
                        GC.showGameCenterLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard")
                        self.lastSpriteName = "empty"
                    }
                }
            }
        } else if self.nodeAtPoint(location) == self.menuOptionButton {
            removeButtonAnim()
            if lastSpriteName == menuOptionButton.name {
                self.menuOptionButton.runAction(buttonPressLight) {
                    self.showOptionScene()
                    self.lastSpriteName = "empty"
                }
            }
        } else if self.nodeAtPoint(location) == self.highScoreLabel {
            removeButtonAnim()
            if lastSpriteName == highScoreLabel.name {
                labelColorLightAction()
                self.lastSpriteName = "empty"
            }
        } else if self.nodeAtPoint(location) == self.nameLabel {
            removeButtonAnim()
            if secretUnlock.secretUnlocked == true {
                if lastSpriteName == nameLabel.name {
                    self.lastSpriteName = "empty"
                    self.showVersion()
                }
            }
        } else {
            lastSpriteName = "empty"
            menuHSButton.removeAllActions()
            menuOptionButton.removeAllActions()
            startGameButton.removeAllActions()
            highScoreLabel.removeAllActions()
            
            self.menuHSButton.runAction(buttonPressLight)
            self.menuOptionButton.runAction(buttonPressLight)
            self.startGameButton.runAction(buttonPressLight)
            labelColorLight()
            pulsingPlayButton()
            
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
            menuOptionButton.runAction(buttonPressLight)
            
        } else if lastSpriteName == self.highScoreLabel.name {
        
            highScoreLabel.removeAllActions()
            labelColorLight()
            
        }
        pulsingPlayButton()
    }
    
    func showVersion() {
        if versionShown == false {
            versionShown = true
            versionLabel.hidden = false
            versionLabel.runAction(SKAction.fadeInWithDuration(1.0)){
                self.timerVersion = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(GameScene.updateTimerVersion), userInfo: nil, repeats: true)
            }
        }
    }
    
    func updateTimerVersion() {
        versionLabel.runAction(SKAction.fadeOutWithDuration(1.0)) {
            self.versionLabel.hidden = true
            self.timerVersion.invalidate()
            self.versionShown = false
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
        GC.reportAchievement(progress: 100.00, achievementIdentifier: "astronautica.achievement_20enemies", showBannnerIfCompleted: true, addToExisting: false)
    }
    
    func explosionEmit(enemy: Enemy) {
        playExplosionSound()
        satelliteSoundPlay = false
        if achievementEwokBool == false {
            if achievementEwokCount < 20 {
                achievementEwokCount += 1
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
        interScene.optionScene = OptionScene(size: self.size)
        let skView = self.view as SKView!
        skView.ignoresSiblingOrder = true
        interScene.optionScene!.scaleMode = .ResizeFill
        interScene.optionScene!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        interScene.optionScene!.size = skView.bounds.size
        interScene.optionScene!.optionSceneActive = true
        skView.presentScene(interScene.optionScene!, transition: transition)
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
                        enemy.position.x -= 3.5 * interScene.scalingfactorSpeed
                    } else if enemy.name == "Satellite15" {
                        enemy.position.x -= 2.5 * interScene.scalingfactorSpeed
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
            if interScene.highScore > interScene.highScoreBefore {
        
                highScoreLabel.text = "Highscore: " + String(interScene.highScore)
                NSUserDefaults.standardUserDefaults().setInteger(interScene.highScore, forKey: "highScore")
                interScene.highScoreBefore = interScene.highScore
            
            }
            if spawnActive == false {
                let number:Int = Int(arc4random_uniform(10))
                if number == 0 {
                    spawnActive = true
                    whichEnemy()
                }
            }
            
            ticks = 0
        }
        ticks = ticks + 1
	}
}