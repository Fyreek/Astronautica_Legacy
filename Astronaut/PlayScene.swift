//
//  PlayScene.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit
import iAd
import AVFoundation

class PlayScene: SGScene, SKPhysicsContactDelegate {
    
    enum gameState {
        case gameOver
        case gamePaused
        case gameActive
        case gameEnded
    }
    
    var viewController: GameViewController!
    
    var currentGameState:gameState = .gameOver
    
	var hero = Hero(imageNamed: "Astronaut25")
    var touchLocation = CGFloat()
	var enemies:[Enemy] = []
	var enemiesIndex:[Int] = []
	var endOfScreenRight = CGFloat()
	var endOfScreenLeft = CGFloat()
	var enemyCount = 0
    var deathEnemy: Enemy!
    var obtainedSpawnCount:Int = 0
    var spawnPoints:[CGFloat] = []
    var spawnPointStats:[Bool] = [true, true, true, true, true]
    var scoreBefore:Int = 0
    var heroHeight:CGFloat = 0
    var bonusItemAlive:Bool = false
    var oxygen = 100
    let oxygenMax = 100
    var oxygenTemp = 100
    var oxygenTempUp = 0
    var upOxygen:Bool = false
    var upOxygenCount:Int = 0
    var bonusItems:[BonusItem] = []
    var updateBonusTick:Int = 15
    var oxygenBar:SKSpriteNode = SKSpriteNode(imageNamed: "OxygenBar8_0")
    let asteroidTexture:SKTexture = SKTexture(imageNamed: "Asteroid16")
    let satelliteTexture:SKTexture = SKTexture(imageNamed: "Satellite15")
    let missileTexture:SKTexture = SKTexture(imageNamed: "Missile8")
    var oxygenMarker:SKSpriteNode = SKSpriteNode(imageNamed: "Orb16")
    var didOxygenCollide:Bool = false
    var didOxygenCollideEnemy:Bool = false
    var achievementOxygenCount:Int = 0
    var enemySound:Bool = false
    var bgAnimSpeed:CGFloat = 16
    var ending:Bool = false
    var newHighScore:Bool = false
    var boostActive:Bool = false
    var boostStart:Bool = false
    var boostStop:Bool = false
    var oldTickTime:Int = 0
    var speedItemActive:Bool = false

    //Layer
    let layerPause = LayerPause()
    let layerEndScreen = LayerEndScreen()
	
    var gameOverMenuLoaded = false
    
    var lastSpriteName:String = "empty"
    
	var highScore:Int = 0
    
    var explosionAnimationFrames = [SKTexture]()
    var backgroundAnimationFrames = [SKTexture]()
    var oxygenBarAnimationFrames = [SKTexture]()
    
	var gameSpeed:Float = 1.0
	var totalSpeedAsteroid:CGFloat = 3.5
	var totalSpeedSatellite:CGFloat = 2.5
	var totalSpeedRocket:CGFloat = 6
    var totalSpeedBonusItem:CGFloat = 4
	var normalSpeedAsteroid:CGFloat = 3.5
	var normalSpeedSatellite:CGFloat = 2.5
	var normalSpeedRocket:CGFloat = 6
    var normalSpeedBonusItem:CGFloat = 4
    
    var gameSpeedOld:CGFloat = 0
    var totalSpeedAsteroidOld:CGFloat = 0
    var totalSpeedSatelliteOld:CGFloat = 0
    var totalSpeedRocketOld:CGFloat = 0
    var totalSpeedBonusItemOld:CGFloat = 0
    var countDownSpeedItem:Int = 0
    
	var countDownRunning = false
	
	let bg = SKSpriteNode(imageNamed: "Background188")
    let bg2 = SKSpriteNode(imageNamed: "Background188")
    let bg3 = SKSpriteNode(imageNamed: "Background188")
    
    var score = 0
	var scoreLabel = SKLabelNode()
	
	var gamePause = SKSpriteNode(imageNamed: "PauseButton32")
    
    var startEnemy:Int = 5
    var scalingFactor:CGFloat = 1
    
    let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 0, duration: 0.2)
    
	var timer = NSTimer()
    var timerPause = NSTimer()
    var timerSpeedItem = NSTimer()
	var countDown = 3
	var countDownText = SKLabelNode(text: "")
	enum ColliderType:UInt32 {
		
        case All = 0xFFFFFFFF
		case Hero = 0b001
		case Enemy = 0b010
        case bonusItem = 0b100
		
	}
    
    override func didMoveToView(view: SKView) {
        
        loadSoundState()
        interScene.playSceneDidLoad = true
        
        achievementNoob.trigger = false
        
		self.physicsWorld.contactDelegate = self
		countDownText = SKLabelNode(text: String(countDown))
        //totalScore = SKLabelNode(text: String(score))
        
        if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
            scalingFactor = interScene.scalingfactoriPhone
        } else if interScene.deviceType == .IPadRetina || interScene.deviceType == .IPad {
            scalingFactor = interScene.scalingfactoriPad
        }
        
        scoreBefore = interScene.highScore
        
        self.backgroundColor = UIColor(rgba: "#1E2124")
        
        if interScene.firstStart == true {
            oxygenMarker.hidden = true
            oxygenMarker.setScale(scalingFactor)
            oxygenMarker.zPosition = 1.05
            let fadeIn:SKAction = SKAction.fadeAlphaTo(0.1, duration: NSTimeInterval(gameSpeed / 2))
            let fadeOut:SKAction = SKAction.fadeAlphaTo(0.4, duration: NSTimeInterval(gameSpeed / 2))
            let fading:SKAction = SKAction.sequence([fadeIn, fadeOut])
            oxygenMarker.runAction(SKAction.repeatActionForever(fading))
            addChild(oxygenMarker)
        }
        
        totalSpeedAsteroid = 3.5 * interScene.scalingfactorSpeed * CGFloat(gameSpeed)
        totalSpeedSatellite = 2.5 * interScene.scalingfactorSpeed * CGFloat(gameSpeed)
        totalSpeedRocket = 6 * interScene.scalingfactorSpeed * CGFloat(gameSpeed)
        totalSpeedBonusItem = 4 * interScene.scalingfactorSpeed * CGFloat(gameSpeed)
        normalSpeedAsteroid = 3.5 * interScene.scalingfactorSpeed * CGFloat(gameSpeed)
        normalSpeedSatellite = 2.5 * interScene.scalingfactorSpeed * CGFloat(gameSpeed)
        normalSpeedRocket = 6 * interScene.scalingfactorSpeed * CGFloat(gameSpeed)
        normalSpeedBonusItem = 4 * interScene.scalingfactorSpeed * CGFloat(gameSpeed)
        
        if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
            oxygenBar.setScale(scalingFactor)
        } else if interScene.deviceType == .IPadRetina {
            oxygenBar.setScale(scalingFactor / 3)
        } else if interScene.deviceType == .IPad {
            oxygenBar.setScale(scalingFactor)
        }
        oxygenBar.position.x = self.size.width / 2 - 40 - oxygenBar.size.width / 2
        oxygenBar.position.y = (self.size.height / 2) - oxygenBar.size.height / 2 - 25
        oxygenBar.zPosition = 1.3
        addChild(oxygenBar)
        oxygenBar.texture?.filteringMode = .Nearest
        
        if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
            startEnemy = 5
            spawnPoints.append(0)
            spawnPoints.append(self.size.height / 2 - SKSpriteNode(texture: satelliteTexture).size.height * scalingFactor)
            spawnPoints.append(-(self.size.height / 2 - SKSpriteNode(texture: satelliteTexture).size.height * scalingFactor))
            spawnPoints.append(self.size.height / 4)
            spawnPoints.append(-(self.size.height / 4))
        } else if interScene.deviceType == .IPadRetina || interScene.deviceType == .IPad {
            startEnemy = 6
            let spawnPointDist: CGFloat = (self.size.height - (CGFloat(startEnemy) * (SKSpriteNode(texture: satelliteTexture).size.height * scalingFactor))) / (CGFloat(startEnemy))
            spawnPoints.append(self.size.height / 2 - (SKSpriteNode(texture: satelliteTexture).size.height / 2 * scalingFactor + (spawnPointDist / 2)))
            spawnPoints.append(self.size.height / 2 - (SKSpriteNode(texture: satelliteTexture).size.height / 2 * scalingFactor * 2 + spawnPointDist * 2))
            spawnPoints.append(self.size.height / 2 - (SKSpriteNode(texture: satelliteTexture).size.height / 2 * scalingFactor * 3 + spawnPointDist * 3))
            spawnPoints.append(-(self.size.height / 2 - (SKSpriteNode(texture: satelliteTexture).size.height / 2 * scalingFactor + (spawnPointDist / 2))))
            spawnPoints.append(-(self.size.height / 2 - (SKSpriteNode(texture: satelliteTexture).size.height / 2 * scalingFactor * 2 + spawnPointDist * 2)))
            spawnPoints.append(-(self.size.height / 2 - (SKSpriteNode(texture: satelliteTexture).size.height / 2 * scalingFactor * 3 + spawnPointDist * 3)))
        }
        
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
        
		addHero()
        
        endOfScreenLeft = (self.size.width / 2) * CGFloat(-1) - ((SKSpriteNode(texture: satelliteTexture).size.width / 2) * scalingFactor)
        endOfScreenRight = (self.size.width / 2) + ((SKSpriteNode(texture: satelliteTexture).size.width / 2) * scalingFactor)
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "gamePaused")
		
        let explosionAtlas = SKTextureAtlas(named: "explosion")
        let oxygenBarAtlas = SKTextureAtlas(named: "oxygenBar")
        let backgroundAtlas = SKTextureAtlas(named: "background")
        
        let numImagesExplosion = explosionAtlas.textureNames.count
        for i in 1 ..< (numImagesExplosion + 3) / 3 {
        
            let explosionTextureName = "explosion32-\(i)"
            explosionAtlas.textureNamed(explosionTextureName).filteringMode = .Nearest
            explosionAnimationFrames.append(explosionAtlas.textureNamed(explosionTextureName))
        }
        
        let numImagesOxygenBar = oxygenBarAtlas.textureNames.count
        for i in 1 ..< (numImagesOxygenBar / 3) {
            
            let oxygenBarTextureName = "OxygenBar8_\(i)"
            oxygenBarAtlas.textureNamed(oxygenBarTextureName).filteringMode = .Nearest
            oxygenBarAnimationFrames.append(oxygenBarAtlas.textureNamed(oxygenBarTextureName))
        }
        
        let numImagesBackground = backgroundAtlas.textureNames.count
        for i in 1 ..< (numImagesBackground / 3) {
        
            let backgroundTextureName = "background107_\(i)"
            backgroundAtlas.textureNamed(backgroundTextureName).filteringMode = .Nearest
            backgroundAnimationFrames.append(backgroundAtlas.textureNamed(backgroundTextureName))
        }
        
        hero.color = UIColor(red: CGFloat(heroColor.heroColorRed) , green: CGFloat(heroColor.heroColorGreen) , blue: CGFloat(heroColor.heroColorBlue), alpha: 1.0)
		hero.colorBlendFactor = 0.4
		
		scoreLabel = SKLabelNode(text: "0")
		scoreLabel = SKLabelNode(fontNamed: "Minecraft")
        scoreLabel.setScale(scalingFactor)
		scoreLabel.fontSize = 15
        scoreLabel.fontColor = UIColor(rgba: "#5F6575")
		scoreLabel.position.y = (self.size.height / 2) - oxygenBar.size.height / 2 - 35
		scoreLabel.position.x = -(self.size.width / 2) + 40
        scoreLabel.zPosition = 1.2
		
		countDownText = SKLabelNode(fontNamed: "Minecraft")
        countDownText.setScale(scalingFactor)
		countDownText.fontSize = 15
		countDownText.fontColor = UIColor(rgba: "#5F6575")
		countDownText.position.y = (self.size.height / 8)
        countDownText.zPosition = 1.2
        countDownText.fontColor = UIColor(rgba: "#5F6575")
		
        gamePause.setScale(scalingFactor)
        if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
            gamePause.position.y = -(self.size.height / 2) + gamePause.size.width / 2 + 10
            gamePause.position.x = -(self.size.width / 2) + gamePause.size.height / 2 + 10
        } else if interScene.deviceType == .IPadRetina || interScene.deviceType == .IPad {
            gamePause.position.y = -(self.size.height / 2) + gamePause.size.width / 2 + 20
            gamePause.position.x = -(self.size.width / 2) + gamePause.size.height / 2 + 20
        }
        gamePause.zPosition = 1.2
        gamePause.texture?.filteringMode = .Nearest
		
		addChild(scoreLabel)
		addChild(gamePause)
        
        addChild(countDownText)
		
		countDownText.hidden = true
        
		gamePause.name = "gamePause"
		gamePause.hidden = true
		gamePause.alpha = 0
        
        GameViewController.prepareInterstitialAds()
        
		startGameNormal()
		
	}
    
    func setSpawnPoints() {
        if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
            spawnPointStats = [true, true, true, true, true]
        } else if interScene.deviceType == .IPadRetina || interScene.deviceType == .IPad {
            spawnPointStats = [true, true, true, true, true, true]        }
    }
    
    func openGameOverMenu() {

        showAds()
        if interScene.deaths >= 3 {
            showFSAd()
        }
        
        addChild(layerEndScreen)
        layerEndScreen.gameShare.hidden = true
        layerEndScreen.runAction(SKAction.fadeInWithDuration(1)){
            self.gameOverMenuLoaded = true
            self.pulsingPlayButton()
        }
        if newHighScore == true {
            layerEndScreen.gameShare.hidden = false
            layerEndScreen.gameShare.runAction(SKAction.fadeInWithDuration(1.0))
        }
    }
    
    func heroGameEnding(otherBody: Enemy?) {
        
        if ending == false {
        
            ending = true
            interScene.deaths += 1
            hero.physicsBody = nil
            currentGameState = .gameEnded
            gamePause.hidden = true
            hero.removeAllActions()
            scoreLabel.hidden = true
            oxygenBar.hidden = true
            
            if otherBody != nil {
                deathEnemy = otherBody
                deathEnemy.deathMoving = true
                deathEnemy.removeFromParent()
            }
            hero.emit = true
            
            interScene.playSceneDidLoad = false
            
            if score >= 100 {
                achievement100Points()
            }
            if score >= 150 {
                achievement150Points()
            }
            if achievementNoob.trigger == false {
                achievementNoob.trigger = true
                if score < 10 {
                    if achievementNoob.Noob4 == true {
                        GC.reportAchievement(progress: 100.00, achievementIdentifier: "astronautica.achievement_earlydeath", showBannnerIfCompleted: true, addToExisting: false)
                    } else if achievementNoob.Noob3 == true {
                        achievementNoob.Noob4 = true
                    } else if achievementNoob.Noob2 == true {
                        achievementNoob.Noob3 = true
                    } else if achievementNoob.Noob1 == true {
                        achievementNoob.Noob2 = true
                    } else {
                        achievementNoob.Noob1 = true
                    }
                } else {
                    achievementNoob.Noob1 = false
                    achievementNoob.Noob2 = false
                    achievementNoob.Noob3 = false
                    achievementNoob.Noob4 = false
                }
            }
            
            if score <= scoreBefore {
                
                layerEndScreen.totalScore.text = ("You reached ") + String(score) + (" points!")
                //totalScore.runAction(SKAction.fadeInWithDuration(1.0))
                
            } else if score > scoreBefore {
                
                newHighScore = true
                
                scoreBefore = score
                NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highScore")
                NSUserDefaults.standardUserDefaults().synchronize()
                interScene.highScore = score
                GC.reportScoreLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard", score: score)
                
                layerEndScreen.totalScore.text = ("New Highscore: ") + String(score) + (" points!")
                //totalScore.runAction(SKAction.fadeInWithDuration(1.0))
            }
        }
	}
    
    func loadSoundState() {
        if interScene.musicState == true {
            viewController.extMusicOn()
        } else {
            viewController.extMusicOff()
        }
    }
    
    func pulsingPlayButton() {
        let pulseUp = SKAction.scaleTo(scalingFactor + 0.02, duration: 1.0)
        let pulseDown = SKAction.scaleTo(scalingFactor - 0.02, duration: 1.0)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatActionForever(pulse)
        layerEndScreen.refresh.runAction(repeatPulse, withKey: "pulse")
    }
    
    func collisionEnemyBonusItem(otherBody: Enemy, bonusItem: BonusItem) {
        
        bonusItem.physicsBody = nil
        otherBody.physicsBody = nil
        
        for i in 0 ..< spawnPointStats.count {
            if spawnPoints[i] == bonusItem.spawnHeight {
                spawnPointStats[i] = true
                bonusItem.spawnHeight = 9999
            }
        }
        
        bonusItem.moving = false
        otherBody.deathMoving = true
        
        playExplosionSound()
        
        otherBody.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
            
            otherBody.hidden = true
            otherBody.removeFromParent()
            var number:Int
            number = self.enemiesIndex.find{ $0 == otherBody.uniqueIndetifier}!
            self.enemies.removeAtIndex(number)
            self.enemiesIndex.removeAtIndex(number)
            if self.currentGameState == .gameActive {
                self.addEnemies()
            }
        })
        bonusItem.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
            
            bonusItem.hidden = true
            bonusItem.removeFromParent()
            self.bonusItems = []
            if self.currentGameState == .gameActive {
                if bonusItem.name == "Oxygen15" {
                    self.addBonusItems("Oxygen")
                }
            }
        })
    }
    
    func collisionHeroSpeedItem(bonusItem: BonusItem) {
        bonusItem.physicsBody = nil
        bonusItem.moving = false
        bonusItem.hidden = true
        
        for i in 0 ..< spawnPointStats.count {
            if spawnPoints[i] == bonusItem.spawnHeight {
                spawnPointStats[i] = true
                bonusItem.spawnHeight = 9999
            }
        }
        
        bonusItems.removeAtIndex(bonusItems.indexOf(bonusItem)!)
        bonusItem.removeFromParent()
        
        hero.physicsBody = nil
        gameSpeedOld = CGFloat(gameSpeed)
        totalSpeedAsteroidOld = totalSpeedAsteroid
        totalSpeedSatelliteOld = totalSpeedSatellite
        totalSpeedRocketOld = totalSpeedRocket
        totalSpeedBonusItemOld = totalSpeedBonusItem
        
        gameSpeed = gameSpeed + 20
        totalSpeedAsteroid = totalSpeedAsteroid + 20
        totalSpeedRocket = totalSpeedRocket + 20
        totalSpeedSatellite = totalSpeedSatellite + 20
        totalSpeedBonusItem = totalSpeedBonusItem + 20
        
        stopBGAnim()
        startBGAnim()
        
        speedItemActive = true
        
        timerSpeedItem = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.updateTimerSpeedItem), userInfo: nil, repeats: true)
    }
    
    func startBoost() {
        hero.physicsBody = nil
        gameSpeedOld = CGFloat(gameSpeed)
        totalSpeedAsteroidOld = totalSpeedAsteroid
        totalSpeedSatelliteOld = totalSpeedSatellite
        totalSpeedRocketOld = totalSpeedRocket
        totalSpeedBonusItemOld = totalSpeedBonusItem
        oldTickTime = interScene.tickTime
        
        interScene.tickTime = 20
        gameSpeed = gameSpeed + 50
        totalSpeedAsteroid = totalSpeedAsteroid + 50
        totalSpeedRocket = totalSpeedRocket + 50
        totalSpeedSatellite = totalSpeedSatellite + 50
        totalSpeedBonusItem = totalSpeedBonusItem + 50
        
        stopBGAnim()
        startBGAnim()
    }
    
    func startBoostEnd() {
        totalSpeedAsteroid = totalSpeedAsteroidOld
        totalSpeedRocket = totalSpeedRocketOld
        totalSpeedSatellite = totalSpeedSatelliteOld
        totalSpeedBonusItem = totalSpeedBonusItemOld
        gameSpeed = Float(gameSpeedOld)
        interScene.tickTime = oldTickTime
        
        stopBGAnim()
        startBGAnim()
        
        heroPhysicsBody()
        hero.physicsBody!.affectedByGravity = false
        hero.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
        hero.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue | ColliderType.bonusItem.rawValue
        hero.physicsBody!.collisionBitMask = 0
        hero.physicsBody!.allowsRotation = false
    }
    
    func collisionHeroBonusItem(bonusItem: BonusItem) {
        
        bonusItem.physicsBody = nil
        bonusItem.moving = false
        bonusItem.hidden = true
        
        for i in 0 ..< spawnPointStats.count {
            if spawnPoints[i] == bonusItem.spawnHeight {
                spawnPointStats[i] = true
                bonusItem.spawnHeight = 9999
            }
        }
        
        oxygenMarker.hidden = true
        bonusItem.removeFromParent()
        oxygenMarker.removeFromParent()
        interScene.firstStart = false
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "firstStart")
        NSUserDefaults.standardUserDefaults().synchronize()
        bonusItemAlive = false
        bonusItems.removeAtIndex(bonusItems.indexOf(bonusItem)!)
        
        interScene.oxygenFail = 0
        
        if achievementOxygenCount < 10 {
            achievementOxygenCount += 1
        } else {
            achievementOxygenCount = 10
            achievementOxygenItem()
        }
        oxygenTemp = oxygen
        if oxygen + 60 > 99 {
            oxygenTempUp = 99 - oxygen
            oxygen = 99
        } else {
            oxygenTempUp = 60
            oxygen = oxygen + 60
        }
        upOxygen = true
        playOxygenSound()
        renderOxygenBar()
    }
    
    func updateTimerSpeedItem() {
    
        if countDownSpeedItem < 3 {
            countDownSpeedItem += 1
        } else {
            timerSpeedItem.invalidate()
            countDownSpeedItem = 0
            totalSpeedAsteroid = totalSpeedAsteroidOld
            totalSpeedRocket = totalSpeedRocketOld
            totalSpeedSatellite = totalSpeedSatelliteOld
            totalSpeedBonusItem = totalSpeedBonusItemOld
            gameSpeed = Float(gameSpeedOld)
            
            stopBGAnim()
            startBGAnim()
            
            speedItemActive = false
            
            heroPhysicsBody()
            hero.physicsBody!.affectedByGravity = false
            hero.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
            hero.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue | ColliderType.bonusItem.rawValue
            hero.physicsBody!.collisionBitMask = 0
            hero.physicsBody!.allowsRotation = false
        }
        
    }
    
	func didBeginContact(contact: SKPhysicsContact) {
        
        contact.bodyA.node?.physicsBody?.contactTestBitMask = 0
        contact.bodyB.node?.physicsBody?.contactTestBitMask = 0
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
         
        case ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue :
            interScene.oxygenFail = 0
            if contact.bodyA.categoryBitMask == ColliderType.Hero.rawValue {
                let otherBody = contact.bodyB.node as? Enemy
                heroGameEnding(otherBody)
            } else {
                let otherBody = contact.bodyA.node as? Enemy
                heroGameEnding(otherBody)
            }
            
        case ColliderType.Hero.rawValue | ColliderType.bonusItem.rawValue :
            if contact.bodyA.categoryBitMask == ColliderType.Hero.rawValue {
                let otherBody = contact.bodyB.node as? BonusItem
                if otherBody?.name == "Oxygen15" {
                    if didOxygenCollide == false {
                        didOxygenCollide = true
                        collisionHeroBonusItem(otherBody!)
                    }
                } else if otherBody?.name == "Speed15" {
                    collisionHeroSpeedItem(otherBody!)
                }
            } else {
                let otherBody = contact.bodyA.node as? BonusItem
                if otherBody?.name == "Oxygen15" {
                    if didOxygenCollide == false {
                        didOxygenCollide = true
                        collisionHeroBonusItem(otherBody!)
                    }
                } else if otherBody?.name == "Speed15" {
                    collisionHeroSpeedItem(otherBody!)
                }
            }
            
        case ColliderType.Enemy.rawValue | ColliderType.bonusItem.rawValue :
            if didOxygenCollideEnemy == false {
                didOxygenCollideEnemy = true
                if contact.bodyA.categoryBitMask == ColliderType.bonusItem.rawValue {
                    let otherBody = contact.bodyB.node as? Enemy
                    let bonusItem = contact.bodyA.node as? BonusItem
                    collisionEnemyBonusItem(otherBody!, bonusItem: bonusItem!)
                } else {
                    let otherBody = contact.bodyA.node as? Enemy
                    let bonusItem = contact.bodyB.node as? BonusItem
                    collisionEnemyBonusItem(otherBody!, bonusItem: bonusItem!)
                }
            }
        case ColliderType.Enemy.rawValue | ColliderType.Enemy.rawValue :
            
            let bodyOne = contact.bodyA.node as? Enemy
            let bodyTwo = contact.bodyB.node as? Enemy
            
            for i in 0 ..< spawnPointStats.count {
                if spawnPoints[i] == bodyOne?.spawnHeight {
                    spawnPointStats[i] = true
                    bodyOne?.spawnHeight = 9999
                }
            }
            for i in 0 ..< spawnPointStats.count {
                if spawnPoints[i] == bodyTwo?.spawnHeight {
                    spawnPointStats[i] = true
                    bodyTwo?.spawnHeight = 9999
                }
            }
            
            bodyOne?.physicsBody = nil
            bodyTwo?.physicsBody = nil
            bodyOne?.deathMoving = true
            bodyTwo?.deathMoving = true
            
            if bodyOne?.deathMoving == true {
                playExplosionSound()
            }
            
            bodyOne?.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
            
                bodyOne?.hidden = true
                bodyOne?.removeFromParent()
                var number:Int
                number = self.enemiesIndex.find{ $0 == bodyOne?.uniqueIndetifier}!
                self.enemies.removeAtIndex(number)
                self.enemiesIndex.removeAtIndex(number)
                if self.currentGameState == .gameActive {
                    self.addEnemies()
                }
            })
            bodyTwo?.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
                
                bodyTwo?.hidden = true
                bodyTwo?.removeFromParent()
                var number:Int
                number = self.enemiesIndex.find{ $0 == bodyTwo?.uniqueIndetifier}!
                self.enemies.removeAtIndex(number)
                self.enemiesIndex.removeAtIndex(number)
                if self.currentGameState == .gameActive {
                    self.addEnemies()
                }
            })
        default :
            fatalError("other collision: \(contactMask)")
        }
	}
    
    func emptyAll() {
        for bonusItem in bonusItems {
            bonusItem.hidden = true
            bonusItem.removeFromParent()
            bonusItems = []
        }
        for enemy in enemies {
            resetEnemy(enemy, yPos: enemy.yPos)
            enemy.hidden = true
            enemy.removeFromParent()
        }
        enemies = []
        enemiesIndex = []
    }
    
	func reloadGame() {
        
        interScene.playSceneDidLoad = true
        oxygenBar.texture = oxygenBarAnimationFrames[49]
        
        achievementOxygenCount = 0
        
        stopBGAnim()
		scoreLabel.hidden = false
        oxygenBar.hidden = false
        hero.hidden = false
		countDownText.hidden = false
		hero.removeAllActions()
        setSpawnPoints()
        oxygen = oxygenMax
        bonusItemAlive = false
        currentGameState = .gamePaused
        
        emptyAll()
        
		hero.movementSpeed = Hero().movementSpeed * CGFloat(gameSpeed)
        heroPhysicsBody()
		hero.physicsBody!.affectedByGravity = false
		hero.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
		hero.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue | ColliderType.bonusItem.rawValue
        hero.physicsBody!.collisionBitMask = 0
        hero.physicsBody!.allowsRotation = false
		
        bg.position.x = 0
        bg2.position.x = self.size.width
        bg3.position.x = self.size.width * 2
        
        hideAds()
        
        gameOverMenuLoaded = false
        
		hero.position.y = 0
		hero.position.x = -(self.size.width/2)/3
		
		score = 0
		scoreLabel.text = "0"
		totalSpeedAsteroid = normalSpeedAsteroid
		totalSpeedSatellite = normalSpeedSatellite
		totalSpeedRocket = normalSpeedRocket
        totalSpeedBonusItem = normalSpeedBonusItem
		
		addEnemies()
		
		for _ in 1 ..< startEnemy {
			self.addEnemies()
		}
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(PlayScene.updateTimer), userInfo: nil, repeats: true)
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
    
	func updateTimer() {
		
		if countDown > 0 {
            
			if hero.position.y != 0 {
				hero.position.y = 0
			}
			
			countDown -= 1
			countDownText.text = String(countDown)
            
		} else {
            
            startBGAnim()
			
            GC.reportAchievement(progress: 100.00, achievementIdentifier: "astronautica.achievement_startup", showBannnerIfCompleted: true, addToExisting: false)
        
			countDown = 3
			countDownText.text = String(countDown)
			countDownText.hidden = true
			currentGameState = .gameActive
			timer.invalidate()
			countDownRunning = false
			gamePause.hidden = false
			gamePause.alpha = 1
			
		}
	}
	
	func addHero(){
		hero = Hero(imageNamed: "Astronaut25")
		hero.setScale(scalingFactor)
        hero.zPosition = 1.1
		hero.texture?.filteringMode = .Nearest
		addChild(hero)
        
	}
	
    func achievementOxygenItem() {
        GC.reportAchievement(progress: 100.00, achievementIdentifier: "astronautica.achievement_10oxygen", showBannnerIfCompleted: true, addToExisting: false)
    }
    
    func achievement100Points() {
        GC.reportAchievement(progress: 100.00, achievementIdentifier: "astronautica.achievement_100points", showBannnerIfCompleted: true, addToExisting: false)
    }
    
    func achievement150Points() {
        GC.reportAchievement(progress: 100.00, achievementIdentifier: "astronautica.achievement_150points", showBannnerIfCompleted: true, addToExisting: false)
    }
    
    func addBonusItems(itemType: String) {
    
        //For more Items later
        let direction:Int = Int(arc4random_uniform(2))
        if itemType == "Oxygen" {
            addBonusItem(named: "Oxygen15", spawned: false, spawnHeight: 0, alive: false, moving: false, rotationDirection: direction)
        } else if itemType == "Speed" {
            addBonusItem(named: "Speed15", spawned: false, spawnHeight: 0, alive: false, moving: false, rotationDirection: direction)
        }
    }
    
    func addBonusItem(named named: String, spawned: Bool, spawnHeight: CGFloat, alive: Bool, moving: Bool, rotationDirection: Int) {
        
        let bonusItem = BonusItem(imageNamed: named)
        bonusItem.setScale(scalingFactor)
        bonusItem.zPosition = 1.1
        bonusItem.name = named
        
        bonusItem.position.x = endOfScreenRight
        bonusItem.spawned = spawned
        bonusItem.spawnHeight = spawnHeight
        bonusItem.alive = alive
        bonusItem.rotationDirection = rotationDirection
        
        bonusItems.append(bonusItem)
        
        if bonusItem.name == "Oxygen15" {
            bonusItemAlive = true
        }
        bonusItem.texture?.filteringMode = .Nearest
        addChild(bonusItem)
    }
    
	func addEnemies() {
		enemyCount += 1
		let number:Int = Int(arc4random_uniform(11))
		let upDown:Int = Int(arc4random_uniform(2))
		let heightNumber:Int = Int((self.size.height / 2) - (SKSpriteNode(imageNamed: "Asteroid16").size.height / 2))
		let height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
		let rotationSpeedRandom:CGFloat = CGFloat(arc4random_uniform(2)  + 1)
        let rotationDirection:Int = Int(arc4random_uniform(2))
        let preLocation:CGFloat = 0
        
		if number == 0 || number == 1 || number == 2 || number == 3 || number == 4 || number == 5 {
			if upDown == 0  {
                addEnemy(named: "Asteroid16", movementSpeed: Float(normalSpeedAsteroid) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999, enemyTexture: asteroidTexture)
			} else if upDown == 1 {
                addEnemy(named: "Asteroid16", movementSpeed: Float(normalSpeedAsteroid) * gameSpeed, yPos: CGFloat(height), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999, enemyTexture: asteroidTexture)
			}
		} else if number == 6 || number == 7 || number == 8 || number == 9 {
			if upDown == 0 {
                addEnemy(named: "Satellite15", movementSpeed: Float(normalSpeedSatellite) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999, enemyTexture: satelliteTexture)
			} else if upDown == 1 {
                addEnemy(named: "Satellite15", movementSpeed: Float(normalSpeedSatellite) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999, enemyTexture: satelliteTexture)
			}
		} else if number == 10 {
			if upDown == 0 {
                addEnemy(named: "Missile8", movementSpeed: Float(normalSpeedRocket) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999, enemyTexture: missileTexture)
			} else if upDown == 1 {
                addEnemy(named: "Missile8", movementSpeed: Float(normalSpeedRocket) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999, enemyTexture: missileTexture)
			}
		}
		
	}
	
    func addEnemy(named named: String, movementSpeed:Float, yPos: CGFloat, rotationSpeed:CGFloat, rotationDirection:Int, preLocation:CGFloat, uniqueIdentifier:Int, deathMoving:Bool, spawned: Bool, spawnHeight: CGFloat, didPlaySound : Bool = false, enemyTexture: SKTexture) {

		let enemy = Enemy(texture: enemyTexture)
		
        enemy.setScale(scalingFactor)
        enemy.zPosition = 1.1
        
		enemy.movementSpeed = movementSpeed
		enemy.yPos = yPos
		enemy.rotationSpeed = rotationSpeed
		enemy.rotationDirection = rotationDirection
		enemy.preLocation = preLocation
		enemy.uniqueIndetifier = uniqueIdentifier
        enemy.scored = false
        enemy.setRandomFrame()
        enemy.spawned = false
        enemy.moving = false
        enemy.spawnHeight = spawnHeight
        enemy.didPlaySound = didPlaySound
        enemy.texture?.filteringMode = .Nearest
		enemies.append(enemy)
		enemiesIndex.append(uniqueIdentifier)
		
		enemy.name = named
		resetEnemy(enemy, yPos: yPos)
		
        if enemy.name == "Missile8" {
            let yMovement:CGFloat = (hero.position.y - enemy.position.y) / (hero.position.x - enemy.position.x)
            enemy.preLocation = yMovement * 2
            var angle = atan2(hero.position.y - enemy.position.y, hero.position.x - enemy.position.x)
            let Pi = CGFloat(M_PI)
            if angle > 3 {
                angle = 3
            } else if angle < -3 {
                angle = -3
            }
            if hero.position.y > enemy.position.y {
                enemy.runAction(SKAction.rotateToAngle(((0) * Pi) / 180, duration: 0))
            } else if hero.position.y < enemy.position.y {
                enemy.runAction(SKAction.rotateToAngle(((0) * Pi) / 180, duration: 0))
            }
        }
		addChild(enemy)
	}
	
    func speedPhysicsBody(bonusItem: BonusItem) {
        let offsetX = bonusItem.frame.size.width * bonusItem.anchorPoint.x / scalingFactor
        let offsetY = bonusItem.frame.size.height * bonusItem.anchorPoint.y / scalingFactor
        let path:CGMutablePathRef = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0 - offsetX, 18 - offsetY);
        CGPathAddLineToPoint(path, nil, 2 - offsetX, 18 - offsetY);
        CGPathAddLineToPoint(path, nil, 2 - offsetX, 28 - offsetY);
        CGPathAddLineToPoint(path, nil, 4 - offsetX, 29 - offsetY);
        CGPathAddLineToPoint(path, nil, 12 - offsetX, 29 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 28 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 18 - offsetY);
        CGPathAddLineToPoint(path, nil, 15 - offsetX, 18 - offsetY);
        CGPathAddLineToPoint(path, nil, 15 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 12 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 12 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 4 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 4 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, nil, 2 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 2 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 0 - offsetX, 10 - offsetY);
        
        CGPathCloseSubpath(path);
        var scaleTransform = CGAffineTransformMakeScale(scalingFactor, scalingFactor)
        let scaledPath = CGPathCreateCopyByTransformingPath(path, &scaleTransform)
        bonusItem.physicsBody = SKPhysicsBody(polygonFromPath: scaledPath!)
    }
    
    func oxygenPhysicsBody(bonusItem: BonusItem) {
        
        let offsetX = bonusItem.frame.size.width * bonusItem.anchorPoint.x / scalingFactor
        let offsetY = bonusItem.frame.size.height * bonusItem.anchorPoint.y / scalingFactor
        let path:CGMutablePathRef = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0 - offsetX, 18 - offsetY);
        CGPathAddLineToPoint(path, nil, 2 - offsetX, 18 - offsetY);
        CGPathAddLineToPoint(path, nil, 2 - offsetX, 28 - offsetY);
        CGPathAddLineToPoint(path, nil, 4 - offsetX, 29 - offsetY);
        CGPathAddLineToPoint(path, nil, 12 - offsetX, 29 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 28 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 18 - offsetY);
        CGPathAddLineToPoint(path, nil, 15 - offsetX, 18 - offsetY);
        CGPathAddLineToPoint(path, nil, 15 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 12 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 12 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 4 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 4 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, nil, 2 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 2 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 0 - offsetX, 10 - offsetY);
        
        CGPathCloseSubpath(path);
        var scaleTransform = CGAffineTransformMakeScale(scalingFactor, scalingFactor)
        let scaledPath = CGPathCreateCopyByTransformingPath(path, &scaleTransform)
        bonusItem.physicsBody = SKPhysicsBody(polygonFromPath: scaledPath!)
    }
    
    func heroPhysicsBody() {
    
        let offsetX = hero.frame.size.width * hero.anchorPoint.x / scalingFactor
        let offsetY = hero.frame.size.height * hero.anchorPoint.y / scalingFactor
        let path:CGMutablePathRef = CGPathCreateMutable()
    
        CGPathMoveToPoint(path, nil, 0 - offsetX, 24 - offsetY);
        CGPathAddLineToPoint(path, nil, 13 - offsetX, 24 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 30 - offsetY);
        CGPathAddLineToPoint(path, nil, 27 - offsetX, 30 - offsetY);
        CGPathAddLineToPoint(path, nil, 29 - offsetX, 28 - offsetY);
        CGPathAddLineToPoint(path, nil, 30 - offsetX, 24 - offsetY);
        CGPathAddLineToPoint(path, nil, 31 - offsetX, 24 - offsetY);
        CGPathAddLineToPoint(path, nil, 32 - offsetX, 25 - offsetY);
        CGPathAddLineToPoint(path, nil, 34 - offsetX, 27 - offsetY);
        CGPathAddLineToPoint(path, nil, 41 - offsetX, 31 - offsetY);
        CGPathAddLineToPoint(path, nil, 45 - offsetX, 31 - offsetY);
        CGPathAddLineToPoint(path, nil, 47 - offsetX, 26 - offsetY);
        CGPathAddLineToPoint(path, nil, 49 - offsetX, 23 - offsetY);
        CGPathAddLineToPoint(path, nil, 49 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 45 - offsetX, 6 - offsetY);
        CGPathAddLineToPoint(path, nil, 42 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 37 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 33 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 30 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, nil, 14 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 13 - offsetX, 9 - offsetY);
        CGPathAddLineToPoint(path, nil, 0 - offsetX, 10 - offsetY);
        
        CGPathCloseSubpath(path)
        var scaleTransform = CGAffineTransformMakeScale(scalingFactor, scalingFactor)
        let scaledPath = CGPathCreateCopyByTransformingPath(path, &scaleTransform)
        hero.physicsBody = SKPhysicsBody(polygonFromPath: scaledPath!)
    }
    
    func missilePhysicsBody(enemy: Enemy) {
        
        let offsetX = enemy.frame.size.width * enemy.anchorPoint.x / scalingFactor
        let offsetY = enemy.frame.size.height * enemy.anchorPoint.y / scalingFactor
        let path:CGMutablePathRef = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0 - offsetX, 9 - offsetY);
        CGPathAddLineToPoint(path, nil, 1 - offsetX, 12 - offsetY);
        CGPathAddLineToPoint(path, nil, 19 - offsetX, 12 - offsetY);
        CGPathAddLineToPoint(path, nil, 23 - offsetX, 15 - offsetY);
        CGPathAddLineToPoint(path, nil, 29 - offsetX, 15 - offsetY);
        CGPathAddLineToPoint(path, nil, 29 - offsetX, 14 - offsetY);
        CGPathAddLineToPoint(path, nil, 27 - offsetX, 12 - offsetY);
        CGPathAddLineToPoint(path, nil, 25 - offsetX, 12 - offsetY);
        CGPathAddLineToPoint(path, nil, 25 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 27 - offsetX, 9 - offsetY);
        CGPathAddLineToPoint(path, nil, 27 - offsetX, 6 - offsetY);
        CGPathAddLineToPoint(path, nil, 25 - offsetX, 5 - offsetY);
        CGPathAddLineToPoint(path, nil, 25 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 27 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, nil, 29 - offsetX, 2 - offsetY);
        CGPathAddLineToPoint(path, nil, 29 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 23 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 20 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 1 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, nil, 0 - offsetX, 5 - offsetY);
        
        CGPathCloseSubpath(path);
        var scaleTransform = CGAffineTransformMakeScale(scalingFactor, scalingFactor)
        let scaledPath = CGPathCreateCopyByTransformingPath(path, &scaleTransform)
        enemy.physicsBody = SKPhysicsBody(polygonFromPath: scaledPath!)
    }
    
    func asteroidPhysicsBody(enemy: Enemy) {
    
        let offsetX = enemy.frame.size.width * enemy.anchorPoint.x / scalingFactor
        let offsetY = enemy.frame.size.height * enemy.anchorPoint.y / scalingFactor
        let path:CGMutablePathRef = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0 - offsetX, 25 - offsetY);
        CGPathAddLineToPoint(path, nil, 6 - offsetX, 31 - offsetY);
        CGPathAddLineToPoint(path, nil, 23 - offsetX, 31 - offsetY);
        CGPathAddLineToPoint(path, nil, 27 - offsetX, 30 - offsetY);
        CGPathAddLineToPoint(path, nil, 29 - offsetX, 23 - offsetY);
        CGPathAddLineToPoint(path, nil, 31 - offsetX, 21 - offsetY);
        CGPathAddLineToPoint(path, nil, 31 - offsetX, 14 - offsetY);
        CGPathAddLineToPoint(path, nil, 29 - offsetX, 11 - offsetY);
        CGPathAddLineToPoint(path, nil, 28 - offsetX, 11 - offsetY);
        CGPathAddLineToPoint(path, nil, 28 - offsetX, 6 - offsetY);
        CGPathAddLineToPoint(path, nil, 25 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, nil, 17 - offsetX, 2 - offsetY);
        CGPathAddLineToPoint(path, nil, 16 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 5 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 3 - offsetX, 3 - offsetY);
        CGPathAddLineToPoint(path, nil, 2 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 0 - offsetX, 14 - offsetY);
        
        CGPathCloseSubpath(path);
        var scaleTransform = CGAffineTransformMakeScale(scalingFactor, scalingFactor)
        let scaledPath = CGPathCreateCopyByTransformingPath(path, &scaleTransform)
        enemy.physicsBody = SKPhysicsBody(polygonFromPath: scaledPath!)
    }
    
    func satellitePhysicsBody(enemy: Enemy) {
        
        let offsetX = enemy.frame.size.width * enemy.anchorPoint.x / scalingFactor
        let offsetY = enemy.frame.size.height * enemy.anchorPoint.y / scalingFactor
        let path:CGMutablePathRef = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, 0 - offsetX, 10 - offsetY);
        CGPathAddLineToPoint(path, nil, 12 - offsetX, 22 - offsetY);
        CGPathAddLineToPoint(path, nil, 19 - offsetX, 22 - offsetY);
        CGPathAddLineToPoint(path, nil, 20 - offsetX, 20 - offsetY);
        CGPathAddLineToPoint(path, nil, 23 - offsetX, 20 - offsetY);
        CGPathAddLineToPoint(path, nil, 24 - offsetX, 21 - offsetY);
        CGPathAddLineToPoint(path, nil, 27 - offsetX, 26 - offsetY);
        CGPathAddLineToPoint(path, nil, 49 - offsetX, 26 - offsetY);
        CGPathAddLineToPoint(path, nil, 53 - offsetX, 22 - offsetY);
        CGPathAddLineToPoint(path, nil, 54 - offsetX, 20 - offsetY);
        CGPathAddLineToPoint(path, nil, 57 - offsetX, 20 - offsetY);
        CGPathAddLineToPoint(path, nil, 57 - offsetX, 22 - offsetY);
        CGPathAddLineToPoint(path, nil, 65 - offsetX, 29 - offsetY);
        CGPathAddLineToPoint(path, nil, 76 - offsetX, 29 - offsetY);
        CGPathAddLineToPoint(path, nil, 77 - offsetX, 28 - offsetY);
        CGPathAddLineToPoint(path, nil, 77 - offsetX, 26 - offsetY);
        CGPathAddLineToPoint(path, nil, 65 - offsetX, 14 - offsetY);
        CGPathAddLineToPoint(path, nil, 58 - offsetX, 14 - offsetY);
        CGPathAddLineToPoint(path, nil, 57 - offsetX, 16 - offsetY);
        CGPathAddLineToPoint(path, nil, 54 - offsetX, 16 - offsetY);
        CGPathAddLineToPoint(path, nil, 54 - offsetX, 14 - offsetY);
        CGPathAddLineToPoint(path, nil, 45 - offsetX, 6 - offsetY);
        CGPathAddLineToPoint(path, nil, 46 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 39 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 37 - offsetX, 0 - offsetY);
        CGPathAddLineToPoint(path, nil, 32 - offsetX, 4 - offsetY);
        CGPathAddLineToPoint(path, nil, 31 - offsetX, 6 - offsetY);
        CGPathAddLineToPoint(path, nil, 24 - offsetX, 14 - offsetY);
        CGPathAddLineToPoint(path, nil, 23 - offsetX, 15 - offsetY);
        CGPathAddLineToPoint(path, nil, 19 - offsetX, 16 - offsetY);
        CGPathAddLineToPoint(path, nil, 20 - offsetX, 14 - offsetY);
        CGPathAddLineToPoint(path, nil, 12 - offsetX, 6 - offsetY);
        CGPathAddLineToPoint(path, nil, 1 - offsetX, 5 - offsetY);
        CGPathAddLineToPoint(path, nil, 0 - offsetX, 7 - offsetY);
        
        CGPathCloseSubpath(path);
        var scaleTransform = CGAffineTransformMakeScale(scalingFactor, scalingFactor)
        let scaledPath = CGPathCreateCopyByTransformingPath(path, &scaleTransform)
        enemy.physicsBody = SKPhysicsBody(polygonFromPath: scaledPath!)
    }
    
    func bonusItemSpawn() {
        for bonusItem in bonusItems {
            for i in 0 ..< spawnPoints.count {
                if bonusItem.spawned == false {
                    if spawnPointStats[i].boolValue == true {
                        bonusItem.position.y = spawnPoints[i]
                        bonusItem.spawnHeight = spawnPoints[i]
                        bonusItem.position.x = endOfScreenRight
                        spawnPointStats[i] = false
                        bonusItem.spawned = true
                        if bonusItem.name == "Oxygen15" {
                            oxygenPhysicsBody(bonusItem)
                        } else if bonusItem.name == "Speed15" {
                            speedPhysicsBody(bonusItem)
                        }
                        bonusItem.physicsBody!.affectedByGravity = false
                        bonusItem.physicsBody!.categoryBitMask = ColliderType.bonusItem.rawValue
                        bonusItem.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue
                        bonusItem.physicsBody!.collisionBitMask = 0
                        bonusItem.physicsBody!.allowsRotation = false
                        bonusItem.moving = true
                    }
                }
            }
        }
    }
    
    func enemySpawn(enemy: Enemy) {
        if obtainedSpawnCount <= (spawnPoints.count - 1) {
            for i in 0 ..< spawnPoints.count {
                if enemy.spawned == false {
                    if spawnPointStats[i].boolValue == true {
                        enemy.yPos = spawnPoints[i]
                        enemy.position.y = enemy.yPos
                        enemy.spawnHeight = enemy.yPos
                        spawnPointStats[i] = false
                        enemy.spawned = true
                        if enemy.name == "Asteroid16" {
                            asteroidPhysicsBody(enemy)
                        } else if enemy.name == "Satellite15" {
                            satellitePhysicsBody(enemy)
                        } else if enemy.name == "Missile8" {
                            missilePhysicsBody(enemy)
                        }
                        enemy.physicsBody!.affectedByGravity = false
                        enemy.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue
                        enemy.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue | ColliderType.bonusItem.rawValue
                        enemy.physicsBody!.collisionBitMask = 0
                        enemy.physicsBody!.allowsRotation = false
                    }
                }
            }
        }
    }
    
    func spawning(enemy: Enemy = Enemy(texture: nil)) {
    
        if enemy.texture == nil {
            bonusItemSpawn()
        } else {
            if bonusItems.count >= 1 {
                for bonusItem in bonusItems {
                    if bonusItem.spawned == true {
                        enemySpawn(enemy)
                    } else {
                        bonusItemSpawn()
                    }
                }
            } else {
                enemySpawn(enemy)
            }
        }
    }
    
	func resetEnemy(enemyNode:SKSpriteNode, yPos: CGFloat) {
		
		enemyNode.position.x = endOfScreenRight
		enemyNode.position.y = yPos
		
	}
	
	func startGameNormal() {
        
		reloadGame()
	}
	
	func showMenu() {
        
        emptyAll()
        
        interScene.tickTime = 200
        
        let transition = SKTransition.fadeWithDuration(1)
        
		let scene = GameScene(size: self.size)
		let skView = self.view as SKView!
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .ResizeFill
		scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		scene.size = skView.bounds.size
        skView.presentScene(scene, transition: transition)
	}
    
    func showFSAd() {
        if interScene.adState == true {
            interScene.deaths = 0
            viewController.showFsAd()
        }
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
    
	func pauseGame() {
		
		if currentGameState == .gameActive {
			
            showAds()
            stopBGAnim()
            
            self.addChild(layerPause)
            layerPause.runAction(SKAction.fadeInWithDuration(1))
            
			currentGameState = .gamePaused
			gamePause.hidden = true
			hero.paused = true
            
            if speedItemActive == true {
                timerSpeedItem.invalidate()
            }
		}
	}
	
	func resumeGame() {
		
		if currentGameState == .gamePaused {
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "gamePaused")
            
            hideAds()
            hero.removeAllActions()
            countDownText.hidden = false
            countDownRunning = true
            timerPause = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(PlayScene.updateTimerPause), userInfo: nil, repeats: true)

		}
	}
	
    func updateTimerPause() {
    
        if countDown > 0 {
            
            countDown -= 1
            countDownText.text = String(countDown)
            
        } else {
            
            startBGAnim()
            
            oxygenMarker.removeAllActions()
            oxygenMarker.hidden = true
            oxygenMarker.removeFromParent()
            countDown = 3
            countDownText.text = String(countDown)
            countDownText.hidden = true
            timerPause.invalidate()
            countDownRunning = false
            currentGameState = .gameActive
            gamePause.hidden = false
            hero.paused = false
            
            timerSpeedItem = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(PlayScene.updateTimerSpeedItem), userInfo: nil, repeats: true)
        }
        
    }
    
	func heroMovement() {
        
        if touchLocation != hero.position.y {
            var duration = 1.0
            var distance:CGFloat = 0
            let prePos:CGFloat = hero.position.y
            
            if touchLocation > self.size.height / 2 - hero.size.height / 2 {
                touchLocation = self.size.height / 2 - hero.size.height / 2
            } else if touchLocation < -(self.size.height / 2 - hero.size.height / 2) {
                touchLocation = -(self.size.height / 2 - hero.size.height / 2)
            }
            
            if prePos > touchLocation {
                distance = prePos - touchLocation
            } else if prePos <= touchLocation {
                distance = touchLocation - prePos
            }
            
            duration = NSTimeInterval(distance / hero.movementSpeed / scalingFactor)
            
            hero.runAction(SKAction.moveToY(touchLocation, duration: duration))
            
        }
	}
	
    override func screenInteractionStarted(location: CGPoint) {
        
        touchLocation = location.y
        if currentGameState == .gameOver || currentGameState == .gameEnded {
            if self.nodeAtPoint(location) == layerEndScreen.refresh {
                lastSpriteName = layerEndScreen.refresh.name!
                if !countDownRunning {
                    layerEndScreen.refresh.runAction(buttonPressDark)
                    layerEndScreen.refresh.removeActionForKey("pulse")
                }
            } else if self.nodeAtPoint(location) == layerEndScreen.menu {
                lastSpriteName = layerEndScreen.menu.name!
                if !countDownRunning {
                    layerEndScreen.menu.runAction(buttonPressDark)
                }
            } else if self.nodeAtPoint(location) == layerEndScreen.gameShare {
                lastSpriteName = layerEndScreen.gameShare.name!
                if !countDownRunning {
                    layerEndScreen.gameShare.runAction(buttonPressDark)
                }
            }
        } else if currentGameState == .gameActive {
            
            if self.nodeAtPoint(location) == self.gamePause {
                lastSpriteName = self.gamePause.name!
                self.gamePause.runAction(buttonPressDark)
            } else {
                if lastSpriteName == "empty" {
                    buttonRemoveAction()
                    hero.removeAllActions()
                } else {
                    buttonRemoveAction()
                }
                
            }
        } else if currentGameState == .gamePaused {
            if self.nodeAtPoint(location) == layerPause.gamePlay {
                lastSpriteName = layerPause.gamePlay.name!
                if !countDownRunning {
                    layerPause.gamePlay.runAction(buttonPressDark)
                }
            } else if self.nodeAtPoint(location) == layerPause.menuPause {
                lastSpriteName = layerPause.menuPause.name!
                if !countDownRunning {
                    layerPause.menuPause.runAction(buttonPressDark)
                }
            }
        }
    }
    
    override func screenInteractionMoved(location: CGPoint) {
        
        if currentGameState == .gameActive {
            touchLocation = location.y
            heroMovement()
        }
    }
    
    override func screenInteractionEnded(location: CGPoint) {
        
        touchLocation = location.y
        if currentGameState == .gameOver || currentGameState == .gameEnded {
            if self.nodeAtPoint(location) == layerEndScreen.refresh {
                if !countDownRunning {
                    removeButtonAnim()
                    if lastSpriteName == layerEndScreen.refresh.name {
                        self.lastSpriteName = "empty"
                        layerEndScreen.refresh.runAction(buttonPressLight){
                            self.layerEndScreen.runAction(SKAction.fadeOutWithDuration(1)){
                                self.layerEndScreen.removeFromParent()
                            }
                            self.showPlayScene()
                        }
                    }
                }
            } else if self.nodeAtPoint(location) == layerEndScreen.menu {
                if !countDownRunning {
                    removeButtonAnim()
                    if lastSpriteName == layerEndScreen.menu.name {
                        self.lastSpriteName = "empty"
                        layerEndScreen.menu.runAction(buttonPressLight){
                            self.layerEndScreen.runAction(SKAction.fadeOutWithDuration(1)){
                                self.layerEndScreen.removeFromParent()
                            }
                            self.showMenu()
                        }
                    }
                }
            } else if self.nodeAtPoint(location) == layerEndScreen.gameShare {
                if !countDownRunning {
                    if lastSpriteName == layerEndScreen.gameShare.name {
                        self.lastSpriteName = "empty"
                        layerEndScreen.gameShare.runAction(buttonPressLight){
                            self.showShareMenu()
                        }
                    }
                }
            } else {
                if gameOverMenuLoaded {
                    buttonRemoveAction()
                }
            }
        } else if currentGameState == .gameActive {
            if self.nodeAtPoint(location) == self.gamePause {
                removeButtonAnim()
                if lastSpriteName == self.gamePause.name {
                    self.lastSpriteName = "empty"
                    self.gamePause.runAction(buttonPressLight){
                        self.pauseGame()
                    }
                }
            } else {
                if lastSpriteName == "empty" {
                    buttonRemoveAction()
                    self.heroMovement()
                } else {
                    buttonRemoveAction()
                    self.lastSpriteName = "empty"
                }
            }
        } else if currentGameState == .gamePaused {
            if self.nodeAtPoint(location) == layerPause.gamePlay {
                if !countDownRunning {
                    removeButtonAnim()
                    if lastSpriteName == layerPause.gamePlay.name {
                        self.lastSpriteName = "empty"
                        layerPause.gamePlay.runAction(buttonPressLight){
                            self.layerPause.runAction(SKAction.fadeOutWithDuration(1)){
                                self.layerPause.removeFromParent()
                            }
                            self.resumeGame()
                        }
                    }
                }
            } else if self.nodeAtPoint(location) == layerPause.menuPause {
                if !countDownRunning {
                    removeButtonAnim()
                    if lastSpriteName == layerPause.menuPause.name {
                        self.lastSpriteName = "empty"
                        layerPause.menuPause.runAction(buttonPressLight){
                            self.layerPause.runAction(SKAction.fadeOutWithDuration(1)){
                                self.layerPause.removeFromParent()
                            }
                            self.showMenu()
                        }
                    }
                }
            }
        } else {
        
            if lastSpriteName == layerPause.menuPause.name {
        
                layerPause.menuPause.removeAllActions()
                layerPause.menuPause.runAction(buttonPressLight)
        
            } else if lastSpriteName == layerPause.gamePlay.name {
        
                layerPause.gamePlay.removeAllActions()
                layerPause.gamePlay.runAction(buttonPressLight)
        
            } else {
        
                if gameOverMenuLoaded == true {
                    buttonRemoveAction()
                }
        
            }
        }
    }
    
    func removeButtonAnim() {
    
        if lastSpriteName == layerEndScreen.refresh.name {
        
            layerEndScreen.refresh.removeAllActions()
            layerEndScreen.refresh.runAction(buttonPressLight)
        
        } else if lastSpriteName == layerEndScreen.menu.name {
        
            layerEndScreen.menu.removeAllActions()
            layerEndScreen.menu.runAction(buttonPressLight)
        
        } else if lastSpriteName == self.gamePause.name {
        
            gamePause.removeAllActions()
            gamePause.runAction(buttonPressLight)
        
        } else if lastSpriteName == layerPause.gamePlay.name {
        
            layerPause.removeAllActions()
            layerPause.runAction(buttonPressLight)
        
        } else if lastSpriteName == layerPause.menuPause.name {
        
            layerPause.removeAllActions()
            layerPause.runAction(buttonPressLight)
            
        }
    }
    
    func buttonRemoveAction() {
        layerPause.menuPause.removeAllActions()
        layerEndScreen.menu.removeAllActions()
        layerEndScreen.refresh.removeAllActions()
        layerPause.gamePlay.removeAllActions()
        gamePause.removeAllActions()
        layerEndScreen.gameShare.removeAllActions()
        layerPause.menuPause.runAction(buttonPressLight)
        layerEndScreen.menu.runAction(buttonPressLight)
        layerEndScreen.refresh.runAction(buttonPressLight)
        layerPause.gamePlay.runAction(buttonPressLight)
        self.gamePause.runAction(buttonPressLight)
        layerEndScreen.gameShare.runAction(buttonPressLight)
        pulsingPlayButton()
    }
    
    func showShareMenu() {
        viewController.showShareMenu()
    }
    
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
        if NSUserDefaults.standardUserDefaults().boolForKey("gamePaused").boolValue == true {
            if currentGameState == .gameActive {
                pauseGame()
            }
        }
        
        if currentGameState == .gameActive || currentGameState == .gameEnded {
            if boostActive == true {
                if score < 50 {
                    if boostStart == false {
                        startBoost()
                        boostStart = true
                    }
                } else {
                    if boostStop == false {
                        startBoostEnd()
                        boostStop = true
                        boostActive = false
                    }
                }
            }
            updateBGPosition()
            updateEnemiesPosition()
            updateBonusItem()
            updateHeroEmitter()
        }
    }
    
    func renderOxygenBar() {
        
        if upOxygen == true {
            if upOxygenCount < oxygenTempUp {
                upOxygenCount = upOxygenCount + 10
                oxygenTemp = oxygenTemp + 10
                if oxygenTemp > 98 {
                        oxygenBar.texture = oxygenBarAnimationFrames[49]
                } else {
                    if oxygenTemp % 2 == 0 {
                        oxygenBar.texture = oxygenBarAnimationFrames[(oxygenTemp) / 2]
                    } else {
                        oxygenBar.texture = oxygenBarAnimationFrames[(oxygenTemp + 1) / 2]
                    }
                }
            } else {
                oxygenTemp = 0
                upOxygenCount = 0
                upOxygen = false
            }
            
        } else {
            if oxygen % 2 == 0 {
                oxygenBar.texture = oxygenBarAnimationFrames[(oxygen + 1) / 2]
            } else {
                oxygenBar.texture = oxygenBarAnimationFrames[(oxygen) / 2]
            }
        }
    }
    
    func updateBonusItem() {
        if currentGameState == .gameActive {
            if updateBonusTick > 0 {
                updateBonusTick -= 1
            } else {
                updateBonusTick = 15
                if oxygen > 0 {
                    if upOxygen == false {
                        oxygen -= 1
                    }
                    renderOxygenBar()
                } else {
                    heroGameEnding(nil)
                    if interScene.oxygenFail == 5 {
                        interScene.introDisplayed = false
                    }
                    interScene.oxygenFail += 1
                }
            }
            if oxygen <= oxygenMax / 2 {
                if bonusItemAlive == false {
                    didOxygenCollide = false
                    didOxygenCollideEnemy = false
                    if boostActive == false {
                        addBonusItems("Oxygen")
                    }
                }
            }
        }
        if bonusItems.count >= 1 {
            for bonusItem in bonusItems {
                spawning()
                if bonusItem.moving == true {
                    if bonusItem.position.x > endOfScreenLeft {
                        bonusItem.position.x -= totalSpeedBonusItem
                        if bonusItem.rotationDirection == 0 {
                            bonusItem.zRotation = bonusItem.zRotation + 0.05
                        } else {
                            bonusItem.zRotation = bonusItem.zRotation - 0.05
                        }
                        if interScene.firstStart == true {
                            oxygenMarker.hidden = false
                            oxygenMarker.alpha = 0.5
                            oxygenMarker.position.x = bonusItem.position.x
                            oxygenMarker.position.y = bonusItem.position.y
                            oxygenMarker.zRotation = bonusItem.zRotation
                        }
                    } else {
                        if bonusItem.name == "Oxygen15" {
                            oxygenMarker.hidden = true
                            bonusItems.removeAtIndex(bonusItems.indexOf(bonusItem)!)
                            bonusItem.removeFromParent()
                            achievementOxygenCount = 0
                            if currentGameState == .gameActive {
                                addBonusItems("Oxygen")
                            }
                        } else if bonusItem.name == "Speed15" {
                            bonusItems.removeAtIndex(bonusItems.indexOf(bonusItem)!)
                            bonusItem.removeFromParent()
                            //bonusItemAlive = false
                        }
                    }
                    if bonusItem.position.x < self.size.width / 2  - 200 {
                        if bonusItem.spawnHeight != 9999 {
                            for i in 0 ..< spawnPointStats.count {
                                if spawnPoints[i] == bonusItem.spawnHeight {
                                    spawnPointStats[i] = true
                                    bonusItem.spawnHeight = 9999
                                }
                            }
                        }
                        
                    } else if bonusItem.position.x < self.size.width / 2 - 50 && interScene.introDisplayed == false {
                        if bonusItem.name == "Oxygen15" {
                            if bonusItem.spawnHeight != 9999 {
                                if interScene.oxygenFail == 5 {
                                    oxygenIntro()
                                    bonusItem.spawnHeight = 9999
                                } else if interScene.firstStart == true {
                                    oxygenIntro()
                                    bonusItem.spawnHeight = 9999
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func showPlayScene() {
        
        emptyAll()
        
        hideAds()
        
        interScene.tickTime = 200
        
        let transition = SKTransition.fadeWithDuration(1)
        let scene = PlayScene(size: self.size)
        let skView = self.view as SKView!
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.size = skView.bounds.size
        skView.presentScene(scene, transition: transition)
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
    
	func updateHeroEmitter(){

        if hero.emit == true {
            hero.emit = false
            playExplosionSound()
            if deathEnemy != nil {
                deathEnemy.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
                    
                    self.deathEnemy.hidden = true
                    
                })
            }
            hero.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
				
                self.hero.hidden = true
                self.hero.removeFromParent()
                self.openGameOverMenu()
                
            })
        }
	}
	
	func updateEnemiesPosition(){
		
		for enemy in enemies {
            if enemy.spawned == true {
                if enemy.deathMoving == false {
                    if enemy.moving == false {
                        enemy.currentFrame = enemy.currentFrame + 1
                        if enemy.currentFrame > enemy.randomFrame{
                            enemy.moving = true
                        }
                    } else {
                        
                        if enemy.name == "Satellite15" {
                            
                            enemy.position.y = CGFloat((Double(enemy.position.y))) + CGFloat(sin(enemy.angle / 2) * enemy.range * Float(scalingFactor))
                            if enemy.position.y > self.size.height / 2 - enemy.size.height / 2{
                                enemy.angle = enemy.angle + Float(M_1_PI)
                            } else if enemy.position.y < -(self.size.height / 2 - enemy.size.height / 2) {
                                enemy.angle = enemy.angle + Float(M_1_PI)
                            }
                            enemy.angle = enemy.angle + 0.1
                            
                        } else if enemy.name == "Missile8" {

                            if hero.position.y > enemy.position.y {
                                enemy.position.y -= enemy.preLocation
                            } else if hero.position.y < enemy.position.y {
                                enemy.position.y -= enemy.preLocation
                            }

                        } else if enemy.name == "Asteroid16" {
                            
                            let degreeRotation = (CDouble(self.speed) * M_PI / 180) * CDouble(enemy.rotationSpeed)
                            if enemy.rotationDirection == 0 {
                                 enemy.zRotation -= CGFloat(degreeRotation)
                            } else {
                                 enemy.zRotation += CGFloat(degreeRotation)
                            }
                           
                            enemy.angle = 0
                            if hero.position.y > enemy.position.y {
                                enemy.position.y = CGFloat(Double(enemy.position.y) + 0.05 )
                            } else if hero.position.y < enemy.position.y {
                                enemy.position.y = CGFloat(Double(enemy.position.y) - 0.05)
                            }
                        }
                        
                        if enemy.position.x > endOfScreenLeft{
                            
                            if enemy.name == "Asteroid16" {
                                enemy.position.x -= totalSpeedAsteroid
                            } else if enemy.name == "Satellite15" {
                                enemy.position.x -= totalSpeedSatellite
                            } else if enemy.name == "Missile8" {
                                enemy.position.x -= totalSpeedRocket
                            }
                            
                        } else {
                            if currentGameState == .gameActive {
                                if enemy.name == "Asteroid16" {
                                    enemy.speed = totalSpeedAsteroid
                                } else if enemy.name == "Satellite15" {
                                    enemy.speed = totalSpeedSatellite
                                } else if enemy.name == "Missile8" {
                                    enemy.speed = totalSpeedRocket
                                }
                                
                                let upDown:Int = Int(arc4random_uniform(2))
                                let heightNumber:Int = Int((self.size.height / 2) - 15)
                                let height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
                                
                                if upDown == 0 {
                                    enemy.position.y = CGFloat(-(height))
                                } else if upDown == 1 {
                                    enemy.position.y = CGFloat(height)
                                }
                                if enemy.name == "Missile8" {
                                    
                                    enemy.removeFromParent()
                                    enemy.moving = false
                                    var number:Int
                                    number = enemiesIndex.find{ $0 == enemy.uniqueIndetifier}!
                                    enemies.removeAtIndex(number)
                                    enemiesIndex.removeAtIndex(number)
                                    enemy.hidden = true
                                    enemy.position.x = self.size.width + 200
                                
                                } else {
                                    
                                    if enemy.name == "Satellite15" {
                                        if enemy.didPlaySound == true {
                                            enemy.didPlaySound = false
                                            enemySound = false
                                        }
                                    }
                                    
                                    enemy.physicsBody = nil
                                    enemy.position.x = endOfScreenRight
                                    enemy.currentFrame = 0
                                    enemy.setRandomFrame()
                                    enemy.moving = false
                                    enemy.spawned = false
                                }
                                
                                enemy.scored = false
                            } else {
                                enemy.moving = false
                                enemy.hidden = true
                                enemy.removeFromParent()
                            }
                        }
                        if enemy.position.x < hero.position.x - enemy.size.width {
                            if enemy.scored == false {
                                updateScore()
                                enemy.scored = true
                            }
                        }
                        if enemy.position.x < self.size.width / 2  - 200{
                            obtainedSpawnCount = obtainedSpawnCount - 1
                            if enemy.spawnHeight != 9999 {
                                for i in 0 ..< spawnPointStats.count {
                                    if spawnPoints[i] == enemy.spawnHeight {
                                        spawnPointStats[i] = true
                                        enemy.spawnHeight = 9999
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                spawning(enemy)
            }
        }
	}
    
	func updateScore(){
		
		score += 1
		scoreLabel.text = String(score)
        
		if score % 5 == 0 {
			
            gameSpeed = gameSpeed + 0.1
			totalSpeedAsteroid = totalSpeedAsteroid + 0.1
			totalSpeedSatellite = totalSpeedSatellite + 0.1
			totalSpeedRocket = totalSpeedRocket + 0.1
            totalSpeedBonusItem = totalSpeedBonusItem + 0.1
			hero.movementSpeed = hero.movementSpeed + 5
            if interScene.tickTime > 50 {
                interScene.tickTime = interScene.tickTime - 5
            }
            
		}
        
        if score % 3 == 0 {
            if boostActive == false {
                let rnd:Int = Int(arc4random_uniform(20))
                if rnd == 1 {
                    self.addBonusItems("Speed")
                }
            }
        }
		
		if score <= 50 {
            if interScene.deviceType == .IPhone || interScene.deviceType == .IPodTouch {
                if score % 10 == 0 {
                    addEnemies()
                }
            } else if interScene.deviceType == .IPadRetina || interScene.deviceType == .IPad {
                if score % 7 == 0 {
                    addEnemies()
                }
            }
		}
		
		if (enemies.count - startEnemy) < (score / 10) {
		
			addEnemies()
		}
	}
    
    func playExplosionSound() {
        if interScene.soundState == true {
            self.runAction(interScene.explosionSound)
        }
    }
    
    func playOxygenSound() {
        if interScene.soundState == true {
            self.runAction(interScene.oxygenSound)
        }
    }
    
    func oxygenIntro() {
        if currentGameState == .gameActive {
            
            interScene.oxygenFail = 0
            interScene.introDisplayed = true
            stopBGAnim()
            
            currentGameState = .gamePaused
            addChild(layerPause)
            layerPause.menuPause.hidden = true
            layerPause.gamePlay.hidden = false
            layerPause.gamePlay.alpha = 1
            hero.paused = true
            countDownText.text = "Collect the Oxygen!"
            countDownText.hidden = false
        }

        
    }
}