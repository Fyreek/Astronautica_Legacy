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

struct interScene {
    static var playSceneDidLoad:Bool = false
    static var soundState:Bool = true
    static var musicState:Bool = true
    static var adState:Bool = true
    static var smallAdLoad:Bool = false
}

struct secretUnlock {
    static var secretStep1:Bool = false
    static var secretStep2:Bool = false
    static var secretStep3:Bool = false
    static var secretStep4:Bool = false
    static var secretStep5:Bool = false
    static var secretStep6:Bool = false
    static var secretUnlocked:Bool = false
}

struct heroColor {
    static var heroColorRed:Float = 1.0
    static var heroColorGreen:Float = 1.0
    static var heroColorBlue:Float = 1.0
}

class PlayScene: SKScene, SKPhysicsContactDelegate {
	var hero = Hero(imageNamed: "Astronaut25")
    var satelliteSound:AVAudioPlayer = AVAudioPlayer()
    var touchLocation = CGFloat()
	var gameOver = true
	var gameStarted = false
	var enemies:[Enemy] = []
	var enemiesIndex:[Int] = []
	var endOfScreenRight = CGFloat()
	var endOfScreenLeft = CGFloat()
	var gamePaused = false
	var enemyCount = 0
    var deathEnemy: Enemy!
    var spawnPoints:[CGFloat] = []
    var spawnPointStats:[Bool] = [true, true, true, true, true]
    var scoreBefore:Int = 0
    var heroHeight:CGFloat = 0
    var bonusItemAlive:Bool = false
    var oxygen = 100
    let oxygenMax = 100
    var bonusItems:[BonusItem] = []
    var updateBonusTick:Int = 10
    var oxygenBar:SKSpriteNode = SKSpriteNode(imageNamed: "OxygenBar8_0")
    var didOxygenCollide:Bool = false
    var didOxygenCollideEnemy:Bool = false
    
    var bgEmit = false
    var bgAnimSpeed:CGFloat = 16
	
    var gameOverMenuLoaded = false
    var heroBlendFactor:Float = 0.4
    
    var lastSpriteName:String = "empty"
    
	var highScore:Int = 0
    
    var explosionAnimationFrames = [SKTexture]()
    var backgroundAnimationFrames = [SKTexture]()
    var oxygenBarAnimationFrames = [SKTexture]()
    
	var gameSpeed:Float = 1
	var totalSpeedAsteroid:CGFloat = 3.5
	var totalSpeedSatellite:CGFloat = 2.5
	var totalSpeedRocket:CGFloat = 6
    var totalSpeedBonusItem:CGFloat = 4
	var normalSpeedAsteroid:CGFloat = 3.5
	var normalSpeedSatellite:CGFloat = 2.5
	var normalSpeedRocket:CGFloat = 6
    var normalSpeedBonusItem:CGFloat = 4
    
	var countDownRunning = false
	
	let bg = SKSpriteNode(imageNamed: "Background188")
    let bg2 = SKSpriteNode(imageNamed: "Background188")
    let bg3 = SKSpriteNode(imageNamed: "Background188")
    let bgAn = SKSpriteNode(imageNamed: "Background188")
    let bg2An = SKSpriteNode(imageNamed: "Background188")
    let bg3An = SKSpriteNode(imageNamed: "Background188")
    var bgAnCount:Int = 0
    
    var score = 0
	var scoreLabel = SKLabelNode()
	var refresh = SKSpriteNode(imageNamed: "ReplayButton32")
	var totalScore = SKLabelNode(text: "")
	var menu = SKSpriteNode(imageNamed: "MenuButton32")
	
	var gamePause = SKSpriteNode(imageNamed: "PauseButton32")
	var gamePlay = SKSpriteNode(imageNamed: "PlayButton32")
    var menuPause = SKSpriteNode(imageNamed: "MenuButton32")
    
    var startEnemy:Int = 5
    var scalingFactor:CGFloat = 1
	
    var touchingScreen = false
    var touchYPosition:CGFloat = 0
    
    let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.clearColor(), colorBlendFactor: 0, duration: 0.2)
    
    var shiftBackground = SKAction()
    var replaceBackground = SKAction()
    var movingAndReplacingBackground = SKAction()
    
	var timer = NSTimer()
    var timerPause = NSTimer()
	var countDown = 3
	var countDownText = SKLabelNode(text: "")
	enum ColliderType:UInt32 {
		
        case All = 0xFFFFFFFF
		case Hero = 0b001
		case Enemy = 0b010
        case bonusItem = 0b100
		
	}
    
    override func didMoveToView(view: SKView) {
        
		//NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highScore") //Reset Highscore on start!
        
        prepareSatelliteSound()
        interScene.playSceneDidLoad = true
        
        shiftBackground = SKAction.moveByX(-bg.size.width, y: 0, duration: 0)
        replaceBackground = SKAction.moveByX(bg.size.width, y:0, duration: 0)
        movingAndReplacingBackground = SKAction.repeatActionForever(SKAction.sequence([shiftBackground,replaceBackground]))
        
		self.physicsWorld.contactDelegate = self
		countDownText = SKLabelNode(text: String(countDown))
        totalScore = SKLabelNode(text: String(score))
        
        scalingFactor = (self.size.height * 2) / 640 //iPhone 5 Height, so iPhone 5 has original scaled sprites.
        
        oxygenBar.position.x = self.size.width / 2 - 40 - oxygenBar.size.width / 2
        oxygenBar.position.y = (self.size.height / 2) - oxygenBar.size.height / 2 - 25
        oxygenBar.zPosition = 1.3
        oxygenBar.setScale(scalingFactor)
        addChild(oxygenBar)
        
        spawnPoints.append(0)
        spawnPoints.append(self.size.height / 2 - SKSpriteNode(imageNamed: "Satellite15").size.height * scalingFactor)
        spawnPoints.append(-(self.size.height / 2 - SKSpriteNode(imageNamed: "Satellite15").size.height * scalingFactor))
        spawnPoints.append(self.size.height / 4)
        spawnPoints.append(-(self.size.height / 4))
        
        bg.zPosition = 0.9
        bg2.zPosition = 0.9
        bg3.zPosition = 0.9
        bgAn.zPosition = 0.95
        bg2An.zPosition = 0.95
        bg3An.zPosition = 0.95
        
        bg.setScale(scalingFactor)
        bg2.setScale(scalingFactor)
        bg3.setScale(scalingFactor)
        bgAn.setScale(scalingFactor)
        bg2An.setScale(scalingFactor)
        bg3An.setScale(scalingFactor)
        
        bgAn.alpha = 0
        bg2An.alpha = 0
        bg3An.alpha = 0
        
        addChild(bg)
        addChild(bgAn)
        bg.position.x = 0
        bgAn.position.x = bg.position.x
        bg2.position.x = self.size.width
        bg2An.position.x = bg2.position.x
        bg3.position.x = self.size.width * 2
        bg3An.position.x = bg3.position.x
        addChild(bg2)
        addChild(bg3)
        
		addHero()
        
        endOfScreenLeft = (self.size.width / 2) * CGFloat(-1) - ((SKSpriteNode(imageNamed: "Satellite15").size.width / 2) * scalingFactor)
        endOfScreenRight = (self.size.width / 2) + ((SKSpriteNode(imageNamed: "Satellite15").size.width / 2) * scalingFactor)
        
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "gamePaused")
		
        let explosionAtlas = SKTextureAtlas(named: "explosion")
        let oxygenBarAtlas = SKTextureAtlas(named: "oxygenBar")
        let backgroundAtlas = SKTextureAtlas(named: "background")
        
        let numImagesExplosion = explosionAtlas.textureNames.count
        for var i=1; i<(numImagesExplosion + 3) / 3; i++ {
        
            let explosionTextureName = "explosion32-\(i)"
            explosionAnimationFrames.append(explosionAtlas.textureNamed(explosionTextureName))
        }
        
        let numImagesOxygenBar = oxygenBarAtlas.textureNames.count
        for var i=1; i<(numImagesOxygenBar / 3); i++ {
            
            let oxygenBarTextureName = "OxygenBar8_\(i)"
            oxygenBarAnimationFrames.append(oxygenBarAtlas.textureNamed(oxygenBarTextureName))
        }
        
        let numImagesBackground = backgroundAtlas.textureNames.count
        for var i=1; i<(numImagesBackground / 3); i++ {
        
            let backgroundTextureName = "background107_\(i)"
            backgroundAnimationFrames.append(backgroundAtlas.textureNamed(backgroundTextureName))
        }
        
        hero.color = UIColor(red: CGFloat(heroColor.heroColorRed) , green: CGFloat(heroColor.heroColorGreen) , blue: CGFloat(heroColor.heroColorBlue), alpha: 1.0)
		hero.colorBlendFactor = 0.4
		
		scoreLabel = SKLabelNode(text: "0")
		scoreLabel = SKLabelNode(fontNamed: "Minecraft")
		scoreLabel.fontSize = 15
        scoreLabel.fontColor = UIColor(rgba: "#5F6575")
		scoreLabel.position.y = (self.size.height / 2) - oxygenBar.size.height / 2 - 35
		scoreLabel.position.x = -(self.size.width / 2) + 40
        scoreLabel.zPosition = 1.2
		
		countDownText = SKLabelNode(fontNamed: "Minecraft")
		countDownText.fontSize = 15
		countDownText.fontColor = UIColor(rgba: "#5F6575")
		countDownText.position.y = (self.size.height / 8)
        countDownText.zPosition = 1.2
        countDownText.fontColor = UIColor(rgba: "#5F6575")
		
		refresh.position.y = -(self.size.height / 4.5)
		refresh.position.x = -(self.size.width / 8)
        refresh.zPosition = 1.2
		
		menu.position.y = -(self.size.height / 4.5)
		menu.position.x = (self.size.width / 8)
        menu.zPosition = 1.2
		
		gamePause.position.y = -(self.size.height / 2) + 40
		gamePause.position.x = -(self.size.width / 2) + 40
        gamePause.zPosition = 1.2
		
		gamePlay.position.y = 0
		gamePlay.position.x = -(self.size.width / 8)
        gamePlay.zPosition = 1.2
        
        menuPause.position.y = 0
        menuPause.position.x = self.size.width / 8
        menuPause.zPosition = 1.2
		
		totalScore = SKLabelNode(fontNamed: "Minecraft")
		totalScore.fontSize = 15
        totalScore.fontColor = UIColor(rgba: "#5F6575")
		totalScore.position.x = 0
		totalScore.position.y = self.size.height / 8
        totalScore.zPosition = 1.2
		
		addChild(totalScore)
		addChild(scoreLabel)
		addChild(refresh)
		addChild(menu)
		addChild(gamePause)
		addChild(gamePlay)
        addChild(menuPause)
		addChild(countDownText)
		
		countDownText.hidden = true
		refresh.name = "refresh"
		refresh.hidden = true
		refresh.alpha = 0
		
		gamePlay.name = "gamePlay"
		gamePlay.hidden = true
		gamePlay.alpha = 0
		
        menuPause.name = "menuPause"
        menuPause.hidden = true
        menuPause.alpha = 0
        
		gamePause.name = "gamePause"
		gamePause.hidden = true
		gamePause.alpha = 0
		
		totalScore.name = "totalScore"
		totalScore.hidden = true
		totalScore.alpha = 0
		
		menu.name = "menu"
		menu.hidden = true
		menu.alpha = 0
        
        GameViewController.prepareInterstitialAds()
        
		startGameNormal()
		
	}
    
    func setSpawnPoints() {
        spawnPointStats = [true, true, true, true, true]
    }
    
    func openGameOverMenu() {

        whichAd()
        
        refresh.hidden = false
        refresh.runAction(SKAction.fadeInWithDuration(1.0)){
            self.gameOverMenuLoaded = true
        }
        refresh.zPosition = 1.2
        menu.zPosition = 1.2
        gamePlay.zPosition = 0.9
        menuPause.zPosition = 0.9
        menu.hidden = false
        menu.runAction(SKAction.fadeInWithDuration(1.0))
        
    }
    
    func heroGameEnding(otherBody: Enemy?) {
        hero.physicsBody = nil
        gameOver = true
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
        
        if score <= scoreBefore {
            
            totalScore.hidden = false
            totalScore.text = ("You reached ") + String(score) + (" points!")
            totalScore.runAction(SKAction.fadeInWithDuration(1.0))
            
        } else if score > scoreBefore {
            
            scoreBefore = score
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highScore")
            NSUserDefaults.standardUserDefaults().synchronize()
            //submit score to GameCenter
            EGC.reportScoreLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard", score: score)
            
            totalScore.hidden = false
            totalScore.text = ("New Highscore: ") + String(score) + (" points!")
            totalScore.runAction(SKAction.fadeInWithDuration(1.0))
            
        }
	}
	
    func showGameInfo() {
        
        let infoHero:SKSpriteNode = SKSpriteNode(imageNamed: "Astronaut25")
        let infoEnemy1:SKSpriteNode = SKSpriteNode(imageNamed: "Satellite15")
        let infoEnemy2:SKSpriteNode = SKSpriteNode(imageNamed: "Asteroid16")
        let infoEnemy3:SKSpriteNode = SKSpriteNode(imageNamed: "Missile8")
        let infoOxygen:SKSpriteNode = SKSpriteNode(imageNamed: "Oxygen15")
        let infoHeroLabel:SKLabelNode = SKLabelNode(text: "You!")
        let infoEnemy1Label:SKLabelNode = SKLabelNode(text: "Enemy")
        let infoEnemy2Label:SKLabelNode = SKLabelNode(text: "Enemy")
        let infoEnemy3Label:SKLabelNode = SKLabelNode(text: "Enemy")
        let infoOxygenLabel:SKLabelNode = SKLabelNode(text: "Oxygen")
        
        infoEnemy1.zPosition = 1.2
        infoEnemy1.position.x = self.size.width / 2 - infoEnemy1.size.width / 2
        infoEnemy1.position.y = self.size.height / 4
        infoEnemy1.setScale(scalingFactor)
        
        infoEnemy1Label.zPosition = 1.2
        infoEnemy1Label.position.x = self.size.width / 2 - infoEnemy1.size.width / 2 - 100
        infoEnemy1Label.position.y = self.size.height / 4
        
        infoEnemy2.zPosition = 1.2
        infoEnemy2.position.x = self.size.width / 2 - infoEnemy1.size.width / 2
        infoEnemy2.position.y = self.size.height / 4 - infoEnemy1.size.height * 2
        infoEnemy2.setScale(scalingFactor)
        
        infoEnemy2Label.zPosition = 1.2
        infoEnemy2Label.position.x = self.size.width / 2 - infoEnemy1.size.width / 2 - 100
        infoEnemy2Label.position.y = self.size.height / 4 - infoEnemy1.size.height * 2
        
        infoEnemy3.zPosition = 1.2
        infoEnemy3.position.x = self.size.width / 2 - infoEnemy1.size.width / 2
        infoEnemy3.position.y = self.size.height / 4 + infoEnemy1.size.height * 2
        infoEnemy3.setScale(scalingFactor)
        
        infoEnemy3Label.zPosition = 1.2
        infoEnemy3Label.position.x = self.size.width / 2 - infoEnemy1.size.width / 2 - 100
        infoEnemy3Label.position.y = self.size.height / 4 + infoEnemy1.size.height * 2
        
        infoHero.zPosition = 1.2
        infoHero.position.x = self.size.width / 2 - infoEnemy1.size.width / 2
        infoHero.position.y = -(infoEnemy1.size.height)
        infoHero.setScale(scalingFactor)
        
        infoHeroLabel.zPosition = 1.2
        infoHeroLabel.position.x = self.size.width / 2 - infoEnemy1.size.width / 2 - 100
        infoHeroLabel.position.y = -(infoEnemy1.size.height)
        
        infoOxygen.zPosition = 1.2
        infoOxygen.position.x = self.size.width / 2 - infoEnemy1.size.width / 2
        infoOxygen.position.y = -(self.size.height / 4)
        infoOxygen.setScale(scalingFactor)
        
        infoOxygenLabel.zPosition = 1.2
        infoOxygenLabel.position.x = self.size.width / 2 - infoEnemy1.size.width / 2 - 100
        infoOxygenLabel.position.y = -(self.size.height / 4)
        
        addChild(infoEnemy1)
        addChild(infoEnemy1Label)
        addChild(infoEnemy2)
        addChild(infoEnemy2Label)
        addChild(infoEnemy3)
        addChild(infoEnemy3Label)
        //addChild(infoHero)
        //addChild(infoHeroLabel)
        addChild(infoOxygen)
        addChild(infoOxygenLabel)
        
    }
    
    func collisionEnemyBonusItem(otherBody: Enemy, bonusItem: BonusItem) {
    
        bonusItem.moving = false
        bonusItem.physicsBody = nil
        otherBody.deathMoving = true
        otherBody.physicsBody = nil
    
        otherBody.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
            
            otherBody.hidden = true
            otherBody.removeFromParent()
            var number:Int
            number = self.enemiesIndex.find{ $0 == otherBody.uniqueIndetifier}!
            self.enemies.removeAtIndex(number)
            self.enemiesIndex.removeAtIndex(number)
            if !self.gameOver {
                self.addEnemies()
            }
        })
        bonusItem.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
            
            bonusItem.hidden = true
            bonusItem.removeFromParent()
            self.bonusItems = []
            if !self.gameOver {
                self.addBonusItems("Oxygen15")
            }
        })
    }
    
    func collisionHeroBonusItem(bonusItem: BonusItem) {
        bonusItem.moving = false
        bonusItem.physicsBody = nil
        bonusItem.hidden = true
        bonusItem.removeFromParent()
        bonusItemAlive = false
        bonusItems = []
        oxygen = oxygen + 60
        updateOxygenBar()
    }
    
	func didBeginContact(contact: SKPhysicsContact) {
		
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
         
        case ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue :
            if contact.bodyA.categoryBitMask == ColliderType.Hero.rawValue {
                let otherBody = contact.bodyB.node as? Enemy
                heroGameEnding(otherBody)
            } else {
                let otherBody = contact.bodyA.node as? Enemy
                heroGameEnding(otherBody)
            }
            
        case ColliderType.Hero.rawValue | ColliderType.bonusItem.rawValue :
            if didOxygenCollide == false {
                didOxygenCollide = true
                if contact.bodyA.categoryBitMask == ColliderType.Hero.rawValue {
                    let otherBody = contact.bodyB.node as? BonusItem
                    collisionHeroBonusItem(otherBody!)
                } else {
                    let otherBody = contact.bodyA.node as? BonusItem
                    collisionHeroBonusItem(otherBody!)
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
            let bodyOne = contact.bodyA.categoryBitMask == ColliderType.Enemy.rawValue ? contact.bodyA.node as? Enemy : contact.bodyB.node as? Enemy
            let bodyTwo = contact.bodyB.categoryBitMask == ColliderType.Enemy.rawValue ? contact.bodyB.node as? Enemy : contact.bodyA.node as? Enemy
            
            for var i = 0; i < spawnPointStats.count; i++ {
                if spawnPoints[i] == bodyOne?.spawnHeight {
                    spawnPointStats[i] = true
                    bodyOne?.spawnHeight = 9999
                }
            }
            for var i = 0; i < spawnPointStats.count; i++ {
                if spawnPoints[i] == bodyTwo?.spawnHeight {
                    spawnPointStats[i] = true
                    bodyTwo?.spawnHeight = 9999
                }
            }
            
            bodyOne?.physicsBody = nil
            bodyTwo?.physicsBody = nil
            bodyOne?.deathMoving = true
            bodyTwo?.deathMoving = true
            bodyOne?.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
            
                bodyOne?.hidden = true
                bodyOne?.removeFromParent()
                var number:Int
                number = self.enemiesIndex.find{ $0 == bodyOne?.uniqueIndetifier}!
                self.enemies.removeAtIndex(number)
                self.enemiesIndex.removeAtIndex(number)
                if !self.gameOver {
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
                if !self.gameOver {
                    self.addEnemies()
                }
            })
        default :
            fatalError("other collision: \(contactMask)")
        }
	}
    
	func reloadGame() {
        
        interScene.playSceneDidLoad = true
        oxygenBar.texture = oxygenBarAnimationFrames[49]
        
        stopBGAnim()
		scoreLabel.hidden = false
        oxygenBar.hidden = false
        hero.hidden = false
		countDownText.hidden = false
		hero.removeAllActions()
        setSpawnPoints()
        oxygen = oxygenMax
        bonusItemAlive = false
        for bonusItem in bonusItems {
            bonusItem.hidden = true
            bonusItem.removeFromParent()
            bonusItems = []
        }
        
        gamePaused = true
        
		hero.movementSpeed = Hero().movementSpeed
		hero.physicsBody = SKPhysicsBody(texture: hero.texture!, alphaThreshold: 0, size: hero.size)
		hero.physicsBody!.affectedByGravity = false
		hero.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
		hero.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue | ColliderType.bonusItem.rawValue
		hero.physicsBody!.collisionBitMask = ColliderType.Enemy.rawValue | ColliderType.bonusItem.rawValue
		hero.physicsBody!.allowsRotation = false
		
        bg.position.x = 0
        bgAn.position.x = bg.position.x
        bg2.position.x = self.size.width
        bg2An.position.x = bg2.position.x
        bg3.position.x = self.size.width * 2
        bg3An.position.x = bg3.position.x
        
        hideAds()
        
        gameOverMenuLoaded = false
        
        refresh.zPosition = 0.9
        menu.zPosition = 0.9
		hero.position.y = 0
		hero.position.x = -(self.size.width/2)/3
		
		refresh.runAction(SKAction.fadeOutWithDuration(1.0))
        menu.runAction(SKAction.fadeOutWithDuration(1.0))
		totalScore.runAction(SKAction.fadeOutWithDuration(1.0))
		score = 0
		scoreLabel.text = "0"
		gameSpeed = 1
		totalSpeedAsteroid = normalSpeedAsteroid
		totalSpeedSatellite = normalSpeedSatellite
		totalSpeedRocket = normalSpeedRocket
        totalSpeedBonusItem = normalSpeedBonusItem
		
		for enemy in enemies {
			resetEnemy(enemy, yPos: enemy.yPos)
			enemy.hidden = true
            enemy.removeFromParent()
		}
        enemies = []
        enemiesIndex = []
		addEnemies()
		
		for var i = 1; i < startEnemy; i++ {
			self.addEnemies()
		}
        
        //showGameInfo() Maybe later for Ingame Tutorial
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
	}
	
    func startBGAnim() {
        bg.runAction(SKAction.moveToX(bg.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
//        bgAn.runAction(SKAction.moveToX(bgAn.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
        bg2.runAction(SKAction.moveToX(bg2.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
//        bg2An.runAction(SKAction.moveToX(bg2An.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
        bg3.runAction(SKAction.moveToX(bg3.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
//        bg3An.runAction(SKAction.moveToX(bg3An.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
    }
    
    func stopBGAnim() {
        bg.removeAllActions()
        bgAn.removeAllActions()
        bg2.removeAllActions()
        bg2An.removeAllActions()
        bg3.removeAllActions()
        bg3An.removeAllActions()
    }
    
	func updateTimer() {
		
		if countDown > 0 {
			
			if hero.position.y != 0 {
				
				hero.position.y = 0
				
			}
			
			countDown--
			countDownText.text = String(countDown)
			
		} else {
            
            startBGAnim()
			
			countDown = 3
			countDownText.text = String(countDown)
			countDownText.hidden = true
			gameOver = false
            gamePaused = false
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
		
		addChild(hero)
		
	}
	
    func addBonusItems(itemType: String) {
    
        //For more Items later
        let direction:Int = Int(arc4random_uniform(2))
        if itemType == "Oxygen15" {
            addBonusItem(named: "Oxygen15", spawned: false, spawnHeight: 0, alive: false, moving: false, rotationDirection: direction)
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
        bonusItemAlive = true
        addChild(bonusItem)
    }
    
	func addEnemies() {
		enemyCount++
		let number:Int = Int(arc4random_uniform(11))
		let upDown:Int = Int(arc4random_uniform(2))
		let heightNumber:Int = Int((self.size.height / 2) - (SKSpriteNode(imageNamed: "Asteroid16").size.height / 2))
		let height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
		let rotationSpeedRandom:CGFloat = CGFloat(arc4random_uniform(2)  + 1)
        let rotationDirection:Int = Int(arc4random_uniform(2))
        let preLocation:CGFloat = 0
		
		if number == 0 || number == 1 || number == 2 || number == 3 || number == 4 || number == 5 {
			if upDown == 0  {
                addEnemy(named: "Asteroid16", movementSpeed: Float(normalSpeedAsteroid) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, health: 10, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999)
			} else if upDown == 1 {
                addEnemy(named: "Asteroid16", movementSpeed: Float(normalSpeedAsteroid) * gameSpeed, yPos: CGFloat(height), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, health: 10, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999)
			}
			
			
		} else if number == 6 || number == 7 || number == 8 || number == 9 {
			if upDown == 0 {
                addEnemy(named: "Satellite15", movementSpeed: Float(normalSpeedSatellite) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 3, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999)
			} else if upDown == 1 {
                addEnemy(named: "Satellite15", movementSpeed: Float(normalSpeedSatellite) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 3, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999)
			}
		} else if number == 10 {
			if upDown == 0 {
                addEnemy(named: "Missile8", movementSpeed: Float(normalSpeedRocket) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 1, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999)
			} else if upDown == 1 {
                addEnemy(named: "Missile8", movementSpeed: Float(normalSpeedRocket) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 1, uniqueIdentifier: enemyCount, deathMoving: false, spawned: false, spawnHeight: 9999)
			}
		}
		
	}
	
    func addEnemy(named named: String, movementSpeed:Float, yPos: CGFloat, rotationSpeed:CGFloat, rotationDirection:Int, preLocation:CGFloat, health:Int, uniqueIdentifier:Int, deathMoving:Bool, spawned: Bool, spawnHeight: CGFloat) {
		
		let enemy = Enemy(imageNamed: named)
		
        enemy.setScale(scalingFactor)
        enemy.zPosition = 1.1
        
		enemy.movementSpeed = movementSpeed
		enemy.yPos = yPos
		enemy.rotationSpeed = rotationSpeed
		enemy.rotationDirection = rotationDirection
		enemy.preLocation = preLocation
		enemy.health = health
		enemy.uniqueIndetifier = uniqueIdentifier
        enemy.scored = false
        enemy.setRandomFrame()
        enemy.spawned = false
        enemy.moving = false
        enemy.spawnHeight = spawnHeight
		enemies.append(enemy)
		enemiesIndex.append(uniqueIdentifier)
		
		enemy.name = named
		resetEnemy(enemy, yPos: yPos)
		
        if enemy.name == "Missile8" {
            let yMovement:CGFloat = (hero.position.y - enemy.position.y) / (hero.position.x - enemy.position.x)
            enemy.preLocation = yMovement * 2
            let angle = atan2(hero.position.y - enemy.position.y, hero.position.x - enemy.position.x)
            let Pi = CGFloat(M_PI)
            if hero.position.y > enemy.position.y {
                enemy.runAction(SKAction.rotateToAngle(angle - 180 * Pi / 180 , duration: 0))
            } else if hero.position.y < enemy.position.y {
                enemy.runAction(SKAction.rotateToAngle(angle - 180 * Pi / 180 , duration: 0))
            }
        }
        //                    if enemy.name == "Missile8" {
        //                        var heightDif:CGFloat = 0
        //                        if hero.position.y > enemy.position.y {
        //                            heightDif = enemy.position.y - hero.position.y
        //
        //                            if heightDif > self.size.height / 2 {
        //
        //                            }
        //                        } else {
        //                            heightDif = hero.position.y - enemy.position.y
        //                        }
        //
        //                        let Pi = CGFloat(M_PI)
        //                        let DegreesToRadians = Pi / 180
        //                        let RadiansToDegrees = 180 / Pi
        //
        //                        let widthDif:CGFloat = enemy.position.x - hero.position.x
        //                        //sqr(b * b + c * c - 2 * b * c * cos(alpha))
        //                        let lineA1 = widthDif * widthDif + heightDif * heightDif
        //                        let lineA2 = 2 * widthDif * heightDif * cos(90)
        //                        let lineA = sqrt(lineA1 - lineA2)
        //                        //acos((b * b - c * c - a * a) / (-2 * c * a))
        //                        let angle1 = widthDif * widthDif - heightDif * heightDif - lineA * lineA
        //                        let angle2 = -2 * heightDif * lineA
        //                        let angle = acos(angle1 / angle2)
        //
        //                        print(widthDif)
        //                        print(heightDif)
        //                        print(lineA)
        //                        print("____")
        //
        //                        if hero.position.y > enemy.position.y {
        //                            enemy.zRotation = -angle
        //                        } else {
        //                            enemy.zRotation = angle
        //                        }
        //
        //                        print("Angle: \(angle)")
        //                  )
        
        //                    if enemy.name == "Missile8" {
        //                        var heightDif:CGFloat = 0
        //                        if hero.position.y > enemy.position.y {
        //                            heightDif = enemy.position.y - hero.position.y
        //                        } else {
        //                            heightDif = hero.position.y - enemy.position.y
        //                        }
        //                        let widthDif:CGFloat = enemy.position.x - hero.position.x
        //
        //                        var angle = atan2(heightDif, widthDif)
        //                        angle = angle * 100
        //                        print(heightDif)
        //                        print(widthDif)
        //                        print(angle)
        //                        print("-----")
        //
        //                        let Pi = CGFloat(M_PI)
        //                        let DegreesToRadians = Pi / 180
        //
        //                        if hero.position.y > enemy.position.y {
        //                            enemy.zRotation = angle * DegreesToRadians
        //                        } else {
        //                            enemy.zRotation = -angle * DegreesToRadians
        //                        }
        //                        if heightDif != 0 {
        //                            let yMovement:CGFloat = round(widthDif / heightDif)
        //                            print(yMovement)
        //                            if hero.position.y > enemy.position.y {
        //                                enemy.preLocation = yMovement
        //                            } else {
        //                                enemy.preLocation = -yMovement
        //                            }
        //                            
        //                            print("----")
        //                        }
        //                    }

		addChild(enemy)
	}
	
    func spawning(enemy: Enemy) {
        for var i = 0; i < spawnPoints.count; i++ {
            if enemy.spawned == false {
                if spawnPointStats[i].boolValue == true {
                    enemy.yPos = spawnPoints[i]
                    enemy.position.y = enemy.yPos
                    enemy.spawnHeight = enemy.yPos
                    spawnPointStats[i] = false
                    enemy.spawned = true
                    enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, alphaThreshold: 0, size: enemy.size)
                    enemy.physicsBody!.affectedByGravity = false
                    enemy.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue
                    enemy.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue | ColliderType.bonusItem.rawValue
                    enemy.physicsBody!.collisionBitMask = ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue | ColliderType.bonusItem.rawValue
                    enemy.physicsBody!.allowsRotation = false
                }
            }
        }
    }
    
	func resetEnemy(enemyNode:SKSpriteNode, yPos: CGFloat) {
		
		enemyNode.position.x = endOfScreenRight
		enemyNode.position.y = yPos
		
	}
	
	func startGameNormal() {
        
		gameStarted = true
		reloadGame()
	}
	
	func showMenu() {
        
        let transition = SKTransition.fadeWithDuration(1)
        
		let scene = GameScene(size: self.size)
		let skView = self.view as SKView!
		skView.ignoresSiblingOrder = true
		scene.scaleMode = .ResizeFill
		scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		scene.size = skView.bounds.size
        skView.presentScene(scene, transition: transition)
		
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
		scene.highScoreLabel.text = "Highscore: " + String(highScore)
		
	}
	
    func whichAd() {
        let number:Int = Int(arc4random_uniform(5))
        if number == 0 {
            showFSAd()
        } else {
            showAds()
        }
    }
    
    func showFSAd() {
        if interScene.adState == true {
            NSNotificationCenter.defaultCenter().postNotificationName("showFSAd", object: nil)
        }
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
    
	func pauseGame() {
		
		//Spiel pausieren.
		
		if !gameOver {
			
            showAds()
            stopBGAnim()
            
			gamePaused = true
			gamePlay.hidden = false
			gamePlay.alpha = 1
            gamePlay.zPosition = 1.2
            menuPause.hidden = false
            menuPause.alpha = 1
            menuPause.zPosition = 1.2
			gamePause.hidden = true
			hero.paused = true
			
		}
	}
	
	func resumeGame() {
		
		//Spiel fortsetzen.
		
		if !gameOver {
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "gamePaused")

            hideAds()
            
            countDownText.hidden = false
            gamePlay.hidden = true
            gamePlay.zPosition = 0.9
            menuPause.zPosition = 0.9
            menuPause.hidden = true
            countDownRunning = true
            timerPause = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("updateTimerPause"), userInfo: nil, repeats: true)

		}
	}
	
    func updateTimerPause() {
    
        if countDown > 0 {
            
            countDown--
            countDownText.text = String(countDown)
            
        } else {
            
            startBGAnim()
            
            countDown = 3
            countDownText.text = String(countDown)
            countDownText.hidden = true
            timerPause.invalidate()
            countDownRunning = false
            gamePaused = false
            gamePlay.hidden = true
            menuPause.hidden = true
            menuPause.alpha = 0
            gamePlay.alpha = 0
            gamePause.hidden = false
            hero.paused = false
            
        }
        
    }
    
	func heroMovement() {
        
        if touchLocation > (self.size.height / 2) - (hero.size.height / 2){
            touchLocation = (self.size.height / 2) - (hero.size.height / 2)
        } else if touchLocation < -((self.size.height / 2) - (hero.size.height / 2)) {
            touchLocation = -((self.size.height / 2) - (hero.size.height / 2))
        }
		let duration = (abs(hero.position.y - touchLocation)) / hero.movementSpeed
		let moveAction = SKAction.moveToY(touchLocation, duration: NSTimeInterval(duration))
		hero.runAction(moveAction, withKey: "movingA")
	}
	
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        funcTouchesOut(touches, withEvent: event!)
        touchingScreen = false
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if !gamePaused {
			if !gameOver {
                for touch: AnyObject in touches {
                    touchLocation = touch.locationInNode(self).y
                    if heroHeight < touchLocation - 20 {
                        heroMovement()
                        heroHeight = touchLocation
                    } else if heroHeight > touchLocation + 20 {
                        heroMovement()
                        heroHeight = touchLocation
                    }
                }
			}
		}
    }
    
    func removeButtonAnim() {
    
        if lastSpriteName == self.refresh.name {
        
            refresh.removeAllActions()
            refresh.runAction(buttonPressLight)
        
        } else if lastSpriteName == self.menu.name {
        
            menu.removeAllActions()
            menu.runAction(buttonPressLight)
        
        } else if lastSpriteName == self.gamePause.name {
        
            gamePause.removeAllActions()
            gamePause.runAction(buttonPressLight)
        
        } else if lastSpriteName == self.gamePlay.name {
        
            gamePlay.removeAllActions()
            gamePlay.runAction(buttonPressLight)
        
        } else if lastSpriteName == self.menuPause.name {
        
            menuPause.removeAllActions()
            menuPause.runAction(buttonPressLight)
            
        }
    
    }
    
    func funcTouchesIn(touches: Set<NSObject>, withEvent event: UIEvent) {
    
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(self).y
            let location = touch.locationInNode(self)
            if !gamePaused {
                if gameOver {
                    if self.nodeAtPoint(location) == self.refresh {
                        lastSpriteName = self.refresh.name!
                        if gameOver {
                            if !countDownRunning {
                                self.refresh.runAction(buttonPressDark)
                            }
                        }
                    } else if self.nodeAtPoint(location) == self.menu {
                        lastSpriteName = self.menu.name!
                        if gameOver {
                            if !countDownRunning {
                                self.menu.runAction(buttonPressDark)
                            }
                        }
                    }
                } else if !gameOver {
                    
                    if self.nodeAtPoint(location) == self.gamePause {
                        lastSpriteName = self.gamePause.name!
                        self.gamePause.runAction(buttonPressDark)
                    } else {
                        if lastSpriteName == "empty" {
                            buttonRemoveAction()
                        } else {
                            buttonRemoveAction()
                        }

                    }
                }
            } else if self.nodeAtPoint(location) == self.gamePlay {
                lastSpriteName = self.gamePlay.name!
                if !countDownRunning {
                    self.gamePlay.runAction(buttonPressDark)
                }
            } else if self.nodeAtPoint(location) == self.menuPause {
                lastSpriteName = self.menuPause.name!
                if !countDownRunning {
                    self.menuPause.runAction(buttonPressDark)
                }
            }
        }
    }
    
    func funcTouchesOut(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(self).y
            let location = touch.locationInNode(self)
            if !gamePaused {
                if gameOver {
                    if self.nodeAtPoint(location) == self.refresh {
                        if gameOver {
                            if !countDownRunning {
                                removeButtonAnim()
                                if lastSpriteName == self.refresh.name {
                                    self.lastSpriteName = "empty"
                                    self.refresh.runAction(buttonPressLight){
                                        self.showPlayScene()
                                        //self.reloadGame() 1337
                                        //self.countDownRunning = true
                                    }
                                }
                            }
                        }
                    } else if self.nodeAtPoint(location) == self.menu {
                        if gameOver {
                            if !countDownRunning {
                                removeButtonAnim()
                                if lastSpriteName == self.menu.name {
                                    self.lastSpriteName = "empty"
                                    self.menu.runAction(buttonPressLight){
                                        self.showMenu()
                                        self.gameStarted = false
                                    }
                                }
                            }
                        }
                    } else {
                        if gameOverMenuLoaded {
                            buttonRemoveAction()
                        }
                    }
                } else if !gameOver {
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
                }
            } else if self.nodeAtPoint(location) == self.gamePlay {
                if !countDownRunning {
                    removeButtonAnim()
                    if lastSpriteName == self.gamePlay.name {
                        self.lastSpriteName = "empty"
                        self.gamePlay.runAction(buttonPressLight){
                            self.resumeGame()
                        }
                    }
                }
            } else if self.nodeAtPoint(location) == self.menuPause {
                if !countDownRunning {
                    removeButtonAnim()
                    if lastSpriteName == self.menuPause.name {
                        self.lastSpriteName = "empty"
                        self.menuPause.runAction(buttonPressLight){
                            self.showMenu()
                        }
                    }
                }
            } else {
                
                if lastSpriteName == self.menuPause.name {
                
                        menuPause.removeAllActions()
                        menuPause.runAction(buttonPressLight)
                
                } else if lastSpriteName == self.gamePlay.name {
                
                    gamePlay.removeAllActions()
                    gamePlay.runAction(buttonPressLight)
                
                } else {
                
                    if gameOverMenuLoaded == true {
                        buttonRemoveAction()
                    }
    
                }
            }
        }
    }
    
    func buttonRemoveAction() {
        menuPause.removeAllActions()
        menu.removeAllActions()
        refresh.removeAllActions()
        gamePlay.removeAllActions()
        gamePause.removeAllActions()
        self.menuPause.runAction(buttonPressLight)
        self.menu.runAction(buttonPressLight)
        self.refresh.runAction(buttonPressLight)
        self.gamePlay.runAction(buttonPressLight)
        self.gamePause.runAction(buttonPressLight)
    }
    
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
							
        funcTouchesIn(touches, withEvent: event!)
        
    }

	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
        if NSUserDefaults.standardUserDefaults().boolForKey("gamePaused").boolValue == true {
            if !gameOver {
                pauseGame()
            }
        }
        
		if !gamePaused {
			if !gameOver {
				updateBGPosition()
                //updateBackgroundEmitter()
			}
            updateEnemiesPosition()
            updateBonusItem()
            updateHeroEmitter()
            
        }
    }
	
    func updateOxygenBar() {
        if oxygen > 99 {
            oxygen = 99
        }
        if oxygen % 2 == 0 {
            oxygenBar.texture = oxygenBarAnimationFrames[(oxygen + 1) / 2]
        } else {
            oxygenBar.texture = oxygenBarAnimationFrames[(oxygen) / 2]
        }
    }
    
    func updateBonusItem() {
        if !gameOver {
            if updateBonusTick > 0 {
                updateBonusTick--
            } else {
                updateBonusTick = 10
                if oxygen > 0 {
                    oxygen--
                    updateOxygenBar()
                } else {
                    heroGameEnding(nil)
                }
            }
            if oxygen <= oxygenMax / 2 {
                if bonusItemAlive == false {
                    didOxygenCollide = false
                    didOxygenCollideEnemy = false
                    addBonusItems("Oxygen15")
                }
            }
        }
        if bonusItems.count >= 1 {
            for bonusItem in bonusItems {
                for var i = 0; i < spawnPoints.count; i++ {
                    if bonusItem.spawned == false {
                        if spawnPointStats[i].boolValue == true {
                            bonusItem.position.y = spawnPoints[i]
                            bonusItem.spawnHeight = spawnPoints[i]
                            bonusItem.position.x = endOfScreenRight
                            spawnPointStats[i] = false
                            bonusItem.spawned = true
                            bonusItem.physicsBody = SKPhysicsBody(texture: bonusItem.texture!, alphaThreshold: 0, size: bonusItem.size)
                            bonusItem.physicsBody!.affectedByGravity = false
                            bonusItem.physicsBody!.categoryBitMask = ColliderType.bonusItem.rawValue
                            bonusItem.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue
                            bonusItem.physicsBody!.collisionBitMask = ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue
                            bonusItem.physicsBody!.allowsRotation = false
                            bonusItem.moving = true
                        }
                    }
                }
                if bonusItem.moving == true {
                    if bonusItem.position.x > endOfScreenLeft {
                        bonusItem.position.x -= totalSpeedBonusItem
                        if bonusItem.rotationDirection == 0 {
                            bonusItem.zRotation = bonusItem.zRotation + 0.05
                        } else {
                            bonusItem.zRotation = bonusItem.zRotation - 0.05
                        }
                    } else {
                        bonusItems = []
                        bonusItem.removeFromParent()
                        if !gameOver {
                            addBonusItems("Oxygen15")
                        }
                    }
                    if bonusItem.position.x < self.size.width / 2  - 200{
                        if bonusItem.spawnHeight == 9999 {
                            
                        } else {
                            for var i = 0; i < spawnPointStats.count; i++ {
                                if spawnPoints[i] == bonusItem.spawnHeight {
                                    spawnPointStats[i] = true
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
    
    func updateBGPosition() {
    
        if bg.position.x <= endOfScreenLeft - self.size.width / 2{
        
            bg.position.x = self.size.width * 2
            bgAn.position.x = bg.position.x
            stopBGAnim()
            startBGAnim()
        
        }
        
        if bg2.position.x <= endOfScreenLeft - self.size.width / 2{
        
            bg2.position.x = self.size.width * 2
            bg2An.position.x = bg2.position.x
            stopBGAnim()
            startBGAnim()
        
        }
    
        if bg3.position.x <= endOfScreenLeft - self.size.width / 2{
        
            bg3.position.x = self.size.width * 2
            bg3An.position.x = bg3.position.x
            stopBGAnim()
            startBGAnim()
        
        }
        
    }
    
    func updateBackgroundEmitter() {
        if bgEmit == true {
            bgEmit = false
            let rNum:Int = Int(arc4random_uniform(UInt32(backgroundAnimationFrames.count)))
            
            self.bgAn.texture = self.backgroundAnimationFrames[rNum]
            self.bg2An.texture = self.backgroundAnimationFrames[rNum]
            self.bg3An.texture = self.backgroundAnimationFrames[rNum]
            
            UIView.animateWithDuration(5.0, animations: {
                self.bgAn.alpha = 1.0
                self.bg2An.alpha = 1.0
                self.bg3An.alpha = 1.0
                }, completion: {(finished: Bool) -> Void in
                    UIView.animateWithDuration(5.0, animations: {
                        self.bgAn.alpha = 0
                        self.bg2An.alpha = 0
                        self.bg3An.alpha = 0
                    })
            })
        }
    }
	
	func updateHeroEmitter(){

        if hero.emit == true {
            hero.emit = false
            if deathEnemy != nil {
                deathEnemy.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.08, resize: true, restore: true), completion: {
                    
                    self.deathEnemy.hidden = true
                    
                })
            }
            hero.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.08, resize: true, restore: true), completion: {
				
                self.hero.hidden = true
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
                            
                            enemy.position.y = CGFloat((Double(enemy.position.y))) + CGFloat(sin(enemy.angle / 2) * enemy.range)
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
                            if !gameOver {
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
                                //stopBGAnim()
                                
                            }
                            
                        }
                        if enemy.position.x < hero.position.x - enemy.size.width {
                            if enemy.scored == false {
                                updateScore()
                                enemy.scored = true
                            }
                        }
                        if enemy.position.x < self.size.width / 2  - 200{
                            if enemy.name == "Satellite15" {
                                if !gameOver {
                                    playSatelliteSound()
                                }
                            }
                            if enemy.spawnHeight == 9999 {
                            } else {
                                for var i = 0; i < spawnPointStats.count; i++ {
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
		
		score++
		scoreLabel.text = String(score)
		
		if score % 5 == 0 {
			
			totalSpeedAsteroid = totalSpeedAsteroid + 0.1
			totalSpeedSatellite = totalSpeedSatellite + 0.1
			totalSpeedRocket = totalSpeedRocket + 0.1
            totalSpeedBonusItem = totalSpeedBonusItem + 0.1
			hero.movementSpeed = hero.movementSpeed + 5
			
            if score > bgAnCount {
                bgEmit = true
                bgAnCount = score
            }
		}
		
		if score <= 50 {
		
			if score % 10 == 0 {
			
				addEnemies()
				
			}
		}
		
		if (enemies.count - 5) < (score / 10) {
		
			addEnemies()
		}
	}
    
    func prepareSatelliteSound() {
        let satelliteSoundURL:NSURL = NSBundle.mainBundle().URLForResource("satellite", withExtension: "m4a")!
        do { satelliteSound = try AVAudioPlayer(contentsOfURL: satelliteSoundURL, fileTypeHint: nil) } catch _ { return }
        satelliteSound.numberOfLoops = 1
        satelliteSound.prepareToPlay()
    }
    
    func playSatelliteSound() {
        if interScene.soundState == true {
            let number:Int = Int(arc4random_uniform(1000))
            if number == 1 {
                satelliteSound.play()
            }
        }
    }
}

extension Array {
    func find(includedElement: Element -> Bool) -> Int?{
        for (idx, element) in self.enumerate() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}