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

class GameScene: SGScene, EGCDelegate {
    
    var startGameButton = SKSpriteNode(imageNamed: "GameButton32")
	var nameLabel = SKSpriteNode(imageNamed: "Astronautica32")
	var menuOptionButton = SKSpriteNode(imageNamed: "SettingsButton32")
	var menuHSButton = SKSpriteNode(imageNamed: "LeaderboardsButton32")
	var highScoreLabel = SKLabelNode(text: "Highscore: 0")
    let bg = SKSpriteNode(imageNamed: "Background188")
    let bg2 = SKSpriteNode(imageNamed: "Background188")
    let bg3 = SKSpriteNode(imageNamed: "Background188")
    let shopBg = SKSpriteNode(imageNamed: "ShopBackground188")
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
    var coinLabel = SKLabelNode(text: "0")
    var versionLabel = SKLabelNode(text: "0")
    var timerVersion = NSTimer()
    var versionShown:Bool = false
    
    //Shop Scene Variables
    
    var shopSceneActive = false
    
    var shopCloseButton = SKSpriteNode(imageNamed: "Asteroid16")
    var menuShopButton = SKSpriteNode(imageNamed: "Shop15")
    
    var startBoostBtn:SKSpriteNode = SKSpriteNode(imageNamed: "shopStartBoostButton32")
    var startBoostLbl:SKLabelNode = SKLabelNode(text: "")
    var startBoostCountLbl:SKLabelNode = SKLabelNode(text: "")
    var heartBtn:SKSpriteNode = SKSpriteNode(imageNamed: "shopHeartButton32")
    var heartLbl:SKLabelNode = SKLabelNode(text: "")
    var heartCountLbl:SKLabelNode = SKLabelNode(text: "")
    
	override func didMoveToView(view: SKView) {
        
        loadingNSUser()
        showAds()
        loadMusicState()
        
        endOfScreenLeft = (self.size.width / 2) * CGFloat(-1) - ((SKSpriteNode(texture: satelliteTexture).size.width / 2) * scalingFactor)
        endOfScreenRight = (self.size.width / 2) + ((SKSpriteNode(texture: satelliteTexture).size.width / 2) * scalingFactor)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchLsButton", name: "switchLbButton", object: nil)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = .Right
        self.view!.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
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
        
        shopBg.zPosition = 2.0
        shopBg.setScale(scalingFactor)
        shopBg.texture?.filteringMode = .Nearest
        shopBg.position.y = shopBg.size.height / 2
        // WARNING: Shop System
        //addChild(shopBg)
        
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
        
        coinLabel = SKLabelNode(fontNamed: "Minecraft")
        coinLabel.fontSize = 15
        
        // WARNING: Shop System
        //addChild(coinLabel)
        
        coinLabel.text = String(interScene.coins)
        coinLabel.fontColor = UIColor(rgba: "#5F6575")
        coinLabel.zPosition = 1.2
        coinLabel.position.x = -(self.size.width / 2 - 50 * scalingFactor / 1.5)
        coinLabel.position.y = self.size.height / 2 - 50 * scalingFactor / 1.5
        coinLabel.alpha = 1.0

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
        
        shopCloseButton.setScale(scalingFactor)
        shopBg.addChild(shopCloseButton)
        shopCloseButton.name = "shopCloseButton"
        shopCloseButton.hidden = false
        shopCloseButton.position.x = self.size.width / 2 - shopCloseButton.size.width / 2 - 20 * scalingFactor
        shopCloseButton.position.y = self.size.height / 2 - shopCloseButton.size.height / 2 - 20 * scalingFactor
        shopCloseButton.zPosition = 2.1
        shopCloseButton.texture?.filteringMode = .Nearest
        
        startBoostBtn.setScale(scalingFactor)
        shopBg.addChild(startBoostBtn)
        startBoostBtn.name = "shopBoostBtn"
        startBoostBtn.hidden = false
        startBoostBtn.position.x = self.size.width / 4
        startBoostBtn.position.y = self.size.height / 4
        startBoostBtn.zPosition = 2.1
        startBoostBtn.texture?.filteringMode = .Nearest
        
        startBoostLbl = SKLabelNode(fontNamed: "Minecraft")
        startBoostLbl.setScale(scalingFactor)
        shopBg.addChild(startBoostLbl)
        startBoostLbl.text = String(price.boost)
        startBoostLbl.fontColor = UIColor(rgba: "#5F6575")
        startBoostLbl.zPosition = 2.1
        startBoostLbl.position.x = startBoostBtn.position.x
        startBoostLbl.position.y = startBoostBtn.position.y - startBoostBtn.size.height / 2 - 30 * scalingFactor
        startBoostLbl.alpha = 1.0
        
        startBoostCountLbl = SKLabelNode(fontNamed: "Minecraft")
        startBoostCountLbl.setScale(scalingFactor)
        shopBg.addChild(startBoostCountLbl)
        startBoostCountLbl.text = String(items.boostCount)
        startBoostCountLbl.fontColor = UIColor(rgba: "#5F6575")
        startBoostCountLbl.zPosition = 2.1
        startBoostCountLbl.position.x = startBoostBtn.position.x - startBoostBtn.size.width / 2 - 20 * scalingFactor
        startBoostCountLbl.position.y = startBoostBtn.position.y
        startBoostCountLbl.alpha = 1.0
        
        heartBtn.setScale(scalingFactor)
        shopBg.addChild(heartBtn)
        heartBtn.name = "shopheartBtn"
        heartBtn.hidden = false
        heartBtn.position.x = -(self.size.width / 4)
        heartBtn.position.y = self.size.height / 4
        heartBtn.zPosition = 2.1
        heartBtn.texture?.filteringMode = .Nearest
        
        heartLbl = SKLabelNode(fontNamed: "Minecraft")
        heartLbl.setScale(scalingFactor)
        shopBg.addChild(heartLbl)
        heartLbl.text = String(price.heart)
        heartLbl.fontColor = UIColor(rgba: "#5F6575")
        heartLbl.zPosition = 2.1
        heartLbl.position.x = heartBtn.position.x
        heartLbl.position.y = heartBtn.position.y - heartBtn.size.height / 2 - 30 * scalingFactor
        heartLbl.alpha = 1.0
        
        heartCountLbl = SKLabelNode(fontNamed: "Minecraft")
        heartCountLbl.setScale(scalingFactor)
        shopBg.addChild(heartCountLbl)
        heartCountLbl.text = String(items.heartCount)
        heartCountLbl.fontColor = UIColor(rgba: "#5F6575")
        heartCountLbl.zPosition = 2.1
        heartCountLbl.position.x = heartBtn.position.x - heartBtn.size.width / 2 - 20 * scalingFactor
        heartCountLbl.position.y = heartBtn.position.y
        heartCountLbl.alpha = 1.0
        
        menuShopButton.setScale(scalingFactor)
        
        // WARNING: Shop System
        //shopBg.addChild(menuShopButton)
        
        menuShopButton.name = "menuShopButton"
        menuShopButton.hidden = false
        //menuShopButton.position.y = self.size.height / 2 - menuShopButton.size.height / 2
        //menuShopButton.position.x = self.size.width / 2 - menuShopButton.size.width / 2 - 20 * scalingFactor
        //menuShopButton.position.y = -((shopBg.size.height / scalingFactor) / 2 + (menuShopButton.size.height / scalingFactor) / 2)
        //menuShopButton.position.x = self.size.width / 2 - menuShopButton.size.width - 20 * scalingFactorX
        menuShopButton.position.y = -(shopBg.size.height / 2) - (menuShopButton.size.height / 2) / scalingFactor
        menuShopButton.zPosition = 2.1
        menuShopButton.texture?.filteringMode = .Nearest
        
        switchLsButton()
        
        let explosionAtlas = SKTextureAtlas(named: "explosion")
        
        let numImagesExplosion = explosionAtlas.textureNames.count
        for var i=1; i<(numImagesExplosion + 3) / 3; i++ {
            
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
                    EGC.showGameCenterLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard")
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
                NSNotificationCenter.defaultCenter().postNotificationName("ShareMenu", object: nil)
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
        
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("coins") {
            interScene.coins = NSUserDefaults.standardUserDefaults().integerForKey("coins")
        } else {
            interScene.coins = 0
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
    
    override func screenInteractionStarted(location: CGPoint) {
        
        if shopSceneActive == false {
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
            } else if self.nodeAtPoint(location) == self.menuShopButton {
                lastSpriteName = self.menuShopButton.name!
                self.menuShopButton.runAction(buttonPressDark)
            }
            for enemy in enemies {
                if self.nodeAtPoint(location) == enemy {
                    enemy.moving = false
                    explosionEmit(enemy)
                }
            }
        } else if shopSceneActive == true {
            if self.nodeAtPoint(location) == self.shopCloseButton {
                lastSpriteName = self.shopCloseButton.name!
                self.shopCloseButton.runAction(buttonPressDark)
            }
        }
    }
    
    override func screenInteractionMoved(location: CGPoint) {
        if shopSceneActive == false {
            if lastSpriteName == menuShopButton.name {
                if location.y > self.size.height / 2 - menuShopButton.size.height / 2 {
                    menuShopButton.position.y = self.size.height / 2 - menuShopButton.size.height / 2
                    shopBg.position.y = shopBg.size.height
                } else {
                    menuShopButton.position.y = location.y
                    shopBg.position.y = menuShopButton.position.y + menuShopButton.size.height / 2 + shopBg.size.height / 2
                }
            }
        }
    }
    
    override func screenInteractionEnded(location: CGPoint) {
        if shopSceneActive == false {
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
                            EGC.showGameCenterLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard")
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
            } else if self.nodeAtPoint(location) == self.menuShopButton {
                removeButtonAnim()
                if lastSpriteName == menuShopButton.name {
                    self.menuShopButton.runAction(buttonPressLight) {
                        self.lastSpriteName = "empty"
                        self.shopButtonMoving()
                    }
                }
            } else {
                shopButtonMoving()
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
        } else if shopSceneActive == true {
            if self.nodeAtPoint(location) == self.shopCloseButton {
                removeButtonAnim()
                if lastSpriteName == shopCloseButton.name {
                    self.shopCloseButton.runAction(buttonPressLight) {
                        self.lastSpriteName = "empty"
                        self.shopClose()
                    }
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
                self.timerVersion = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: Selector("updateTimerVersion"), userInfo: nil, repeats: true)
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
    
    func shopButtonMoving() {
        let scrollPoint:CGFloat = (self.size.height / 2) * (1 / 6)
        if menuShopButton.position.y > scrollPoint {
            
            let time:CGFloat = ((self.size.height / 2) - menuShopButton.position.y) / self.size.height / 2
            menuShopButton.runAction(SKAction.moveToY(self.size.height / 2 - menuShopButton.size.height / 2, duration: 1 * Double(time)))
            shopBg.runAction(SKAction.moveToY(shopBg.size.height, duration: 1 * Double(time)))
       
        } else if menuShopButton.position.y <= scrollPoint {
            
            let time:CGFloat = ((self.size.height / 2) - menuShopButton.position.y) / self.size.height / 2
            menuShopButton.runAction(SKAction.moveToY(-(self.size.height / 2 + menuShopButton.size.height / 2), duration: 1 * Double(time)))
            shopBg.runAction(SKAction.moveToY(0, duration: 1 * Double(time)))
            shopSceneActive = true
        
        }
    }
    
    func shopClose() {
        shopBg.runAction(SKAction.moveToY(shopBg.size.height, duration: 1.0))
        menuShopButton.runAction(SKAction.moveToY(self.size.height / 2 - menuShopButton.size.height / 2, duration: 1.0)) {
            self.shopSceneActive = false
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