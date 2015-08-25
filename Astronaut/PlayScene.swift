//
//  PlayScene.swift
//  Astronaut
//
//  Created by Yannik Lauenstein on 20/08/15.
//  Copyright (c) 2015 YaLu. All rights reserved.
//

import SpriteKit

class PlayScene: SKScene, SKPhysicsContactDelegate {
	var hero:Hero!
	var touchLocation = CGFloat()
	var gameOver = true
	var gameStarted = false
	var enemys:[Enemy] = []
	var enemysIndex:[Int] = []
	var endOfScreenRight = CGFloat()
	var endOfScreenLeft = CGFloat()
	var gamePaused = false
	var enemyCount = 0
	
    var heroColorRed:CGFloat = 1
    var heroColorGreen:CGFloat = 1
    var heroColorBlue:CGFloat = 1
    var heroBlendFactor:Float = 0.4
    
    var playSceneActive = false
    
	var highScore:Int = 0
	
    var explosionAnimationFrames = [SKTexture]()
    
	var gameSpeed:Float = 1.3
	var gameProgress:Int = 0
	var totalSpeedAsteroid:CGFloat = 1.5
	var totalSpeedSatellite:CGFloat = 2
	var totalSpeedRocket:CGFloat = 3
	var normalSpeedAsteroid:CGFloat = 1.5
	var normalSpeedSatellite:CGFloat = 2
	var normalSpeedRocket:CGFloat = 3
	
	var countDownRunning = false
	
	let bg = SKSpriteNode(imageNamed: "Background188")
    
	var score = 0
	var scoreLabel = SKLabelNode()
	var refresh = SKSpriteNode(imageNamed: "ReplayButton32")
	var totalScore = SKLabelNode(text: "0")
	var menu = SKSpriteNode(imageNamed: "MenuButton32")
	
	var gamePause = SKSpriteNode(imageNamed: "PauseButton32")
	var gamePlay = SKSpriteNode(imageNamed: "PlayButton32")
    var menuPause = SKSpriteNode(imageNamed: "MenuButton32")
    
    var startEnemy:Int = 3
	
    var touchingScreen = false
    var touchYPosition:CGFloat = 0
    
    let buttonPressDark = SKAction.colorizeWithColor(UIColor.blackColor(), colorBlendFactor: 0.2, duration: 0.2)
    let buttonPressLight = SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 0.2, duration: 0.2)
    
	var timer = NSTimer()
    var timerPause = NSTimer()
	var countDown = 3
	var countDownText = SKLabelNode(text: "3")
	enum ColliderType:UInt32 {
		
		case Hero = 1
		case Enemy = 2
		
	}
	
	override func didMoveToView(view: SKView) {
		//NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highScore") Reset Highscore on start!
		
		self.physicsWorld.contactDelegate = self
		endOfScreenLeft = (self.size.width / 2) * CGFloat(-1) - (SKSpriteNode(imageNamed: "Satellite15").size.width / 2)
		endOfScreenRight = (self.size.width / 2) + (SKSpriteNode(imageNamed: "Satellite15").size.width / 2)
		
		addChild(bg)
		addHero()
		
		highScore = NSUserDefaults.standardUserDefaults().integerForKey("highScore")
		
        let explosionAtlas = SKTextureAtlas(named: "explosion")
        
        let numImages = explosionAtlas.textureNames.count
        for var i=1; i<(numImages + 3) / 3; i++ {
        
            let explosionTextureName = "explosion32-\(i)"
            explosionAnimationFrames.append(explosionAtlas.textureNamed(explosionTextureName))
        
        }
        
        heroColorRed = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("heroColorRed"))
        heroColorGreen = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("heroColorGreen"))
        heroColorBlue = CGFloat(NSUserDefaults.standardUserDefaults().floatForKey("heroColorBlue"))
        
        hero.color = UIColor(red: heroColorRed , green: heroColorGreen , blue: heroColorBlue, alpha: 1.0)
		hero.colorBlendFactor = 0.4
		
        println(heroColorRed)
        println(heroColorGreen)
        println(heroColorBlue)
        
		scoreLabel = SKLabelNode(text: "0")
		scoreLabel.fontColor = UIColor.whiteColor()
		scoreLabel.position.y = (self.size.height / 2) - 40
		scoreLabel.position.x = -(self.size.width / 2) + 40
		
		countDownText.fontColor = UIColor.whiteColor()
		countDownText.setScale(2.0)
		countDownText.position.y = (self.size.height / 8)
		
		refresh.position.y = 0
		refresh.position.x = -(self.size.width / 8)
		
		menu.position.y = 0
		menu.position.x = (self.size.width / 8)
		
		gamePause.position.y = -(self.size.height / 2) + 40
		gamePause.position.x = -(self.size.width / 2) + 40
		
		gamePlay.position.y = 0
		gamePlay.position.x = -(self.size.width / 8)
        
        menuPause.position.y = 0
        menuPause.position.x = self.size.width / 8
        
		totalScore.position.x = 0
		totalScore.position.y = self.size.height / 8
		
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
		refresh.zPosition = 1.1
		refresh.alpha = 0
		
		gamePlay.name = "gamePlay"
		gamePlay.hidden = true
		gamePlay.zPosition = 1.1
		gamePlay.alpha = 0
		
        menuPause.name = "menuPause"
        menuPause.hidden = true
        menuPause.zPosition = 1.1
        menuPause.alpha = 0
        
		gamePause.name = "gamePause"
		gamePause.hidden = true
		gamePause.zPosition = 1.1
		gamePause.alpha = 0
		
		totalScore.name = "totaScore"
		totalScore.fontColor = UIColor.whiteColor()
		totalScore.hidden = true
		totalScore.zPosition = 1.1
		totalScore.alpha = 0
		
		menu.name = "menu"
		menu.hidden = true
		menu.zPosition = 1.1
		menu.alpha = 0
		
		startGameNormal()
		
	}
	
    func openGameOverMenu() {
    
        refresh.hidden = false
        refresh.runAction(SKAction.fadeInWithDuration(1.0))
        refresh.zPosition = 1.1
        menu.zPosition = 1.1
        gamePlay.zPosition = 0.9
        menuPause.zPosition = 0.9
        menu.hidden = false
        menu.runAction(SKAction.fadeInWithDuration(1.0))
        
    }
    
    func heroGameEnding() {
    
        gameOver = true
        gamePause.hidden = true
        hero.removeAllActions()
        
        hero.emit = true
        
        if score > NSUserDefaults.standardUserDefaults().integerForKey("highScore") {
            
            NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highScore")
            NSUserDefaults.standardUserDefaults().synchronize()
            //submit score to GameCenter
            EasyGameCenter.reportScoreLeaderboard(leaderboardIdentifier: "astronautgame_leaderboard", score: score)
            
            totalScore.hidden = false
            totalScore.text = ("New Highscore: ") + String(score) + (" points!")
            totalScore.runAction(SKAction.fadeInWithDuration(1.0))
            
        } else {
            
            totalScore.hidden = false
            totalScore.text = ("You reached ") + String(score) + (" points!")
            totalScore.runAction(SKAction.fadeInWithDuration(1.0))
            
        }
    }
    
	func didBeginContact(contact: SKPhysicsContact) {
		
        let firstNode = contact.bodyA.node as! SKSpriteNode
        let secondNode = contact.bodyB.node as! SKSpriteNode
        
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

    func enemyCollisionOnStart(#firstNode: SKSpriteNode, secondNode: SKSpriteNode) {
    
        firstNode.removeAllActions()
        firstNode.hidden = true
        firstNode.position.x = endOfScreenRight + 200
        firstNode.removeFromParent()
        
        println("reranged starting pos")
        addEnemys()
        
    }
    
	func reloadGame() {
		
        
        
        hero.hidden = false
		countDownText.hidden = false
		hero.removeAllActions()
		
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
		
		for enemy in enemys {
			
			resetEnemy(enemy, yPos: enemy.yPos)
			enemy.hidden = true
			
		}
		
		enemys.removeAll(keepCapacity: false)
		addEnemys()
		
		for var i = 1; i < startEnemy; i++ {
			
			self.addEnemys()
			
		}
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
		
		
	}
	
	func updateTimer() {
		
		if countDown > 0 {
			
			if hero.position.y != 0 {
				
				hero.position.y = 0
				
			}
			
			countDown--
			countDownText.text = String(countDown)
			
		} else {
			
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
		
		hero.physicsBody = SKPhysicsBody(texture: hero.texture, alphaThreshold: 0, size: hero.size)
		hero.physicsBody!.affectedByGravity = false
		hero.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
        hero.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue
		hero.physicsBody!.collisionBitMask = ColliderType.Enemy.rawValue
		hero.physicsBody!.allowsRotation = false
		
		addChild(hero)
		
	}
	
	func addEnemys() {
		enemyCount++
		var number:Int = Int(arc4random_uniform(11))
		var upDown:Int = Int(arc4random_uniform(2))
		var heightNumber:Int = Int((self.size.height / 2) - 15)
		var height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
		var rotationSpeedRandom:CGFloat = CGFloat(arc4random_uniform(2)  + 1)
        var rotationDirection:Int = Int(arc4random_uniform(2))
        var preLocation:CGFloat = 0
        var health:Int = 0
		
		//number = 10
		
		println(number)
		
		if number == 0 || number == 1 || number == 2 || number == 3 || number == 4 || number == 5 {
			if upDown == 0  {
				addEnemy(named: "Asteroid16", movementSpeed: Float(normalSpeedAsteroid) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, health: 10, uniqueIdentifier: enemyCount)
			} else if upDown == 1 {
                addEnemy(named: "Asteroid16", movementSpeed: Float(normalSpeedAsteroid) * gameSpeed, yPos: CGFloat(height), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, health: 10, uniqueIdentifier: enemyCount)
			}
			
			
		} else if number == 6 || number == 7 || number == 8 || number == 9 {
			if upDown == 0 {
                addEnemy(named: "Satellite15", movementSpeed: Float(normalSpeedSatellite) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 3, uniqueIdentifier: enemyCount)
			} else if upDown == 1 {
                addEnemy(named: "Satellite15", movementSpeed: Float(normalSpeedSatellite) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 3, uniqueIdentifier: enemyCount)
			}
		} else if number == 10 {
			if upDown == 0 {
                addEnemy(named: "Missile8", movementSpeed: Float(normalSpeedRocket) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 1, uniqueIdentifier: enemyCount)
			} else if upDown == 1 {
                addEnemy(named: "Missile8", movementSpeed: Float(normalSpeedRocket) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 1, uniqueIdentifier: enemyCount)
			}
		}
		
	}
	
	func addEnemy(#named: String, movementSpeed:Float, yPos: CGFloat, rotationSpeed:CGFloat, rotationDirection:Int, preLocation:CGFloat, health:Int, uniqueIdentifier:Int) {
		
		var enemy = Enemy(imageNamed: named)
		
		enemy.physicsBody = SKPhysicsBody(texture: enemy.texture, alphaThreshold: 0, size: enemy.size)
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
		enemys.append(enemy)
		enemysIndex.append(uniqueIdentifier)
		
		enemy.name = named
		resetEnemy(enemy, yPos: yPos)
		
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
        
		var scene = GameScene(size: self.size)
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
	
	func pauseGame() {
		
		//Spiel pausieren.
		
		if !gameOver {
			
			gamePaused = true
			gamePlay.hidden = false
			gamePlay.alpha = 1
            gamePlay.zPosition = 1.1
            menuPause.hidden = false
            menuPause.alpha = 1
            menuPause.zPosition = 1.1
			gamePause.hidden = true
			hero.paused = true
			
		}
	}
	
	func resumeGame() {
		
		//Spiel fortsetzen.
		
		if !gameOver {
            
            countDownText.hidden = false
            gamePlay.hidden = true
            gamePlay.zPosition = 0.9
            menuPause.zPosition = 0.9
            menuPause.hidden = true
            countDownRunning = true
            timerPause = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimerPause"), userInfo: nil, repeats: true)

		}
	}
	
    func updateTimerPause() {
    
        if countDown > 0 {
            
            countDown--
            countDownText.text = String(countDown)
            
        } else {
            
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
        
		var duration = (abs(hero.position.y - touchLocation)) / hero.movementSpeed
		
		let moveAction = SKAction.moveToY(touchLocation, duration: NSTimeInterval(duration))
		
		moveAction.timingMode = SKActionTimingMode.EaseOut
		hero.runAction(moveAction, withKey: "movingA")
        
	}
	
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        funcTouchesOut(touches, withEvent: event)
        touchingScreen = false
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        funcTouchesIn(touches, withEvent: event)
    }
    
    func funcTouchesIn(touches: Set<NSObject>, withEvent event: UIEvent) {
    
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(self).y
            let location = touch.locationInNode(self)
            if !gamePaused {
                if gameOver {
                    if self.nodeAtPoint(location) == self.refresh {
                        if gameOver {
                            if !countDownRunning {
                                self.refresh.runAction(buttonPressDark)
                            }
                        }
                    } else if self.nodeAtPoint(location) == self.menu {
                        if gameOver {
                            if !countDownRunning {
                                self.menu.runAction(buttonPressDark)
                            }
                        }
                    }
                } else if !gameOver {
                    
                    if self.nodeAtPoint(location) == self.gamePause {
                        self.gamePause.runAction(buttonPressDark)
                    } else {
                        self.heroMovement()
                    }
                }
            } else if self.nodeAtPoint(location) == self.gamePlay {
                if !countDownRunning {
                    self.gamePlay.runAction(buttonPressDark)
                }
            } else if self.nodeAtPoint(location) == self.menuPause {
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
                                self.refresh.runAction(buttonPressLight){
                                    self.reloadGame()
                                    self.countDownRunning = true
                                }
                            }
                        }
                    } else if self.nodeAtPoint(location) == self.menu {
                        if gameOver {
                            if !countDownRunning {
                                self.menu.runAction(buttonPressLight){
                                    self.showMenu()
                                    self.gameStarted = false
                                }
                            }
                        }
                    }
                } else if !gameOver {
                    if self.nodeAtPoint(location) == self.gamePause {
                        self.gamePause.runAction(buttonPressLight){
                            self.pauseGame()
                        }
                    } else {
                        self.heroMovement()
                    }
                }
            } else if self.nodeAtPoint(location) == self.gamePlay {
                if !countDownRunning {
                    self.gamePlay.runAction(buttonPressLight){
                        self.resumeGame()
                    }
                }
            } else if self.nodeAtPoint(location) == self.menuPause {
                if !countDownRunning {
                    self.menuPause.runAction(buttonPressLight){
                        self.showMenu()
                    }
                }
            }
        }
    }
    
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
							
        funcTouchesIn(touches, withEvent: event)
        
    }

	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
		if !gamePaused {
			if !gameOver {
				
				updateEnemysPosition()
			}
            
            updateHeroEmitter()
            
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
	
	func updateEnemysPosition(){
		
		for enemy in enemys {
			
			if enemy.moving == false {
				
				enemy.currentFrame = enemy.currentFrame + 1
				if enemy.currentFrame > enemy.randomFrame{
					
					enemy.moving = true
					
				}
			} else {
                
				if enemy.name == "Satellite15" {
					
					enemy.position.y = CGFloat((Double(enemy.position.y))) + CGFloat(sin(enemy.angle / 2) * enemy.range)
					//enemy.angle += hero.pace
					enemy.angle = enemy.angle + Float(hero.pace)
					
				} else if enemy.name == "Missile8" {
					if enemy.position.x >= hero.position.x + 100 {
                        print("Enemy Pos: ")
                        println(enemy.position.y)
                        print("Hero Pos: ")
                        println(hero.position.y)
                        
                        if hero.position.y > enemy.position.y {
						
                            enemy.position.y = CGFloat(Double(enemy.position.y) + 1 )
                            enemy.rotationSpeed = 0
                            //enemy.zRotation = -45
                            enemy.preLocation = enemy.position.y
                            
                        } else if hero.position.y < enemy.position.y {
						
                            enemy.position.y = CGFloat(Double(enemy.position.y) - 1)
                            enemy.rotationSpeed = 1
                            //enemy.zRotation = 45
                            enemy.preLocation = enemy.position.y
                            
                        } else {
                        
                            //enemy.runAction(SKAction.rotateToAngle(0, duration: 1))
                            
                        }
                    } else {
                        
                        var testLocation:CGFloat = CGFloat(abs(Int(hero.position.y - enemy.position.y)))
                        println(testLocation)
                        
                        if enemy.rotationSpeed == 0 {
                        
                            enemy.position.y = CGFloat(Double(enemy.position.y) + 1 )
                            
                        } else if enemy.rotationSpeed == 1 {
                        
                            enemy.position.y = CGFloat(Double(enemy.position.y) - 1 )
                            
                        } else {
                        
                            enemy.position.y = CGFloat(enemy.position.y)
                        
                        }
                    
                    }

				} else if enemy.name == "Asteroid16" {
                    
                    var degreeRotation = (CDouble(self.speed) * M_PI / 180) * CDouble(enemy.rotationSpeed)
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
					
					//enemy.position.x -= CGFloat(enemy.speed)
					
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
					
					var upDown:Int = Int(arc4random_uniform(2))
					var heightNumber:Int = Int((self.size.height / 2) - 15)
					var height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
					
					if upDown == 0 {
						enemy.position.y = CGFloat(-(height))
					} else if upDown == 1 {
						enemy.position.y = CGFloat(height)
					}
					if enemy.name == "Missile8" {
						
						enemy.removeFromParent()
						enemy.moving = false
                        var number:Int
                        number = enemysIndex.find{ $0 == enemy.uniqueIndetifier}!
                        enemys.removeAtIndex(number)
                        enemysIndex.removeAtIndex(number)
						enemy.hidden = true
						enemy.position.x = self.size.width + 200
						
					} else {
						
						enemy.position.x = endOfScreenRight
						enemy.currentFrame = 0
						enemy.setRandomFrame()
						enemy.moving = false
						enemy.range = enemy.range + 0.1
						
					}
					
					updateScore()
					
				}
			}
			
		}
		
	}
	
	func updateScore(){
		
		score++
		scoreLabel.text = String(score)
		
		if score % 3 == 0 {
			
			totalSpeedAsteroid = totalSpeedAsteroid + 0.1
			totalSpeedSatellite = totalSpeedSatellite + 0.1
			totalSpeedRocket = totalSpeedRocket + 0.1
			
			gameProgress++
			//gameSpeed = gameSpeed + 0.1
			
			
		} else if score % 5 == 0 {
			
			addEnemys()
			
		}
	}
}

extension Array {
    func find(includedElement: T -> Bool) -> Int?{
        for (idx, element) in enumerate(self) {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
    
    
}