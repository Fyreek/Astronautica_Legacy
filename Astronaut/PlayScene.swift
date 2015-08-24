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
	var endOfScreenRight = CGFloat()
	var endOfScreenLeft = CGFloat()
	var gamePaused = false
    
    var heroColor:UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    var heroColorRed:CGFloat = 0
    var heroColorGreen:CGFloat = 0
    var heroColorBlue:CGFloat = 0
    var heroBlendFactor:Int = 0
    
    var playSceneActive = false
    
	var highScore:Int = 0
	
    var explosionAnimationFrames = [SKTexture]()
    
	var gameSpeed:Float = 1.3
	var gameProgress:Int = 0
	var totalSpeedenemyAsteroid:CGFloat = 1.5
	var totalSpeedenemySatellite:CGFloat = 2
	var totalSpeedenemyRocket:CGFloat = 3
	var normalSpeedenemyAsteroid:CGFloat = 1.5
	var normalSpeedenemySatellite:CGFloat = 2
	var normalSpeedenemyRocket:CGFloat = 3
	
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
		addheroPlayer()
		
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
        
        hero.guy.color = UIColor(red: heroColorRed , green: heroColorGreen , blue: heroColorBlue, alpha: 1.0)
        hero.guy.colorBlendFactor = 0.4
        
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
        hero.guy.removeAllActions()
        
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
        
        } else if contact.bodyA.categoryBitMask == ColliderType.Enemy.rawValue && contact.bodyB.categoryBitMask == ColliderType.Enemy.rawValue {
        
            if firstNode.position.x == endOfScreenRight {
            
                /*if firstNode.position.y > self.frame.height / 2 - 50 {
                
                    firstNode.position.y -= firstNode.size.height / 2 - 10
                    firstNode.zRotation = 0
                    println("moved first Node down")
                    
                } else {
                
                    firstNode.position.y += firstNode.size.height / 2 + 10
                    firstNode.zRotation = 0
                    println("moved first Node up")
                }
                
            
            } else if secondNode.position.x == endOfScreenRight {

                if secondNode.position.y > self.frame.height / 2 - 50 {
                    
                    secondNode.position.y -= secondNode.size.height / 2 - 10
                    firstNode.zRotation = 0
                    println("moved second Node down")
                    
                } else {
                    
                    secondNode.position.y += secondNode.size.height / 2 + 10
                    firstNode.zRotation = 0
                    println("moved second Node up")
                }*/
                
            } else {
                
                //println("collision on screen")

            }
        }
        
		
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
		
        
        
        hero.guy.hidden = false
		countDownText.hidden = false
		hero.guy.removeAllActions()
		
        refresh.zPosition = 0.9
        menu.zPosition = 0.9
        
		hero.guy.position.y = 0
		hero.guy.position.x = -(self.size.width/2)/3
		//hero.guy.name = "kevin"
		
		refresh.runAction(SKAction.fadeOutWithDuration(1.0))
		menu.runAction(SKAction.fadeOutWithDuration(1.0))
		totalScore.runAction(SKAction.fadeOutWithDuration(1.0))
		score = 0
		scoreLabel.text = "0"
		gameProgress = 0
		gameSpeed = 1
		totalSpeedenemyAsteroid = normalSpeedenemyAsteroid
		totalSpeedenemySatellite = normalSpeedenemySatellite
		totalSpeedenemyRocket = normalSpeedenemyRocket
		
		for enemy in enemys {
			
			resetEnemy(enemy.guy, yPos: enemy.yPos)
			enemy.guy.hidden = true
			
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
			
			if hero.guy.position.y != 0 {
				
				hero.guy.position.y = 0
				
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
	
	func addheroPlayer(){
		
		let heroPlayer = SKSpriteNode(imageNamed: "Astronaut25")
		
		heroPlayer.physicsBody = SKPhysicsBody(texture: heroPlayer.texture, alphaThreshold: 0, size: heroPlayer.size)
		heroPlayer.physicsBody!.affectedByGravity = false
		heroPlayer.physicsBody!.categoryBitMask = ColliderType.Hero.rawValue
        heroPlayer.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue
		heroPlayer.physicsBody!.collisionBitMask = ColliderType.Enemy.rawValue
		
		let heroParticles = SKEmitterNode(fileNamed: "HitParticle.sks")
		heroParticles.hidden = true
		hero = Hero(guy: heroPlayer, particles: heroParticles)
		heroPlayer.addChild(heroParticles)
		addChild(heroPlayer)
		
	}
	
	func addEnemys() {
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
                addEnemy(named: "Asteroid16", speed: Float(normalSpeedenemyAsteroid) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, health: 10)
			} else if upDown == 1 {
                addEnemy(named: "Asteroid16", speed: Float(normalSpeedenemyAsteroid) * gameSpeed, yPos: CGFloat(height), rotationSpeed: rotationSpeedRandom, rotationDirection: rotationDirection, preLocation: preLocation, health: 10)
			}
			
			
		} else if number == 6 || number == 7 || number == 8 || number == 9 {
			if upDown == 0 {
                addEnemy(named: "Satellite15", speed: Float(normalSpeedenemySatellite) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 3)
			} else if upDown == 1 {
                addEnemy(named: "Satellite15", speed: Float(normalSpeedenemySatellite) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 3)
			}
		} else if number == 10 {
			if upDown == 0 {
                addEnemy(named: "Missile8", speed: Float(normalSpeedenemyRocket) * gameSpeed, yPos: CGFloat(-(height)), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 1)
			} else if upDown == 1 {
                addEnemy(named: "Missile8", speed: Float(normalSpeedenemyRocket) * gameSpeed, yPos: CGFloat(height), rotationSpeed: 0, rotationDirection: rotationDirection, preLocation: preLocation, health: 1)
			}
		}
		
	}
	
    func addEnemy(#named: String, speed:Float, yPos: CGFloat, rotationSpeed:CGFloat, rotationDirection:Int, preLocation:CGFloat, health:Int) {
		
		var enemyNode = SKSpriteNode(imageNamed: named)
		
		enemyNode.physicsBody = SKPhysicsBody(texture: enemyNode.texture, alphaThreshold: 0, size: enemyNode.size)
		enemyNode.physicsBody!.affectedByGravity = false
		enemyNode.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue
		enemyNode.physicsBody!.contactTestBitMask = ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue
		enemyNode.physicsBody!.collisionBitMask = ColliderType.Hero.rawValue | ColliderType.Enemy.rawValue
		enemyNode.physicsBody?.allowsRotation = false
        
        var enemy = Enemy(speed: speed, guy: enemyNode, rotationSpeed: rotationSpeed, rotationDirection: rotationDirection, preLocation: preLocation, health: health)
		enemys.append(enemy)
		enemy.guy.name = named
		resetEnemy(enemyNode, yPos: yPos)
		enemy.yPos = enemyNode.position.y
		addChild(enemyNode)
		
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
		
        let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 1.0)
        
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
			hero.guy.paused = true
			
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
            hero.guy.paused = false
            
        }
        
    }
    
	func heroMovement() {
        
		var duration = (abs(hero.guy.position.y - touchLocation)) / hero.speed
		
		let moveAction = SKAction.moveToY(touchLocation, duration: NSTimeInterval(duration))
		
		moveAction.timingMode = SKActionTimingMode.EaseOut
		hero.guy.runAction(moveAction, withKey: "movingA")
        
	}
	
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        touchingScreen = false
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        funcTouches(touches, withEvent: event)
    }
    
    func funcTouches(touches: Set<NSObject>, withEvent event: UIEvent) {
    
        
        let buttonPressAnim = SKAction.sequence([buttonPressDark, buttonPressLight])
        
        for touch: AnyObject in touches {
            touchLocation = touch.locationInNode(self).y
            let location = touch.locationInNode(self)
            if !gamePaused {
                if gameOver {
                    
                    if self.nodeAtPoint(location) == self.refresh {
                        if gameOver {
                            if !countDownRunning {
                                self.refresh.runAction(buttonPressAnim){
                                    self.reloadGame()
                                    self.countDownRunning = true
                                }
                            }
                        }
                    } else if self.nodeAtPoint(location) == self.menu {
                        if gameOver {
                            if !countDownRunning {
                                self.menu.runAction(buttonPressAnim){
                                    self.showMenu()
                                    self.gameStarted = false
                                }
                            }
                        }
                        
                    }
                    
                    
                } else if !gameOver {
                    
                    if self.nodeAtPoint(location) == self.gamePause {
                        self.gamePause.runAction(buttonPressAnim){
                            self.pauseGame()
                        }
                    } else {
                        
                        self.heroMovement()
                        
                    }
                    
                }
                
            } else if self.nodeAtPoint(location) == self.gamePlay {
                if !countDownRunning {
                    self.gamePlay.runAction(buttonPressAnim){
                        self.resumeGame()
                    }
                }
            } else if self.nodeAtPoint(location) == self.menuPause {
                if !countDownRunning {
                    self.menuPause.runAction(buttonPressAnim){
                        self.showMenu()
                    }
                }
            }
        }
    }
    
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
							
        funcTouches(touches, withEvent: event)
        
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

        if hero.emit {
            hero.emit = false
            hero.guy.runAction(SKAction.animateWithTextures(explosionAnimationFrames, timePerFrame: 0.05, resize: true, restore: true), completion: {
                
                self.hero.guy.hidden = true
                self.openGameOverMenu()
                
            })
        }
	}
	
	func updateEnemysPosition(){
		
		for enemy in enemys {
			
			if !enemy.moving {
				
				enemy.currentFrame++
				if enemy.currentFrame > enemy.randomFrame{
					
					enemy.moving = true
					
				}
			} else {
                
				if enemy.guy.name == "Satellite15" {
					
					enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) + sin(enemy.angle / 2) * enemy.range)
					enemy.angle += hero.pace
					
				} else if enemy.guy.name == "Missile8" {
                    if enemy.guy.position.x >= hero.guy.position.x + 100 {
                        print("Enemy Pos: ")
                        println(enemy.guy.position.y)
                        print("Hero Pos: ")
                        println(hero.guy.position.y)
                        
                        if hero.guy.position.y > enemy.guy.position.y {
						
                            enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) + 1 )
                            enemy.rotationSpeed = 0
                            //enemy.guy.zRotation = -45
                            enemy.preLocation = enemy.guy.position.y
                            
                        } else if hero.guy.position.y < enemy.guy.position.y {
						
                            enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) - 1)
                            enemy.rotationSpeed = 1
                            //enemy.guy.zRotation = 45
                            enemy.preLocation = enemy.guy.position.y
                            
                        } else {
                        
                            //enemy.guy.runAction(SKAction.rotateToAngle(0, duration: 1))
                            
                        }
                    } else {
                        
                        var testLocation:CGFloat = CGFloat(abs(Int(hero.guy.position.y - enemy.guy.position.y)))
                        println(testLocation)
                        
                        if enemy.rotationSpeed == 0 {
                        
                            enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) + 1 )
                            
                        } else if enemy.rotationSpeed == 1 {
                        
                            enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) - 1 )
                            
                        } else {
                        
                            enemy.guy.position.y = CGFloat(enemy.guy.position.y)
                        
                        }
                    
                    }
				} else if enemy.guy.name == "Asteroid16" {
                    
                    var degreeRotation = (CDouble(self.speed) * M_PI / 180) * CDouble(enemy.rotationSpeed)
                    if enemy.rotationDirection == 0 {
                         enemy.guy.zRotation -= CGFloat(degreeRotation)
                    } else {
                         enemy.guy.zRotation += CGFloat(degreeRotation)
                    }
                   
					enemy.angle = 0
					if hero.guy.position.y > enemy.guy.position.y {
						
						enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) + 0.05 )
						
					} else if hero.guy.position.y < enemy.guy.position.y {
						
						enemy.guy.position.y = CGFloat(Double(enemy.guy.position.y) - 0.05)
						
					}
				}
				
				if enemy.guy.position.x > endOfScreenLeft{
					
					enemy.guy.position.x -= CGFloat(enemy.speed)
					
				} else {
                    
					if enemy.guy.name == "Asteroid16" {
						enemy.guy.speed = totalSpeedenemyAsteroid
					} else if enemy.guy.name == "Satellite15" {
						enemy.guy.speed = totalSpeedenemySatellite
					} else if enemy.guy.name == "Missile8" {
						enemy.guy.speed = totalSpeedenemyRocket
					}
					
					var upDown:Int = Int(arc4random_uniform(2))
					var heightNumber:Int = Int((self.size.height / 2) - 15)
					var height:Int = Int(arc4random_uniform(UInt32(heightNumber)))
					
					if upDown == 0 {
						enemy.guy.position.y = CGFloat(-(height))
					} else if upDown == 1 {
						enemy.guy.position.y = CGFloat(height)
					}
					if enemy.guy.name == "Missile8" {
						
						enemy.guy.removeFromParent()
						enemy.moving = false
						enemy.guy.hidden = true
						enemy.guy.position.x = self.size.width + 200
						
					} else {
						
						enemy.guy.position.x = endOfScreenRight
						enemy.currentFrame = 0
						enemy.setRandomFrame()
						enemy.moving = false
						enemy.range += 0.1
						
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
			
			totalSpeedenemyAsteroid = totalSpeedenemyAsteroid + 0.1
			totalSpeedenemySatellite = totalSpeedenemySatellite + 0.1
			totalSpeedenemyRocket = totalSpeedenemyRocket + 0.1
			
			gameProgress++
			gameSpeed = gameSpeed + 0.1
			
			
		} else if score % 5 == 0 {
			
			addEnemys()
			
		}
	}
}

