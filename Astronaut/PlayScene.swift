//
//  PlayScene.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit
import iAd

class PlayScene: SKScene, SKPhysicsContactDelegate {
	var hero = Hero(imageNamed: "Astronaut25")
    var touchLocation = CGFloat()
	var gameOver = true
	var gameStarted = false
	var enemies:[Enemy] = []
	var enemiesIndex:[Int] = []
	var endOfScreenRight = CGFloat()
	var endOfScreenLeft = CGFloat()
	var gamePaused = false
	var enemyCount = 0
	
    var bgEmit = false
    var bgAnimSpeed:CGFloat = 16
	
    var gameOverMenuLoaded = false
    
    var heroColorRed:CGFloat = 1
    var heroColorGreen:CGFloat = 1
    var heroColorBlue:CGFloat = 1
    var heroBlendFactor:Float = 0.4
    
    var playSceneActive = false
    
    var lastSpriteName:String = "empty"
    
	var highScore:Int = 0
    
    var explosionAnimationFrames = [SKTexture]()
    var backgroundAnimationFrames = [SKTexture]()
    
	var gameSpeed:Float = 1
	var gameProgress:Int = 0
	var totalSpeedAsteroid:CGFloat = 3.5
	var totalSpeedSatellite:CGFloat = 2.5
	var totalSpeedRocket:CGFloat = 6
	var normalSpeedAsteroid:CGFloat = 3.5
	var normalSpeedSatellite:CGFloat = 2.5
	var normalSpeedRocket:CGFloat = 6
	
    var viewController: GameViewController!
    
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
	var totalScore = SKLabelNode(text: "0")
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
	var countDownText = SKLabelNode(text: "3")
	enum ColliderType:UInt32 {
		
		case Hero = 1
		case Enemy = 2
		
	}
    
    override func didMoveToView(view: SKView) {
        
		//NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highScore") //Reset Highscore on start!
        
        shiftBackground = SKAction.moveByX(-bg.size.width, y: 0, duration: 0)
        replaceBackground = SKAction.moveByX(bg.size.width, y:0, duration: 0)
        movingAndReplacingBackground = SKAction.repeatActionForever(SKAction.sequence([shiftBackground,replaceBackground]))
        
		self.physicsWorld.contactDelegate = self
		
        scalingFactor = (self.size.height * 2) / 640 //iPhone 5 Height, so iPhone 5 has original scaled sprites.
        print("Scaling Factor: ", terminator: "")
        print(scalingFactor)
        
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
        let backgroundAtlas = SKTextureAtlas(named: "background")
        
        let numImagesExplosion = explosionAtlas.textureNames.count
        for var i=1; i<(numImagesExplosion + 3) / 3; i++ {
        
            let explosionTextureName = "explosion32-\(i)"
            explosionAnimationFrames.append(explosionAtlas.textureNamed(explosionTextureName))
        
        }
        
        let numImagesBackground = backgroundAtlas.textureNames.count
        for var i=1; i<(numImagesBackground / 3); i++ {
        
            let backgroundTextureName = "background107_\(i)"
            backgroundAnimationFrames.append(backgroundAtlas.textureNamed(backgroundTextureName))
        
        }
        
        if NSUserDefaults.standardUserDefaults().floatForKey("heroColorRed") != 0.0 {
            heroColorRed = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("heroColorRed"))
        } else {
            heroColorRed = 1
            NSUserDefaults.standardUserDefaults().setFloat(1, forKey: "heroColorRed")
        }
        if NSUserDefaults.standardUserDefaults().floatForKey("heroColorGreen") != 0.0 {
            heroColorGreen = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("heroColorGreen"))
        } else {
            heroColorGreen = 1
            NSUserDefaults.standardUserDefaults().setFloat(1, forKey: "heroColorGreen")
        }
        if NSUserDefaults.standardUserDefaults().floatForKey("heroColorBlue") != 0.0 {
            heroColorBlue = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("heroColorBlue"))
        } else {
            heroColorBlue = 1
            NSUserDefaults.standardUserDefaults().setFloat(1, forKey: "heroColorBlue")
        }
        
        hero.color = UIColor(red: heroColorRed , green: heroColorGreen , blue: heroColorBlue, alpha: 1.0)
		hero.colorBlendFactor = 0.4
		
        print(heroColorRed)
        print(heroColorGreen)
        print(heroColorBlue)
		
		scoreLabel = SKLabelNode(text: "0")
		scoreLabel = SKLabelNode(fontNamed: "Minecraft")
		scoreLabel.fontSize = 22
		scoreLabel.fontColor = UIColor.whiteColor()
		scoreLabel.position.y = (self.size.height / 2) - 40
		scoreLabel.position.x = -(self.size.width / 2) + 40
        scoreLabel.zPosition = 1.2
		
		countDownText = SKLabelNode(fontNamed: "Minecraft")
		countDownText.fontSize = 22
		countDownText.fontColor = UIColor.whiteColor()
		countDownText.position.y = (self.size.height / 8)
        countDownText.zPosition = 1.2
		
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
		totalScore.fontSize = 18
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
		totalScore.fontColor = UIColor.whiteColor()
		totalScore.hidden = true
		totalScore.alpha = 0
		
		menu.name = "menu"
		menu.hidden = true
		menu.alpha = 0
        
		startGameNormal()
		
	}
	
    func openGameOverMenu() {

        showAds()
        
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
    
    func heroGameEnding() {
			
			hero.physicsBody = nil
			gameOver = true
			gamePause.hidden = true
			hero.removeAllActions()
			scoreLabel.hidden = true
			stopBGAnim()
			
			hero.emit = true
			
			let scoreBefore:Int = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
			
			if score <= scoreBefore {
				
				totalScore.hidden = false
				totalScore.text = ("You reached ") + String(score) + (" points!")
				totalScore.runAction(SKAction.fadeInWithDuration(1.0))
				
			} else if score > scoreBefore {
				
				NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highScore")
				NSUserDefaults.standardUserDefaults().synchronize()
				//submit score to GameCenter
				EasyGameCenter.reportScoreLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard", score: score)
				
				totalScore.hidden = false
				totalScore.text = ("New Highscore: ") + String(score) + (" points!")
				totalScore.runAction(SKAction.fadeInWithDuration(1.0))
				
			}
	}
	
	func didBeginContact(contact: SKPhysicsContact) {
		
        //let firstNode = contact.bodyA.node as! SKSpriteNode
        //let secondNode = contact.bodyB.node as! SKSpriteNode
        
        if contact.bodyA.categoryBitMask == ColliderType.Hero.rawValue && contact.bodyB.categoryBitMask == ColliderType.Enemy.rawValue {
			
            heroGameEnding()
        
        } else if contact.bodyA.categoryBitMask == ColliderType.Enemy.rawValue && contact.bodyB.categoryBitMask == ColliderType.Hero.rawValue {
			
            heroGameEnding()
        
        } //else if contact.bodyA.categoryBitMask == ColliderType.Enemy.rawValue && contact.bodyB.categoryBitMask == ColliderType.Enemy.rawValue {
//        
//            if firstNode.position.x == endOfScreenRight {
//            
//                /*if firstNode.position.y > self.frame.height / 2 - 50 {
//                
//                    firstNode.position.y -= firstNode.size.height / 2 - 10
//                    firstNode.zRotation = 0
//                    println("moved first Node down")
//                    
//                } else {
//                
//                    firstNode.position.y += firstNode.size.height / 2 + 10
//                    firstNode.zRotation = 0
//                    println("moved first Node up")
//                }
//                
//            
//            } else if secondNode.position.x == endOfScreenRight {
//
//                if secondNode.position.y > self.frame.height / 2 - 50 {
//                    
//                    secondNode.position.y -= secondNode.size.height / 2 - 10
//                    firstNode.zRotation = 0
//                    println("moved second Node down")
//                    
//                } else {
//                    
//                    secondNode.position.y += secondNode.size.height / 2 + 10
//                    firstNode.zRotation = 0
//                    println("moved second Node up")
//                }*/
//                
//            } else {
//                
//                //println("collision on screen")
//
//            }
//		}
		
	}
    
    func enemyCollisionOnStart(firstNode firstNode: SKSpriteNode, secondNode: SKSpriteNode) {
    
        firstNode.removeAllActions()
        firstNode.hidden = true
        firstNode.position.x = endOfScreenRight + 200
        firstNode.removeFromParent()
        
        print("reranged starting pos")
        addEnemies()
        
    }
    
	func reloadGame() {
		
		scoreLabel.hidden = false
        hero.hidden = false
		countDownText.hidden = false
		hero.removeAllActions()

		hero.movementSpeed = Hero().movementSpeed
		hero.physicsBody = SKPhysicsBody(texture: hero.texture!, alphaThreshold: 0, size: hero.size)
		hero.physicsBody!.affectedByGravity = false
		hero.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
		hero.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue
		hero.physicsBody!.collisionBitMask = ColliderType.Enemy.rawValue
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
		gameProgress = 0
		gameSpeed = 1
		totalSpeedAsteroid = normalSpeedAsteroid
		totalSpeedSatellite = normalSpeedSatellite
		totalSpeedRocket = normalSpeedRocket
		
		for enemy in enemies {
			
			resetEnemy(enemy, yPos: enemy.yPos)
			enemy.hidden = true
			
		}
		
		enemies.removeAll(keepCapacity: false)
        enemiesIndex.removeAll(keepCapacity: false)
		addEnemies()
		
		for var i = 1; i < startEnemy; i++ {
			
			self.addEnemies()
			
		}
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
		
		
	}
	
    func startBGAnim() {
        bg.runAction(SKAction.moveToX(bg.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
        bgAn.runAction(SKAction.moveToX(bgAn.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
        bg2.runAction(SKAction.moveToX(bg2.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
        bg2An.runAction(SKAction.moveToX(bg2An.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
        bg3.runAction(SKAction.moveToX(bg3.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
        bg3An.runAction(SKAction.moveToX(bg3An.position.x - self.size.width * 2 - SKSpriteNode(imageNamed: "Satellite15").size.width / 2, duration: NSTimeInterval(self.size.width / CGFloat(gameSpeed) / bgAnimSpeed)))
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
	
	func addEnemies() {
		enemyCount++
		var number:Int = Int(arc4random_uniform(11))
		let upDown:Int = Int(arc4random_uniform(2))
		let heightNumber:Int = Int((self.size.height / 2) - (SKSpriteNode(imageNamed: "Asteroid16").size.height / 2))
		let height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
		let rotationSpeedRandom:CGFloat = CGFloat(arc4random_uniform(2)  + 1)
        let rotationDirection:Int = Int(arc4random_uniform(2))
        let preLocation:CGFloat = 0

		//number = 6
		
		print(number)
		
		if number == 0 || number == 1 || number == 2 || number == 3 || number == 4 || number == 5 {
			if upDown == 0  {
				addEnemy(named: "Asteroid16", movementSpeed: Float(normalSpeedAsteroid) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, health: 10, uniqueIdentifier: enemyCount)
			} else if upDown == 1 {
                addEnemy(named: "Asteroid16", movementSpeed: Float(normalSpeedAsteroid) * gameSpeed, yPos: CGFloat(height), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, health: 10, uniqueIdentifier: enemyCount)
			}
			
			
		} else if number == 6 || number == 7 || number == 8 || number == 9 {
			if upDown == 0 {
                //height = height - (90 * Int(scalingFactor))
//                if height >= Int((self.size.height / 2) - (90 * scalingFactor)) {
//                    height = (height - 90)
//                }
                addEnemy(named: "Satellite15", movementSpeed: Float(normalSpeedSatellite) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 3, uniqueIdentifier: enemyCount)
			} else if upDown == 1 {
//                if height <= Int(-(self.size.height / 2) + (90 * scalingFactor)) {
//                    height = -(height - 90)
//                }
                addEnemy(named: "Satellite15", movementSpeed: Float(normalSpeedSatellite) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 3, uniqueIdentifier: enemyCount)
			}
		} else if number == 10 {
			if upDown == 0 {
                addEnemy(named: "Missile8", movementSpeed: Float(normalSpeedRocket) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 1, uniqueIdentifier: enemyCount)
			} else if upDown == 1 {
                addEnemy(named: "Missile8", movementSpeed: Float(normalSpeedRocket) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 1, uniqueIdentifier: enemyCount)
			}
		}
		
	}
	
	func addEnemy(named named: String, movementSpeed:Float, yPos: CGFloat, rotationSpeed:CGFloat, rotationDirection:Int, preLocation:CGFloat, health:Int, uniqueIdentifier:Int) {
		
		let enemy = Enemy(imageNamed: named)
		
        enemy.setScale(scalingFactor)
        enemy.zPosition = 1.1
        
		enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, alphaThreshold: 0, size: enemy.size)
		enemy.physicsBody!.affectedByGravity = false
		enemy.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue
		enemy.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue
		enemy.physicsBody!.collisionBitMask = ColliderType.Hero.rawValue
		enemy.physicsBody!.allowsRotation = false
        
		enemy.movementSpeed = movementSpeed
		enemy.yPos = yPos
		enemy.rotationSpeed = rotationSpeed
		enemy.rotationDirection = rotationDirection
		enemy.preLocation = preLocation
		enemy.health = health
		enemy.uniqueIndetifier = uniqueIdentifier
        enemy.scored = false
        enemy.setRandomFrame()
		enemies.append(enemy)
		enemiesIndex.append(uniqueIdentifier)
		
		enemy.name = named
		resetEnemy(enemy, yPos: yPos)
		
        if enemy.name == "Missile8" {
            let yMovement:CGFloat = (hero.position.y - enemy.position.y) / (hero.position.x - enemy.position.x)
            enemy.preLocation = yMovement * 2
            //let an:CGFloat = hero.position.x - enemy.position.x
            //let geg:CGFloat = hero.position.y - enemy.position.y
            //var angleBetween:CGFloat = sin(an / geg)
            let angle = atan2(hero.position.y - enemy.position.y, hero.position.x - enemy.position.x)
            let Pi = CGFloat(M_PI)
            if hero.position.y > enemy.position.y {
                enemy.runAction(SKAction.rotateToAngle(angle - 180 * Pi / 180 , duration: 0))
            } else if hero.position.y < enemy.position.y {
                enemy.runAction(SKAction.rotateToAngle(angle - 180 * Pi / 180, duration: 0))
            }
        }
        
		addChild(enemy)

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
        self.playSceneActive = false
        skView.presentScene(scene, transition: transition)
		
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
		scene.highScoreLabel.text = "Highscore: " + String(highScore)
		
	}
	
    func showAds(){
        NSNotificationCenter.defaultCenter().postNotificationName("showadsID", object: nil)
    }
    
    func hideAds(){
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
				heroMovement()
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
                            //removeAllActions()
                            buttonRemoveAction()
                            self.heroMovement()
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
                                        self.reloadGame()
                                        self.countDownRunning = true
                                        //self.lastSpriteName = "empty"
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
                                        //self.lastSpriteName = "empty"
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
                                //self.lastSpriteName = "emtpy"
                            }
                        }
                    } else {
                        if lastSpriteName == "empty" {
                            //removeAllActions()
                            buttonRemoveAction()
                            self.heroMovement()
                        } else {
                            buttonRemoveAction()
                            self.lastSpriteName = "empty"
                        }
                        //removeAllActions()
                        //buttonRemoveAction()
                        //self.heroMovement()
                    }
                }
            } else if self.nodeAtPoint(location) == self.gamePlay {
                if !countDownRunning {
                    removeButtonAnim()
                    if lastSpriteName == self.gamePlay.name {
                        self.lastSpriteName = "empty"
                        self.gamePlay.runAction(buttonPressLight){
                            self.resumeGame()
                            //self.lastSpriteName = "empty"
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
                            //self.lastSpriteName = "empty"
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
				updateEnemiesPosition()
                //updateBackgroundEmitter()
			}
            
            updateHeroEmitter()
            
        }
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
    
    func updateBackgroundEmitterOld() {
        if bgEmit == true {
            bgEmit = false
            bg.runAction(SKAction.animateWithTextures(backgroundAnimationFrames, timePerFrame: 0.05))
            bg.runAction(SKAction.animateWithTextures(backgroundAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
            
                self.bg.texture = SKTexture(imageNamed: "Background188")
                self.bg2.texture = SKTexture(imageNamed: "Background188")
                self.bg3.texture = SKTexture(imageNamed: "Background188")
            })
            bg2.runAction(SKAction.animateWithTextures(backgroundAnimationFrames, timePerFrame: 0.05))
            bg3.runAction(SKAction.animateWithTextures(backgroundAnimationFrames, timePerFrame: 0.05))
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
            hero.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
				
                self.hero.hidden = true
                self.openGameOverMenu()
                
            })
        }
	}
	
	func updateEnemiesPosition(){
		
		for enemy in enemies {
			
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
                    //print(enemy.position.y)
					
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
						enemy.position.x -= CGFloat(totalSpeedAsteroid)
                    } else if enemy.name == "Satellite15" {
						enemy.position.x -= CGFloat(totalSpeedSatellite)
					} else if enemy.name == "Missile8" {
						enemy.position.x -= CGFloat(totalSpeedRocket)
                    }
					
				} else {
                    
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
						
						enemy.position.x = endOfScreenRight
						enemy.currentFrame = 0
						enemy.setRandomFrame()
						enemy.moving = false
						//enemy.range = enemy.range + 0.1
						
					}
					
					enemy.scored = false
					
				}
                if enemy.position.x < hero.position.x - enemy.size.width {
                    if enemy.scored == false {
                        updateScore()
                        enemy.scored = true
                    }
                }
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
			hero.movementSpeed = hero.movementSpeed + 5
			
            if score > bgAnCount {
                bgEmit = true
                bgAnCount = score
            }
			gameProgress++
			
			
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